# RV32I_singleCycle
This is a custom behavioral implementation (in VHDL) of RV32I (RISC-V) specification  istruction set (in developing). Currently there are 27/40 istructions implemented (arithmetic, logic, store, load istructions)


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
2. Verify that in clk_filter.vhd file the statement "clk_out <= clk_in;" is present and "clk_out <= internal_counter(27);" is commented
3. In the file "defs.vhd" you can change the number of "clk_periods", according to the number of istruction your program is made of
4. Start simulation targeting the file "top_tb.vhd"
5. You can check internal component state by enabling them into your wave simulation tool


## How to customize program to run (memory.vhd)
If you want to customize the program to be run on this design, you should follow the next steps:
1. Compile the RISC-V GNU toolchain. Follow the istructions provided in this repo [RISC-V GNU toolchain](https://github.com/riscv/riscv-gnu-toolchain). Use the following flags when configuring:
    1. --prefix=/opt/riscv
    2. --with-arch=rv32i
    3. --with-abi=ilp32
2. Write a simple and short C program (without any branches/jumps or functions). Be carefull about overlapping of code area and stack, because, currently, memory support just 256 bytes (a maximum of 64 data+istruction words)
3. ```riscv32-unknown-elf-gcc -c file.c```
4. ```riscv32-unknown-elf-objcopy -O -ihex file.o file.hex```
5. Study here the [hex format](https://en.wikipedia.org/wiki/Intel_HEX) and extract the machine code istructions
6. Put the istructions in the memory.vhd file following the example implementation. "0 => x"130101FE" means that the machine code exadecimal 130101FE is going to be put into the first memory word (bytes 0,1,2 and 3)
7. Follow simulation steps discussed above

## How to run on ZYBO board (or another board, just customize the right things)
1. Add the costraint file present in this repo to your project. You can customize this file for your target board.
2. Exclude "top_tb.vhd" file from the synthesis/implementation files.
3. Choose which signal you want to see on the 4 leds. By default you see the memory content which is going to be written with value "5". If you have a board with more leds you can customize the "test_out" and "dbg_data_signal" signals width in "top.vhd" module.  To modify what is going to be mapped on leds you have to follow these steps:
    1. Add an output signal (STD_LOGIC_VECTOR(3 downto 0)) to the internal module you are interested in, or choose the width according to the number of leds
    2. Assign the internal signals you want to watch to the output signal discussed in the previous point
    3. Update the component interface in the "top.vhd" module
    4. Portmap the new output signal to dbg_data_signal
    5. Eliminate memory related default logic or you will have a multidriven signal
4. Verify that in "clk_filter.vhd" file the statement "clk_out <= clk_in;" is commented and "clk_out <= internal_counter(27);" is present. You can customize this module so that the evolution leds state speed changes.
5. Run synthesis, implementation and generate bitstream
6. Switch ON the switch0 on board, so that you can enable the clock. You can Switch OFF everytime you want to stop the clock and analyze leds state and Switch ON again to continue
7. Switch OFF clock when the last istruction occurs to avoid unpredictable behaviours.
