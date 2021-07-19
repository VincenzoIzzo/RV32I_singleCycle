# RV32I_singleCycle
This is a custom behavioral implementation (in VHDL) of RV32I specification istruction set (in developing). Currently there are 27/40 istructions implemented (arithmetic, logic, store, load istructions)


## How to simulate (top_tb.vhdl)
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
