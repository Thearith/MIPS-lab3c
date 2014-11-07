----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:26:14 11/07/2014 
-- Design Name: 
-- Module Name:    HILO - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HILO is
Port (Clk			: in	STD_LOGIC;
		HILORead    : in  STD_LOGIC_VECTOR(1 downto 0);
		HILOWrite   : in  STD_LOGIC;
		HI_In       : in  STD_LOGIC_VECTOR(31 downto 0);
		LO_In       : in  STD_LOGIC_VECTOR(31 downto 0);
 		HILO_Out    : out STD_LOGIC_VECTOR(31 downto 0));
end HILO;

architecture Behavioral of HILO is

signal HI_Reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal LO_Reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

HILO_Out <= HI_Reg when HILORead = "10" else
				LO_Reg when HILORead = "01" else
				(others => '0');
	
process(CLK) is
begin

	if(CLK'event and CLK = '1') then
		if(HILOWrite = '1') then
			HI_Reg <= HI_In;
			LO_Reg <= LO_In;
		end if;	
	end if;

end process;


end Behavioral;

