-- Author: Ronaldo Dall'Agnol Veiga
--			@roniveiga
-- UFRGS - Instituto de Informática
-- Sistemas Digitais
-- Profa. Dra. Fernanda Gusmão de Lima Kastensmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;d

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
    Port ( instruction_in : in  STD_LOGIC_VECTOR (7 downto 0);
           --decod_instr : out  STD_LOGIC_VECTOR(3 downto 0);
			  s_exec_nop, s_exec_sta, s_exec_lda, s_exec_add, s_exec_or, s_exec_shr, s_exec_shl, s_exec_mul,
				s_exec_and, s_exec_not, s_exec_jmp, s_exec_jn, s_exec_jz, s_exec_hlt : out STD_LOGIC
				);
end decoder;

architecture Behavioral of decoder is
begin
		-- decod_instr	<= instruction_in(7 downto 4);
		-- 0000 -> NOP
		-- 0001 -> STA
		-- 0010 -> LDA
		-- 0011 -> ADD
		-- 0100 -> OR
		-- 0101 -> AND
		-- 0110 -> NOT
		-- 0111 -> SHR
		-- 1000 -> JMP
		-- 1001 -> JN
		-- 1010 -> JZ
		-- 1011 -> SHL
		-- 1100 -> MUL
		-- 1111 -> HLT
		
		program: process (instruction_in(7 downto 4))
		begin
			-- Set all as zero
			s_exec_nop <= '0';
			s_exec_sta <= '0';
			s_exec_lda <= '0';
			s_exec_add <= '0';
			s_exec_or 	<= '0';
			s_exec_and <= '0';
			s_exec_not <= '0';
			s_exec_jmp <= '0';
			s_exec_jn 	<= '0';
			s_exec_jz 	<= '0';
			s_exec_hlt <= '0';
			s_exec_shr <= '0';
			s_exec_shl <= '0';
			s_exec_mul <= '0';
			if (instruction_in(7 downto 4) = "0000") then 	-- NOP
				s_exec_nop <= '1';
			elsif (instruction_in(7 downto 4) = "0001") then -- STA
				s_exec_sta <= '1';
			elsif (instruction_in(7 downto 4) = "0010") then -- LDA
				s_exec_lda <= '1';
			elsif (instruction_in(7 downto 4) = "0011") then -- ADD
				s_exec_add <= '1';
			elsif (instruction_in(7 downto 4) = "0100") then -- OR
				s_exec_or <= '1';
			elsif (instruction_in(7 downto 4) = "0101") then -- AND
				s_exec_and <= '1';
			elsif (instruction_in(7 downto 4) = "0110") then -- NOT
				s_exec_not <= '1';
			elsif (instruction_in(7 downto 4) = "1000") then -- JMP
				s_exec_jmp <= '1';
			elsif (instruction_in(7 downto 4) = "1001") then -- JN
				s_exec_jn <= '1';
			elsif (instruction_in(7 downto 4) = "1010") then -- JZ
				s_exec_jz <= '1';
			elsif (instruction_in(7 downto 4) = "1111") then -- HLT
				s_exec_hlt <= '1';
			-- Challenge instructions SHR, SHL e MUL
			elsif (instruction_in(7 downto 4) = "0111") then -- SHR
				s_exec_shr <= '1';
			elsif (instruction_in(7 downto 4) = "1011") then -- SHL
				s_exec_shl <= '1';
			elsif (instruction_in(7 downto 4) = "1100") then -- MUL
				s_exec_mul <= '1';
			-- End challenge
			end if;
		
		end process program;
			
end Behavioral;
