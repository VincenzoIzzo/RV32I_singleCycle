----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.07.2021 19:48:50
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

entity control_unit is
    Port (istruction_in : in STD_LOGIC_VECTOR(XLEN-1 downto 0);
          ctrl_signal: out STD_LOGIC_VECTOR(9 downto 0);
          mem_write_en: out STD_LOGIC;
          mem_RF_en: out STD_LOGIC;
          beq: in STD_LOGIC;
          blt: in STD_LOGIC;
          bltu: in STD_LOGIC;
          branch_cond_yes: out STD_LOGIC;
          branch_uncond_yes: out STD_LOGIC
          );
end control_unit;

architecture Behavioral of control_unit is

    signal funct3 : STD_LOGIC_VECTOR (2 downto 0);
    signal funct7_5 : STD_LOGIC;
    signal istr_6 : STD_LOGIC;
    signal istr_5 : STD_LOGIC;
    signal istr_4: STD_LOGIC;
    
begin


    funct3 <= istruction_in(x_funct3'range);
    funct7_5 <= istruction_in(select_add_or_sub);
    istr_6 <= istruction_in(6);
    istr_5 <= istruction_in(5);
    istr_4 <= istruction_in(4);
    
   
    --BRANCH PROCESS
    process(istruction_in, beq, blt, bltu)
    begin
        if(istruction_in(6) = '1') then --branch istruction 
            if(istruction_in(2) = '1') then --unconditional JAL AND JALR
                branch_uncond_yes <= '1';
                branch_cond_yes <= '0';
            else --conditional
                case funct3 is
                    when "000" =>   --beq
                        branch_cond_yes <= beq;
                    when "001" =>   --bne
                        branch_cond_yes <= not(beq);
                    when "100" =>   --blt
                        branch_cond_yes <= blt;
                    when "101" =>   --bge
                        branch_cond_yes <= not(blt);
                    when "110" =>   --bltu
                        branch_cond_yes <= bltu;
                    when "111" =>   --bgeu
                        branch_cond_yes <= not(bltu);
                        
                    when others =>
                        branch_cond_yes <= '0';
                end case;
                branch_uncond_yes <= '0';
            end if;
            
        else                       --no branch istruction 
            branch_cond_yes <= '0';
            branch_uncond_yes <= '0';
        end if;
    end process;
    
    --MEM ENABLE PROCESS
    process(istr_6, istr_5, istr_4)
    begin
        if(istr_6 = '0') then -- no branch
            if(istr_4 = '0' and istr_5 = '1') then    --STORE 
                mem_write_en <= '1';
                mem_RF_en <= '0';
            else
                mem_write_en <= '0';
                mem_RF_en <= '1';
            end if;
        else 
            if(istruction_in(2) = '1') then --JAL and JALR
                mem_RF_en <= '1';
                mem_write_en <= '0';
            else 
                mem_write_en <= '0';
                mem_RF_en <= '0';
            end if;
            
        end if;
        
    end process;
    
    
    --SIGNAL FOR ALU PROCESS
    process(funct3, funct7_5, istr_6, istr_5, istr_4)
    begin
        if(istr_4 = '1') then
            case funct3 is
                when "000" =>
                    if(istr_5 = '1' and funct7_5 = '1') then --check if is a reg and is a sub
                        if(funct7_5 = '1') then --sub
                            ctrl_signal <= "0100000000";
                        end if;
                    else --ADD,    if is immediate and you want to do a sub, pass already the negative base complement immediate
                        ctrl_signal <= "1000000000";
                    end if;
                when "001" => --sll
                    ctrl_signal <= "0000010000";
                when "010" => --set less than UNSIGNED
                    ctrl_signal <= "0000000001";
                when "011" => --set less than SIGNED
                    ctrl_signal <= "0000000010";
                when "100" =>  --xor
                    ctrl_signal <= "0000100000";
                    
                when "101" =>  --shift right
                    if(funct7_5 = '1') then   --arit right
                        ctrl_signal <= "0000000100";
                    else                        --logic right
                        ctrl_signal <= "0000001000";
                    end if;
                when "110" =>  --or
                    ctrl_signal <= "0001000000";
                when "111" =>  --and
                    ctrl_signal <= "0010000000";
                when others =>
                    ctrl_signal <= "0000000000";
                    
            end case;
        else
            ctrl_signal <= "1000000000";
        end if;
            
        
    end process;
    

end Behavioral;
