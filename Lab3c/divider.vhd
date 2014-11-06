----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:48:47 09/27/2014 
-- Design Name: 
-- Module Name:    divider - divider_arch 
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
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divider is
	 generic(width : integer := 32); -- change the width to 4 for testing
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  dividend : in  STD_LOGIC_VECTOR (width-1 downto 0);
           divisor : in  STD_LOGIC_VECTOR (width-1 downto 0);
           quotient : out  STD_LOGIC_VECTOR (width-1 downto 0);
           remainder : out  STD_LOGIC_VECTOR (width-1 downto 0);
			  done : out STD_LOGIC);
end divider;

architecture divider_arch of divider is

----------------------------------------------------------------------------
-- INSTANTIATION OF ADDER
----------------------------------------------------------------------------

component adder is
generic (width : integer);
port (A 		: in std_logic_vector(width-1 downto 0);
		B 		: in std_logic_vector(width-1 downto 0);
		C_in 	: in std_logic;
		S 		: out std_logic_vector(width-1 downto 0);
		C_out	: out std_logic);
end component adder;

----------------------------------------------------------------------------
-- SIGNALS FOR ADDER
----------------------------------------------------------------------------

signal carry_in : STD_LOGIC; 
signal carry_out : STD_LOGIC;
signal temp_divisor : STD_LOGIC_VECTOR (width downto 0);
signal temp_acc : STD_LOGIC_VECTOR (width downto 0);
signal result : STD_LOGIC_VECTOR (width downto 0);

----------------------------------------------------------------------------
-- SIGNALS FOR DIVIDER
----------------------------------------------------------------------------

type state_type is (IDLE,INIT, BUSY);
signal n_acc, acc : STD_LOGIC_VECTOR (width downto 0); -- accumulator
signal n_quo, quo : STD_LOGIC_VECTOR (width downto 0); -- quotient
signal n_cycle,cycle : STD_LOGIC_VECTOR(5 downto 0); -- keep tracks of cycle
signal state,n_state : state_type;
begin

adder_1 : adder generic map (width => (width+1)) port map (A => temp_acc, B => temp_divisor, C_in => carry_in, S=> result, C_out => carry_out);

process(clk)
begin
	if(clk'event and clk = '1') then
		if(reset = '1') then
			state <= INIT;
		else
			acc <= n_acc;
			quo <= n_quo;
			state <= n_state;
			cycle <= n_cycle;
		end if;
	end if;
end process;
		
process(state, acc, quo, divisor, cycle, result, dividend)
begin
	-- initialisation so as to remove latches
	n_state <= state;
	n_quo <= quo;
	n_acc <= acc;
	n_cycle <= cycle;
	temp_acc <= (others => '0');
	temp_divisor <= (others => '0');
	carry_in <= '0';
	quotient <= (others => '0');
	remainder <= (others => '0');
	done <= '0'; 
	case state is
		when IDLE =>
			n_acc <= (others => '0');
			n_quo <= (others => '0');
			n_cycle <= (others => '0');
			n_state <= IDLE;
		when INIT =>
			n_acc <= (others => '0');
			n_quo <= '0' & dividend;
			n_cycle <= (others => '0');
			n_state <= BUSY;
		when BUSY =>
			n_cycle <= cycle + '1';
			temp_acc <= acc(width-1 downto 0) & quo(width);
			if acc(width) = '1' then -- if acc < 0
				temp_divisor <= '0' & divisor; -- add A and divisor
				carry_in <= '0';
				n_acc <= result;
			else -- if acc >= 0
				temp_divisor <= '1' & not(divisor); -- sub divisor from A
				carry_in <= '1';
				n_acc <= result;
			end if;
			n_quo <= quo(width-1 downto 0) & not(result(width));-- shift left
			
			if(cycle = "100001") then	
				quotient <= quo(width-1 downto 0);
				temp_acc <= acc;
				done <= '1';
				if(acc(width) = '1') then
					temp_divisor <= '0' & divisor; -- add A and divisor
					carry_in <= '0';
					remainder <= result(width-1 downto 0);
				else
					remainder  <= acc(width-1 downto 0);
				end if;
				n_state <= IDLE;
			else
				n_state <= BUSY;
			end if;
			
	end case;
end process;

end divider_arch;