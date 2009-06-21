-----------------------------------------------------------
-- TX rs232 module for FPGA
--
--  --------------
--  |            | <--	rs232_in - in in hardware port
--  |            | -->	dout - received byte 
--  |   rs232    | <--	rx_done_tick - receive done
--  |    rx      | <--	reset - you know what is it
--  |            | <--	clk - tick-tack
--  |            | <--	rs232_clk - clk at 115200 bits/sec speed 
--  --------------
--
-- Developer: Alex Nikiforov nikiforov.al [at] gmail.com
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rs232rx is
    	Port (	clk : in STD_LOGIC ;
		reset : in STD_LOGIC ;
		dout : out STD_LOGIC_VECTOR (7 downto 0) ; 
		rs232_in: in std_logic ;
		rx_done_tick : out std_logic ;
		rs232_clk: in std_logic
	     );
end rs232rx;

architecture arch of rs232rx is
	type rs232_type is(idle, start, data, stop);
	signal rs232_state, rs232_next_state: rs232_type;
	--signal rs232_state: bit_vector (2 downto 0) := "111";
	signal rs232_counter: integer range 0 to 8 := 0;
	--signal rs232_value: bit_vector (7 downto 0) := X"41"; -- A - char
	signal rs232_value: STD_LOGIC_VECTOR (7 downto 0) := ( others => '0') ;
	
begin

process(clk, reset)
begin

	if( reset = '1') then
		rs232_state <= idle;
	elsif rising_edge(clk) then
		rs232_state <= rs232_next_state;
	end if;

end process;

-- next state logic 
process(rs232_clk, rs232_state, rs232_value, rs232_next_state, rs232_in, rs232_counter)
begin
	rx_done_tick <= '0' ;
	
	if( rs232_clk = '1') then 

		case rs232_state is
		
		-- idle
		when idle =>

			if( rs232_in = '0' ) then
				rs232_next_state <= data; -- FIXME data or start?? checkit
				rs232_value <= ( others => '0' ) ;
				rs232_counter <= 0;
			end if;

		-- start bit
		when start =>
			rs232_next_state <= data;

		-- data bit
		when data =>
			if( rs232_counter = 8 ) then
				rs232_next_state <= stop;
			else
				rs232_value(rs232_counter) <= rs232_in;
				rs232_counter <= rs232_counter + 1 ;
			end if;
	
		-- stop
		when stop =>
			if rs232_in = '1' then
				rs232_next_state <= idle ;
				dout <= rs232_value ; 
				rx_done_tick <= '1' ;
			end if;

		when others => NULL ;
							
		end case;

	end if; -- if( rs232_clk = '1') then 

end process;
	
end arch;
