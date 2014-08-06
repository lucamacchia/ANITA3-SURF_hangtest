----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:11:34 07/25/2014 
-- Design Name: 
-- Module Name:    NewSCALERSHOT - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NewSCALERSHOT is
port(
CLK : in std_logic;
T1 : in std_logic;
O : out std_logic
); 

end NewSCALERSHOT;

architecture Behavioral of NewSCALERSHOT is
signal pulse_async : std_logic := '0';
signal pulse_sync : std_logic := '0';
signal pulse_sync1 : std_logic := '0';
signal pulse_sync_d : std_logic := '0';
signal stuck_on : std_logic := '0';
signal detect_stuck1 : std_logic := '0';
signal detect_stuck2 : std_logic := '0';
signal detect_stuck3 : std_logic := '0';


begin

process(T1, pulse_sync)
begin
if pulse_sync = '1' then
	pulse_async<='0';
elsif rising_edge(T1) then
	pulse_async<='1';
end if;
end process;

process(CLK)
begin
if rising_edge(CLK) then
	pulse_sync1<=pulse_async;
end if;
end process;


process(CLK)
begin
if rising_edge(CLK) then
	if pulse_sync = '1' then 
		pulse_sync<='0';
	else
		pulse_sync<=pulse_sync1;
	end if;
	
end if;
end process;

process(CLK)
begin
if rising_edge(CLK) then
	detect_stuck1<=T1;
	detect_stuck2<=detect_stuck1;
	detect_stuck3<=detect_stuck2;
	stuck_on<= detect_stuck1  and detect_stuck2 and detect_stuck3;
end if;
end process;

O<= stuck_on or pulse_sync;


end Behavioral;

