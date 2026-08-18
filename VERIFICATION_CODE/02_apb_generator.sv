

// ============================================================
// GENERATOR
// Generates randomized transactions and sends them to the driver.
// ============================================================
class generator;

   // Transaction object used for generating stimulus.
   transaction tr;

   // Mailbox used to transfer transactions from generator to driver.
   mailbox #(transaction) mbx;

   // Number of transactions to generate.
   int count = 0;

   // Synchronization event between generator and driver.
   event nextdrv;

   // Synchronization event between generator and scoreboard.
   event nextsco;

   // Indicates that transaction generation is complete.
   event done;


   // Constructor.
   function new(mailbox #(transaction) mbx);
       this.mbx = mbx;
       tr = new();
   endfunction;


   // Generates transactions and synchronizes with
   // driver and scoreboard.
   task run();

     repeat(count)
     begin

       // Randomize the transaction.
       assert(tr.randomize())
       else $error("Randomization failed");

       // Send a copy of the transaction to the driver.
       mbx.put(tr.copy);

       // Display generated transaction.
       tr.display("GEN");

       // Wait until driver completes the operation.
       @(nextdrv);

       // Wait until scoreboard completes checking.
       @(nextsco);

     end

     // Indicate that all transactions are generated.
     ->done;

   endtask

endclass

