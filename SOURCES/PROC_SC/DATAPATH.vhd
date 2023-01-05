---------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
---------------------------------------------------------------------------------
ENTITY DATAPATH IS
	PORT ( 
		CLK				: IN STD_LOGIC;
		RST 			: IN STD_LOGIC;
		PC_LdEn 		: IN STD_LOGIC;
		PC_sel			: IN STD_LOGIC;
		RF_WrEn			: IN STD_LOGIC;
		RF_WrData_sel	: IN STD_LOGIC;
		RF_A_sel		: IN STD_LOGIC;
		RF_B_sel		: IN STD_LOGIC;
		Immed_ctrl		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALU_Bin_sel 	: IN STD_LOGIC;
		Op				: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		ByteOp			: IN STD_LOGIC;
		MEM_WrEn		: IN STD_LOGIC;
		ALU_zero		: OUT STD_LOGIC;
		Instr			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);		--connect with ram
		MM_RdData 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);		--connect with ram
		MM_Addr 		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	--connect with ram
		MM_WrEn 		: OUT STD_LOGIC;						--connect with ram
		MM_WrData 		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	--connect with ram
		PC				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)		--connect with ram
	);
END DATAPATH;
---------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF DATAPATH IS

	COMPONENT IFSTAGE
	PORT (
		PC_Immed	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC_sel		: IN STD_LOGIC;
		PC_LdEn		: IN STD_LOGIC;
		Reset		: IN STD_LOGIC;
		Clk			: IN STD_LOGIC;
		PC			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT DECSTAGE
	PORT (
		Clk				: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		Instr			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		RF_WrEn			: IN STD_LOGIC;
		ALU_out			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		MEM_out			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		RF_WrData_sel	: IN STD_LOGIC;
		RF_A_sel		: IN STD_LOGIC;
		RF_B_sel		: IN STD_LOGIC;
		Immed_ctrl		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		Immed			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		RF_A			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		RF_B			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT EXSTAGE
	PORT (
		RF_A		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		RF_B		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Immed		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_Bin_sel	: IN STD_LOGIC;
		Op			: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		ALU_out		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_zero	: OUT STD_LOGIC
	);
    END COMPONENT;
	
	COMPONENT MEMSTAGE
	PORT (
		ByteOp			: IN STD_LOGIC;
		MEM_WrEn		: IN STD_LOGIC;
		ALU_MEM_Addr	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		MEM_DataIn		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		MEM_DataOut		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		MM_Addr			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		MM_WrEn			: OUT STD_LOGIC;
		MM_WrData		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		MM_RdData		: IN STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	END COMPONENT;
	
	SIGNAL RF_A_internal			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RF_B_internal			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Immed_internal			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_internal			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEM_out_internal			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
BEGIN
	
	ifstage_inst : IFSTAGE
	PORT MAP (
		PC_Immed		=> Immed_internal, --apo to decode
		PC_sel			=> PC_sel,
		PC_LdEn			=> PC_LdEn,
		Reset			=> RST,
		Clk				=> CLK,
		PC				=> PC
	);
	
	decstage_inst : DECSTAGE
	PORT MAP (
		Clk				=> CLK,
		RST				=> RST,
		Instr			=> Instr,
		RF_WrEn			=> RF_WrEn,
		ALU_out			=> ALU_out_internal, --me thn exodo ths alu
		MEM_out			=> MEM_out_internal, --me to MEM_DataOut tou MEMSTAGE
		RF_WrData_sel	=> RF_WrData_sel,
		RF_A_sel		=> RF_A_sel,
		RF_B_sel		=> RF_B_sel,
		Immed_ctrl		=> Immed_ctrl,
		Immed			=> Immed_internal, --apo to decode
		RF_A			=> RF_A_internal,
		RF_B			=> RF_B_internal
	);
	
	exstage_inst : EXSTAGE
	PORT MAP (
		RF_A			=> RF_A_internal,
		RF_B			=> RF_B_internal,
		Immed			=> Immed_internal,
		ALU_Bin_sel		=> ALU_Bin_sel,
		Op				=> Op,
		ALU_out			=> ALU_out_internal, --mia eisodos sto dec kai mia sto mem
		ALU_zero		=> ALU_zero
	);
	
	memstage_inst : MEMSTAGE
	PORT MAP (
		ByteOp			=> ByteOp,
		MEM_WrEn		=> MEM_WrEn,
		ALU_MEM_Addr	=> ALU_out_internal,
		MEM_DataIn		=> RF_B_internal,
		MEM_DataOut		=> MEM_out_internal,
		MM_Addr			=> MM_Addr,
		MM_WrEn			=> MM_WrEn,
		MM_WrData		=> MM_WrData,
		MM_RdData		=> MM_RdData
	);
	
end Behavioral;
---------------------------------------------------------------------------------