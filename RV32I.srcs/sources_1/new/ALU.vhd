----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2021 14:49:41
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( src1 : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           src2 : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           dest : out STD_LOGIC_VECTOR (XLEN-1 downto 0);
           ctrl_signal: in STD_LOGIC_VECTOR(9 downto 0));
end ALU;

architecture Behavioral of ALU is
    
    signal shamt : STD_LOGIC_VECTOR(4 downto 0);
begin

    shamt <= src2(4 downto 0);
    
    process(src1, src2, ctrl_signal)
    begin
        case ctrl_signal is
            when "1000000000" => --add
                dest <= std_logic_vector(to_unsigned(to_integer(unsigned(src1))+to_integer(unsigned(src2)),XLEN));

            when "0100000000" => --sub
                dest <= std_logic_vector(to_unsigned(to_integer(unsigned(src1))-to_integer(unsigned(src2)),XLEN));
       
            when "0010000000" => --and
                dest <= src1 and src2;
                
            when "0001000000" => --or
                dest <= src1 or src2;
        
            when "0000100000" => --xor
                dest <= src1 xor src2;
                
            when "0000010000" => --sll
                dest <= std_logic_vector(shift_left(unsigned(src1), to_integer(unsigned(shamt))));    
            
            when "0000001000" => --srl
                dest <= std_logic_vector(shift_right(unsigned(src1), to_integer(unsigned(shamt))));
                            
            when "0000000100" => --sra
                dest <= std_logic_vector(shift_right(signed(src1), to_integer(unsigned(shamt))));
                
            when "0000000010" => --slt
                if (to_integer(signed(src1)) < to_integer(signed(src2)))  then
                    dest <= "00000000000000000000000000000001";
                else
                    dest <= (others => '0');
                end if;
                
            when "0000000001" => --sltu
                if (to_integer(unsigned(src1)) < to_integer(unsigned(src2)))  then
                    dest <= "00000000000000000000000000000001";
                else
                    dest <= (others => '0');
                end if;
                
            when others =>
                dest <= (others => '0');   
        end case;
    end process;
    
end Behavioral;
