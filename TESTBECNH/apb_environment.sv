
// ============================================================
// ENVIRONMENT
// Instantiates and connects generator, driver, monitor
// and scoreboard using mailboxes and events.
// ============================================================
class environment;

     // Verification components.
     generator gen;
     driver drv;
     monitor mon;
     scoreboard sco;


     // Synchronization events.
     event nextgd;  // Generator -> Driver
     event nextgs;  // Generator -> Scoreboard


     // Mailbox between generator and driver.
     mailbox #(transaction) gdmbx;

     // Mailbox between monitor and scoreboard.
     mailbox #(transaction) msmbx;


     // Virtual APB interface.
     virtual abp_if vif;


     // Constructor.
     function new(virtual abp_if vif);

       // Create generator-driver mailbox.
       gdmbx = new();

       // Create generator and driver.
       gen = new(gdmbx);
       drv = new(gdmbx);


       // Create monitor-scoreboard mailbox.
       msmbx = new();

       // Create monitor and scoreboard.
       mon = new(msmbx);
       sco = new(msmbx);


       // Connect virtual interface.
       this.vif = vif;
       drv.vif = this.vif;
       mon.vif = this.vif;


       // Connect synchronization events.
       gen.nextsco = nextgs;
       sco.nextsco = nextgs;

       gen.nextdrv = nextgd;
       drv.nextdrv = nextgd;

     endfunction


     // Perform reset before the test.
     task pre_test();
       drv.reset();
     endtask


     // Start all verification components concurrently.
     task test();

       fork
         gen.run();
         drv.run();
         mon.run();
         sco.run();
       join_any

     endtask


     // Wait for generator completion and finish simulation.
     task post_test();

       wait(gen.done.triggered);

       $finish();

     endtask


     // Complete verification flow.
     task run();

       pre_test();
       test();
       post_test();

     endtask

endclass
