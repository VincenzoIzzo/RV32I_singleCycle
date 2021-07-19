# RV32I_singleCycle
This is a custom behavioral implementation (in VHDL) of RV32I specification istruction set (in developing). Currently there are 27/40 istructions implemented (arithmetic, logic, store, load istructions)


## How to simulate (top_tb.vhd)
These steps are needed in order to simulate the default program loaded in the memory design.
The program is compiled with RISC-V GNU toolchain (NewLib), compiled for I extension only with 32-bit soft-float ABI (floating-point registers are not currently implemented).
```
int main() {
  int a = 2;
  int b = 3;
  int c = a + b;
  return 0;
}
```
Steps are the following:
1. Create a project with all VHDL files in the repository
2. Verify that in clk_filter.vhd file the statement "clk_out <= clk_in;" is present and "clk_out <= internal_counter(27);" is commented.
3. Start simulation targeting the file "top_tb.vhd"
4. You can check internal component state by enabling them into your wave simulation tool


## How to customize program to run (memory.vhd)
If you want to customize the program to be run on this design, you should follow the next steps:
1. Compile the RISC-V GNU toolchain. Follow the istructions provided in this repo [RISC-V GNU toolchain](https://github.com/riscv/riscv-gnu-toolchain). Use the following flags when configuring:
1. --prefix=/opt/riscv
2. --with-arch=rv32i
3. --with-abi=ilp32
