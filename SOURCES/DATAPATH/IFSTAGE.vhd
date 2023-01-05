-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
-------------------------------------------------------------------------------
ENTITY IFSTAGE IS
	PORT (
		PC_Immed : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		PC_sel   : IN STD_LOGIC;
		PC_LdEn  : IN STD_LOGIC;
		Reset    : IN STD_LOGIC;
		Clk      : IN STD_LOGIC;
		PC       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END IFSTAGE;
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF IFSTAGE IS

	COMPONENT REG
		PORT (
			CLK : IN STD_LOGIC; -- clock.
			RST : IN STD_LOGIC; -- async. clear.
			d   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			WE  : IN STD_LOGIC; -- load/enable.
			q   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- output
		);
	END COMPONENT;

	COMPONENT ADDER
		PORT (
			A      : IN std_logic_vector (31 DOWNTO 0);
			B      : IN std_logic_vector (31 DOWNTO 0);
			Output : OUT std_logic_vector (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT MUX_2x1
		PORT (
			Ctrl : IN STD_LOGIC;
			Din0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL output_adder_4     : std_logic_vector (31 DOWNTO 0);
	SIGNAL output_adder_immed : std_logic_vector (31 DOWNTO 0);
	SIGNAL PC_in              : std_logic_vector (31 DOWNTO 0);
	SIGNAL PC_out             : std_logic_vector (31 DOWNTO 0);

BEGIN

	pc_reg : REG
	PORT MAP (
		CLK => clk,
		RST => Reset,
		WE  => PC_LdEn,
		d   => PC_in,
		q   => PC_out
	);
	
	mux : MUX_2x1
	PORT MAP (
		ctrl => PC_Sel,
		Din0 => output_adder_4,
		Din1 => output_adder_immed,
		Dout => PC_in
	);
	
	adder_4 : ADDER
	PORT MAP (
		A      => PC_out,
		B      => x"00000004",
		Output => output_adder_4
	);
	
	adder_immed : ADDER
	PORT MAP (
		A      => PC_Immed,
		B      => output_adder_4,
		Output => output_adder_immed
	);

	PC <= PC_out;

END Behavioral;
-------------------------------------------------------------------------------