----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2021 11:59:59
-- Design Name: 
-- Module Name: memory - Behavioral
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


--NB PARAMETRIZATION IS NEEDED TO PORT FOR 64 ECC 
--IN AND OUT DATA ARE IN LITTLE ENDIAN(CONVERSION IS IN PROCESSOR LOGIC)
--read port: istructions and data(LOAD)
--write port(rising edge): data(STORE)
entity memory is
    Port ( istr_address : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           data_address : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           data_write : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           data_read : out STD_LOGIC_VECTOR (XLEN-1 downto 0);
           enable_d_w : in STD_LOGIC;
           istr_read : out STD_LOGIC_VECTOR (XLEN-1 downto 0);
           --dbg_data: out STD_LOGIC_VECTOR(3 downto 0);
           clk : in STD_LOGIC);
end memory;

architecture Behavioral of memory is
    
    signal memory_space: memory_space_t := (
--ALL LITTLE ENDIAN
0 => x"130101FE",
1 => x"232E8100",
2 => x"13040102",
3 => x"93072000",
4 => x"2326F4FE",
5 => x"93073000",
6 => x"2324F4FE",
7 => x"0327C4FE",
8 => x"832784FE",
9 => x"B307F700",
10 => x"2322F4FE",
11 => x"6F000000", --jal
--11 => "01100111000000001100111100000000", --jalr


--11 => x"13000000",
--12 => x"032744FE",
--13 => x"93075000",
--14 => x"E30CF7FE",
--15 => x"93070000",
--16 => x"13850700",
--17 => x"0324C101",
--18 => x"13010102",
--19 => x"", return 

-- others
others => (others => '1')
    );
    signal al_istr_address : STD_LOGIC_VECTOR (5 downto 0);
    signal al_data_address : STD_LOGIC_VECTOR (5 downto 0);
    
begin
    --dbg_data <= memory_space(57)(27 downto 24);
    
    
    --memory grows up-down with increasing address
    --little endian MEMORY
    --memory address always aligned on 4 byte and always give 32 bit as a response
    al_istr_address <= istr_address(7 downto 2);
    al_data_address <= data_address(7 downto 2);
    --istr_read and data_read exit as big endian, ready to be written in registers 
    istr_read <= memory_space(to_integer(unsigned(al_istr_address)));
    data_read <= memory_space(to_integer(unsigned(al_data_address)));
    
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(enable_d_w = '1') then 
                memory_space(to_integer(unsigned(al_data_address))) <= data_write(XLEN-1 downto 0);
            end if;
        end if;
    end process;
    
end Behavioral;
