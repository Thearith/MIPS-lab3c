----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:07:26 09/27/2014 
-- Design Name: 
-- Module Name:    nshifter - nshifter_archi 
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

entity nshifter is
	 generic(N: integer; width : integer := 32);
    Port ( A : in  STD_LOGIC_VECTOR(width-1 downto 0);
			  ENABLE : in STD_LOGIC;
			  ARITH_ENABLE : in STD_LOGIC;
           RIGHT : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR(width-1 downto 0));
end nshifter;

architecture nshifter_archi of nshifter is

begin
process(A,RIGHT, ENABLE,ARITH_ENABLE)
begin
if(ENABLE = '1') then
	if(RIGHT = '1') then
		S(width-N-1 downto 0) <= A(width-1 downto N);
		S(width-1 downto width-N) <= (others => ARITH_ENABLE);
	else
		S(width-1 downto N) <= A(width-1-N downto 0);
		s(N-1 downto 0) <= (others => '0');
	end if;
else
	S <= A;
end if;
end process;
end nshifter_archi;

