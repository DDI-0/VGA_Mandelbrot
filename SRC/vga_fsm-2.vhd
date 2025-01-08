library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

entity vga_fsm is
	generic (
		vga_res:	vga_timing := vga_res_default
	);
	port (
		vga_clock:		in	std_logic;
		reset:			in	std_logic;

		point:			out	coordinate;
		point_valid:	out	boolean;

		h_sync:			out	std_logic;
		v_sync:			out std_logic
	);
end entity vga_fsm;

architecture fsm of vga_fsm is
	-- any internal signals you may need
	signal current_point : coordinate := make_coordinate(0,0);

begin
	-- implement methodology to drive outputs here
	-- use vga_data functions and types to make your life easier
	process(vga_clock, reset)
	begin
		if reset = '0' then
			--reset coordinates and counter

			current_point <= make_coordinate(0,0);

		elsif rising_edge(vga_clock) then
			current_point <= next_coordinate(current_point, vga_res);
			--progress horizontal
--			if x_count < timing_range(vga_res, horizontal) - 1 then
--				x_count <= x_count + 1;
--			else
--				x_count <= 0;
--				
--				--move to next line when reaching end of horizontal timing
--				if y_count < timing_range(vga_res, vertical) - 1 then
--					y_count <= y_count + 1;
--				else
--					--restart vertical when reaching end of frame
--					y_count <= 0;
--				end if;
--			end if;
--			
--			--update current point
--			current_point <= make_coordinate(x_count, y_count);
--			
--			--set horizontal sync pulse
--			h_sync <= do_horizontal_sync(current_point, vga_res);
--			
--			--set vertical sync pulse
--			v_sync <= do_vertical_sync(current_point, vga_res);
--			
--			--set point valid for visible area
--			point_valid <= point_visible(current_point, vga_res);
		end if;
	end process;
		
	--output current point
	process(vga_clock) is
	begin
		if rising_edge(vga_clock) then
			point <= current_point;
			point_valid <= point_visible(current_point, vga_res);
			h_sync <= do_horizontal_sync(current_point, vga_res);
			v_sync <= do_vertical_sync(current_point, vga_res);
		end if;
	end process;
end architecture fsm;
