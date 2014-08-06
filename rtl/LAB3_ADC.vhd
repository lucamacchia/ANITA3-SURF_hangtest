----------------------------------------------------------------------------------
-- Company: 		UH - IDL
-- Engineer: 		GSV
-- 
-- Create Date:    14:40:31 5/1/2014 
-- Design Name: 
-- Module Name:    LAB3_ADC - Behavioral 
-- Project Name:   SURFv3 Readout
-- Target Devices:    SURFv3
-- Tool versions: 
-- Description:   Simple state machine used to handle Wilkinson ADC for LAB3
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--   Completely converted over from schematic-based version
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity LAB3_ADC is
   port ( WCLK     : in    std_logic;  -- 125MHz (CLK125)
          START    : in    std_logic; 
          RAMP		 : out   std_logic; 
          GCK      : out   std_logic; 
          GCCLR    : out   std_logic; 
          ADC_Done : out   std_logic);
end LAB3_ADC;

architecture BEHAVIORAL of LAB3_ADC is
   signal count     : integer := 0;
-- Define for outputs
   signal iRamp     : std_logic;
   signal iWCLK     : std_logic;
   signal iGCCLR 	  : std_logic;
   signal iADC_Done : std_logic;
 
   --STATES
   type state_type is (
			IDLE, 
			CLR_GCC_1,
			CLR_GCC_2,
			CLR_GCC_3,
			WAIT_STEP,
			RUNNING,
			ADC_DONE_ACTIVE
			); 
   signal STATE : state_type := IDLE;
 
begin
	-- update outputs
	process(WCLK) begin
		if(rising_edge(WCLK)) then
			RAMP 		<= iRamp;
			GCCLR 	<= iGCCLR;
			ADC_Done <= iADC_Done;
		end if;
	end process;

	iWCLK <= NOT WCLK;

   GCC_clock : OFDDRRSE
   port map (
      Q => GCK,    		-- Clock (connect directly to top-level port)
      C0 => WCLK,    	-- 0 degree clock input
      C1 => iWCLK,   	-- 180 degree clock input
      CE => iRamp,    	-- Clock enable input
      D0 => '0',    		-- Posedge data input
      D1 => '1',    		-- Negedge data input
      R => '0',      	-- Synchronous reset input
      S => '0'      		-- Synchronous preset input
   );
	
	
	Digitize_LAB3 : process(WCLK)
	begin
		------------------------------------------------------------
		IF RISING_EDGE(WCLK) THEN
			CASE STATE IS
				--------------------------------
				WHEN IDLE =>
					iRamp  				<= '0';
					iGCCLR 				<= '0';
					iADC_Done 			<= '0';

					if(START = '1') then
						iGCCLR 	<= '1';
						STATE 	<= CLR_GCC_1;
					end if;

				--------------------------------				
				WHEN CLR_GCC_1 =>
						iGCCLR	<= '1';
						STATE <= CLR_GCC_2;				WHEN CLR_GCC_2 =>
						
						iGCCLR	<= '1';
						
						STATE <= CLR_GCC_3;
				WHEN CLR_GCC_3 =>
						iGCCLR	<= '1';
						STATE <= WAIT_STEP;
				WHEN WAIT_STEP =>
						iGCCLR	<= '0';
						iRamp 	<= '1';
						STATE <= RUNNING;
				--------------------------------		
				WHEN RUNNING =>
					if(count < 8192) then											
						count <= count + 1;
					else
						count <= 0;
						iRAMP	<= '0';
						STATE <= ADC_DONE_ACTIVE;
					end if;				

				--------------------------------	
				WHEN ADC_DONE_ACTIVE =>
						iADC_Done <= '1';
						STATE <= IDLE;

				--------------------------------
				WHEN OTHERS =>
					STATE <= IDLE;
			END CASE;
			------------------------------------------------------------
		END IF;
		------------------------------------------------------------
	END PROCESS Digitize_LAB3;

	
end BEHAVIORAL;
