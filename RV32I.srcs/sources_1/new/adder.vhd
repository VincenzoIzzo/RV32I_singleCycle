----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2021 16:03:05
-- Design Name: 
-- Module Name: adder - Behavioral
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
use work.defs.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder is
    Port ( op1 : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           op2 : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           ris : out STD_LOGIC_VECTOR (XLEN-1 downto 0);
           carry_out : out STD_LOGIC);
end adder;

architecture Behavioral of adder is
    signal tot_ris : STD_LOGIC_VECTOR (XLEN downto 0);
begin
    tot_ris <= std_logic_vector(to_signed(to_integer(signed(op1)) + to_integer(signed(op2)),XLEN+1));
    ris <= tot_ris(XLEN-1 downto 0);
    carry_out <= tot_ris(XLEN);
end Behavioral;
