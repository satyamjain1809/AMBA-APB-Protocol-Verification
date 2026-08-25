// ============================================================
// GENERATOR
// Generates randomized transaction-level stimulus.
// ============================================================

class generator;

  // Transaction object
  transaction tr;

  // Mailbox for generator -> driver communication
  mailbox #(transaction) mbx;

  // Number of transactions
  int count = 0;

  // Synchronization with driver
  event nextdrv;

  // Synchronization with scoreboard
  event nextsco;

  // Indicates generation is complete
  event done;

  // CONSTRUCTOR
  function new(mailbox #(transaction) mbx);

    this.mbx = mbx;
    tr = new();

  endfunction

  // RUN TASK
  task run();
    repeat(count)
    begin

      // Generate transaction-level stimulus
      assert(tr.randomize())
      else $error("[GEN] : Randomization failed");

      // --------------------------------------------------------
      // Send independent copy to driver
      // --------------------------------------------------------
      mbx.put(tr.copy());

      // Display generated transaction
      tr.display("GEN");

      // Wait for driver to complete transaction
      @(nextdrv);

      // Wait for scoreboard
      @(nextsco);
    end

    // All transactions generated
    ->done;
  endtask
endclass
