library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multHshortPipe_testBench is
    --Port ();
end multHshortPipe_testBench;

architecture Behavioral of multHshortPipe_testBench is
    
    component multHshortPipe is
        Generic ( log2stages : integer);
        Port ( reset : in STD_LOGIC;
               clock : in STD_LOGIC;
               empty_out : out std_logic;
               load_in : in std_logic;
               x_in : in STD_LOGIC_VECTOR (127 downto 0);
               y_in : in STD_LOGIC_VECTOR (127 downto 0);
               ready_out : out std_logic;
               z_out : out STD_LOGIC_VECTOR (127 downto 0));
    end component;

    constant log2stages : integer := 3;
    signal reset :  STD_LOGIC := '1';
    signal clock :  STD_LOGIC := '1';
    signal empty_out :  std_logic;
    signal load_in :  std_logic := '0';
    signal x_in :  STD_LOGIC_VECTOR (127 downto 0) := x"0000000000000400000000000000000a";
    signal y_in :  STD_LOGIC_VECTOR (127 downto 0) := x"0000000000003000000000000000000b";
    signal ready_out :  std_logic;
    signal z_out :  STD_LOGIC_VECTOR (127 downto 0);
    signal passed : std_logic;

begin

reset_proc : process begin
    wait for 105ns;
    reset <= '0';
end process;

clock_proc : process begin
    wait for 5ns;
    clock <= not clock;
end process;

passed <= '1' when z_out = x"2a7000000002b53000000000018000f4" else '0';

dut : multHshortPipe Generic Map(log2stages) Port Map(reset, clock, empty_out, load_in, x_in, y_in, ready_out, z_out);

load_in <= empty_out;

end Behavioral;
