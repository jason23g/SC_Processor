-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-------------------------------------------------------------------------------
ENTITY PROC_SC IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC
	);
END PROC_SC;
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF PROC_SC IS

	COMPONENT DATAPATH
	PORT (
		CLK				: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		PC_LdEn			: IN STD_LOGIC;
		PC_sel			: IN STD_LOGIC;
		RF_WrEn			: IN STD_LOGIC;
		RF_WrData_sel	: IN STD_LOGIC;
		RF_A_sel		: IN STD_LOGIC;
		RF_B_sel		: IN STD_LOGIC;
		Immed_ctrl		: IN STD_LOGIC_VECTOR(1 downto 0);
		ALU_Bin_sel		: IN STD_LOGIC;
		Op				: IN STD_LOGIC_VECTOR(3 downto 0);
		ByteOp			: IN STD_LOGIC;
		Mem_WrEn		: IN STD_LOGIC;
		ALU_zero		: OUT STD_LOGIC;
		Instr			: IN STD_LOGIC_VECTOR(31 downto 0);
		MM_RdData		: IN STD_LOGIC_VECTOR(31 downto 0);
		MM_Addr			: OUT STD_LOGIC_VECTOR(31 downto 0);
		MM_WrEn			: OUT STD_LOGIC;
		MM_WrData		: OUT STD_LOGIC_VECTOR(31 downto 0);
		PC				: OUT STD_LOGIC_VECTOR(31 downto 0)
	);
	END COMPONENT;
	
	COMPONENT RAM
	PORT (
         clk			: IN STD_LOGIC;
         inst_addr		: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
         inst_dout		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         data_we		: IN STD_LOGIC;
         data_addr		: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
         data_din		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         data_dout		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT ALU_CONTROL
	PORT (
		ALU_Op	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		func	: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		Op		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT CONTROL
    PORT (
         --CLK			: IN STD_LOGIC;
         --RST			: IN STD_LOGIC;
		 Opcode			: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
         ALU_Op			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         ALU_Bin_sel	: OUT STD_LOGIC;
		 RF_A_sel		: OUT STD_LOGIC;
         RF_B_sel		: OUT STD_LOGIC;
         MEM_WrEn		: OUT STD_LOGIC;
         RF_WrEn		: OUT STD_LOGIC;
         RF_WrData_sel	: OUT STD_LOGIC;
         BranchEq		: OUT STD_LOGIC;
         BranchNotEq	: OUT STD_LOGIC;
         Jump			: OUT STD_LOGIC;
         ByteOp			: OUT STD_LOGIC;
         Immed_ctrl		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 PC_LdEn		: OUT STD_LOGIC
	);
	END COMPONENT;
	
	SIGNAL PC_LdEn_internal			: STD_LOGIC;
	SIGNAL PC_sel_internal			: STD_LOGIC;
	SIGNAL RF_WrEn_internal			: STD_LOGIC;
	SIGNAL RF_WrData_sel_internal	: STD_LOGIC;
	SIGNAL RF_A_sel_internal		: STD_LOGIC;
	SIGNAL RF_B_sel_internal		: STD_LOGIC;
	SIGNAL Immed_ctrl_internal		: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ALU_Bin_sel_internal		: STD_LOGIC;
	SIGNAL Op_internal				: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL ALU_Op_internal			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL ByteOp_internal			: STD_LOGIC;
	SIGNAL Mem_WrEn_internal		: STD_LOGIC;
	SIGNAL Instr_internal			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MM_RdData_internal		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_zero_internal		: STD_LOGIC;
	SIGNAL MM_Addr_internal			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MM_WrEn_internal			: STD_LOGIC;
	SIGNAL MM_WrData_internal		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_internal				: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BranchEq_internal		: STD_LOGIC;
	SIGNAL BranchNotEq_internal		: STD_LOGIC;
	SIGNAL Jump_internal			: STD_LOGIC;
	
BEGIN
	
	datapath_inst : DATAPATH
	PORT MAP (
		CLK				=> CLK,--connects with top level
		RST				=> RST,--connects with top level
		PC_LdEn			=> PC_LdEn_internal,
		PC_sel			=> PC_sel_internal,
		RF_WrEn			=> RF_WrEn_internal,
		RF_WrData_sel	=> RF_WrData_sel_internal,
		RF_A_sel		=> RF_A_sel_internal,
		RF_B_sel		=> RF_B_sel_internal,
		Immed_ctrl		=> Immed_ctrl_internal,
		ALU_Bin_sel		=> ALU_Bin_sel_internal,
		Op				=> Op_internal,
		ByteOp			=> ByteOp_internal,
		Mem_WrEn		=> Mem_WrEn_internal,
		ALU_zero		=> ALU_zero_internal,
		Instr			=> Instr_internal,--comes from from the Ram, inst_dout
		MM_RdData		=> MM_RdData_internal,
		MM_Addr			=> MM_Addr_internal,
		MM_WrEn			=> MM_WrEn_internal,
		MM_WrData		=> MM_WrData_internal,
		PC				=> PC_internal
	);
	
	ram_inst : RAM
	PORT MAP (
		clk			=> CLK,--connects with top level
		inst_addr	=> PC_internal(12 DOWNTO 2),
		inst_dout	=> Instr_internal,
		data_we		=> MM_WrEn_internal,
		data_addr	=> MM_Addr_internal(12 DOWNTO 2),
		data_din	=> MM_WrData_internal,
		data_dout	=> MM_RdData_internal
	);
	
	control_inst : Control
	PORT MAP (
		--CLK				=> CLK,--connects with top level
		--RST				=> RST,--connects with top level
		Opcode			=> Instr_internal(31 DOWNTO 26),
		ALU_Op			=> ALU_Op_internal,
		ALU_Bin_sel		=> ALU_Bin_sel_internal,
		RF_A_sel		=> RF_A_sel_internal,
		RF_B_sel		=> RF_B_sel_internal,
		MEM_WrEn		=> MEM_WrEn_internal,
		RF_WrEn			=> RF_WrEn_internal,
		RF_WrData_sel	=> RF_WrData_sel_internal,
		BranchEq		=> BranchEq_internal,
		BranchNotEq		=> BranchNotEq_internal,
		Jump			=> Jump_internal,
		ByteOp			=> ByteOp_internal,
		Immed_ctrl		=> Immed_ctrl_internal,
		PC_LdEn			=> PC_LdEn_internal
	);
	
	alu_control_inst : ALU_CONTROL
	PORT MAP (
		ALU_Op	=> ALU_Op_internal,--input, comes from the FSM
		func	=> Instr_internal(5 DOWNTO 0),--input, comes from the instruction
		Op		=> Op_internal-- output, goes to the Datapath and more specifically to the ALU
	);
	
	PC_sel_internal <= Jump_internal OR (BranchEq_internal AND ALU_zero_internal) OR (BranchNotEq_internal AND (NOT ALU_zero_internal)) after 10 ns;

END Behavioral;
-------------------------------------------------------------------------------