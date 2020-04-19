library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multHpipe is
    Port ( clock : in STD_LOGIC;
           X_in : in STD_LOGIC_VECTOR (127 downto 0) := x"0000000000000400000000000000000a";
           Y_in : in STD_LOGIC_VECTOR (127 downto 0) := x"0000000000003000000000000000000b";
           Z_out : out STD_LOGIC_VECTOR (127 downto 0));--x"2a7000000002b53000000000018000f4"
end multHpipe;

architecture Behavioral of multHpipe is
    type arrT is array(0 to 128) of std_logic_vector(127 downto 0);
    signal y, z : arrT;
    constant r : std_logic_vector(7 downto 0) := "10000111";
    --testing
    --signal clock : std_logic := '1';

begin

z(0) <= (others => '0');

gen : for i in 0 to 127 generate
    process(clock) begin
        if rising_edge(clock) then
            y(0)(127-i) <= Y_in(i);
            
--          z(i+1) <= z(i) when X_in(127-i) = '0' else (z(i) xor y(i));
            if X_in(127-i) = '0' then
                z(i+1) <= z(i);
            else
                z(i+1) <= z(i) xor y(i);
            end if;
--          y(i+1) <= (y(i)(126 downto 0) & '0') when y(i)(127) = '0' else (y(i)(126 downto 7) & ((y(i)(6 downto 0) & '0') xor r));
            if y(i)(127) = '0' then
                y(i+1) <= (y(i)(126 downto 0) & '0');
            else
                y(i+1) <= (y(i)(126 downto 7) & ((y(i)(6 downto 0) & '0') xor r));
            end if;

            Z_out(127-i) <= z(128)(i);
        end if;
    end process;
end generate;

--testing
--process begin
--    wait for 5 ns;
--    clock <= not clock;
--end process;

end Behavioral;


