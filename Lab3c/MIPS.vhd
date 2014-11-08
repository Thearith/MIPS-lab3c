----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	MIPS
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: MIPS processor
--
-- Dependencies: PC, ALU, ControlUnit, RegFile
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: DO NOT modify the interface (entity). Implementation (architecture) can be modified.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity MIPS is -- DO NOT modify the interface (entity)
    Port ( 	
			Addr_Instr 		: out STD_LOGIC_VECTOR (31 downto 0);
			Instr 			: in STD_LOGIC_VECTOR (31 downto 0);
			Addr_Data		: out STD_LOGIC_VECTOR (31 downto 0);
			Data_In			: in STD_LOGIC_VECTOR (31 downto 0);
			Data_Out			: out  STD_LOGIC_VECTOR (31 downto 0);
			MemRead 			: out STD_LOGIC; 
			MemWrite 		: out STD_LOGIC; 
			RESET				: in STD_LOGIC;
			CLK				: in STD_LOGIC
			);
end MIPS;


architecture arch_MIPS of MIPS is

----------------------------------------------------------------
-- Program Counter
----------------------------------------------------------------
component PC is
	Port(	
			PC_in 	    : in STD_LOGIC_VECTOR (31 downto 0);
			PC_out 	    : out STD_LOGIC_VECTOR (31 downto 0);
			Busy_Status  : in  STD_LOGIC;
			RESET		    : in STD_LOGIC;
			CLK		    : in STD_LOGIC);
end component;

----------------------------------------------------------------
-- ALU
----------------------------------------------------------------
component ALU is
    Port ( 
			CLK            : in STD_LOGIC;
			Control		: in	STD_LOGIC_VECTOR (5 downto 0);
			Operand1		: in	STD_LOGIC_VECTOR (31 downto 0);
			Operand2		: in	STD_LOGIC_VECTOR (31 downto 0);
			Result1		: out	STD_LOGIC_VECTOR (31 downto 0);
			Result2		: out	STD_LOGIC_VECTOR (31 downto 0);
			Status		: out	STD_LOGIC_VECTOR (3 downto 0); -- negative (sub), busy (multicycle only), overflow (add and sub), zero (sub)
			Debug			: out	STD_LOGIC_VECTOR (31 downto 0));
end component;

----------------------------------------------------------------
-- Control Unit
----------------------------------------------------------------
component ControlUnit is
    Port ( 	
			opcode 		: in   STD_LOGIC_VECTOR (5 downto 0);
			ALU_Funct   : in   STD_LOGIC_VECTOR (5 downto 0);
			Rt_FirstBit : in   STD_LOGIC;
			ALUOp 		: out  STD_LOGIC_VECTOR (1 downto 0);
			Branch 		: out  STD_LOGIC;
			BGEZ        : out  STD_LOGIC;
			AL          : out  STD_LOGIC;
			Jump	 		: out  STD_LOGIC;
			JR          : out  STD_LOGIC;
			MemRead 		: out  STD_LOGIC;	
			MemtoReg 	: out  STD_LOGIC;	
			InstrtoReg	: out  STD_LOGIC; -- true for LUI. When true, Instr(15 downto 0)&x"0000" is written to rt
			MemWrite		: out  STD_LOGIC;	
			ALUSrc 		: out  STD_LOGIC; 
			SignExtend 	: out  STD_LOGIC; -- false for ORI 
			RegWrite		: out  STD_LOGIC;	
			RegDst		: out  STD_LOGIC;
			HILORead    : out  STD_LOGIC_VECTOR (1 downto 0);
			HILOWrite   : out  STD_LOGIC;
			isShift  : out  STD_LOGIC);
end component;

----------------------------------------------------------------
-- Register File
----------------------------------------------------------------
component RegFile is
    Port ( 	
			ReadAddr1_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
			ReadAddr2_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
			ReadData1_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);
			ReadData2_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);				
			WriteAddr_Reg	: in  STD_LOGIC_VECTOR (4 downto 0); 
			WriteData_Reg 	: in STD_LOGIC_VECTOR (31 downto 0);
			RegWrite 		: in STD_LOGIC; 
			CLK 				: in  STD_LOGIC);
end component;

----------------------------------------------------------------
-- HILO Registers
----------------------------------------------------------------
component HILO is
	Port (
		CLK			: in	STD_LOGIC;
		HILORead    : in  STD_LOGIC_VECTOR(1 downto 0);
		HILOWrite   : in  STD_LOGIC;
		HI_In       : in  STD_LOGIC_VECTOR(31 downto 0);
		LO_In       : in  STD_LOGIC_VECTOR(31 downto 0);
 		HILO_Out    : out STD_LOGIC_VECTOR(31 downto 0));
end component;

----------------------------------------------------------------
-- PC Signals
----------------------------------------------------------------
	signal	PC_in 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal   Busy_Status :  STD_LOGIC;
	signal	PC_out 		:  STD_LOGIC_VECTOR (31 downto 0);

----------------------------------------------------------------
-- ALU Signals
----------------------------------------------------------------
	signal	ALU_InA   		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_InB 	    	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_OutA 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_OutB 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_Control	   :  STD_LOGIC_VECTOR (5 downto 0);
	signal	ALU_Status		:  STD_LOGIC_VECTOR (3 downto 0);			
	signal   ALU_Debug      :  STD_LOGIC_VECTOR (31 downto 0);

----------------------------------------------------------------
-- Control Unit Signals
----------------------------------------------------------------				
 	signal	opcode 		:  STD_LOGIC_VECTOR (5 downto 0);
	signal   ALU_Funct   :  STD_LOGIC_VECTOR (5 downto 0);
	signal   Rt_FirstBit :  STD_LOGIC;
	signal	ALUOp 		:  STD_LOGIC_VECTOR (1 downto 0);
	signal	Branch 		:  STD_LOGIC;
	signal   BGEZ        :  STD_LOGIC;
	signal   AL          :  STD_LOGIC;
	signal	Jump	 		:  STD_LOGIC;
	signal   JR          :  STD_LOGIC;
	signal	MemtoReg 	:  STD_LOGIC;
	signal 	InstrtoReg	: 	STD_LOGIC;		
	signal	ALUSrc 		:  STD_LOGIC;	
	signal	SignExtend 	: 	STD_LOGIC;
	signal	RegWrite		: 	STD_LOGIC;	
	signal	RegDst		:  STD_LOGIC;
	signal   HILORead    :  STD_LOGIC_VECTOR (1 downto 0);
	signal   HILOWrite   :  STD_LOGIC;
	signal   isShift  :  STD_LOGIC;

----------------------------------------------------------------
-- Register File Signals
----------------------------------------------------------------
 	signal	ReadAddr1_Reg 	:  STD_LOGIC_VECTOR (4 downto 0);
	signal	ReadAddr2_Reg 	:  STD_LOGIC_VECTOR (4 downto 0);
	signal	ReadData1_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ReadData2_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	WriteAddr_Reg	:  STD_LOGIC_VECTOR (4 downto 0); 
	signal	WriteData_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	
----------------------------------------------------------------
-- HILO Signals
----------------------------------------------------------------

	signal   HI_In          :  STD_LOGIC_VECTOR(31 downto 0);
	signal   LO_In          :  STD_LOGIC_VECTOR(31 downto 0);
 	signal 	HILO_Out       :  STD_LOGIC_VECTOR(31 downto 0);

----------------------------------------------------------------
-- Decode Signals
---------------------------------------------------------------- 
	signal ImmData        : STD_LOGIC_VECTOR (31 downto 0);
	signal PC_temp        : STD_LOGIC_VECTOR (31 downto 0);
	signal PC_next        : STD_LOGIC_VECTOR (31 downto 0);

----------------------------------------------------------------	
----------------------------------------------------------------
-- <MIPS architecture>
----------------------------------------------------------------
----------------------------------------------------------------
begin

----------------------------------------------------------------
-- PC port map
----------------------------------------------------------------
PC1				: PC port map
						(
						PC_in 	=> PC_in, 
						PC_out 	=> PC_out,
						Busy_Status => Busy_Status,
						RESET 	=> RESET,
						CLK 		=> CLK
						);
						
----------------------------------------------------------------
-- ALU port map
----------------------------------------------------------------
ALU1 				: ALU port map
						(
						CLK            => CLK,
						Control        => ALU_Control,
						Operand1 		=> ALU_InA, 
						Operand2 		=> ALU_InB, 
						Result1 			=> ALU_OutA, 
						Result2 			=> ALU_OutB, 
						Status  			=> ALU_Status,
						Debug      		=> ALU_Debug
						);
						
----------------------------------------------------------------
-- ControlUnit port map
----------------------------------------------------------------
ControlUnit1 	: ControlUnit port map
						(
						opcode 		=> opcode,
                  ALU_Funct   => ALU_Funct,
						Rt_FirstBit => Rt_FirstBit,
						ALUOp 		=> ALUOp, 
						Branch 		=> Branch, 
						BGEZ        => BGEZ,
						AL          => AL,
						Jump 			=> Jump, 
						JR          => JR,
						MemRead 		=> MemRead, 
						MemtoReg 	=> MemtoReg, 
						InstrtoReg 	=> InstrtoReg, 
						MemWrite 	=> MemWrite, 
						ALUSrc 		=> ALUSrc, 
						SignExtend 	=> SignExtend, 
						RegWrite 	=> RegWrite, 
						RegDst 		=> RegDst,
						HILORead    => HILORead,
						HILOWrite   => HILOWrite,
						isShift  => isShift
						);
						
----------------------------------------------------------------
-- Register file port map
----------------------------------------------------------------
RegFile1			: RegFile port map
						(
						ReadAddr1_Reg 	=>  ReadAddr1_Reg,
						ReadAddr2_Reg 	=>  ReadAddr2_Reg,
						ReadData1_Reg 	=>  ReadData1_Reg,
						ReadData2_Reg 	=>  ReadData2_Reg,
						WriteAddr_Reg 	=>  WriteAddr_Reg,
						WriteData_Reg 	=>  WriteData_Reg,
						RegWrite 		=> RegWrite,
						CLK 				=> CLK				
						);
						
----------------------------------------------------------------
-- Register file port map
----------------------------------------------------------------

HILO1           : HILO   port map
						(
						CLK			   =>   CLK,
						HILORead       =>   HILORead,
						HILOWrite      =>   HILOWrite,
						HI_In          =>   HI_In,
						LO_In          =>   LO_In,
						HILO_Out       =>   HILO_Out
						);

----------------------------------------------------------------
-- Processor logic
----------------------------------------------------------------

-- fetch instruction stage
Addr_Instr <= PC_out;
PC_next <= PC_out + X"00000004";

-- Decode stage
opcode <= Instr(31 downto 26); -- Updating Control Unit
ALU_Funct <= Instr(5 downto 0); -- Updating ALU Function
Rt_FirstBit <= Instr(20); -- for bgez and bgezal

ImmData <= "000000000000000000000000000" & Instr(10 downto 6) when isShift = '1'  else
           Instr(15 downto 0) & "0000000000000000" when InstrtoReg = '1' else
			  "0000000000000000" & Instr(15 downto 0) when Instr(15) = '0' or SignExtend = '0' else
           "1111111111111111" & Instr(15 downto 0);

-- Reading from registers
ReadAddr1_Reg <= Instr(25 downto 21) when isShift = '0' else
					  Instr(20 downto 16);
ReadAddr2_Reg <= "00000"             when BGEZ = '1' else
					  Instr(20 downto 16) when isShift = '0' else
					  Instr(25 downto 21);

WriteAddr_Reg <= "11111"           when AL = '1' else
					  Instr(20 downto 16) when RegDst = '0' else
				     Instr(15 downto 11);
	
-- Executing stage
ALU_InA <= ReadData1_Reg when InstrtoReg = '0' else
			  X"00000000";
ALU_InB <= ReadData2_Reg when ALUSrc = '0' else
	        ImmData;

-- changing ALU Control
with ALUOp select
ALU_Control <= Instr(5 downto 0)   when "10",          -- r type instructions
	            "100000"            when "00",          -- sw/ lw uses alu.add
			      "100010"            when "01",          -- beq/bgez/bgezal uses alu.sub
					Instr(31 downto 26) when others;        -- all immediate uses their opcode

-- calling for MemRead
Addr_Data <= ALU_OutA;

-- Updating data out					  
Data_out <= ReadData2_Reg;

-- HILO_Out is read when HILORead signal is updated
-- calling for RegWrite
WriteData_Reg <= PC_out + X"00000008"  when AL = '1' else -- And link instr, send PC + 8 to register 31
					  HILO_Out when HILORead = "10" or HILORead = "01" else -- MFHI or MFLO 
					  ALU_OutA when MemToReg = '0'  else -- ALU use HILOWrite to prevent writing mult/div results to general reg
				     Data_in;
					  
-- calling to write in HILO registers
HI_In <= ALU_OutB;
LO_In <= ALU_OutA;

-- updating PC
PC_temp <= PC_next(31 downto 28) & Instr(25 downto 0) & "00" when Jump = '1' else -- jump
			  ReadData1_Reg  when JR = '1' else -- JR
		    (ImmData(29 downto 0) & "00") +  PC_next when ((Branch = '1' and ALU_Status(0) = '1') or (BGEZ = '1' and ALU_Status(3) = '0')) else -- beq, bgez
		     PC_next;

PC_in <= PC_temp;
Busy_Status <= ALU_Status(2); -- get busy status to check if alu has completed its process

end arch_MIPS;

----------------------------------------------------------------	
----------------------------------------------------------------
-- </MIPS architecture>
----------------------------------------------------------------
----------------------------------------------------------------	
