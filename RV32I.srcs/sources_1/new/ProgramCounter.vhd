----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2021 12:40:27
-- Design Name: 
-- Module Name: ProgramCounter - Behavioral
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

entity ProgramCounter is
    Port ( clk : in STD_LOGIC;
           PC : out STD_LOGIC_VECTOR (XLEN-1 downto 0));
end ProgramCounter;

architecture Behavioral of ProgramCounter is

    signal PC_value : STD_LOGIC_VECTOR (XLEN-1 downto 0) := PC_rst_val;
    signal PC_new : STD_LOGIC_VECTOR(XLEN-1 downto 0) := (others => '0');
begin

    PC <= PC_value;
    PC_new <= std_logic_vector(to_unsigned(to_integer(unsigned(PC_value))+4,XLEN));
    process(clk)
    begin
        if(rising_edge(clk)) then
            PC_value <= PC_new;
        end if;
    end process;

end Behavioral;
