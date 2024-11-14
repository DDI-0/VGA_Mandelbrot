library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

entity computational_unit is
    generic (
        MAX_ITERATIONS : integer := 100  -- Maximum iterations
    );

    port (
        clk      : in std_logic;               -- Clock signal
        reset    : in std_logic;               -- Reset signal
        start    : in std_logic;               -- Start signal for a new computation
        c        : in ads_complex;            -- Input complex number (c)
        z_out    : out ads_complex;           -- Final computed value of z
        is_member: out std_logic;             -- Indicates if c is part of the Mandelbrot Set
        ready    : out std_logic              -- Indicates computation is complete
    );
end entity computational_unit;

architecture behavioral of computational_unit is
    constant THRESHOLD       : ads_sfixed := to_ads_sfixed(4); -- Threshold for ||z||^2

    signal z       : ads_complex := complex_zero;  -- Current value of z
    signal z_re    : ads_sfixed;                   -- Real part of z
    signal z_im    : ads_sfixed;                   -- Imaginary part of z
    signal iteration: integer := 0;               -- Current iteration count
    signal complete: std_logic := '0';            -- Internal ready flag
begin
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset the computational unit
            z <= complex_zero;
            z_re <= to_ads_sfixed(0);
            z_im <= to_ads_sfixed(0);
            iteration <= 0;
            complete <= '0';
            ready <= '0';
            is_member <= '0';
        elsif rising_edge(clk) then
            if start = '1' then
                -- Start a new computation
                z <= complex_zero;
                z_re <= to_ads_sfixed(0);
                z_im <= to_ads_sfixed(0);
                iteration <= 0;
                complete <= '0';
                ready <= '0';
                is_member <= '0';
            elsif complete = '0' then
                -- Separate the real and imaginary parts
                z_re <= z.re;
                z_im <= z.im;

                -- Perform the iterative computation
                z_re <= (z_re * z_re) - (z_im * z_im) + c.re; -- Real part: Re(z^2) + Re(c)
                z_im <= (z_re * z_im * to_ads_sfixed(2)) + c.im; -- Imaginary part: 2*Re(z)*Im(z) + Im(c)

                -- Combine real and imaginary parts back into z
                z <= ads_cmplx(z_re, z_im);

                iteration <= iteration + 1;

                -- Check for escape condition or max iterations
                if abs2(z) > THRESHOLD then
                    complete <= '1';
                    ready <= '1';
                    is_member <= '0'; -- Escaped, not part of Mandelbrot Set
                elsif iteration >= MAX_ITERATIONS then
                    complete <= '1';
                    ready <= '1';
                    is_member <= '1'; -- Bounded, part of Mandelbrot Set
                end if;
            end if;
        end if;
    end process;

    -- Output the final value of z
    z_out <= z;
end architecture behavioral;
