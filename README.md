# AMBA-APB-Protocol-Verification
AMBA APB Protocol Verification using SystemVerilog with functional verification, constraint-based stimulus generation, and simulation.

# Introduction #

AMBA APB (Advanced Peripheral Bus) is a simple, low-power, non-pipelined communication protocol in the ARM AMBA family. It is primarily designed for communication between a system bus and low-bandwidth peripheral devices.
APB is commonly used for peripherals such as UARTs, timers, watchdogs, SPI interfaces, and interrupt controllers. It can be connected to the main system through an AXI-to-APB or AHB-to-APB bridge, which converts high-speed system transactions into simpler APB transfers.
APB is a synchronous and non-pipelined protocol. All signals are synchronized with the rising edge of PCLK, and only one transfer takes place at a time. Because of its simple architecture, APB requires relatively low hardware complexity and is easy to design and verify.

Key Characteristics
Simple and low-power peripheral communication protocol.
Synchronous protocol controlled by PCLK.
Non-pipelined — only one transfer occurs at a time.
Supports both read and write transactions.
A normal transfer requires at least two clock cycles.
Supports wait states using PREADY.
Supports error reporting using PSLVERR.
Uses separate SETUP and ACCESS phases.

# APB SIGNALS USED IN THIS PROJECT #
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/aca636ec-02e8-4891-9855-70a26bce479e" />

# APB FSM #

APB works in three states:  
I. IDLE  
II. SETUP  
III. ACCESS
<img width="1337" height="1177" alt="image" src="https://github.com/user-attachments/assets/1842ba93-f8e5-4a0f-97ef-f2e0cc26500c" />

## I) IDLE state -

* **PSEL = 0** • **No transfer is taking place**
* This is the default state of the APB bus  
 → **"The bus is waiting for a request".**

## II) SETUP state -

* **PSEL = 1** • **PENABLE = 0**
* Master places the address and control signals on bus.
* This state lasts for **1 clock cycle only.**  
 → **"Getting Ready for the transfer".**

## III) ACCESS state -

* **PSEL = 1** • **PENABLE = 1**
* The actual read or write operation occurs
* If **PREADY = 1**, the transfer completes
* If **PREADY = 0**, the bus stays in ACCESS and waits  
 → **"Execute the transfer".**




