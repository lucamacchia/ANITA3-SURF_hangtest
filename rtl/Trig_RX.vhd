library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;


  
   entity Trig_RX is
      port ( 	A1TC			: in    std_logic_vector(7 downto 0);
					A2TC			: in    std_logic_vector(7 downto 0);
					A3TC			: in    std_logic_vector(7 downto 0);
					A4TC			: in    std_logic_vector(7 downto 0);				
				   VTRG_A1TC  : in    std_logic_vector(7 downto 0);
					VTRG_A2TC  : in    std_logic_vector(7 downto 0);
					VTRG_A3TC  : in    std_logic_vector(7 downto 0);
					VTRG_A4TC  : in    std_logic_vector(7 downto 0);
				 out_for_scaler : out std_logic_vector (31 downto 0); 
             ANT_A      : out   std_logic_vector (7 downto 0); 
             ANT_B      : out   std_logic_vector (7 downto 0); 
             ANT_C      : out   std_logic_vector (7 downto 0); 
             ANT_D      : out   std_logic_vector (7 downto 0));
   end Trig_RX;
 

architecture BEHAVIORAL of Trig_RX is
  



   component CH_input
      port ( ANT_out   : out   std_logic; 
             IN_P      : in    std_logic; 
             IN_N      : in    std_logic; 
				 out_for_scaler : out std_logic);
   end component;
	

begin


CH_input_gen_A: for i in 0 to 7 generate
					CH_input_u: CH_input port map(
					 IN_N=>VTRG_A1TC(i),
                IN_P=>A1TC(i),
                ANT_out=>ANT_A(i),
					 out_for_scaler => out_for_scaler(i)
									);
				  end generate;

CH_input_gen_B: for i in 0 to 7 generate
					CH_input_u: CH_input port map(
					 IN_N=>VTRG_A2TC(i),
                IN_P=>A2TC(i),
                ANT_out=>ANT_B(i),
					 out_for_scaler => out_for_scaler(8+i)
									);
				  end generate;

CH_input_gen_C: for i in 0 to 7 generate
					CH_input_u: CH_input port map(
					 IN_N=>VTRG_A3TC(i),
                IN_P=>A3TC(i),
                ANT_out=>ANT_C(i),
					 out_for_scaler => out_for_scaler(16+i)
									);
				  end generate;

CH_input_gen_D: for i in 0 to 7 generate
					CH_input_u: CH_input port map(
					 IN_N=>VTRG_A4TC(i),
                IN_P=>A4TC(i),
                ANT_out=>ANT_D(i),
					 out_for_scaler => out_for_scaler(24+i)
									);
				  end generate;								

				  
end BEHAVIORAL;
