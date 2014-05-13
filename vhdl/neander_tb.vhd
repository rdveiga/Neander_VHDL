LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY ramses_tb IS
END ramses_tb;
 
ARCHITECTURE behavior OF ramses_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ramses
    PORT(
         clk_in : IN  std_logic;
         rst_in : IN  std_logic;
         enable_ramses : IN  std_logic;
         debug_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal rst_in : std_logic := '0';
   signal enable_ramses : std_logic := '0';


 	--Outputs
   signal debug_out : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ramses PORT MAP (
          clk_in => clk_in,
          rst_in => rst_in,
          enable_ramses => enable_ramses,
          debug_out => debug_out
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clock_period/2;
		clk_in <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 10us.
      rst_in <= '1';
		enable_ramses <= '0';
      wait for clock_period*5;	
        rst_in <= '0';
		  wait for clock_period*5;
      wait until rising_edge(clk_in);
    	enable_ramses <= '1';
		--wait for clock_period*50;

      -- insert stimulus here

      wait;
   end process;

END;
