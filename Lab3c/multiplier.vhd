----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:25:34 09/29/2014 
-- Design Name: 
-- Module Name:    multiplier - multiplier_archi 
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

entity multiplier is
	 generic(width : integer := 34);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           mcand : in  STD_LOGIC_VECTOR(width-1 downto 0);
           mplier : in  STD_LOGIC_VECTOR(width-1 downto 0);
           product : out  STD_LOGIC_VECTOR(2*width-1 downto 0);
			  done : out STD_LOGIC);
end multiplier;

architecture multiplier_archi of multiplier is

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
signal second : STD_LOGIC_VECTOR (width downto 0);
signal first : STD_LOGIC_VECTOR (width downto 0);
signal result : STD_LOGIC_VECTOR (width downto 0);

----------------------------------------------------------------------------
-- SIGNALS FOR MULTIPLIER
----------------------------------------------------------------------------

type state_type is (IDLE,INIT,BUSY);
signal state,n_state : state_type;
signal mcand_reg, n_mcand_reg : STD_LOGIC_VECTOR(width-1 downto 0); -- stores mcand since it is added to pdt
signal pdt_reg, n_pdt_reg : STD_LOGIC_VECTOR(2*width downto 0); -- temp pdt before assigning to the output
signal radix: STD_LOGIC_VECTOR(2 downto 0); -- holds the radix bits for modified radix-4 booth encoding
signal cycles,n_cycles : STD_LOGIC_VECTOR(5 downto 0); -- counter
begin

adder_1 : adder generic map (width => width+1) port map (A => first, B => second, C_in => carry_in, S=> result, C_out => carry_out);

process(clk)
begin
	if(clk'event and clk='1') then
		if(reset = '1') then
			state <= INIT;
		else
			state <= n_state;
			mcand_reg <= n_mcand_reg;
			pdt_reg <= n_pdt_reg(2*width) & n_pdt_reg(2*width downto 1); -- shift right
			radix <= n_pdt_reg(2 downto 0);
			cycles <= n_cycles;
		end if;
	end if;
end process;

process(state, mcand, mplier, mcand_reg, pdt_reg, radix, cycles, result)
begin
	n_state <= state;
	n_mcand_reg <= mcand_reg;
	n_pdt_reg <= pdt_reg;
	n_cycles <= cycles;
	first <= (others => '0');
	second <= (others => '0');
	carry_in <= '0';
	product <= (others => '0');
	done <= '0';
	case state is
		when IDLE =>
			n_state <= IDLE;
		when INIT =>
			n_mcand_reg <= mcand;
			n_pdt_reg(2*width downto width+1) <= (others => '0');
			n_pdt_reg(width downto 1) <= mplier;
			n_pdt_reg(0) <= '0';
			n_cycles <= (others => '0');
			n_state <= BUSY;
		when BUSY =>
			if(cycles = "010001") then
				product <= pdt_reg(2*width) & pdt_reg(2*width-1 downto 1);
				done <= '1';
				n_state <= IDLE;
			else
				n_state <= BUSY;
				case radix is
					when "001" | "010" => -- add mcand
						first <= pdt_reg(2*width) & pdt_reg(2*width downto width+1);
						second <= mcand_reg(width-1) & mcand_reg;
						carry_in <= '0';
						n_pdt_reg <= result & pdt_reg(width downto 1);
					when "101" | "110" => -- subtract mcand
						first <= pdt_reg(2*width) & pdt_reg(2*width downto width+1);
						second <= not(mcand_reg(width-1) & mcand_reg);
						carry_in <= '1';
						n_pdt_reg <= result & pdt_reg(width downto 1);
					when "011" => -- add 2* mcand
						first <= pdt_reg(2*width) & pdt_reg(2*width downto width+1);
						second <=  mcand_reg & '0';
						carry_in <= '0';
						n_pdt_reg <= result & pdt_reg(width downto 1);
					when "100" => -- sub 2* mcand
						first <= pdt_reg(2*width) & pdt_reg(2*width downto width+1);
						second <=  not(mcand_reg & '0');
						carry_in <= '1';
						n_pdt_reg <= result & pdt_reg(width downto 1);
					when others => -- add/sub 0
						n_pdt_reg <= pdt_reg(2*width) & pdt_reg(2*width downto 1);
				end case;
			end if;
			n_cycles <= cycles + '1';
	end case;
end process;
end multiplier_archi;

