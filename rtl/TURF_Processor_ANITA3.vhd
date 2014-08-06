library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity TURF_Processor_ANITA3 is
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
end TURF_Processor_ANITA3;

architecture BEHAVIORAL of TURF_Processor_ANITA3 is
   attribute BOX_TYPE   : string ;
--   signal ANT1        : std_logic_vector (3 downto 0);
--   signal ANT1SCALER  : std_logic_vector (3 downto 0);
--   signal ANT2        : std_logic_vector (3 downto 0);
--   signal ANT2SCALER  : std_logic_vector (3 downto 0);
--   signal ANT3        : std_logic_vector (3 downto 0);
--   signal ANT3SCALER  : std_logic_vector (3 downto 0);
--   signal ANT4        : std_logic_vector (3 downto 0);
--   signal ANT4SCALER  : std_logic_vector (3 downto 0);
--	
--   signal MON_SCALER2 : std_logic_vector (7 downto 0);
--   signal MON_SCALER3 : std_logic_vector (7 downto 0);
 
   component ANITA3_L1_TRIGGER_PIPE
      port ( REF_PULSE  : in    std_logic; 
             CLK        : in    std_logic; 
             BOTTOM     : in    std_logic; 
             MIDDLE     : in    std_logic; 
             TOP        : in    std_logic; 
				 mask_pass  : in   std_logic_vector (2 downto 0); 
             L1         : out   std_logic; 
             TRIGGER_PULSE : out   std_logic_vector (2 downto 0); 
             MON_SCALER : out   std_logic);
   end component;
   
   component SCALERSHOT
      port ( CLK : in    std_logic; 
             O   : out   std_logic; 
             T1  : in    std_logic; 
             T2  : in    std_logic);
   end component;
 
   component NewSCALERSHOT
      port ( CLK : in    std_logic; 
             T1   : in   std_logic; 
             O  : out    std_logic);
   end component;
	
   component REFPULSECOUNT
      port ( REF  : in    std_logic; 
             MCLK : in    std_logic; 
             PCLK : in    std_logic; 
             CNT  : out   std_logic);
   end component;
	
	
	component SignalStretcher 
		port(
			clk250 : in std_logic;
			clk33 : in std_logic;
			L1_250MHz : in std_logic;
			L1_pulsed_33MHz: out std_logic);
	end component;
	
   signal MON_SCALER : std_logic_vector(3 downto 0);
   signal ANT_SCALER: std_logic_vector(11 downto 0);
   signal TRIGGER_PULSE: std_logic_vector(11 downto 0);
	
   signal BOTTOM : std_logic_vector(3 downto 0);
   signal MIDDLE : std_logic_vector(3 downto 0);
   signal TOP : std_logic_vector(3 downto 0);
   signal ANTENNA : std_logic_vector(11 downto 0);
   signal L1 : std_logic_vector(3 downto 0);
   signal L1_pulsed_33MHz : std_logic_vector(3 downto 0);
	
	signal mask_pass_to_trigger : std_logic_vector (11 downto 0); 			 			 

	
	
begin

-- PHI 0 V signals -> L1(0) = old ANT_1 -- note: TOP first
	BOTTOM(0) <= A2_TC(6);
	MIDDLE(0) <= A2_TC(4);
	TOP(0)    <= A2_TC(0);

-- PHI 1 V signals -> L1(1) = old ANT_2
	BOTTOM(1) <= A3_TC(6);
	MIDDLE(1) <= A3_TC(4);
	TOP(1)    <= A3_TC(0);	

-- PHI 0 H signals -> L1(2) = old ANT_3
	BOTTOM(2) <= A2_TC(7);
	MIDDLE(2) <= A2_TC(5);
	TOP(2)    <= A2_TC(1);

-- PHI 1 H signals -> L1(3) = old ANT_4
	BOTTOM(3) <= A3_TC(7);
	MIDDLE(3) <= A3_TC(5);
	TOP(3)    <= A3_TC(1);	


-- the following are duplicates to help writing a generate for the scalershots.
--									 PHI	   POL	POS
--	ANTENNA(0) <= A2_TC_1; -- 0		 V		 T		
--	ANTENNA(1) <= A2_TC_5; -- 0		 V		 M		
--	ANTENNA(2) <= A2_TC_7; -- 0		 V		 B		
--	ANTENNA(3) <= A3_TC_1; -- 1		 V		 T		
--	ANTENNA(4) <= A3_TC_5; -- 1		 V		 M		
--	ANTENNA(5) <= A3_TC_7; -- 1		 V		 B		
--	ANTENNA(6) <= A2_TC_2; -- 0		 H		 T		
--	ANTENNA(7) <= A2_TC_6; -- 0		 H		 M		
--	ANTENNA(8) <= A2_TC_8; -- 0		 H		 B		
--	ANTENNA(9) <= A3_TC_2; -- 1		 V		 T		
--	ANTENNA(10) <= A3_TC_6;-- 1		 V		 M		
--	ANTENNA(11) <= A3_TC_8;-- 1		 V		 B	
	
--									 					PHI	   POL	POS
	ANTENNA(0) <= ANT_B_for_scalers(0);    -- 0		 V		 T		
	ANTENNA(1) <= ANT_B_for_scalers(4);    -- 0		 V		 M		
	ANTENNA(2) <= ANT_B_for_scalers(6);    -- 0		 V		 B		
	ANTENNA(3) <= ANT_C_for_scalers(0);    -- 1		 V		 T		
	ANTENNA(4) <= ANT_C_for_scalers(4);    -- 1		 V		 M		
	ANTENNA(5) <= ANT_C_for_scalers(6);    -- 1		 V		 B		
	ANTENNA(6) <= ANT_B_for_scalers(1);    -- 0		 H		 T		
	ANTENNA(7) <= ANT_B_for_scalers(5);    -- 0		 H		 M		
	ANTENNA(8) <= ANT_B_for_scalers(7);    -- 0		 H		 B		
	ANTENNA(9) <= ANT_C_for_scalers(1);    -- 1		 V		 T		
	ANTENNA(10) <= ANT_C_for_scalers(5);   -- 1		 V		 M		
	ANTENNA(11) <= ANT_C_for_scalers(7);   -- 1		 V		 B		

	mask_pass_to_trigger(0) <= mask_pass(8+0);
	mask_pass_to_trigger(1) <= mask_pass(8+4);
	mask_pass_to_trigger(2) <= mask_pass(8+6);
	mask_pass_to_trigger(3) <= mask_pass(16+0);
	mask_pass_to_trigger(4) <= mask_pass(16+4);
	mask_pass_to_trigger(5) <= mask_pass(16+6);
	mask_pass_to_trigger(6) <= mask_pass(8+1);
	mask_pass_to_trigger(7) <= mask_pass(8+5);
	mask_pass_to_trigger(8) <= mask_pass(8+7);
	mask_pass_to_trigger(9) <= mask_pass(16+1);
	mask_pass_to_trigger(10) <= mask_pass(16+5);
	mask_pass_to_trigger(11) <= mask_pass(16+7);
	
   ant_pipes: for i in 0 to 3 generate
		pipe: ANITA3_L1_TRIGGER_PIPE
      port map (
		   CLK=>qCLK,
			BOTTOM => BOTTOM(i),
			MIDDLE => MIDDLE(i),
			TOP => TOP(i),
			mask_pass => mask_pass(i*3+2 downto i*3),
         REF_PULSE=>REFPULSE,
         L1=>L1(i),
			MON_SCALER=>MON_SCALER(i),
			TRIGGER_PULSE=>TRIGGER_PULSE(i*3+2 downto i*3));
	end generate;
	
	 L1_stretchers: for i in 0 to 3 generate
		L1_stretcher: SignalStretcher port map(
				clk250 => qCLK,
				clk33 => MCLK,
				L1_250MHz => L1(i),
				L1_pulsed_33MHz => L1_pulsed_33MHz(i)
    );
	end generate;
	
	ANT_1 <= L1(0);
	ANT_2 <= L1(1);
	ANT_3 <= L1(2);
	ANT_4 <= L1(3);
	
	-- Note: CR1 is still reference pulse scaler
	   
--   REFPULSECOUNT_u : REFPULSECOUNT
--      port map (MCLK=>MCLK,
--                PCLK=>qCLK,
--                REF=>REFPULSE,
--                CNT=>CR(0));
   
	process(MCLK)
	begin
		if rising_edge(MCLK) then
			CR(0)<=REFPULSE;
		end if;
	end process;
	
	CR(4 downto 1) <= L1_pulsed_33MHz;
	CR(16 downto 5) <= ANT_SCALER;
   CR(31 downto 17) <= (others => '0');
--
--   scalershots: for i in 0 to 11 generate
--		sclsht: SCALERSHOT
--      port map (CLK=>MCLK,
--                T1=>ANTENNA(i),
----                T2=>TRIGGER_PULSE(i),
--                T2=>ANTENNA(i),
--					 O=>ANT_SCALER(i));
--	end generate;
   
  scalershots: for i in 0 to 11 generate
		sclsht: NewSCALERSHOT
      port map (CLK=>MCLK,
                T1=>ANTENNA(i),
					 O=>ANT_SCALER(i));
	end generate;
end BEHAVIORAL;
