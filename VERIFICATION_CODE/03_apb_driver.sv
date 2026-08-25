// ============================================================
// DRIVER
// Converts transaction-level information into APB pin-level activity.
// ============================================================
class driver;

   // APB virtual interface
   virtual abp_if vif;

   // Generator to driver mailbox
   mailbox #(transaction) mbx;

   // Transaction received from generator
   transaction datac;

   // Synchronization event
   event nextdrv;

   // Constructor
   function new(mailbox #(transaction) mbx);
      this.mbx = mbx;
   endfunction

   // Reset task
   task reset();
      // Drive reset values
      vif.presetn <= 1'b0;
      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwdata  <= 0;
      vif.paddr   <= 0;
      vif.pwrite  <= 1'b0;

      // Keep reset active for 5 clock cycles
      repeat(5) @(posedge vif.pclk);

      // Release reset
      vif.presetn <= 1'b1;

      repeat(5) @(posedge vif.pclk);
      $display("[DRV] : RESET DONE");
      
   endtask

   // APB write transfer
   task write_transfer();

      // SETUP phase
      @(posedge vif.pclk);

      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;
      vif.paddr   <= datac.paddr;
      vif.pwdata  <= datac.pwdata;
      vif.pwrite  <= 1'b1;

      // ACCESS phase
      @(posedge vif.pclk);

      vif.penable <= 1'b1;

      // Wait until slave completes the transfer
      while(!vif.pready)
         @(posedge vif.pclk);

      // Capture slave error response
      datac.pslverr = vif.pslverr;

      // Return to IDLE
      @(posedge vif.pclk);

      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;

      $display("[DRV] : WRITE | ADDR=%0d DATA=%0d PREADY=%0b PSLVERR=%0b",
               datac.paddr, datac.pwdata, vif.pready, vif.pslverr);

   endtask

   // APB read transfer
   task read_transfer();

      // SETUP phase
      @(posedge vif.pclk);

      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;
      vif.paddr   <= datac.paddr;
      vif.pwdata  <= 32'd0;
      vif.pwrite  <= 1'b0;

      // ACCESS phase
      @(posedge vif.pclk);

      vif.penable <= 1'b1;

      // Wait until slave completes the transfer
      while(!vif.pready)
         @(posedge vif.pclk);

      // Capture read data and error response
      datac.prdata  = vif.prdata;
      datac.pslverr = vif.pslverr;

      // Return to IDLE
      @(posedge vif.pclk);

      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;

      $display("[DRV] : READ | ADDR=%0d RDATA=%0d PREADY=%0b PSLVERR=%0b",
               datac.paddr, datac.prdata, vif.pready, vif.pslverr);

   endtask

   // Random operation
   task random_transfer();

      // Randomly choose between read and write
      if($urandom_range(0,1))
      begin
         datac.pwrite = 1'b1;
         write_transfer();
      end
      else
      begin
         datac.pwrite = 1'b0;
         read_transfer();
      end

   endtask

   // Error operation
   task error_transfer();

      // SETUP phase
      @(posedge vif.pclk);

      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;

      // Generate an invalid address
      vif.paddr   <= $urandom_range(32,100);
      vif.pwdata  <= datac.pwdata;
      vif.pwrite  <= datac.pwrite;

      // ACCESS phase
      @(posedge vif.pclk);

      vif.penable <= 1'b1;

      // Wait until slave completes the transfer
      while(!vif.pready)
         @(posedge vif.pclk);

      // Capture slave error response
      datac.pslverr = vif.pslverr;

      // Return to IDLE
      @(posedge vif.pclk);

      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;

      $display("[DRV] : ERROR | PREADY=%0b PSLVERR=%0b",
               vif.pready, vif.pslverr);

   endtask

   // Driver run task
   task run();

      forever
      begin

         // Get transaction from generator
         mbx.get(datac);

         // Select operation based on transaction type
         case(datac.oper)

            // Normal write
            write:
               write_transfer();

            // Normal read
            read:
               read_transfer();

            // Randomly select read or write
            random:
               random_transfer();

            // Generate error transaction
            error:
               error_transfer();

            default:
               $error("[DRV] : Unknown operation");

         endcase

         // Notify generator that driver completed the transaction
         ->nextdrv;

      end

   endtask

endclass
