// ============================================================
// MONITOR
// Observes APB interface signals and converts them into
// transactions for the scoreboard.
// ============================================================
class monitor;

   // Virtual interface used to observe APB signals.
   virtual abp_if vif;

   // Mailbox used to send monitored transactions to scoreboard.
   mailbox #(transaction) mbx;

   // Transaction object used to store sampled signals.
   transaction tr;


   // Constructor.
   function new(mailbox #(transaction) mbx);
      this.mbx = mbx;
   endfunction;


   // Monitor continuously observes the APB interface.
   task run();

     tr = new();

     forever begin

       // Wait for a clock edge.
       @(posedge vif.pclk);

       // Detect APB SETUP phase.
       if((vif.psel) && (!vif.penable))
       begin

         @(posedge vif.pclk);


         // ----------------------------------------------------
         // WRITE ACCESS
         // ----------------------------------------------------
         if(vif.psel && vif.pwrite && vif.penable)
         begin

           @(posedge vif.pclk);

           // Capture write transaction information.
           tr.pwdata  = vif.pwdata;
           tr.paddr   = vif.paddr;
           tr.pwrite  = vif.pwrite;
           tr.pslverr = vif.pslverr;

           $display("[MON] : DATA WRITE data : %0d and addr : %0d write :%0b",
                    vif.pwdata, vif.paddr, vif.pwrite);

           @(posedge vif.pclk);

         end


         // ----------------------------------------------------
         // READ ACCESS
         // ----------------------------------------------------
         else if(vif.psel && !vif.pwrite && vif.penable)
         begin

           @(posedge vif.pclk);

           // Capture read transaction information.
           tr.prdata  = vif.prdata;
           tr.pwrite  = vif.pwrite;
           tr.paddr   = vif.paddr;
           tr.pslverr = vif.pslverr;

           @(posedge vif.pclk);

           $display("[MON] : DATA READ data : %0d and addr : %0d write:%0b",
                    vif.prdata, vif.paddr, vif.pwrite);

         end


         // Send monitored transaction to scoreboard.
         mbx.put(tr);

       end

     end

   endtask

endclass
