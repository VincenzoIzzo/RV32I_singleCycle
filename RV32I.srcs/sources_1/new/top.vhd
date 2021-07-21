----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2021 12:48:04
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port (ext_clk : in STD_LOGIC;
          en_clk: in STD_LOGIC;
          test_out : out STD_LOGIC_VECTOR(3 downto 0));
end top;

architecture Behavioral of top is
    
    --filter clock to debug on zybo
    component clk_filter is
        Port ( clk_in : in STD_LOGIC;
               en_in : in STD_LOGIC;
               clk_out : out STD_LOGIC);
    end component;
    
    component control_unit is
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
    end component;

    component memory is
        Port ( istr_address : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
               data_address : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
               data_write : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
               data_read : out STD_LOGIC_VECTOR (XLEN-1 downto 0);
               enable_d_w : in STD_LOGIC;
               istr_read : out STD_LOGIC_VECTOR (XLEN-1 downto 0);
              -- dbg_data: out STD_LOGIC_VECTOR(3 downto 0);
               clk : in STD_LOGIC);
    end component;

    component ProgramCounter is
        Port ( clk : in STD_LOGIC;
               new_PC_in : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
               PC_out : out STD_LOGIC_VECTOR (XLEN-1 downto 0));
    end component;
    
    component register_file is
        Port ( src1_index : in STD_LOGIC_VECTOR (4 downto 0);
               src2_index : in STD_LOGIC_VECTOR (4 downto 0);
               dest_index : in STD_LOGIC_VECTOR (4 downto 0);
               write_en : in STD_LOGIC;
               clk : in STD_LOGIC;
               src1_read : out STD_LOGIC_VECTOR (31 downto 0);
               src2_read : out STD_LOGIC_VECTOR (31 downto 0);
               dest_write : in STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component ALU is
        Port ( src1 : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
               src2 : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
               dest : out STD_LOGIC_VECTOR (XLEN-1 downto 0);
               beq: out STD_LOGIC;
               blt: out STD_LOGIC;
               bltu: out STD_LOGIC;
               ctrl_signal: in STD_LOGIC_VECTOR(9 downto 0));
    end component;

    component adder is
        Port ( op1 : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
               op2 : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
               ris : out STD_LOGIC_VECTOR (XLEN-1 downto 0);
               carry_out : out STD_LOGIC);
    end component;

    signal beq_signal : STD_LOGIC;
    signal blt_signal : STD_LOGIC;
    signal bltu_signal : STD_LOGIC;
    
    
    signal new_PC_in_signal : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal PC_plus_4_signal : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal PC_out_signal : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal carry_out_PC_signal : STD_LOGIC;
    signal carry_out_PC_plus_4_signal : STD_LOGIC;
    signal mux_PC_ctrl_cond: STD_LOGIC;
    signal mux_PC_ctrl_uncond: STD_LOGIC;
    signal PC_adder_op1_signal: STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal PC_adder_op2_signal: STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal le_istruction: STD_LOGIC_VECTOR (XLEN-1 downto 0); --little endian
    signal be_istruction : STD_LOGIC_VECTOR (XLEN-1 downto 0); --big endian
    
   
    signal le_data_mem_signal: STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal be_data_mem_signal: STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal poststore_be_data_mem_signal: STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal val_to_load_in_RF: STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal src1_RF_signal : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal src2_RF_signal : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal dest_RF_signal : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal le_data_mem_write_signal: STD_LOGIC_VECTOR (XLEN-1 downto 0);
   
    --ALU
    signal ALU_result : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal ALU_src2 : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal imm_extended : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    signal imm_splitted_store : STD_LOGIC_VECTOR (11 downto 0);
    signal imm_splitted_branch : STD_LOGIC_VECTOR (12 downto 0);
    signal imm_splitted_jump : STD_LOGIC_VECTOR (20 downto 0);
    signal filtered_clock: STD_LOGIC;
    
    --mem data address
    signal data_address_signal : STD_LOGIC_VECTOR (XLEN-1 downto 0);
    
    --CU TO ALU SIGNALS
    signal ctrl_signal_sig: STD_LOGIC_VECTOR(9 downto 0);
    
    --CU TO MEM SIGNALS
    signal mem_write_en_signal: STD_LOGIC;
    
    --CU TO RF SIGNALS 
    signal mem_RF_en_signal: STD_LOGIC;
    
    --debug
    signal dbg_data_signal: STD_LOGIC_VECTOR(3 downto 0);
    
begin

filt: clk_filter port map(clk_in => ext_clk,
                          en_in => en_clk,
                              clk_out => filtered_clock 
                              );
                              
    mem: memory port map(istr_address => PC_out_signal,
                         data_address => data_address_signal,
                         data_write => le_data_mem_write_signal,
                         data_read => le_data_mem_signal,
                         enable_d_w => mem_write_en_signal, 
                         istr_read => le_istruction,
                         --dbg_data => dbg_data_signal,
                         clk => filtered_clock
                         );
                         
    PC: ProgramCounter port map(clk => filtered_clock,
                                new_PC_in => new_PC_in_signal,
                                PC_out => PC_out_signal);
    
    PC_adder: adder port map(op1 => PC_adder_op1_signal,
                             op2 => PC_adder_op2_signal,
                             ris => new_PC_in_signal,
                             carry_out => carry_out_PC_signal
                             );
    PC_plus_4_adder: adder port map(op1 => PC_out_signal,
                             op2 => "00000000000000000000000000000100",
                             ris => PC_plus_4_signal,
                             carry_out => carry_out_PC_plus_4_signal
                             );                    
    RF: register_file port map(src1_index => be_istruction(R_rs1'range),
                               src2_index => be_istruction(R_rs2'range),
                               dest_index => be_istruction(R_rd'range),
                               write_en => mem_RF_en_signal,
                               clk => filtered_clock,
                               src1_read => src1_RF_signal,
                               src2_read => src2_RF_signal,
                               dest_write => dest_RF_signal);                          
    
    my_alu: ALU port map(src1 => src1_RF_signal,
                      src2 => ALU_src2,
                      dest => ALU_result,
                      beq => beq_signal,
                      blt => blt_signal,
                      bltu => bltu_signal,
                      ctrl_signal => ctrl_signal_sig
                       
                         );
    CU: control_unit port map(istruction_in  => be_istruction,
                       ctrl_signal => ctrl_signal_sig,
                       mem_write_en => mem_write_en_signal,
                       mem_RF_en => mem_RF_en_signal,
                       beq => beq_signal,
                       blt => blt_signal,
                       bltu => bltu_signal,
                       branch_cond_yes => mux_PC_ctrl_cond,
                       branch_uncond_yes => mux_PC_ctrl_uncond
                                );
    --test
    test_out <= dbg_data_signal;
    dbg_data_signal <= PC_out_signal(5 downto 2);
    
    data_address_signal <= ALU_result;
    
    --immediate value sign extension 
    imm_splitted_store <= be_istruction(S_imm_1'range)&be_istruction(S_imm_0'range);
    
    
    immediate_construction: process(be_istruction, imm_splitted_store)
    begin 
        if(be_istruction(4) = '0' and be_istruction(5) = '1') then --store
            imm_extended <= std_logic_vector(resize(signed(imm_splitted_store), XLEN));
        else
            imm_extended <= std_logic_vector(resize(signed(be_istruction(I_imm'range)), XLEN));
        end if;
    end process;
     
    imm_splitted_branch <= be_istruction(B_imm_12)&be_istruction(B_imm_11)&be_istruction(B_imm_10_5'range)&be_istruction(B_imm_4_1'range)&'0';
    imm_splitted_jump <= be_istruction(J_imm_20)&be_istruction(J_imm_19_12'range)&be_istruction(J_imm_11)&be_istruction(J_imm_10_1'range)&'0';
    
    
    
    
    --istruction little endian to bigendian conversion
    be_istruction(XLEN-1 downto 24) <= le_istruction(7 downto 0);
    be_istruction(23 downto 16) <= le_istruction(15 downto 8);
    be_istruction(15 downto 8) <= le_istruction(23 downto 16);
    be_istruction(7 downto 0) <= le_istruction(31 downto 24);
    
    --data little endian to bigendian conversion
    be_data_mem_signal(XLEN-1 downto 24) <= le_data_mem_signal(7 downto 0);
    be_data_mem_signal(23 downto 16) <= le_data_mem_signal(15 downto 8);
    be_data_mem_signal(15 downto 8) <= le_data_mem_signal(23 downto 16);
    be_data_mem_signal(7 downto 0) <= le_data_mem_signal(31 downto 24);
    
    --data bigendian to littleendian conversion
    le_data_mem_write_signal(XLEN-1 downto 24) <= poststore_be_data_mem_signal(7 downto 0);
    le_data_mem_write_signal(23 downto 16) <= poststore_be_data_mem_signal(15 downto 8);
    le_data_mem_write_signal(15 downto 8) <= poststore_be_data_mem_signal(23 downto 16);
    le_data_mem_write_signal(7 downto 0) <= poststore_be_data_mem_signal(31 downto 24);
    
    --changing read value from memory in order to store a variation
    store_type: process(be_data_mem_signal, be_istruction(x_funct3'range), data_address_signal(1 downto 0), src2_RF_signal)
        variable byte_offset : integer;
        variable half_offset : integer;
    begin
        byte_offset := to_integer(unsigned(data_address_signal(1 downto 0)));
        case data_address_signal(1) is 
            when '1' =>
                half_offset := 1;
            when others =>
                half_offset := 0;
        end case;
           ---------------     le_data_mem_write_signal-----------
        poststore_be_data_mem_signal <= be_data_mem_signal;
        
        case be_istruction(x_funct3'range) is
                when "000" => --sb
                    poststore_be_data_mem_signal(byte_offset*8+7 downto byte_offset*8+0) <= src2_RF_signal(7 downto 0);
                when "001" => --sh
                    poststore_be_data_mem_signal(half_offset*16+15 downto half_offset*16+0) <= src2_RF_signal(15 downto 0);
                when "010" => --sw
                    poststore_be_data_mem_signal <= src2_RF_signal;
                when others =>
                    poststore_be_data_mem_signal <= be_data_mem_signal;
        end case;
    end process;
    
    
    
    
    
    --mux which decide signextension word byte ecc in load istruction
    load_type: process(be_data_mem_signal, be_istruction(x_funct3'range), data_address_signal(1 downto 0))
        variable byte_offset : integer;
        variable half_offset : integer;
    begin
        byte_offset := to_integer(unsigned(data_address_signal(1 downto 0)));
        --half_offset := to_integer(unsigned("0" & data_address_signal(1)));
        case data_address_signal(1) is 
            when '1' =>
                half_offset := 1;
            when others =>
                half_offset := 0;
        end case;
        
        case be_istruction(x_funct3'range) is
                when "000" => --lb
                    val_to_load_in_RF <= std_logic_vector(resize(signed(be_data_mem_signal(byte_offset*8+7 downto byte_offset*8+0)), XLEN));
                when "001" => --lh
                    val_to_load_in_RF <= std_logic_vector(resize(signed(be_data_mem_signal(half_offset*16+15 downto half_offset*16+0)), XLEN));
                when "010" => --lw
                    val_to_load_in_RF <= be_data_mem_signal;
                when "100" => --lbu
                    val_to_load_in_RF <= std_logic_vector(resize(unsigned(be_data_mem_signal(byte_offset*8+7 downto byte_offset*8+0)), XLEN));
                when "101" => --lwu
                    val_to_load_in_RF <= std_logic_vector(resize(unsigned(be_data_mem_signal(half_offset*16+15 downto half_offset*16+0)), XLEN));
                when others =>
                    val_to_load_in_RF <= be_data_mem_signal;
        end case;
    end process;
    
    
    
    
    --mux which decide if rs2 is a register or immediate in istruction, based on bit5-4 in opcode
    mux_imm_reg_arit: process(imm_extended, src2_RF_signal, be_istruction(6 downto 4))
    begin
        if(be_istruction(6) = '0') then  --no branch
            if(be_istruction(5) = '1' and be_istruction(4) = '1') then --alu istruction reg-to-reg
                ALU_src2 <= src2_RF_signal;
            else
                ALU_src2 <= imm_extended;
            end if;
        else       -- branch
            ALU_src2 <= src2_RF_signal;
        end if;
        
    end process;
    
    --mux which decide if data to be written in RF is from memory(LOAD) or from ALU(add ecc) based on bit4 in opcode
    mux_rfw_mem_alu: process(val_to_load_in_RF, ALU_result, be_istruction(6 downto 2), PC_plus_4_signal)
    begin
        if(be_istruction(6) = '1' and be_istruction(2) = '1') then --JAL AND JALR
                dest_RF_signal <= PC_plus_4_signal;
        else --no branch
            if(be_istruction(4) = '1') then
                dest_RF_signal <= ALU_result;
            else
                dest_RF_signal <= val_to_load_in_RF;
            end if;
        end if;
        
    end process;
    
    mux_pc_adder_op2: process(mux_PC_ctrl_cond, mux_PC_ctrl_uncond, imm_splitted_branch, imm_splitted_jump, be_istruction(3))
    begin 
        if(mux_PC_ctrl_cond = '0' and mux_PC_ctrl_uncond = '0') then --no branch
            PC_adder_op2_signal <= "00000000000000000000000000000100";
        elsif(mux_PC_ctrl_cond = '1' and mux_PC_ctrl_uncond = '0') then  --conditional branch
            PC_adder_op2_signal <= std_logic_vector(resize(signed(imm_splitted_branch), XLEN));
        elsif(mux_PC_ctrl_cond = '0' and mux_PC_ctrl_uncond = '1') then --unconditional branch
            if(be_istruction(3) = '1') then --jal
                PC_adder_op2_signal <= std_logic_vector(resize(signed(imm_splitted_jump), XLEN));
            else                -- jalr
                PC_adder_op2_signal <= std_logic_vector(resize(signed(be_istruction(I_imm'range)), XLEN));
            end if;
        else
            PC_adder_op2_signal <= "00000000000000000000000000000000";
        end if;                     
    
    end process;
    
    
    --new pc value mux 
    mux_pc_val: process(be_istruction(3), PC_out_signal, src1_RF_signal)
    begin
        if(be_istruction(6 downto 0) = "1100111") then --jalr
            PC_adder_op1_signal <= src1_RF_signal;
        else                          --no jalr
            PC_adder_op1_signal <= PC_out_signal;
        end if;
        
    
    end process; 
    
end Behavioral;
