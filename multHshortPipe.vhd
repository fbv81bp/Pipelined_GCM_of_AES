library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity multHshortPipe is
    Generic ( log2stages : integer);
    Port ( reset : in STD_LOGIC;
           clock : in STD_LOGIC;
           empty_out : out std_logic;
           load_in : in std_logic;
           x_in : in STD_LOGIC_VECTOR (127 downto 0);
           y_in : in STD_LOGIC_VECTOR (127 downto 0);
           ready_out : out std_logic;
           z_out : out STD_LOGIC_VECTOR (127 downto 0));
end multHshortPipe;

architecture Behavioral of multHshortPipe is

    type pipeT is array(2**log2stages-1 downto 0) of std_logic_vector(127 downto 0);
    signal x, y, z : pipeT;
    constant r : std_logic_vector(7 downto 0) := "10000111";
    signal empty, ready : std_logic;
    type stateT is array(2**log2stages-1 downto 0) of std_logic_vector(6-log2stages downto 0);
    signal state : stateT;
    constant theEnd : std_logic_vector(6-log2stages downto 0) := (others => '1');
    constant zero : std_logic_vector(6-log2stages downto 0) := (others => '0');
    signal z_out_i : std_logic_vector(127 downto 0);
    
begin

control : process(clock) begin
    if rising_edge(clock) then
        if reset = '1' then
            for j in 0 to 2**log2stages-1 loop
                state(j) <= theEnd;
            end loop;
        else
            if empty = '1' then
                if load_in = '1' then
                    state <= state(state'high-1 downto 0) & zero;
                else
                    state <= state(state'high-1 downto 0) & state(state'high);
                end if;
            else
                state <= state(state'high-1 downto 0) & (state(state'high) + '1');
            end if;
        end if;
    end if;
end process;

empty <= '1' when state(state'high) = theEnd else '0';
--enable <= '1' when state(state'low) = theEnd else '0';
ready <= empty;
empty_out <= empty;

--z(0) <= (others => '0')          when empty = '1'       else 
--        z(z'high)                when x(x'high)(0) = '0' else
--        z(z'high) xor y(y'high);
pipeline : for i in 0 to 2**log2stages-2 generate
    stages : process(clock) begin
        if rising_edge(clock) then
            x(i+1) <= '0' & x(i)(127 downto 1);
            if x(i)(0) = '0' then
                z(i+1) <= z(i);
            else
                z(i+1) <= z(i) xor y(i);
            end if;
            if y(i)(127) = '0' then
                y(i+1) <= (y(i)(126 downto 0) & '0');
            else
                y(i+1) <= (y(i)(126 downto 7) & ((y(i)(6 downto 0) & '0') xor r));
            end if;
        end if;
    end process;
end generate;

feedback_and_output : process(clock) begin
    if rising_edge(clock) then
        if empty = '1' and load_in = '1' then
            for k in 0 to 127 loop
                y(0)(127-k) <= y_in(k);
                x(0)(127-k) <= x_in(k);
                z(0) <= (others => '0');
            end loop;
        else
            x(0) <= '0' & x(x'high)(127 downto 1);
            if y(y'high)(127) = '0' then
                y(0) <= (y(y'high)(126 downto 0) & '0');
            else
                y(0) <= (y(y'high)(126 downto 7) & ((y(y'high)(6 downto 0) & '0') xor r));
            end if;
--        z(z'high)                when x(x'high)(0) = '0' else
--        z(z'high) xor y(y'high);
            if x(x'high)(0) = '0' then
                z(0) <= z(z'high);
            else
                z(0) <= z(z'high) xor y(y'high);
            end if;
        end if;
--        if ready = '1' then
--            if x(x'high)(0) = '0' then
--                z_out_i <= z(z'high);
--            else
--                z_out_i <= z(z'high) xor y(y'high);
--            end if;                
--        end if;
    end if;
end process;

ready_out <= ready;
z_out_i <= (others => '0') when ready = '0' else
            z(z'high) when x(x'high)(0) = '0' else
            z(z'high) xor y(y'high);

out_endianness: for l in 0 to 127 generate
    z_out(127-l) <= z_out_i(l);
end generate;

end Behavioral;
