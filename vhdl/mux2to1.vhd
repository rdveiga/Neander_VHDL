-- Author: Ronaldo Dall'Agnol Veiga
--			@roniveiga
-- UFRGS - Instituto de Informática
-- Sistemas Digitais
-- Profa. Dra. Fernanda Gusmão de Lima Kastensmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mux2to1 is 
port (
	mux_data1_i    : in std_logic_vector(7 downto 0);
	mux_data2_i    : in std_logic_vector(7 downto 0);
	mux2_sel_i     : in std_logic;

	mux_data_o     : out std_logic_vector(7 downto 0)
);
end mux2to1;

architecture Behavioral of mux2to1 is


begin
	--solucao simples, mas nao mantem a saida se mudar todas as entradas (nao eh register)
	with mux2_sel_i select
	mux_data_o <= mux_data1_i when '0',
                 mux_data2_i when others;

end Behavioral;



