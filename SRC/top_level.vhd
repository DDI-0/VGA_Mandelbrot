library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vga;
use vga.vga_data.all;
library work;
use work.color_data.all;


library ads;
use ads.ads_complex_pkg.all;
use ads.ads_fixed.all;



entity top_level is
	generic (
		pipeline_len:	positive := 16;
		vga_res:	vga_timing := vga_res_640x480
	);
	port (
		onboard_clock : in std_logic; --de10lite clock 50MHz
		reset : in std_logic;
		h_sync : out std_logic;
		v_sync : out std_logic;
		color : out rgb_color;
		sw9 : in std_logic
	);
end entity top_level;

architecture rtl of top_level is
	signal pll_clk_out : std_logic; --clock from pll to vga
	signal point : coordinate; --current point on vga
	signal point_valid : boolean; --if point is in visible area
	signal stage_output : StageTypeVector(0 to pipeline_len);
	signal seed : ads_complex;
	signal iteration_count : natural;
begin
	pll_inst: entity work.vga_pll
		port map(
			inclk0 => onboard_clock, --input 50Mhz clock
			c0 => pll_clk_out --vga clock output
		);
		
	vga_fsm_inst: entity work.vga_fsm
		generic map(
			vga_res => vga_res
		)
		port map(
			vga_clock => pll_clk_out,
			reset => reset,
			point => point,
			point_valid => point_valid,
			h_sync => h_sync,
			v_sync => v_sync
		);
		
	data_gen_inst: entity work.data_generation
		generic map(
			vga_res => vga_res
		)
		port map(
			clk => pll_clk_out,
			reset => reset,
			mode => sw9,
			point => point,
			seed => seed
		);
		
	-- hardcoded for Mandelbrot set
	stage_output(0).z <= complex_zero when sw9 = '0' else seed;
	stage_output(0).c <= seed when sw9 = '0' else ads_cmplx(to_ads_sfixed(-0.5), to_ads_sfixed(-0.5));
	stage_output(0).stage_overflow <= false;
	stage_output(0).stage_data <= 0;

	-- generate all stages
	gen_stages: for i in 0 to pipeline_len - 1 generate
		stage: entity work.pipeline_stage
			generic map (
				threshold =>	to_ads_sfixed(2),
				stage_num =>	i
			)
			port map (
						reset => reset,
						clock => pll_clk_out,
						stage_input => stage_output(i),
						stage_output => stage_output(i+1)
			);
	end generate gen_stages;

	-- generate color output
	color <= 	color_black when stage_output(pipeline_len).stage_data <= 1
			else	get_color(2, 2) when stage_output(pipeline_len).stage_data <= 3
			else	get_color(2, 1) when stage_output(pipeline_len).stage_data <= 5
			else	get_color(2, 0) when stage_output(pipeline_len).stage_data <= 7
			else	get_color(1, 3) when stage_output(pipeline_len).stage_data <= 9
			else	get_color(1, 2) when stage_output(pipeline_len).stage_data <= 12
			else  get_color(1, 1) when stage_output(pipeline_len).stage_data <= 15
			else	get_color(1, 0);

					
end architecture rtl;