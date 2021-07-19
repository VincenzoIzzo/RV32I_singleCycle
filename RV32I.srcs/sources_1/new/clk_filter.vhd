----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.07.2021 18:57:18
-- Design Name: 
-- Module Name: clk_filter - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_filter is
    Port ( clk_in : in STD_LOGIC;
           en_in : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end clk_filter;

architecture Behavioral of clk_filter is
    signal internal_counter : STD_LOGIC_VECTOR(27 downto 0) := (others =>'0');
    
begin

    process(clk_in)
    begin
        if(rising_edge(clk_in)) then
            if(en_in = '1') then
                internal_counter <= std_logic_vector(to_unsigned(to_integer(unsigned(internal_counter))+1,28));
            end if;
        end if;
    end process;
    
   clk_out <= internal_counter(27);
   --clk_out <= clk_in; --debug simulation
end Behavioral;
