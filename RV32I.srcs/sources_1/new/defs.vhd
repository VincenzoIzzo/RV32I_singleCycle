----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2021 12:02:31
-- Design Name: 
-- Module Name: defs - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package defs is

  -- Data widths
  
  -- Processor register/address space width
  constant XLEN      : positive := 32;
  
  -- Clk duration (max 63 given that i have 64 istr max in memory)
  constant clk_periods : positive := 31;
  
  
  -- Memory types
  --type memory_space_t is array((2**XLEN)-1 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
  -- so it is implementable
  type memory_space_t is array(63 downto 0) of STD_LOGIC_VECTOR(XLEN-1 downto 0);
    --to parametrize if RV64 
  constant zero_padding : STD_LOGIC_VECTOR(1 downto 0) := "00";
  
  
  -- register file types
  
  type register_space_t is array(31 downto 0) of STD_LOGIC_VECTOR(XLEN-1 downto 0);
  
  
  -- PC types
  constant PC_rst_val : STD_LOGIC_VECTOR(XLEN-1 downto 0) := (others => '0');
  
  
  -- istructions format R
  subtype R_funct7 is STD_LOGIC_VECTOR(31 downto 25);
  subtype R_rs2 is STD_LOGIC_VECTOR(24 downto 20);
  subtype R_rs1 is STD_LOGIC_VECTOR(19 downto 15);
  subtype R_funct3 is STD_LOGIC_VECTOR(14 downto 12);
  subtype R_rd is STD_LOGIC_VECTOR(11 downto 7);
  subtype R_opcode is STD_LOGIC_VECTOR(6 downto 0);
  
  -- istructions format I
  subtype I_imm is STD_LOGIC_VECTOR(31 downto 20);
  subtype I_rs1 is STD_LOGIC_VECTOR(19 downto 15);
  subtype I_funct3 is STD_LOGIC_VECTOR(14 downto 12);
  subtype I_rd is STD_LOGIC_VECTOR(11 downto 7);
  subtype I_opcode is STD_LOGIC_VECTOR(6 downto 0);
  
  -- istructions format S
  subtype S_imm_1 is STD_LOGIC_VECTOR(31 downto 25);
  subtype S_rs2 is STD_LOGIC_VECTOR(24 downto 20);
  subtype S_rs1 is STD_LOGIC_VECTOR(19 downto 15);
  subtype S_funct3 is STD_LOGIC_VECTOR(14 downto 12);
  subtype S_imm_0 is STD_LOGIC_VECTOR(11 downto 7);
  subtype S_opcode is STD_LOGIC_VECTOR(6 downto 0);
  
  -- istructions format B
  constant B_imm_12 : natural := 31;
  subtype B_imm_10_5 is STD_LOGIC_VECTOR(30 downto 25);
  subtype B_rs2 is STD_LOGIC_VECTOR(24 downto 20);
  subtype B_rs1 is STD_LOGIC_VECTOR(19 downto 15);
  subtype B_funct3 is STD_LOGIC_VECTOR(14 downto 12);
  subtype B_imm_4_1 is STD_LOGIC_VECTOR(11 downto 8);
  constant B_imm_11 : natural := 7;
  subtype B_opcode is STD_LOGIC_VECTOR(6 downto 0);
  
  subtype x_funct3 is STD_LOGIC_VECTOR(14 downto 12);
  
  constant select_imm_reg_arit : natural := 5;
  constant select_rfw_mem_alu : natural := 4;
  constant select_add_or_sub : natural := 30;
  
end package defs;
