// ============================================================
// SCOREBOARD
// Maintains expected memory contents and compares DUT output
// against the expected values.
// ============================================================
class scoreboard;

   // Mailbox receiving transactions from monitor.
   mailbox #(transaction) mbx;

   // Transaction received from monitor.
   transaction tr;

   // Synchronization event for generator.
   event nextsco;

   // Reference memory used to store expected write data.
   bit [31:0] pwdata[12] = '{default:0};

   // Stores expected read data.
   bit [31:0] rdata;

   int index;

   // Constructor.
   function new(mailbox #(transaction) mbx);
      this.mbx = mbx;
   endfunction

   // Continuously receives transactions and checks them.
   task run();

      forever begin

         // Get monitored transaction.
         mbx.get(tr);

         $display("[SCO] : DATA RCVD wdata:%0d rdata:%0d addr:%0d write:%0b",
                  tr.pwdata, tr.prdata, tr.paddr, tr.pwrite);

         // Check successful write.
         if((tr.pwrite == 1'b1) && (tr.pslverr == 1'b0))
         begin

            // Store write data in reference memory.
            pwdata[tr.paddr] = tr.pwdata;

            $display("[SCO] : DATA STORED DATA : %0d ADDR: %0d",
                     tr.pwdata, tr.paddr);

         end

         // Check successful read.
         else if((tr.pwrite == 1'b0) && (tr.pslverr == 1'b0))
         begin

            // Get expected data from reference memory.
            rdata = pwdata[tr.paddr];

            // Compare DUT read data with expected data.
            if(tr.prdata == rdata)
               $display("[SCO] : Data Matched");
            else
               $display("[SCO] : Data Mismatched");

         end

         // Check slave error.
         else if(tr.pslverr == 1'b1)
         begin

            // Report detected APB slave error.
            $display("[SCO] : SLV ERROR DETECTED");

         end

         // Notify generator that scoreboard completed checking.
         ->nextsco;

      end

   endtask
endclass
