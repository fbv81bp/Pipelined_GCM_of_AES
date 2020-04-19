library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity multHandXor_TestBench is
    --Port ();
end multHandXor_TestBench;

architecture Behavioral of multHandXor_TestBench is

    component multHandXor is
        Generic ( log2stages : integer);
        Port ( reset : in STD_LOGIC;
               clock : in STD_LOGIC;
               start_in : in std_logic;
               frame_length_in : in std_logic_vector(31 downto 0);
               empty_out : out std_logic;
               load_in : in std_logic;
               add_in : in STD_LOGIC_VECTOR (127 downto 0);
               ready_out : out std_logic;
               mac_out : out STD_LOGIC_VECTOR (127 downto 0));
    end component;

    constant log2stages : integer := 2;
    signal reset :  STD_LOGIC := '0';
    signal clock :  STD_LOGIC := '1';
    signal start_in :  std_logic := '0';
    signal frame_length_in :  std_logic_vector(31 downto 0) := x"0000001e"; --30
    signal empty_out :  std_logic;
    signal load_in :  std_logic := '0';
    signal add_in :  STD_LOGIC_VECTOR (127 downto 0) := (others => '0');
    signal ready_out :  std_logic;
    signal mac_out :  STD_LOGIC_VECTOR (127 downto 0);
    signal passed : std_logic;


begin

dut : multHandXor
        Generic Map (log2stages)
        Port Map ( reset,clock,start_in,frame_length_in,empty_out,load_in,add_in,ready_out,mac_out);

passed <= '1' when mac_out = x"e7c44b5b116310a491cd47073db6c298" else '0';

reset_proc : process begin
    wait for 5 ns;
    reset <= '1';
    wait for 100ns;
    reset <= '0';
    wait;
end process;

clock_proc : process begin
    wait for 5ns;
    clock <= not clock;
end process;

process(clock) begin
    if rising_edge(clock) then
        if reset = '1' then
            add_in <= x"00000000000000000000000000000005";
        elsif empty_out = '1' then
            add_in <= add_in + '1';
        end if;
    end if;
end process;

start_in <= '1';
load_in <= '1';

end Behavioral;
