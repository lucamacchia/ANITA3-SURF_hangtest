library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity CH_input is
   port ( IN_N      : in    std_logic; 
          IN_P      : in    std_logic; 
          ANT_out   : out   std_logic;
			 out_for_scaler : out std_logic);
end CH_input;

architecture BEHAVIORAL of CH_input is
  
	signal out_for_scaler_b : std_logic;
	
begin

   in_buf_u : IBUFDS_DIFF_OUT
      port map (I=>IN_P,
                IB=>IN_N,
                O=>ANT_out,
					 OB=>out_for_scaler_b);
   
--	out_for_scaler <= not out_for_scaler_b;
	out_for_scaler <= out_for_scaler_b; -- scalers expect a positive pulse, so the inversion is needed, and comes natural from the DIFF_OUT
													-- the other inversion is embedded in the 2 out of 3 logic

   
	
end BEHAVIORAL;
