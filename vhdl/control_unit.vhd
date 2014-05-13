-- Author: Ronaldo Dall'Agnol Veiga
--			@roniveiga
-- UFRGS - Instituto de Informática
-- Sistemas Digitais
-- Profa. Dra. Fernanda Gusmão de Lima Kastensmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control_unit is
    Port ( 	
			-- inputs
			clk_in		: in STD_LOGIC;
			rst_in		: in STD_LOGIC;
			enable_neander : in STD_LOGIC;
			N		: in STD_LOGIC;
			Z		: in STD_LOGIC;
			s_exec_nop, s_exec_sta, s_exec_lda, s_exec_add, s_exec_or, s_exec_shr, s_exec_shl, s_exec_mul,
				s_exec_and, s_exec_not, s_exec_jmp, s_exec_jn, s_exec_jz, s_exec_hlt : in STD_LOGIC;
				
			-- outputs--
			-- operation selector
			sel_ula		: out STD_LOGIC_VECTOR(2 downto 0);
			-- registers loads
			loadAC		: out STD_LOGIC;
			loadPC		: out STD_LOGIC;
			loadREM		: out STD_LOGIC;
			loadRDM		: out STD_LOGIC;
			loadRI 		: out STD_LOGIC;
			loadN			: out STD_LOGIC;
			loadZ			: out STD_LOGIC;
			-- write in memory
			wr_enable_mem : out STD_LOGIC_VECTOR (0 downto 0);
			-- selector for mux_rem: 0 for PC, 1 for RDM
			sel 			: out STD_LOGIC;
			-- Program Counter increment
			PC_inc 		: out STD_LOGIC;
			-- selector for mux_rdm: 0 for mem(read), 1 for AC
			sel_mux_RDM : out STD_LOGIC;
			-- stop signal
			stop		: out STD_LOGIC
			  );
end control_unit;

architecture Behavioral of control_unit is
	type state_machine is (IDLE, BUSCA_INSTRUCAO, LER_INSTRUCAO, CARREGA_RI, 
									EXEC_STA2, BUSCA_DADOS, BUSCA_ENDERECO, TRATA_JUMP, TRATA_JUMP_FAIL, 
									READ_MEMORY, EXEC_STA, TRATA_HLT, EXEC_ULA, EXEC_ULA2);
	signal current_state : state_machine;
	signal next_state : state_machine;	
	signal stop_s : STD_LOGIC;

begin

	process (clk_in, rst_in)
    variable state_timer: integer; -- states for two cicles
	begin
		if (rst_in = '1') then
			stop_s <= '0';
			loadAC <= '0';
			loadPC <= '0';
			PC_inc <= '0';
			loadREM <= '0';
			loadRDM <= '0';
			loadRI <= '0';			
			loadN <= '0';
			loadZ <= '0';			
			wr_enable_mem <= "0";
         state_timer := 1;
			next_state <= IDLE;
		elsif (clk_in = '1' and clk_in'EVENT) then
			case current_state is
			
			when IDLE =>
				if (enable_neander = '1' and stop_s = '0') then -- start signal
					next_state <= BUSCA_INSTRUCAO;
				else
					next_state <= IDLE;
				end if;
			-- E0: REM <- PC	
			when BUSCA_INSTRUCAO =>
				sel_mux_RDM <= '0';
				loadAC <= '0';
				loadPC <= '0';
            PC_inc <= '0';
				loadRDM <= '0';
				loadRI <= '0';
				wr_enable_mem <= "0";
				loadN <= '0';
				loadZ <= '0';
				-- select 0 for PC->REM
				sel <= '0';
				-- load REM
				loadREM <= '1';
			   next_state <= LER_INSTRUCAO;
			-- E1: RDM <- MEM(read), PC+	
			when LER_INSTRUCAO =>
				loadREM <= '0';
				loadRDM <= '1';
				PC_inc <= '1'; 
				next_state <= CARREGA_RI;
			-- E2: RI <- RDM	
			when CARREGA_RI =>
				loadRDM <= '0';
				PC_inc <= '0';
				loadRI <= '1';
				if (s_exec_hlt = '1') then 	-- HLT
					next_state <= TRATA_HLT;
				elsif (s_exec_nop = '1') then -- NOP
					next_state <= BUSCA_INSTRUCAO;
				elsif (s_exec_not = '1') then -- NOT
					next_state <= EXEC_ULA2;
				elsif ((s_exec_jn = '1') and (N = '0')) or ((s_exec_jz = '1') and (z = '0')) then -- jump fail
					next_state <= TRATA_JUMP_FAIL;
				else
					next_state <= BUSCA_DADOS;
				end if;
			-- E3: REM <- PC
			when BUSCA_DADOS =>
				loadRI <= '0';
				sel <= '0';
				loadREM <= '1';
				next_state <= READ_MEMORY;
			-- E4: RDM <- MEM(read), PC+
			WHEN READ_MEMORY => 				
				loadREM <= '0';
				loadRDM <= '1';
				PC_inc <= '1';
				if (s_exec_add = '1') then 	-- ADD
				next_state <= BUSCA_ENDERECO;
				elsif (s_exec_or = '1') then 	-- OR
				next_state <= BUSCA_ENDERECO;
				elsif (s_exec_and = '1') then -- AND
				next_state <= BUSCA_ENDERECO;
				elsif (s_exec_lda = '1') then -- LDA
				next_state <= BUSCA_ENDERECO;
				elsif (s_exec_shr = '1') then -- SHR
				next_state <= BUSCA_ENDERECO;
				elsif (s_exec_shl = '1') then -- SHL
				next_state <= BUSCA_ENDERECO;
				elsif (s_exec_mul = '1') then -- MUL
				next_state <= BUSCA_ENDERECO;
				elsif (s_exec_sta = '1') then -- STA
				next_state <= BUSCA_ENDERECO;
				elsif ((s_exec_jmp = '1') or ((s_exec_jn = '1') and (N = '1')) or ((s_exec_jz = '1') and (z = '1'))) then -- real jump
					next_state <= TRATA_JUMP;
				else
					next_state <= IDLE;
				end if;
			-- E5: REM <- RDM
			when BUSCA_ENDERECO =>
				loadRDM <= '0';
				PC_inc <= '0';
				sel <= '1';		-- select 1 for RDM->REM
				loadREM <= '1';
				if (s_exec_add = '1') then 	-- ADD
				next_state <= EXEC_ULA;
				elsif (s_exec_or = '1') then 	-- OR
				next_state <= EXEC_ULA;
				elsif (s_exec_and = '1') then -- AND
				next_state <= EXEC_ULA;
				elsif (s_exec_lda = '1') then -- LDA
				next_state <= EXEC_ULA;
				elsif (s_exec_shr = '1') then -- SHR
				next_state <= EXEC_ULA;
				elsif (s_exec_shl = '1') then -- SHL
				next_state <= EXEC_ULA;
				elsif (s_exec_mul = '1') then -- MUL
				next_state <= EXEC_ULA;
				elsif (s_exec_sta = '1') then -- STA
				next_state <= EXEC_STA;
				end if;
			-- E6: RDM <- MEM(read)
			when EXEC_ULA =>
				loadREM <= '0';
				loadRDM <= '1';
				if (s_exec_add = '1') then 	-- ADD
				sel_ula <= "000";
				elsif (s_exec_or = '1') then 	-- OR
				sel_ula <= "010";
				elsif (s_exec_and = '1') then -- AND
				sel_ula <= "001";
				elsif (s_exec_not = '1') then -- NOT
				sel_ula <= "011";
				elsif (s_exec_lda = '1') then -- LDA
				sel_ula <= "100";
				elsif (s_exec_shr = '1') then -- SHR
				sel_ula <= "101";
				elsif (s_exec_shl = '1') then -- SHL
				sel_ula <= "110";
				elsif (s_exec_mul = '1') then -- MUL
				sel_ula <= "111";
				end if;
				next_state <= EXEC_ULA2;
			-- E7: AC <- ULA
			when EXEC_ULA2 =>
				loadRDM <= '0';
				loadRI <= '0';
				loadAC <= '1';
				loadN <= '1';
				loadZ <= '1';
				next_state <= BUSCA_INSTRUCAO;
			-- E8: RDM <- AC
			when EXEC_STA =>
				loadREM <= '0';
				sel_mux_RDM <= '1'; -- select 1 for AC->RDM
				loadRDM <= '1';
				next_state <= EXEC_STA2;
			-- E9: MEM <- RDM(write)
			when EXEC_STA2 =>
				sel_mux_RDM <= '0';
				loadRDM <= '0';
				wr_enable_mem <= "1";
				next_state <= BUSCA_INSTRUCAO;
			-- E10: PC <- RDM
			when TRATA_JUMP =>
				loadRDM <= '0';
				PC_inc <= '0';
				loadPC <= '1';
				next_state <= BUSCA_INSTRUCAO;
			-- E11: PC+
			when TRATA_JUMP_FAIL =>
				loadRI <= '0';
				PC_inc <= '1';
				next_state <= BUSCA_INSTRUCAO;
			-- E12: STOP
			when TRATA_HLT =>
				loadRI <= '0';
				stop_s <= '1';
				next_state <= IDLE;
			-- others	
			when others =>
				next_state <= IDLE;
			end case;
            if state_timer = 0 then			-- states for two cicles
					current_state <= next_state;
					state_timer := 1;
            else
					current_state <= current_state;
					state_timer := state_timer -1;
            end if;
		end if;
		
		stop <= stop_s;
	end process;
end;	
				
			
				
				
				
		
			
