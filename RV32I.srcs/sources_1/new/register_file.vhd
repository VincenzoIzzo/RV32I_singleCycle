----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2021 14:31:53
-- Design Name: 
-- Module Name: register_file - Behavioral
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

entity register_file is
    Port ( src1_index : in STD_LOGIC_VECTOR (4 downto 0);
           src2_index : in STD_LOGIC_VECTOR (4 downto 0);
           dest_index : in STD_LOGIC_VECTOR (4 downto 0);
           write_en : in STD_LOGIC;
           clk : in STD_LOGIC;
           src1_read : out STD_LOGIC_VECTOR (31 downto 0);
           src2_read : out STD_LOGIC_VECTOR (31 downto 0);
           dest_write : in STD_LOGIC_VECTOR (31 downto 0));
end register_file;

architecture Behavioral of register_file is

    
    signal register_space: register_space_t := (
--0 => "00000000000000000000000000000001",
--1 => "00000000000000000000000000000001",
  2 => "00000000000000000000000100000000", --sp = primo inidirizzo non esistente della 65-esima parola(256)
others => (others => '0')
    );
    
begin
    src1_read <= register_space(to_integer(unsigned(src1_index)));
    src2_read <= register_space(to_integer(unsigned(src2_index)));
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(write_en = '1') then 
                register_space(to_integer(unsigned(dest_index))) <= dest_write;
            end if;
        end if;
    end process;
    
end Behavioral;
