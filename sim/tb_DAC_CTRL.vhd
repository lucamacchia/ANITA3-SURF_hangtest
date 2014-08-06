--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:18:20 07/31/2014
-- Design Name:   
-- Module Name:   C:/Users/radio/Desktop/SURF-HangTest/firmware_3.8.8.69af93acdf/firmware-surf-master_3.8.8.69af93acdf/firmware-surf-master/sim/tb_DAC_CTRL.vhd
-- Project Name:  SURFv38
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DAC_CTRL_v3
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
 
ENTITY tb_DAC_CTRL IS
END tb_DAC_CTRL;
 
ARCHITECTURE behavior OF tb_DAC_CTRL IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DAC_CTRL_v3
    PORT(
         clk_i : IN  std_logic;
         dac_we_i : IN  std_logic;
         dac_waddr_i : IN  std_logic_vector(4 downto 0);
         dac_dat_i : IN  std_logic_vector(15 downto 0);
         dac_raddr_i : IN  std_logic_vector(4 downto 0);
         dac_dat_o : OUT  std_logic_vector(15 downto 0);
         update_i : IN  std_logic;
         busy_o : OUT  std_logic;
         SCLK : OUT  std_logic;
         NSYNC : OUT  std_logic;
         DIN : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal dac_we_i : std_logic := '0';
   signal dac_waddr_i : std_logic_vector(4 downto 0) := (others => '0');
   signal dac_dat_i : std_logic_vector(15 downto 0) := (others => '0');
   signal dac_raddr_i : std_logic_vector(4 downto 0) := (others => '0');
   signal update_i : std_logic := '0';

 	--Outputs
   signal dac_dat_o : std_logic_vector(15 downto 0);
   signal busy_o : std_logic;
   signal SCLK : std_logic;
   signal NSYNC : std_logic;
   signal DIN : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_i_period : time := 30 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DAC_CTRL_v3 PORT MAP (
          clk_i => clk_i,
          dac_we_i => dac_we_i,
          dac_waddr_i => dac_waddr_i,
          dac_dat_i => dac_dat_i,
          dac_raddr_i => dac_raddr_i,
          dac_dat_o => dac_dat_o,
          update_i => update_i,
          busy_o => busy_o,
          SCLK => SCLK,
          NSYNC => NSYNC,
          DIN => DIN
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;

 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		
		   dac_we_i <= '0';
         dac_waddr_i <= "00000";
         dac_dat_i <= (others => '0');
         dac_raddr_i <= "00000";
			update_i <= '0';
		
      wait for 130 ns;	
		   update_i <= '1';
			
      wait for clk_i_period;
		   update_i <= '0';


      wait;
   end process;

END;
