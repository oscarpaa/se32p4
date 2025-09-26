# README

This is a personal project aimed at learning more about computer architectures and FPGA-based hardware design.  

## Project Structure  

- **rtl/**  
  Contains the hardware description (SystemVerilog).  
  - `core/` – Processor implementation, including ALU, control logic, pipeline stages, CSR, and register file.  
  <!--- `ip/` – Placeholder for reusable IP blocks. -->
  - `sim/` – Testbenches and simulation files.  
  - `system/` – System-level modules such as memory, UART, and clocking.  

- **sw/**  
  Contains the software stack running on the processor.  
  - `apps/` – Example applications (e.g., hello world, sorting).  
  - `libs/` – Standard library functions, UART driver, syscalls, and headers.  
  - `crt0.s`, `link.ld`, `makefile` – Startup code, linker script, and build system.  

- **utils/**  
  Utility scripts

## Project Status  

- ✅ RV32IC 4 stage processor.
- ✅ Basic UART.
- ✅ Software toolchain with startup code, linker script, and basic libraries.  
- 🟨 Simulation testbench.

## Roadmap  

- Adopt a verification methodology such as UVM.
- Simple branch dinamyc prediction. 
- Integrate an AXI-Lite bus.
- ...
