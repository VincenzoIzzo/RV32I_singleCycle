----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2021 16:44:34
-- Design Name: 
-- Module Name: top_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is

    component top is
        Port (ext_clk : in STD_LOGIC;
              en_clk: in STD_LOGIC;
              test_out : out STD_LOGIC_VECTOR(3 downto 0));   
    end component;
    
    signal clk_signal: STD_LOGIC := '0';
    signal en_clk_signal : STD_LOGIC := '1';
    signal test_out_signal: STD_LOGIC_VECTOR(3 downto 0);
    
begin
    DUT: top port map(ext_clk => clk_signal,
                      en_clk => en_clk_signal,
                      test_out => test_out_signal);
    
    clk_process: process
        variable current_count : natural := 0;
    begin
        while(current_count < clk_periods) loop
            wait for 5 ns;
            clk_signal <= '1';
            wait for 5 ns;
            clk_signal <= '0';
            current_count := current_count + 1;
        end loop;
        wait;
    end process;

end Behavioral;
