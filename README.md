# RV32I_singleCycle
This is a custom behavioral implementation (in VHDL) of RV32I specification instruction set (in developing). Currently there are 37/40 instructions implemented (arithmetic, logic, store, load, conditional branch , unconditional branch and upper immediate instructions).


## How to simulate (top_tb.vhd)
These steps are needed in order to simulate the default program loaded in the memory design.
The program is compiled with RISC-V GNU toolchain (NewLib), compiled for I extension only with 32-bit soft-float ABI (floating-point registers are not currently implemented).
```
int main() {
  int a = 2;
  int b = 3;
  int c = a + b;
  while(1);
  return 0;
}
```
Steps are the following:
1. Create a project with all VHDL files in the repository
2. Verify that in clk_filter.vhd file the statement "clk_out <= clk_in;" is present and "clk_out <= internal_counter(27);" is commented
3. In the file "defs.vhd" you can change the number of "clk_periods" you want to run
4. You can check internal component state by enabling them into your wave analyzer tool


## How to customize program to run (memory.vhd)
If you want to customize the program to be run on this design, you should follow the next steps:
1. Compile the RISC-V GNU toolchain. Follow the istructions provided in this repo [RISC-V GNU toolchain](https://github.com/riscv/riscv-gnu-toolchain). Use the following flags when configuring:
    1. --prefix=/opt/riscv
    2. --with-arch=rv32i
    3. --with-abi=ilp32
2. Write a C program. Be carefull about overlapping of code area and stack, because, currently, memory support just 4096 bytes (a maximum of 1024 data+istruction words). NB: always finish the program with a "while(true condition);", so that the Program Counter doesn't acquire wrong values after the running program. Return istruction has to be avoided, since there isn't an operating environment (or it can be put after the while istruction, so that the processor will never run the return istruction)
3. ```riscv32-unknown-elf-gcc -c my_file.c```
4. ```riscv32-unknown-elf-objcopy -O -ihex my_file.o my_file.hex```
5. ```python3 updateMemContent.py my_file.hex memory.vhd "row_start_number" "row_end_number" memoutputfile.vhd``` 
row_start_number and row_end_number are the lines in which there are     ```    signal memory_space: memory_space_t := (``` and the closing bracket ```);```. For example you can put 52 and 81.
6. Add the new memory file to the project. The script generates a new file in order to avoid possible wrong uses. If you are sure that you have done the right thing checking the new generated memory file, you can delete the old "memory.vhd" file.
7. Follow simulation steps discussed above

## How to run on ZYBO board (or another board, just customize the right things)
1. Add the costraint file present in this repo to your project. You can customize this file for your target board.
2. Exclude "top_tb.vhd" file from the synthesis/implementation files.
3. Choose which signal you want to see on the 4 leds. By default you see the PC 5 downto 2 bits (every istruction it increases by 1). If you have a board with more leds you can customize the "test_out" and "dbg_data_signal" signals width in "top.vhd" module.  To modify what is going to be mapped on leds you have to follow these steps:
    1. Add an output signal (STD_LOGIC_VECTOR(3 downto 0)) to the internal module you are interested in, or choose the width according to the number of leds
    2. Assign the internal signals you want to watch to the output signal discussed in the previous point
    3. Update the component interface in the "top.vhd" module
    4. Portmap the new output signal to dbg_data_signal
    5. Eliminate PC related default debug logic or you will have a multidriven signal
4. Verify that in "clk_filter.vhd" file the statement "clk_out <= clk_in;" is commented and "clk_out <= internal_counter(27);" is present. You can customize this module so that the evolution leds state speed changes.
5. Run synthesis, implementation and generate bitstream
6. Switch ON the switch0 on board, so that you can enable the clock. You can Switch OFF everytime you want to stop the clock and analyze leds state and Switch ON again to continue
