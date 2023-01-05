-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-------------------------------------------------------------------------------
ENTITY PROC_SC_TB IS
END PROC_SC_TB;
-------------------------------------------------------------------------------
ARCHITECTURE behavior OF PROC_SC_TB IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT PROC_SC
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC
	);
	END COMPONENT;
	
	--Inputs
	SIGNAL CLK : STD_LOGIC := '0';
	SIGNAL RST : STD_LOGIC := '0';
	
	-- Clock period definitions
	CONSTANT CLK_period : TIME := 100 ns;
	
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : PROC_SC PORT MAP (
		CLK => CLK,
		RST => RST
	);
	
	-- Clock process definitions
	CLK_process : PROCESS
	BEGIN
		CLK <= '0';
		WAIT FOR CLK_period/2;
		CLK <= '1';
		WAIT FOR CLK_period/2;
	END PROCESS;
	
	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		-- hold reset state for 100 ns.
		RST <= '0';
		WAIT FOR 300 ns;
		-- insert stimulus here
		RST <= '1';
		WAIT FOR CLK_period * 20;
		WAIT;
	END PROCESS;

END;
-------------------------------------------------------------------------------