// ============================================================
// DRIVER
// Converts transactions into APB pin-level activity.
// ============================================================
class driver;

   // Virtual interface used to drive APB signals.
   virtual abp_if vif;

   // Mailbox from which driver receives transactions.
   mailbox #(transaction) mbx;

   // Transaction received from generator.
   transaction datac;

   // Event used to notify generator that driver is done.
   event nextdrv;


   // Constructor.
   function new(mailbox #(transaction) mbx);
      this.mbx = mbx;
   endfunction;


   // ----------------------------------------------------------
   // RESET TASK
   // Drives reset values to the APB interface.
   // ----------------------------------------------------------
   task reset();

     vif.presetn <= 1'b0;
     vif.psel    <= 1'b0;
     vif.penable <= 1'b0;
     vif.pwdata  <= 0;
     vif.paddr   <= 0;
     vif.pwrite  <= 1'b0;

     // Keep reset active for 5 clock cycles.
     repeat(5) @(posedge vif.pclk);

     // Release reset.
     vif.presetn <= 1'b1;

     repeat(5) @(posedge vif.pclk);

     $display("[DRV] : RESET DONE");

   endtask


   // ----------------------------------------------------------
   // DRIVER RUN TASK
   // Receives transactions and drives corresponding APB operations.
   // ----------------------------------------------------------
   task run();

     forever begin

       // Get transaction from generator mailbox.
       mbx.get(datac);


       // ------------------------------------------------------
       // WRITE OPERATION
       // ------------------------------------------------------
       if(datac.oper == 0)
       begin

         @(posedge vif.pclk);

         // APB SETUP phase.
         vif.psel    <= 1'b1;
         vif.penable <= 1'b0;
         vif.pwdata  <= datac.pwdata;
         vif.paddr   <= datac.paddr;
         vif.pwrite  <= 1'b1;

         @(posedge vif.pclk);

         // APB ACCESS phase.
         vif.penable <= 1'b1;

         repeat(2) @(posedge vif.pclk);

         // Return signals to idle state.
         vif.psel    <= 1'b0;
         vif.penable <= 1'b0;
         vif.pwrite  <= 1'b0;

         $display("[DRV] : DATA WRITE OP data : %0d and addr : %0d",
                  datac.pwdata, datac.paddr);

       end


       // ------------------------------------------------------
       // READ OPERATION
       // ------------------------------------------------------
       else if(datac.oper == 1)
       begin

         @(posedge vif.pclk);

         // APB SETUP phase.
         vif.psel    <= 1'b1;
         vif.penable <= 1'b0;
         vif.pwdata  <= datac.pwdata;
         vif.paddr   <= datac.paddr;
         vif.pwrite  <= 1'b0;

         @(posedge vif.pclk);

         // APB ACCESS phase.
         vif.penable <= 1'b1;

         repeat(2) @(posedge vif.pclk);

         // Return signals to idle state.
         vif.psel    <= 1'b0;
         vif.penable <= 1'b0;
         vif.pwrite  <= 1'b0;

         $display("[DRV] : DATA READ OP addr : %0d", datac.paddr);

       end


       // ------------------------------------------------------
       // RANDOM OPERATION
       // ------------------------------------------------------
       else if(datac.oper == 2)
       begin

         @(posedge vif.pclk);

         // Drive randomized APB control/data signals.
         vif.psel    <= 1;
         vif.penable <= 0;
         vif.pwdata  <= datac.pwdata;
         vif.paddr   <= datac.paddr;
         vif.pwrite  <= datac.pwrite;

         @(posedge vif.pclk);

         // ACCESS phase.
         vif.penable <= 1;

         repeat(2) @(posedge vif.pclk);

         // Return to idle state.
         vif.psel    <= 1'b0;
         vif.penable <= 1'b0;
         vif.pwrite  <= 1'b0;

         $display("[DRV] : RANDOM OPERATION");

       end


       // ------------------------------------------------------
       // SLAVE ERROR OPERATION
       // ------------------------------------------------------
       else if(datac.oper == 3)
       begin

         @(posedge vif.pclk);

         // Start APB transfer.
         vif.psel    <= 1;
         vif.penable <= 0;
         vif.pwdata  <= datac.pwdata;

         // Generate an address outside the valid range
         // to intentionally trigger a slave error.
         vif.paddr   <= $urandom_range(32,100);

         vif.pwrite  <= datac.pwrite;

         @(posedge vif.pclk);

         // ACCESS phase.
         vif.penable <= 1;

         repeat(2) @(posedge vif.pclk);

         // Return to idle state.
         vif.psel    <= 1'b0;
         vif.penable <= 1'b0;
         vif.pwrite  <= 1'b0;

         $display("[DRV] : SLV ERROR");

       end


       // Notify generator that driver completed the transaction.
       ->nextdrv;

     end

   endtask

endclass

