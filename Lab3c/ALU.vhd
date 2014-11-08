----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   10:39:18 13/09/2014
-- Design Name: 	ALU
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: ALU template for MIPS processor
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------


------------------------------------------------------------------
-- ALU Entity
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
generic (width 	: integer := 32);
Port (Clk			: in	STD_LOGIC;
		Control		: in	STD_LOGIC_VECTOR (5 downto 0);
		Operand1		: in	STD_LOGIC_VECTOR (width-1 downto 0);
		Operand2		: in	STD_LOGIC_VECTOR (width-1 downto 0);
		Result1		: out	STD_LOGIC_VECTOR (width-1 downto 0);
		Result2		: out	STD_LOGIC_VECTOR (width-1 downto 0);
		Status		: out	STD_LOGIC_VECTOR (3 downto 0); -- negative (sub), busy (multicycle only), overflow (add and sub), zero (sub)
		Debug			: out	STD_LOGIC_VECTOR (width-1 downto 0));		
end ALU;

------------------------------------------------------------------
-- ALU Architecture
------------------------------------------------------------------

architecture Behavioral of ALU is

type states is (COMBINATIONAL, MULTI_CYCLE);
signal state, n_state 	: states := COMBINATIONAL;


----------------------------------------------------------------------------
-- Adder instantiation
----------------------------------------------------------------------------
component adder is
generic (width : integer);
port (A 		: in 	std_logic_vector(width-1 downto 0);
		B 		: in 	std_logic_vector(width-1 downto 0);
		C_in 	: in 	std_logic;
		S 		: out std_logic_vector(width-1 downto 0);
		C_out	: out std_logic);
end component adder;

----------------------------------------------------------------------------
-- Adder signals
----------------------------------------------------------------------------
signal B 		: std_logic_vector(width-1 downto 0) := (others => '0'); 
signal C_in 	: std_logic := '0';
signal S 		: std_logic_vector(width-1 downto 0) := (others => '0'); 
signal C_out	: std_logic := '0'; --not used

----------------------------------------------------------------------------
-- Shifter instantiation
----------------------------------------------------------------------------

component shifter is
	 generic(width : integer := 32);
    Port ( Input : in  STD_LOGIC_VECTOR(width-1 downto 0);
           ShiftAmt : in  STD_LOGIC_VECTOR(4 downto 0);
			  ARITHMETIC_ENABLE : in STD_LOGIC;
           Dir : in  STD_LOGIC;
           Output : out  STD_LOGIC_VECTOR(width-1 downto 0));
end component shifter;

----------------------------------------------------------------------------
-- Signals for Shifter
----------------------------------------------------------------------------

signal dir_right : std_logic := '0';
signal arith_flag :std_logic := '0';
signal shift_output : STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0');

----------------------------------------------------------------------------
-- Divider instantiation
----------------------------------------------------------------------------
component divider is
	 generic(width : integer);
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  dividend : in  STD_LOGIC_VECTOR (width-1 downto 0);
           divisor : in  STD_LOGIC_VECTOR (width-1 downto 0);
           quotient : out  STD_LOGIC_VECTOR (width-1 downto 0);
           remainder : out  STD_LOGIC_VECTOR (width-1 downto 0);
			  done : out STD_LOGIC);
end component divider;

----------------------------------------------------------------------------
-- Divider signals
----------------------------------------------------------------------------
signal div_reset : STD_LOGIC := '0';
signal div_operand1 : STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0');
signal div_operand2 : STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0');
signal div_quotient : std_logic_vector (width-1 downto 0) := (others => '0'); 
signal div_remainder : std_logic_vector (width-1 downto 0) := (others => '0'); 
signal div_done : STD_LOGIC := '0';

----------------------------------------------------------------------------
-- Multiplier instantiation
----------------------------------------------------------------------------
component multiplier is
	 generic(width : integer);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           mcand : in  STD_LOGIC_VECTOR(33 downto 0);
           mplier : in  STD_LOGIC_VECTOR(33 downto 0);
           product : out  STD_LOGIC_VECTOR(2*34-1 downto 0);
			  done : out STD_LOGIC);
end component multiplier;

----------------------------------------------------------------------------
-- Multiplier signals
----------------------------------------------------------------------------
signal mul_operand1     : STD_LOGIC_VECTOR (33 downto 0);
signal mul_operand2     : STD_LOGIC_VECTOR (33 downto 0);
signal mul_reset        : STD_LOGIC := '0';
signal mul_product 	   : std_logic_vector (2*34-1 downto 0) := (others => '0');
signal mul_done         : STD_LOGIC := '0';

----------------------------------------------------------------------------
-- Signals for MULTI_CYCLE_PROCESS
----------------------------------------------------------------------------
signal Result1_multi		: STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0'); 
signal Result2_multi		: STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0');
signal Debug_multi		: STD_LOGIC_VECTOR (width-1 downto 0) := (others => '0'); 
signal done		 			: STD_LOGIC := '0';

begin

-- <port maps>
adder32 : adder generic map (width =>  width) port map (  A=>Operand1, B=>B, C_in=>C_in, S=>S, C_out=>C_out );
shifter32 : shifter generic map(width => width) port map( Input => Operand1, ShiftAmt => Operand2(4 downto 0), ARITHMETIC_ENABLE=> arith_flag, Dir => dir_right, Output => shift_output);
multiplier32 : multiplier generic map(width => width+2) port map ( clk => Clk, reset => mul_reset, mcand => mul_operand1, mplier => mul_operand2, product => mul_product, done => mul_done);
divider32 : divider generic map (width => width) port map ( clk => Clk, reset => div_reset, dividend => div_operand1, divisor => div_operand2, quotient => div_quotient, remainder => div_remainder, done => div_done); 
-- </port maps>


----------------------------------------------------------------------------
-- COMBINATIONAL PROCESS
----------------------------------------------------------------------------
COMBINATIONAL_PROCESS : process (
											Control, Operand1, Operand2, state, C_out,-- external inputs
											S, shift_output, -- ouput from other components
											Result1_multi, Result2_multi, Debug_multi, done -- from multi-cycle process(es)
											)
variable temp_overflow : std_logic;
begin
-- <default outputs>
Status(3 downto 0) <= "0000"; -- both statuses '0' by default 
Result1 <= (others=>'0');
Result2 <= (others=>'0');
Debug <= (others=>'0');
dir_right <= '0';
arith_flag <= '0';
n_state <= state;
Debug_multi <= (others => '0');

B <= Operand2;
C_in <= '0';
-- </default outputs>

--reset
if Control /= "011000" and Control /= "011001" and Control /= "011010" and Control /= "011011" then
	n_state <= COMBINATIONAL;
else

case state is
	when COMBINATIONAL =>
		case Control(5 downto 0) is
		--and
		when "100100" =>   -- takes 0 cycles to execute
			Result1 <= Operand1 and Operand2;
			
		--andu
		
		--or/ori
		when "100101" | "001101" =>
			Result1 <= Operand1 or Operand2;
		
		--nor
		when "100111" => 
			Result1 <= Operand1 nor Operand2;
		
		--xor
		when "100110" =>
			Result1 <= Operand1 xor Operand2;
		
		--add/addi
		when "100000" | "001000" =>
			Result1 <= S;
			-- overflow
			Status(1) <= ( Operand1(width-1) xnor  Operand2(width-1) )  and ( Operand2(width-1) xor S(width-1) );
		
		-- sub
		when "100010" =>
			B <= not(Operand2);
			C_in <= '1';
			Result1 <= S;
			Status(1) <= (not(Operand1(width-1)) and Operand2(width-1) and S(width-1)) or (Operand1(width-1) and not(Operand2(width-1)) and not(S(width-1)));
			
			if S(31) = '1' then -- negative flag
				Status(3) <= '1';
			else
				Status(3) <= '0';
			end if;
			
			if S = x"00000000" then -- zero flag
				Status(0) <= '1'; 
			else
				Status(0) <= '0';
			end if;
			
		-- slt/slti
		when "101010" | "001010" =>
			B <= not(Operand2);
			C_in <= '1';
			temp_overflow := (not(Operand1(width-1)) and Operand2(width-1) and S(width-1)) or (Operand1(width-1) and not(Operand2(width-1)) and not(S(width-1)));
			if(temp_overflow = '0' and S(width-1) = '1') then
				Result1 <= x"00000001";
			elsif(temp_overflow = '1' and S(width-1) = '0') then
				Result1 <= x"00000001";
			else
				Result1 <= x"00000000";
			end if;
			
		-- sltu
		when "101011" =>
			B <= not(Operand2);
			C_in <= '1';
			if(C_out = '0') then
				Result1 <= x"00000001";
			else
				Result1 <= x"00000000";
			end if;
			
		-- sll / sllv
		when "000000" | "000100" =>
			dir_right <= '0';
			arith_flag <= '0'; -- doesn't matter, actually...
			Result1 <= shift_output;
			
		-- srl / srlv
		when "000010" | "000110" =>
			dir_right <= '1';
			arith_flag <= '0';
			Result1 <= shift_output;
			
		-- sra / srav
		when "000011" | "000111" =>
			dir_right <= '1';
			arith_flag <= Operand1(width-1);
			Result1 <= shift_output;
			
		-- multi-cycle operations
		when "011000" | "011001" | "011010" | "011011" => 
			n_state <= MULTI_CYCLE;
			Status(2) <= '1';
		-- default cases (already covered)
		when others=> null;
		end case;
		
	when MULTI_CYCLE => 
		if done = '1' then
			Result1 <= Result1_multi;
			Result2 <= Result2_multi;
			Debug <= Debug_multi;
			n_state <= COMBINATIONAL;
			Status(2) <= '0';
		else
			Status(2) <= '1';
			n_state <= MULTI_CYCLE;
		end if;
	end case;
end if;	
end process;


----------------------------------------------------------------------------
-- STATE UPDATE PROCESS
----------------------------------------------------------------------------

STATE_UPDATE_PROCESS : process (Clk) -- state updating
begin  
   if (Clk'event and Clk = '1') then
		state <= n_state;
   end if;
end process;

----------------------------------------------------------------------------
-- MULTI CYCLE PROCESS
----------------------------------------------------------------------------

MULTI_CYCLE_PROCESS : process (Clk) -- multi-cycle operations done here
-- assume that Operand1 and Operand 2 do not change while multi-cycle operations are being performed 
begin  
   if (Clk'event and Clk = '1') then 
		if Control(5) = '1' then
		end if;
		done <= '0';
		if n_state = MULTI_CYCLE then
			case Control(5 downto 0) is
			
				-- mul
				when "011000" | "011001" =>
					if(state = COMBINATIONAL) then
						mul_reset <= '1';
						if(Control(0) = '0') then
							mul_operand1 <= Operand1(31) & Operand1(31) & Operand1;
							mul_operand2 <= Operand2(31) & Operand2(31) & Operand2;
						else
							mul_operand1 <= "00" & Operand1; 
							mul_operand2 <= "00" & Operand2;
						end if;	
					else
						mul_reset <= '0';
					end if;
					
					if mul_done = '1' then
						Result1_multi <= mul_product(31 downto 0);
						Result2_multi <= mul_product(2*32-1 downto 32);
						done <= '1'; 
					end if;
				
				-- div
				when "011010" =>
					if(state = COMBINATIONAL) then
						div_reset <= '1';
						if(Operand1(31) = '1') then -- operand1 is negative, change to positive (2's complement)
							div_operand1 <= not(Operand1) + 1;
						else 
							div_operand1 <= Operand1;
						end if;
						if(Operand2(31) = '1') then -- operand2 is negative, change to positive (2's complement)
							div_operand2 <= not(Operand2) + 1;
						else 
							div_operand2 <= Operand2;
						end if;
					else
						div_reset <= '0';
					end if;
					
					if div_done = '1' then
						
						if(Operand1(31) = '0') then  -- conventionally, remainder has the same sign as operand1
							Result2_multi <= div_remainder;
						else -- operand1 (dividend) is negative, change remainder to negative (2's complement)
							Result2_multi <= not(div_remainder) + 1;
						end if;
						
						if(Operand1(31) = Operand2(31)) then -- quotient is postive if Operand1 (dividend) and Operand2 (divisor) has the same sign
							Result1_multi <= div_quotient;
						else -- if different sign, change quotient to negative (2's complement)
							Result1_multi <= not(div_quotient) + 1;
						end if;
						
						done <= '1';
					end if;
					
				-- divu 
				when "011011" =>
					if(state = COMBINATIONAL) then
						div_reset <= '1';
						div_operand1 <= Operand1;
						div_operand2 <= Operand2;
					else
						div_reset <= '0';
					end if;
					
					if div_done = '1' then
						Result1_multi <= div_quotient;
						Result2_multi <= div_remainder;
						done <= '1';
					end if;
				when others=> null;
					
				end case;
		end if;
	end if;
end process;


end Behavioral;


------------------------------------------------------------------
-- Adder Entity
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder is
generic (width : integer := 32);
port (A 		: in std_logic_vector(width-1 downto 0);
		B 		: in std_logic_vector(width-1 downto 0);
		C_in 	: in std_logic;
		S 		: out std_logic_vector(width-1 downto 0);
		C_out	: out std_logic);
end adder;

------------------------------------------------------------------
-- Adder Architecture
------------------------------------------------------------------

architecture adder_arch of adder is
signal S_wider : std_logic_vector(width downto 0);
begin
	S_wider <= ('0'& A) + ('0'& B) + C_in;
	S <= S_wider(width-1 downto 0);
	C_out <= S_wider(width);
end adder_arch;