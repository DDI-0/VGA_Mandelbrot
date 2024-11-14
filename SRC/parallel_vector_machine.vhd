library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

entity parallel_vector_machine is
    generic (
        NUM_UNITS : integer := 3; -- Number of computational units
        MAX_ITERATIONS : integer := 100 -- Maximum iterations per unit
    );
    port (
        clk        : in std_logic;                                -- Clock signal
        reset      : in std_logic;                                -- Reset signal
        start      : in std_logic;                                -- Start signal
        points_in  : in ads_complex_vector(NUM_UNITS-1 downto 0); -- Input points for Mandelbrot
        results    : out std_logic_vector(NUM_UNITS-1 downto 0);  -- Membership results
        ready_flag : out std_logic_vector(NUM_UNITS-1 downto 0)   -- Ready flags from units
    );
end entity parallel_vector_machine;

architecture rtl of parallel_vector_machine is
    -- Declare ads_complex_vector locally
    type ads_complex_vector is array (natural range <>) of ads_complex;

    -- Signals for computational units
    signal unit_ready    : std_logic_vector(NUM_UNITS-1 downto 0);
    signal unit_results  : std_logic_vector(NUM_UNITS-1 downto 0);
    signal unit_start    : std_logic_vector(NUM_UNITS-1 downto 0) := (others => '0');
    signal unit_c        : ads_complex_vector(NUM_UNITS-1 downto 0);
    signal z_out         : ads_complex_vector(NUM_UNITS-1 downto 0);

    -- Control signals
    signal computation_started : std_logic := '0';
begin
    -- Instantiate multiple computational units
    gen_units: for i in 0 to NUM_UNITS-1 generate
        comp_unit: entity work.computational_unit
            port map (
                clk      => clk,
                reset    => reset,
                start    => unit_start(i),
                c        => unit_c(i),
                z_out    => z_out(i),
                is_member=> unit_results(i),
                ready    => unit_ready(i)
            );
    end generate;

    -- Control Unit Process
    control_unit: process(clk, reset)
    begin
        if reset = '1' then
            computation_started <= '0';
            unit_start <= (others => '0');
        elsif rising_edge(clk) then
            if start = '1' and computation_started = '0' then
                -- Begin computation: Assign input points and trigger starts
                computation_started <= '1';
                for i in 0 to NUM_UNITS-1 loop
                    unit_c(i) <= points_in(i); -- Assign each point
                    unit_start(i) <= '1';      -- Trigger start for each unit
                end loop;
            elsif computation_started = '1' then
                -- Clear start signals after triggering
                unit_start <= (others => '0');

                -- Monitor ready signals
                for i in 0 to NUM_UNITS-1 loop
                    if unit_ready(i) = '1' then
                        -- Unit i is ready, result can be read
                        unit_start(i) <= '0'; -- Ensure no re-triggering
                    end if;
                end loop;
            end if;
        end if;
    end process;

    -- Output Mapping
    results <= unit_results;
    ready_flag <= unit_ready;

end architecture rtl;
