// ============================================================
// TRANSACTION CLASS
// Stores one APB transaction.
// The transaction describes WHAT operation is required.
// The driver decides HOW to generate APB protocol signals.
// ============================================================

class transaction;

  // ------------------------------------------------------------
  // APB operation types
  // ------------------------------------------------------------
  typedef enum int {
    write  = 0,
    read   = 1,
    random = 2,
    error  = 3
  } op_type;

  // Randomized operation
  randc op_type oper;

  // Randomized transaction-level fields
  rand bit [31:0] paddr;
  rand bit [31:0] pwdata;
  rand bit        pwrite;

  // ------------------------------------------------------------
  // Response signals from APB slave
  // ------------------------------------------------------------

  // Read data returned by slave
  bit [31:0] prdata;

  // Indicates completion of APB transfer
  bit pready;

  // Indicates slave error
  bit pslverr;


  // ------------------------------------------------------------
  // Address constraint
  // Valid addresses: 2, 3, 4
  // ------------------------------------------------------------
  constraint addr_c {
    paddr > 1;
    paddr < 5;
  }


  // ------------------------------------------------------------
  // Write data constraint
  // Values: 2 to 9
  // ------------------------------------------------------------
  constraint data_c {
    pwdata > 1;
    pwdata < 10;
  }


  // ------------------------------------------------------------
  // Display transaction
  // ------------------------------------------------------------
  function void display(input string tag);

    $display(
      "[%0s] : OP:%0s paddr:%0d pwdata:%0d pwrite:%0b prdata:%0d pready:%0b pslverr:%0b",
      tag,
      oper.name(),
      paddr,
      pwdata,
      pwrite,
      prdata,
      pready,
      pslverr
    );

  endfunction


  // ------------------------------------------------------------
  // Copy function
  // ------------------------------------------------------------
  function transaction copy();
    copy = new();
    copy.oper    = this.oper;
    copy.paddr   = this.paddr;
    copy.pwdata  = this.pwdata;
    copy.pwrite  = this.pwrite;
    copy.prdata  = this.prdata;
    copy.pready  = this.pready;
    copy.pslverr = this.pslverr;

  endfunction
endclass
