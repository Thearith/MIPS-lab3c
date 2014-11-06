----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:49:40 09/27/2014 
-- Design Name: 
-- Module Name:    shifter - shifter_archi 
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

entity shifter is
	 generic(width : integer := 32);
    Port ( Input : in  STD_LOGIC_VECTOR(width-1 downto 0);
           ShiftAmt : in  STD_LOGIC_VECTOR(4 downto 0);
			  ARITHMETIC_ENABLE : in STD_LOGIC;
           Dir : in  STD_LOGIC;
           Output : out  STD_LOGIC_VECTOR(width-1 downto 0));
end shifter;

architecture shifter_archi of shifter is
component nshifter is
	 generic( N: integer; width : integer := 32);
    Port ( A : in  STD_LOGIC_VECTOR(width-1 downto 0);
			  ENABLE : in STD_LOGIC;
			  ARITH_ENABLE: in STD_LOGIC;
           RIGHT : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR(width-1 downto 0));
end component nshifter;
signal output_1,output_2,output_3,output_4 : std_logic_vector(width-1 downto 0);
begin

shifter_1 : nshifter generic map(N => 1, width => width) port map (A => Input, ENABLE => ShiftAmt(0), ARITH_ENABLE => ARITHMETIC_ENABLE, RIGHT => Dir, S=> output_1);
shifter_2 : nshifter generic map(N => 2, width => width) port map (A => output_1, ENABLE => ShiftAmt(1), ARITH_ENABLE => ARITHMETIC_ENABLE, RIGHT => Dir, S=> output_2);
shifter_4 : nshifter generic map(N => 4, width => width) port map (A => output_2, ENABLE => ShiftAmt(2), ARITH_ENABLE => ARITHMETIC_ENABLE, RIGHT => Dir, S=> output_3);
shifter_8 : nshifter generic map(N => 8, width => width) port map (A => output_3, ENABLE => ShiftAmt(3), ARITH_ENABLE => ARITHMETIC_ENABLE, RIGHT => Dir, S=> output_4);
shifter_16 : nshifter generic map(N => 16, width => width) port map (A => output_4, ENABLE => ShiftAmt(4),ARITH_ENABLE => ARITHMETIC_ENABLE, RIGHT => Dir, S=> Output);

end shifter_archi;

