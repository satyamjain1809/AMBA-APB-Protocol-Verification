// ============================================================
// TOP-LEVEL TESTBENCH
// Instantiates the APB interface, DUT and verification environment.
// ============================================================
module tb;

   // APB interface instance.
   abp_if vif();


   // Instantiate APB DUT and connect interface signals.
   apb_ram dut (
       vif.presetn,
       vif.pclk,
       vif.psel,
       vif.penable,
       vif.pwrite,
       vif.paddr,
       vif.pwdata,
       vif.prdata,
       vif.pready,
       vif.pslverr
   );


   // Initialize clock.
   initial begin
     vif.pclk <= 0;
   end


   // Generate clock with 20 time-unit period.
   always #10 vif.pclk <= ~vif.pclk;


   // Environment handle.
   environment env;


   // Create environment and start the test.
   initial begin

     env = new(vif);

     // Generate 30 transactions.
     env.gen.count = 30;

     env.run();

   end


   // Generate waveform dump for simulation analysis.
   initial begin

     $dumpfile("dump.vcd");
     $dumpvars;

   end

endmodule
