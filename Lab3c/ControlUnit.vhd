----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	ControlUnit
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: Control Unit for the basic MIPS processor
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: The interface (entity) as well as implementation (architecture) can be modified
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity ControlUnit is
    Port ( 	opcode 		: in   STD_LOGIC_VECTOR (5 downto 0);
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
				InstrtoReg	: out  STD_LOGIC;
				MemWrite		: out  STD_LOGIC;	
				ALUSrc 		: out  STD_LOGIC;	
				SignExtend 	: out  STD_LOGIC;
				RegWrite		: out  STD_LOGIC;	
				RegDst		: out  STD_LOGIC;
				HILORead    : out  STD_LOGIC_VECTOR (1 downto 0);
				HILOWrite   : out  STD_LOGIC;
				isShift  : out  STD_LOGIC);
end ControlUnit;


architecture arch_ControlUnit of ControlUnit is  
begin   

process(opcode, ALU_Funct, Rt_FirstBit) is
begin

ALUOp <= "00";
Branch <= '0';		
BGEZ  <= '0';     
AL  <= '0';       
Jump	<= '0'; 		
JR    <= '0';     
MemRead <= '0';	
MemtoReg <= '0';	
InstrtoReg <= '0';
MemWrite	<= '0';	
ALUSrc 	<= '0';	
SignExtend <= '0';
RegWrite	<= '0';	
RegDst	<= '0';	
HILORead   <= "00";
HILOWrite  <= '0'; 
isShift  <= '0';
	
case opcode is

	-- R type instructions
	when "000000" =>
		RegDst <= '1';
		MemtoReg <= '0';
		MemRead <= '0';
		MemWrite <= '0';
		Branch <= '0';
		Jump <= '0';
		JR <= '0';
		ALUOp <= "10";
		SignExtend <= '1';
		BGEZ <= '0';
		InstrtoReg <= '0';
		AL <= '0';
		
		case ALU_Funct is
			when "000000" | "000010" | "000011" => -- sll, srl and sra 
				ALUSrc <= '1';
				isShift <= '1';
				RegWrite <= '1';
				
				HILOWrite <= '0';
				HILORead <= "00";
			when "000100" | "000110" | "000111" => -- sllv, srlva and srav
				ALUSrc <= '0';
				isShift <= '1';
				RegWrite <= '1';
				
				HILOWrite <= '0';
				HILORead <= "00";
			when "011000" | "011001" | "011010" | "011011" => -- mult, multu, div, divu
				ALUSrc <= '0';
				isShift <= '0';
				RegWrite <= '0';
				HILOWrite <= '1';
				HILORead <= "00";
			when "010000" => -- MFHI
				ALUSrc <= '0';
				RegWrite <= '1';
				isShift <= '0';
				
				HILORead <= "10";
				HILOWrite <= '0';
			when "010010" => --MFLO
				ALUSrc <= '0';
				RegWrite <= '1';
				isShift <= '0';
				
				HILORead <= "01";
				HILOWrite <= '0';
			
			when others => 
				ALUSrc <= '0';
				HILOWrite <= '0';
				HILORead <= "00";
				isShift <= '0';
				RegWrite <= '1';
		end case;

	-- lw
	when "100011" => 
		RegDst <= '0';
		ALUSrc <= '1';
		MemtoReg <= '1';
		RegWrite <= '1';
		MemRead <= '1';
		MemWrite <= '0';
		Branch <= '0';
		BGEZ <= '0';
		Jump <= '0';
		JR <= '0';
		ALUOp <= "00";
		SignExtend <= '1';
		InstrtoReg <= '0';
		HILORead <= "00";
		HILOWrite <= '0';
		isShift <= '0';
		AL <= '0';

	-- sw
	when "101011" => 
		RegDst <= '0'; -- doesnt matter
		ALUSrc <= '1';
		MemtoReg <= '0'; -- doesnt matter
		RegWrite <= '0';
		MemRead <= '0';
		MemWrite <= '1';
		Branch <= '0';
		BGEZ <= '0';
		Jump <= '0';
		JR <= '0';
		ALUOp <= "00";
		SignExtend <= '1';
		InstrtoReg <= '0';
		HILORead <= "00";
		HILOWrite <= '0';
		isShift <= '0';
		AL <= '0';
	
	-- beq
	when "000100" => 
		RegDst <= '0'; -- doesnt matter
		ALUSrc <= '0';
		RegWrite <= '0';
		MemtoReg <= '0'; -- doesnt matter
		MemRead <= '0';
		MemWrite <= '0';
		Branch <= '1';
		Jump <= '0';
		JR <= '0';
		BGEZ <= '0';
		ALUOp <= "01";
		SignExtend <= '1';
		InstrtoReg <= '0';
		HILORead <= "00";
		HILOWrite <= '0';
		isShift <= '0';
		AL <= '0';
		
	-- bgez
	when "000001" =>
		RegDst <= '0'; -- doesnt matter
		ALUSrc <= '0';
		MemtoReg <= '0'; -- doesnt matter
		MemRead <= '0';
		MemWrite <= '0';
		Branch <= '0';
		BGEZ <= '1';
		Jump <= '0';
		JR <= '0';
		ALUOp <= "01";
		SignExtend <= '1';
		InstrtoReg <= '0';
		HILORead <= "00";
		HILOWrite <= '0';
		isShift <= '0';
		
		RegWrite <= Rt_FirstBit;
		AL <= Rt_FirstBit;

	-- jump
	when "000010" =>
		RegDst <= '0';
		ALUSrc <= '0';
		RegWrite <= '0';
		MemtoReg <= '0'; -- doesnt matter
		MemRead <= '0';
		MemWrite <= '0';
		Branch <= '0';
		BGEZ <= '0';
		Jump <= '1';
		JR <= '0';
		ALUOp <= "01";
		SignExtend <= '1';
		InstrtoReg <= '0';
		HILORead <= "00";
		HILOWrite <= '0';
		isShift <= '0';
		AL <= '0';
		
	-- jal
	when "000011" =>
		RegDst <= '0';
		ALUSrc <= '0';
		RegWrite <= '0';
		MemtoReg <= '0'; -- doesnt matter
		MemRead <= '0';
		MemWrite <= '0';
		Branch <= '0';
		BGEZ <= '0';
		Jump <= '1';
		JR <= '0';
		ALUOp <= "01";
		SignExtend <= '1';
		InstrtoReg <= '0';
		HILORead <= "00";
		HILOWrite <= '0';
		isShift <= '0';
		AL <= '1';
		
	-- ori, addi, slti
	when "001101" | "001000" | "001010" => 
		RegDst <= '0';
		ALUSrc <= '1';
		MemtoReg <= '0';
		RegWrite <= '1';
		MemRead <= '0';
		MemWrite <= '0';
		Branch <= '0';
		Jump <= '0';
		JR <= '0';
		BGEZ <= '0';
		ALUOp <= "11";
		SignExtend <= '0';
		InstrtoReg <= '0';
		HILORead <= "00";
		HILOWrite <= '0';
		isShift <= '0';
		AL <= '0';
	
	-- lui	
	when "001111" =>
		RegDst <= '0';
		ALUSrc <= '1';
		MemtoReg <= '0';
		RegWrite <= '1';
		MemRead <= '0';
		MemWrite <= '0';
		Branch <= '0';
		Jump <= '0';
		JR <= '0';
		BGEZ <= '0';
		ALUOp <= "00";
		SignExtend <= '1';
		InstrtoReg <= '1';
		HILORead <= "00";
		HILOWrite <= '0';			
		isShift <= '0';
		AL <= '0';
		
	when others => null;
	
end case;

end process;

end arch_ControlUnit;

