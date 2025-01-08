package color_data is

	subtype color_channel_type is natural range 0 to 15;

	type rgb_color is
	record
		red:	color_channel_type;
		green:	color_channel_type;
		blue:	color_channel_type;
	end record rgb_color;

	-- NOTE: on your toplevel you can define an output as
	-- 
	-- color: out rgb_color;
	--
	-- then on pin placement:
	--
	-- set_location_assignment PIN_XXXX -to color.red[0]
	-- set_location_assignment PIN_YYYY -to color.red[1]
	--
	-- and so on (use loops to simplify the work!)

	constant color_black: rgb_color :=
		( red =>  0, green =>  0, blue =>  0 );
	constant color_red: rgb_color :=
		( red => 15, green =>  0, blue =>  0 );
	constant color_green: rgb_color :=
		( red =>  0, green => 15, blue =>  0 );
	constant color_blue: rgb_color :=
		( red =>  0, green =>  0, blue => 15 );

	type color_table_type is array(natural range 0 to 3) of rgb_color;
	constant color_table_1: color_table_type := (
			0 => ( red =>  0, green =>  0, blue =>  15 ),
			1 => ( red =>  1, green =>  1, blue =>  14 ),
			2 => ( red =>  2, green =>  2, blue =>  13 ),
			3 => ( red =>  3, green =>  3, blue =>  12 )
			-- TODO: add as many entries as you plan to have
			-- stages/computational units! (mind the commas!)
		);

	constant color_table_2: color_table_type := (
			-- TODO: needs more color, must have same number of entries as the
			-- previous table
			0 => ( red =>  15, green =>  0, blue =>  15 ),
			1 => ( red =>  15, green =>  0, blue =>  13 ),
			2 => ( red =>  15, green =>  0, blue =>  11 ),
			3 => ( red =>  15, green =>  0, blue =>  9 )
		);

	type color_palette_type is array(natural range 0 to 3) of color_table_type;
	constant color_palette_table: color_palette_type := (
			0 => color_table_1,
			1 => color_table_2,
			2 => (
				0 => ( red => 15, green =>  0, blue =>  7 ),
				1 => ( red => 15, green =>  0, blue =>  5 ),
				2 => ( red => 15, green =>  0, blue =>  3 ),
				3 => ( red => 15, green =>  0, blue =>  1 )
			),
			3 => (
				0 => ( red => 15, green =>  0, blue =>  0 ),
				1 => ( red => 14, green =>  1, blue =>  0 ),
				2 => ( red => 13, green =>  2, blue =>  0 ),
				3 => ( red => 12, green =>  3, blue =>  0 )
				-- TODO: add more colors, must have same number of entries as
				-- previous tables
			)
		);

	subtype color_index_type is natural range color_table_1'range;
	subtype palette_index_type is natural range color_palette_table'range;

	function get_color (
			palette_index: in palette_index_type;
			color_index: in color_index_type
		) return rgb_color;

	function get_palette (
			palette_index: in palette_index_type
		) return color_table_type;

end package color_data;


package body color_data is

	function get_color (
			palette_index: in palette_index_type;
			color_index: in color_index_type
		) return rgb_color
	is
	begin
		-- TODO: return a color from the provided color palette
		return get_palette(palette_index)(color_index);
		
	end function get_color;

	function get_palette (
			palette_index: in palette_index_type
		) return color_table_type
	is
	begin
		-- TODO: return something from the color palette table
		return color_palette_table(palette_index);
	end function get_palette;

end package body color_data; 
