-- Author: Ronaldo Dall'Agnol Veiga
-- UFRGS - Instituto de Informática
-- Sistemas Digitais
-- Profa. Dra. Fernanda Gusmão de Lima Kastensmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ramses is
    Port ( clk_in : IN  std_logic;
         rst_in : IN  std_logic;
         enable_ramses : IN  std_logic;
         debug_out : OUT  std_logic);
end ramses;

architecture Behavioral of ramses is

component PC_register is 
port (

	clk_in        : in std_logic;
	rst_in        : in std_logic;
	
	cargaPC_i    : in std_logic;
	incPC_i      : in std_logic;
	pc_data_i    : in std_logic_vector(7 downto 0);
	pc_data_o    : out std_logic_vector(7 downto 0)
);
end component;

component control_unit is
    Port ( 	clk_in		: in STD_LOGIC;
			rst_in		: in STD_LOGIC;
			enable_ramses : in STD_LOGIC;
			--NZC 		: in  STD_LOGIC_VECTOR (2 downto 0);
			N		: in STD_LOGIC;
			Z		: in STD_LOGIC;
			C		: in STD_LOGIC;
			decod_instr : in  STD_LOGIC_VECTOR (3 downto 0);
			reg_type 	: in  STD_LOGIC_VECTOR (1 downto 0);
			address_mode: in  STD_LOGIC_VECTOR (1 downto 0);
			--outputs--

			--seletor de operacao
			sel_ula		: out STD_LOGIC_VECTOR(3 downto 0);

			--carga dos regs
			loadRX		: out STD_LOGIC;
			loadRA		: out STD_LOGIC;
			loadRB		: out STD_LOGIC;
			loadPC		: out STD_LOGIC;
			loadREM		: out STD_LOGIC;
			loadRDM		: out STD_LOGIC;
			--loadNZC		: out STD_LOGIC_VECTOR(2 downto 0);
			loadN		: out STD_LOGIC;
			loadZ		: out STD_LOGIC;
			loadC		: out STD_LOGIC;
			loadRI 		: out STD_LOGIC;
	
			--write da mem (nao tem read_en)
			wr_enable_mem : out STD_LOGIC_VECTOR (0 downto 0);
	
			--seletor de mux da arq do livro
			s1s2 		: out STD_LOGIC_VECTOR(1 downto 0);
			s3s4 		: out STD_LOGIC_VECTOR(1 downto 0);
			s5 			: out STD_LOGIC;
	
			-- incremento do PC
			PC_inc 		: out STD_LOGIC;
	
			-- seletor do mux2to1 extra para RDM
			sel_mux_RDM : out STD_LOGIC;
			stop			: out STD_LOGIC
			  );
end component;

component decoder is
    Port ( instruction_in : in  STD_LOGIC_VECTOR (7 downto 0);
           decod_instr : out  STD_LOGIC_VECTOR(3 downto 0);
           reg_type : out  STD_LOGIC_VECTOR(1 downto 0);
           address_mode : out  STD_LOGIC_VECTOR(1 downto 0)
			  );
end component;

component memoria is 
port (
		addra : in STD_LOGIC_VECTOR (7 downto 0);
		clka	: in STD_LOGIC;
		dina	: in STD_LOGIC_VECTOR (7 downto 0);
		douta : out STD_LOGIC_VECTOR (7 downto 0);
		wea	: in STD_LOGIC_VECTOR (0 downto 0)
);
end component;

component mux2to1 is 
port (
	mux_data1_i    : in std_logic_vector(7 downto 0);
	mux_data2_i    : in std_logic_vector(7 downto 0);
	mux2_sel_i     : in std_logic;

	mux_data_o     : out std_logic_vector(7 downto 0)
);
end component;

component reg1bit is
    Port ( 	data_in : in  STD_LOGIC;
			clk_in	: in  STD_LOGIC;
			rst_in	: in  STD_LOGIC;
			load	: in  STD_LOGIC;
			data_out : out  STD_LOGIC
			  );
end component;

component reg8bits is
    Port ( 	data_in : in  STD_LOGIC_VECTOR (7 downto 0);
			clk_in	: in  STD_LOGIC;
			rst_in	: in  STD_LOGIC;
			load	: in  STD_LOGIC;
			data_out : out  STD_LOGIC_VECTOR (7 downto 0)
			  );
end component;

component ula is
    Port ( X : in  STD_LOGIC_VECTOR (7 downto 0);
           Y : in  STD_LOGIC_VECTOR (7 downto 0);
           sel_ula : in  STD_LOGIC_VECTOR (3 downto 0);
           --NZC : out  STD_LOGIC_VECTOR (2 downto 0);
		   N 	: out STD_LOGIC;
		   Z	: out STD_LOGIC;
		   C	: out STD_LOGIC;
			  ula_output : out STD_LOGIC_VECTOR (7 downto 0)
			  );
end component;

--sinais

	signal loadRA_s 	: STD_LOGIC;
	signal loadRB_s 	: STD_LOGIC;
	signal loadRX_s 	: STD_LOGIC;
	signal loadPC_s 	: STD_LOGIC;
	signal loadRDM_s 	: STD_LOGIC;
	signal loadREM_s 	: STD_LOGIC;
	signal loadRI_s 	: STD_LOGIC;
	signal PC_inc_s 	: STD_LOGIC;
	
	signal RAdata_out_s	: STD_LOGIC_VECTOR (7 downto 0);
	signal RBdata_out_s	: STD_LOGIC_VECTOR (7 downto 0);
	signal RXdata_out_s	: STD_LOGIC_VECTOR (7 downto 0);
	
	signal REMdata_in_s	: STD_LOGIC_VECTOR (7 downto 0);
	signal REMdata_out_s : STD_LOGIC_VECTOR (7 downto 0);
	
	signal RDMdata_in_s	: STD_LOGIC_VECTOR (7 downto 0);
	signal RDMdata_out_s : STD_LOGIC_VECTOR (7 downto 0);
	
	signal PCdata_in_s	: STD_LOGIC_VECTOR (7 downto 0);
	signal PCdata_out_s	: STD_LOGIC_VECTOR (7 downto 0);
	
	signal N_reg_s : STD_LOGIC; -- saem do registrador e vo pra unidade de controle
	signal Z_reg_s : STD_LOGIC;
	signal C_reg_s : STD_LOGIC;
	
	signal N_s : STD_LOGIC; -- saem da ula e vo pro registrador de flag
	signal Z_s : STD_LOGIC;
	signal C_s : STD_LOGIC;
	
	signal loadN_s :STD_LOGIC;
	signal loadZ_s :STD_LOGIC;
	signal loadC_s :STD_LOGIC;
	
	signal decod_instr_s 	: STD_LOGIC_VECTOR (3 downto 0);
	signal instruction_s		: STD_LOGIC_VECTOR (7 downto 0);
	signal reg_type_s 		: STD_LOGIC_VECTOR (1 downto 0);
	signal address_mode_s 	: STD_LOGIC_VECTOR (1 downto 0);

	signal wr_enable_mem_s 	: STD_LOGIC_VECTOR (0 downto 0);
	
	signal s1s2_s 				: STD_LOGIC_VECTOR(1 downto 0);
	signal s3s4_s 				: STD_LOGIC_VECTOR(1 downto 0);
	signal s5_s 				: STD_LOGIC;

	signal sel_mux_RDM_s 	: STD_LOGIC;
	
	signal X_s					: STD_LOGIC_VECTOR (7 downto 0);
	signal sel_ula_s			: STD_LOGIC_VECTOR (3 downto 0);
	signal ula_output_s		: STD_LOGIC_VECTOR (7 downto 0);
	
	signal MEMdata_out_s		: STD_LOGIC_VECTOR (7 downto 0);

	signal stop_s				: STD_LOGIC;
begin

	control_unit_0 : control_unit
   Port map ( 	
			clk_in			=> clk_in,
			rst_in			=> rst_in,
			enable_ramses 	=> enable_ramses,
			--NZC 		: in  STD_LOGIC_VECTOR (2 downto 0);
			N					=> N_reg_s,
			Z					=> Z_reg_s,
			C					=> C_reg_s,
			decod_instr 	=> decod_instr_s,
			reg_type 		=> reg_type_s,
			address_mode	=> address_mode_s,
			--outputs--

			--seletor de operacao
			sel_ula			=> sel_ula_s,

			--carga dos regs
			loadRX			=> loadRX_s,
			loadRA			=> loadRA_s,
			loadRB			=> loadRB_s,
			loadPC			=> loadPC_s,
			loadREM			=> loadREM_s,
			loadRDM			=> loadRDM_s,
			--loadNZC		: out STD_LOGIC_VECTOR(2 downto 0);
			loadN				=> loadN_s,
			loadZ				=> loadZ_s,
			loadC				=> loadC_s,
			loadRI 			=> loadRI_s,
	
			--write da mem (nao tem read_en)
			wr_enable_mem => wr_enable_mem_s,
	
			--seletor de mux da arq do livro
			s1s2 		=> s1s2_s,
			s3s4 		=> s3s4_s,
			s5 		=> s5_s,
	
			-- incremento do PC
			PC_inc 		=> PC_inc_s,
	
			-- seletor do mux2to1 extra para RDM
			sel_mux_RDM => sel_mux_RDM_s,
			stop	=> stop_s
			  );
			  
	
	N_flag : reg1bit
	Port map (
		 	data_in 	=> N_s,
			clk_in	=> clk_in,
			rst_in	=> rst_in,
			load		=> loadN_s,
			data_out => N_reg_s
			  );
			  
	Z_flag : reg1bit
	Port map (
		 	data_in 	=> Z_s,
			clk_in	=> clk_in,
			rst_in	=> rst_in,
			load		=> loadN_s,
			data_out => Z_reg_s
			  );
	
	decoder_0 : decoder
	Port map (
				instruction_in => instruction_s,
				decod_instr 	=> decod_instr_s,
				reg_type 		=> reg_type_s,
				address_mode 	=> address_mode_s
			  );
			  
	ula_0 : ula
	Port map (
					X => X_s,
					Y => RDMdata_out_s,
					sel_ula => sel_ula_s,
					N 	=> N_s,
					Z	=> Z_s,
					C	=> C_s,
					ula_output => ula_output_s
			  );

	REM_0 : reg8bits
    port map (
				data_in	=> REMdata_in_s,
				clk_in	=> clk_in,
				rst_in	=> rst_in,
				load		=> loadREM_s,
				data_out	=> REMdata_out_s					
				);

	RDM_0 : reg8bits
    port map (
				data_in	=> RDMdata_in_s,
				clk_in	=> clk_in,
				rst_in	=> rst_in,
				load		=> loadRDM_s,
				data_out	=> RDMdata_out_s					
				);

	RI_0 : reg8bits
    port map (
				data_in	=> RDMdata_out_s,
				clk_in	=> clk_in,
				rst_in	=> rst_in,
				load		=> loadRI_s,
				data_out	=> instruction_s			
				);
				
	PC_0 : PC_register
    port map (
				clk_in		=> clk_in,
				rst_in		=> rst_in,
				cargaPC_i	=> loadPC_s,
				incPC_i		=> PC_inc_s,
				pc_data_i	=> PCdata_in_s,	
				pc_data_o	=> PCdata_out_s					
				);
					
	mux_s5 : mux2to1
    port map (
				mux_data1_i	=> ula_output_s,
				mux_data2_i	=> REMdata_out_s,
				mux2_sel_i	=> s5_s,	
				mux_data_o	=> PCdata_in_s					
	);

	mux_RDM : mux2to1 --mux extra para selecionar entrada no RDM
    port map (
				mux_data1_i	=> MEMdata_out_s,
				mux_data2_i	=> X_s,
				mux2_sel_i	=> sel_mux_RDM_s,	
				mux_data_o	=> RDMdata_in_s
				);
				
	memoriaRamses : memoria
	port map (
				addra => REMdata_out_s,
				clka => clk_in,
				dina => RDMdata_out_s,
				douta => MEMdata_out_s,
				wea => wr_enable_mem_s
				);
				
	debug_out <= stop_s;
end Behavioral;

