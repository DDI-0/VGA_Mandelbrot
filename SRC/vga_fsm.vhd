library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

entity vga_fsm is
    generic (
        vga_res : vga_timing := vga_res_default  -- VGA resolution
    );
    port (
        -- Clock and reset
        vga_clock  : in std_logic;               -- VGA pixel clock from PLL
        reset      : in std_logic;               -- Asynchronous active-low reset

        -- VGA coordinate outputs
        point      : out coordinate;             -- Current point on the screen
        point_valid: out boolean;                -- True if point is in the visible area

        -- VGA sync outputs
        h_sync     : out std_logic;              -- VGA horizontal sync signal
        v_sync     : out std_logic               -- VGA vertical sync signal
    );
end entity vga_fsm;

architecture fsm of vga_fsm is
    -- Internal signal to track the current point (coordinate)
    signal current_point : coordinate := make_coordinate(0, 0);

begin
    -- VGA FSM process
    process (vga_clock, reset)
    begin
        if reset = '0' then -- Active-low reset
            -- Reset all outputs and internal states
            current_point <= make_coordinate(0, 0);
            point <= make_coordinate(0, 0);
            point_valid <= false;
            h_sync <= '0';
            v_sync <= '0';
        elsif rising_edge(vga_clock) then
            -- Update the current point
            current_point <= next_coordinate(current_point, vga_res);
            point <= current_point;

            -- Determine visibility of the current point
            point_valid <= point_visible(current_point, vga_res);

            -- Generate sync signals
            h_sync <= do_horizontal_sync(current_point, vga_res);
            v_sync <= do_vertical_sync(current_point, vga_res);
        end if;
    end process;

end architecture fsm;
