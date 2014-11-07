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
				ALUOp 		: out  STD_LOGIC_VECTOR (1 downto 0);
				Branch 		: out  STD_LOGIC;	
				BGEZ        : out  STD_LOGIC;
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
				isShftAmnt  : out  STD_LOGIC);
end ControlUnit;


architecture arch_ControlUnit of ControlUnit is  
begin   

process(opcode, ALU_Funct) is
begin
	
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
			
			case ALU_Funct is
				when "000000" | "000010" | "000011" => -- shift, takes argument from shftamnt 
					ALUSrc <= '1';
					HILOWrite <= '0';
					HILORead <= "00";
					RegWrite <= '1';
					isShftAmnt <= '1';
				when "011000" | "011001" | "011010" | "011011" => -- mult, multu, div, divu
					HILOWrite <= '1';
					HILORead <= "00";
					ALUSrc <= '0';
					RegWrite <= '0';
					isShftAmnt <= '0';
				when "010000" => -- MFHI
					HILORead <= "10";
					HILOWrite <= '0';
					ALUSrc <= '0';
					RegWrite <= '1';
					isShftAmnt <= '0';
				when "010010" => --MFLO
					HILORead <= "01";
					HILOWrite <= '0';
					ALUSrc <= '0';
					RegWrite <= '1';
					isShftAmnt <= '0';
				when others => 
					ALUSrc <= '0';
					HILOWrite <= '0';
					HILORead <= "00";
					RegWrite <= '1';
					isShftAmnt <= '0';
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

		-- sw
		when "101011" => 
			RegDst <= '-';
			ALUSrc <= '1';
			MemtoReg <= '-';
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
		
		-- beq
		when "000100" => 
			RegDst <= '-';
			ALUSrc <= '0';
			RegWrite <= '0';
			MemtoReg <= '-';
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
			
		-- bgez
		when "000001" =>
			RegDst <= '-';
			ALUSrc <= '0';
			RegWrite <= '0';
			MemtoReg <= '-';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '1';
			BGEZ <= '1';
			Jump <= '0';
			JR <= '0';
			ALUOp <= "01";
			SignExtend <= '1';
			InstrtoReg <= '0';
			HILORead <= "00";
			HILOWrite <= '0';

		-- jump
		when "000010" =>
			RegDst <= '0';
			ALUSrc <= '0';
			RegWrite <= '0';
			MemtoReg <= '-';
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
			
		-- jr
		when "000000" =>
			RegDst <= '0';
			ALUSrc <= '0';
			RegWrite <= '0';
			MemtoReg <= '-';
			MemRead <= '0';
			MemWrite <= '0';
			Branch <= '0';
			Jump <= '0';
			JR <= '1';
			BGEZ <= '0';
			ALUOp <= "01";
			SignExtend <= '1';
			InstrtoReg <= '0';
			HILORead <= "00";
			HILOWrite <= '0';
			
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
			
		when others => null;
		
	end case;
end process;

end arch_ControlUnit;

