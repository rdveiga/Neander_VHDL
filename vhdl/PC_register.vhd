-- Author: Ronaldo Dall'Agnol Veiga
--			@roniveiga
-- UFRGS - Instituto de Informática
-- Sistemas Digitais
-- Profa. Dra. Fernanda Gusmão de Lima Kastensmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_register is 
port (

	clk_in        : in std_logic;
	rst_in        : in std_logic;
	
	cargaPC_i    : in std_logic;
	incPC_i      : in std_logic;
	pc_data_i    : in std_logic_vector(7 downto 0);
	pc_data_o    : out std_logic_vector(7 downto 0)
);
end PC_register;

architecture Behavioral of PC_register is 


begin
	process(clk_in, rst_in)
		variable pc_data_o_w : std_logic_vector(7 downto 0);  -- variavel auxiliar
      variable incPC_cont : integer;
	begin
		if (rst_in = '1') then	
			pc_data_o_w := "00000001";
         incPC_cont := 0;
		elsif (clk_in = '1' and clk_in'event) then
			if (cargaPC_i = '1') then
				pc_data_o_w := pc_data_i;
			elsif (incPC_i = '1') then
				 incPC_cont := incPC_cont + 1;
				 if incPC_cont = 2 then
						pc_data_o_w := std_logic_vector(unsigned(pc_data_o_w) + 1);
						incPC_cont := 0;
				 end if;
			end if;
		end if;
		pc_data_o <= pc_data_o_w;
	end process;

end Behavioral;



