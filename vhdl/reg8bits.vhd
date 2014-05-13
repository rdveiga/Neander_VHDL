-- Author: Ronaldo Dall'Agnol Veiga
--			@roniveiga
-- UFRGS - Instituto de Informática
-- Sistemas Digitais
-- Profa. Dra. Fernanda Gusmão de Lima Kastensmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg8bits is
    Port ( 	data_in : in  STD_LOGIC_VECTOR (7 downto 0);
			clk_in	: in  STD_LOGIC;
			rst_in	: in  STD_LOGIC;
			load	: in  STD_LOGIC;
			data_out : out  STD_LOGIC_VECTOR (7 downto 0)
			  );
end reg8bits;

architecture Behavioral of reg8bits is

--signal reg : std_logic_vector (7 downto 0);

begin
	
	process (clk_in, rst_in)
	begin
		if (rst_in = '1') then
			data_out <= "00000000";
		elsif (clk_in = '1' and clk_in'EVENT) then
			if (load = '1') then
				data_out <= data_in;
			end if;
		end if;
	end process;
end Behavioral;
	
			
	
