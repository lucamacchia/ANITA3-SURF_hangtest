library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity Level1_Trigger is
   port ( ANT_A     : in    std_logic_vector (7 downto 0); 
          ANT_B     : in    std_logic_vector (7 downto 0); 
          ANT_C     : in    std_logic_vector (7 downto 0); 
          ANT_D     : in    std_logic_vector (7 downto 0); 
	  ANT_A_for_scalers : in std_logic_vector (7 downto 0); 
	  ANT_B_for_scalers : in std_logic_vector (7 downto 0); 
	  ANT_C_for_scalers : in std_logic_vector (7 downto 0); 
	  ANT_D_for_scalers : in std_logic_vector (7 downto 0); 
          CLK       : in    std_logic; 
          CLR_ALL   : in    std_logic; 
          REFPULSE  : in    std_logic;
          L1        : out   std_logic_vector (3 downto 0);
	mask_pass : in std_logic_vector (31 downto 0); 	
          CR	    : out   std_logic_vector (31 downto 0); 			 
          MONSCALER : out   std_logic_vector (7 downto 0); 
          MON2      : out   std_logic; 
          MON3      : out   std_logic; 
          MON4      : out   std_logic;
			 CLK125    : in std_logic;
			 CLK250    : in std_logic;
			 CLK250_180 : in std_logic
			 );
end Level1_Trigger;

architecture BEHAVIORAL of Level1_Trigger is
   signal NqCLK     : std_logic;
   signal qCLK      : std_logic;
 
   
	
component TURF_Processor_ANITA3 
   port ( 
			 A1_TC       : in    std_logic_vector(7 downto 0); 
			 A2_TC       : in    std_logic_vector(7 downto 0); 
			 A3_TC       : in    std_logic_vector(7 downto 0); 
			 A4_TC       : in    std_logic_vector(7 downto 0); 
          MCLK        : in    std_logic; 
          NqCLK       : in    std_logic; 
          qCLK        : in    std_logic; 
			 ANT_A_for_scalers : in std_logic_vector (7 downto 0); 
			 ANT_B_for_scalers : in std_logic_vector (7 downto 0); 
		    ANT_C_for_scalers : in std_logic_vector (7 downto 0); 
		    ANT_D_for_scalers : in std_logic_vector (7 downto 0);
			 mask_pass : in std_logic_vector (31 downto 0); 			 			 
          REFPULSE    : in    std_logic; 
          ANT_1       : out   std_logic; 
          ANT_2       : out   std_logic; 
          ANT_3       : out   std_logic; 
          ANT_4       : out   std_logic; 
			 CR 			 : out   std_logic_vector (31 downto 0); 			 			 
          MON_SCALER4 : out   std_logic_vector (7 downto 0); 
          MON2        : out   std_logic; 
          MON3        : out   std_logic; 
          MON4        : out   std_logic);
end component;	
	


signal ANT_1 : std_logic;
signal ANT_2 : std_logic;
signal ANT_3 : std_logic;
signal ANT_4 : std_logic;

begin

NqCLK <= CLK250_180;
qCLK <= CLK250;
--LM end new
	
   turfprocessor : TURF_Processor_ANITA3
      port map (A1_TC=>ANT_A,
					 A2_TC=>ANT_B,
					 A3_TC=>ANT_C,
					 A4_TC=>ANT_D,
                MCLK=>CLK,
                NqCLK=>NqCLK,
                qCLK=>qCLK,
					 ANT_A_for_scalers=>ANT_A_for_scalers,
                ANT_B_for_scalers=>ANT_B_for_scalers,
                ANT_C_for_scalers=>ANT_C_for_scalers,
                ANT_D_for_scalers=>ANT_D_for_scalers,
					 mask_pass => mask_pass,
                REFPULSE=>REFPULSE,
                ANT_1=>L1(0),
                ANT_2=>L1(1),
                ANT_3=>L1(2),
                ANT_4=>L1(3),				 
					 CR => CR,             
                MON_SCALER4(7 downto 0)=>MONSCALER(7 downto 0),
                MON2=>MON2,
                MON3=>MON3,
                MON4=>MON4--,
					 --debug_DAC => debug_DAC
					 );
end BEHAVIORAL;
