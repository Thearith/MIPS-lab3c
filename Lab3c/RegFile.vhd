----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	RegFile
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: Register File for the MIPS processor
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

entity RegFile is
    Port ( 	ReadAddr1_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
				ReadAddr2_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
				ReadData1_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);
				ReadData2_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);				
				WriteAddr_Reg	: in  STD_LOGIC_VECTOR (4 downto 0); 
				WriteData_Reg 	: in STD_LOGIC_VECTOR (31 downto 0);
				RegWrite 		: in STD_LOGIC; 
				CLK 				: in  STD_LOGIC);
end RegFile;


architecture arch_RegFile of RegFile is

type REG_32x32 is array (0 to 31) of std_logic_vector (31 downto 0);

signal DATA_REG : REG_32x32 := (others=> x"00000000");

begin

ReadData1_Reg <= DATA_REG(conv_integer(ReadAddr1_Reg));
ReadData2_Reg <= DATA_REG(conv_integer(ReadAddr2_Reg));

process(CLK) is
begin
	
	if CLK'event and CLK = '1' then
		if RegWrite = '1' then
			if(conv_integer(WriteAddr_Reg) /= 0) then
				DATA_REG(conv_integer(WriteAddr_Reg)) <= WriteData_Reg;
			end if;
		end if;
	end if;

end process;

end arch_RegFile;

