-- Author: Ronaldo Dall'Agnol Veiga
--			@roniveiga
-- UFRGS - Instituto de Informática
-- Sistemas Digitais
-- Profa. Dra. Fernanda Gusmão de Lima Kastensmidt

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

entity ula is
    Port ( 	X : in  STD_LOGIC_VECTOR (7 downto 0);
				Y : in  STD_LOGIC_VECTOR (7 downto 0);
				sel_ula : in  STD_LOGIC_VECTOR (2 downto 0);
				N 	: out STD_LOGIC;
				Z	: out STD_LOGIC;
				ula_output : out STD_LOGIC_VECTOR (7 downto 0)
			 );
end ula;

architecture Behavioral of ula is

	signal result : STD_LOGIC_VECTOR(8 downto 0);
   signal X_temp, Y_temp : STD_LOGIC_VECTOR(8 downto 0);

begin

	X_temp(8 downto 0) <= '0' & X(7 downto 0);
	Y_temp(8 downto 0) <= '0' & Y(7 downto 0);

	ula_output <= result(7 downto 0);
	
	result <= 	(X_temp(8 downto 0) + Y_temp(8 downto 0)) when sel_ula = "000" else 		--	ADD
					(X_temp(8 downto 0) AND Y_temp(8 downto 0)) when sel_ula = "001" else --	AND
					(X_temp(8 downto 0) OR Y_temp(8 downto 0)) when sel_ula = "010" else 	--	OR
					('0' & not(X_temp(7 downto 0)))  when sel_ula = "011" else					--	NOT
					'0' & Y when sel_ula = "100" else													--	LDA
					("00" & X_temp(7 downto 1)) when sel_ula = "101" else							--	SHR
					('0' & X_temp(6 downto 0) & '0') when sel_ula = "110" else					--	SHL
					(X_temp(8 downto 0) + Y_temp(8 downto 0)) when sel_ula = "111" else 		--	MUL
					"000000000";

		-- Carry
--		C <= result(8);

		-- Zero
		Z <= '1' when result(7 downto 0) = "00000000" 
			else '0';

		-- Negative
		N <= result(7);


end Behavioral;