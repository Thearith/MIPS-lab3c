--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:05:01 10/30/2014
-- Design Name:   
-- Module Name:   D:/CEG/Semester 5/CG3207/Lab/VHDL/Lab3v1/tb.vhd
-- Project Name:  Lab3v1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb IS
END tb;
 
ARCHITECTURE behavior OF tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP
    PORT(
         DIP : IN  std_logic_vector(15 downto 0);
         LED : OUT  std_logic_vector(15 downto 0);
         RESET : IN  std_logic;
         CLK_undiv : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal DIP : std_logic_vector(15 downto 0) := (others => '0');
   signal RESET : std_logic := '0';
   signal CLK_undiv : std_logic := '0';

 	--Outputs
   signal LED : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant CLK_undiv_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP PORT MAP (
          DIP => DIP,
          LED => LED,
          RESET => RESET,
          CLK_undiv => CLK_undiv
        );

   -- Clock process definitions
   CLK_undiv_process :process
   begin
		CLK_undiv <= '0';
		wait for CLK_undiv_period/2;
		CLK_undiv <= '1';
		wait for CLK_undiv_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		RESET <= '1';
      wait for 10 ns;	
		RESET <= '0';
      wait for CLK_undiv_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
