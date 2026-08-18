// ============================================================
// TRANSACTION CLASS
// Stores one APB operation and provides randomization,
// display and copy functionality.
// ============================================================
class transaction;

  // Defines the different types of APB operations.
  typedef enum int {write = 0, read = 1, random = 2, error = 3} op_type;

  // randc cycles through operation values without repeating
  // the same value until all values have been used.
  randc op_type oper;

  // Randomized APB address.
  rand bit [31:0] paddr;

  // Randomized write data.
  rand bit [31:0] pwdata;

  // APB select signal.
  rand bit psel;

  // APB enable signal.
  rand bit penable;

  // Indicates write (1) or read (0) operation.
  rand bit pwrite;

  // Read data returned by the APB slave.
  bit [31:0] prdata;

  // Indicates that the slave has completed the transfer.
  bit pready;

  // Indicates an APB slave error.
  bit pslverr;


  // Constrains generated addresses to 2, 3 and 4.
  constraint addr_c {
    paddr > 1;
    paddr < 5;
  }


  // Constrains generated write data from 2 to 9.
  constraint data_c {
    pwdata > 1;
    pwdata < 10;
  }


  // Displays the complete transaction for debugging.
  function void display(input string tag);
    $display("[%0s] : OP:%0s  paddr:%0d  pwdata:%0d  psel:%0b  penable:%0b  pwrite:%0b  prdata:%0d  pready:%0b  pslverr:%0b",
             tag, oper.name(), paddr, pwdata, psel, penable,
             pwrite, prdata, pready, pslverr);
  endfunction


  // Creates and returns an independent copy of the transaction.
  function transaction copy();

    copy = new();

    copy.oper    = this.oper;
    copy.paddr   = this.paddr;
    copy.pwdata  = this.pwdata;
    copy.psel    = this.psel;
    copy.penable = this.penable;
    copy.pwrite  = this.pwrite;
    copy.prdata  = this.prdata;
    copy.pready  = this.pready;
    copy.pslverr = this.pslverr;

  endfunction

endclass
