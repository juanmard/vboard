library ieee;
context ieee.ieee_std_context;

use work.ICE40_components.all;
use work.Icestick_PLL_cfg.all;

entity Icestick_Top is
  generic (
    SCREEN : natural := 22
  );
  port (
    CLK : in std_logic; -- System clock (12Mhz)

    PMOD7 : out std_logic; -- VGA vsync
    PMOD8 : out std_logic; -- VGA HSync
    PMOD1 : out std_logic; -- VGA R
    PMOD2 : out std_logic; -- VGA G
    PMOD3 : out std_logic; -- VGA B

    LED1 : out std_logic;
    LED2 : out std_logic;
    LED3 : out std_logic;
    LED4 : out std_logic;
    LED5 : out std_logic
  );
end;

architecture arch of Icestick_Top is

  constant PLL_cfg : PLL_config_t := PLL_configs(screen_configs(SCREEN));

  signal clki : std_logic;
  signal rgb  : std_logic_vector(2 downto 0);

begin

  PLL_0: PLL
  generic map (
    DIVF => to_unsigned( PLL_cfg.DIVF, 7),
    DIVQ => to_unsigned( PLL_cfg.DIVQ, 3)
  )
  port map (
    clki => CLK,
    clko => clki
  );

  UUT: entity work.vga_pattern
  generic map (
    G_SCREEN => SCREEN
  )
  port map (
    CLK   => clki,
    EN    => '1',
    RST   => '0',
    HSYNC => PMOD8,
    VSYNC => PMOD7,
    RGB   => rgb
  );

  PMOD1 <= rgb(2);
  PMOD2 <= rgb(1);
  PMOD3 <= rgb(0);

  LED1 <= '0';
  LED2 <= '0';
  LED3 <= '0';
  LED4 <= '0';
  LED5 <= '1';

end;
