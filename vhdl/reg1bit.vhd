-- Author: Ronaldo Dall'Agnol Veiga
--			@roniveiga
-- UFRGS - Instituto de Informática
-- Sistemas Digitais
-- Profa. Dra. Fernanda Gusmão de Lima Kastensmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg1bit is
    Port ( 	data_in : in  STD_LOGIC;
			clk_in	: in  STD_LOGIC;
			rst_in	: in  STD_LOGIC;
			load	: in  STD_LOGIC;
			data_out : out  STD_LOGIC
			  );
end reg1bit;

architecture Behavioral of reg1bit is

signal reg : std_logic;

begin
	
	process (clk_in, rst_in)
	begin
		if (rst_in = '1') then
			reg <= '0';
		elsif (clk_in = '1' and clk_in'EVENT) then
			if (load = '1') then
				reg <= data_in;
			else
				reg <= reg;
			end if;
		end if;
	end process;
	data_out <= reg;
end Behavioral;
	
			
	