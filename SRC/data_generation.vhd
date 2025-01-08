--part of ads library uses other ads packages
library ads;
use ads.ads_complex_pkg.all;
use ads.ads_fixed.all;

library vga;
use vga.vga_data.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_generation is
	generic (	vga_res: vga_timing := vga_res_default );
	port ( 	clk	: in std_logic;
				reset	: in std_logic;
				mode:	in	std_logic;

				point: in coordinate;
				
				seed: out ads_complex);
				
				
				
end entity data_generation;
				
architecture Behavioral of data_generation is
	-- signal iterations : ads_sfixed : 255;
	
	
	
	--create a function declaration that creates a variable pt that takes a value from point, returns an ads_complex value
	function mandelbrot_seed (
		pt: in coordinate
	) return ads_complex
	is
		variable ret: ads_complex;--create a varaible ret of ads_complex type
		--delta x
		constant delta_x: ads_sfixed := to_ads_sfixed(3.2 / real(vga_res.horizontal.active));--create a constant of ads_sfixed
		constant delta_y: ads_sfixed := to_ads_sfixed(-4.4 / real(vga_res.vertical.active));--TODO
	begin
		ret.re := delta_x * to_ads_sfixed(pt.x) - to_ads_sfixed(2.2);
		ret.im := delta_y * to_ads_sfixed(pt.y) + to_ads_sfixed(1.2);--todo
		return ret;
	end function mandelbrot_seed;

	function julia_seed (
		pt: in coordinate
	) return ads_complex
	-- ...
	is
		variable ret: ads_complex;--create a varaible ret of ads_complex type
		--delta x
		constant delta_x: ads_sfixed := to_ads_sfixed(4.4 / real(vga_res.horizontal.active));--create a constant of ads_sfixed
		constant delta_y: ads_sfixed := to_ads_sfixed(-4.4 / real(vga_res.horizontal.active));--TODO
	begin
		ret.re := delta_x * to_ads_sfixed(pt.x) - to_ads_sfixed(2.2);
		ret.im := delta_y * to_ads_sfixed(pt.y) + to_ads_sfixed(2.2);--todo
		return ret;
	end function julia_seed;
begin 

	assign_output: process(clk, reset) is
	begin
		if reset = '0' then
			--
		elsif rising_edge(clk) then
			if mode = '0' then
				seed <= mandelbrot_seed(point);
			else
				seed <= julia_seed(point);
			end if;
		end if;
	end process assign_output;

end Behavioral;

