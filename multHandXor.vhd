library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity multHandXor is
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
end multHandXor;

architecture Behavioral of multHandXor is

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

    signal pipe_empty : std_logic;
    signal load_pipe : std_logic;
    signal x_in : STD_LOGIC_VECTOR (127 downto 0);
    signal y_in : STD_LOGIC_VECTOR (127 downto 0);
    signal pipe_ready : std_logic;
    signal z_out : STD_LOGIC_VECTOR (127 downto 0);

    type HarrayT is array(0 to 2**log2stages-1) of std_logic_vector(127 downto 0);
    signal Harray : HarrayT := (
        x"1234568900000000000000000000abcd",
        x"94800a202228808200000000effc4d9a",
        x"4344a47c5175cda9ecde509d9d516e20",
        x"9e00800000880800df8c088df89aa663"
    );
    
    signal frameLength, lengthCounter : std_logic_vector(31 downto 0);
    signal warmUpCounter, finalizeCounter, flushCounter : std_logic_vector(log2stages-1 downto 0);
    type stateT is (empty, warmUp, run, finalize, flush, ready);
    signal state : stateT := empty;
    signal Haddress : std_logic_vector(log2stages-1 downto 0);
    signal accu : std_logic_vector(127 downto 0);
    constant ones : std_logic_vector(log2stages-1 downto 0) := (others => '1');
    constant zero : std_logic_vector(log2stages-1 downto 0) := (others => '0');
    signal add : std_logic_vector(127 downto 0);
    
begin

    control : process(clock) begin
        if rising_edge(clock) then
            case state is
                when empty =>
                    warmUpCounter <= (others => '0');
                    lengthCounter <= (others => '0');
                    finalizeCounter <= (others => '0');
                    flushCounter <= (others => '0');
                    Haddress <= ones;
                    if start_in = '1' then
                        frameLength <= frame_length_in - x"9";
                        state <= warmUp;
                    end if;

                when warmUp =>
                    if pipe_ready = '1' then
                        if warmUpCounter = ones then
                            state <= run;
                        else
                            warmUpCounter <= warmUpCounter + '1';
                        end if;
                    end if;
                    
                when run =>
                    if pipe_ready = '1' then
                        if lengthCounter = frameLength then
                            state <= finalize;
                        else
                            lengthCounter <= lengthCounter + '1';
                        end if;
                    end if;

                when finalize =>
                    if pipe_ready = '1' then
                        Haddress <= Haddress - '1';
                        if finalizeCounter = ones then
                            state <= flush;
                        else
                            finalizeCounter <= finalizeCounter + '1';
                        end if;
                    end if;
                when flush =>
                    if pipe_ready = '1' then
                        if flushCounter = ones then
                            state <= ready;
                        else
                            flushCounter <= flushCounter + '1';
                        end if;
                    end if;
                    
                when others => --ready
                    state <= empty;

            end case;

            if reset = '1' then
                state <= empty;
            end if;                
        end if;
    end process;
    
    empty_out <= pipe_empty when state = warmUp or state = run or state = finalize else '0';
    load_pipe <= load_in when state = warmUp or state = run or state = finalize else 
                 pipe_ready when state = flush else
                 '0';
    x_in <= add_in when state = warmUp else 
            z_out xor add_in when state = run or state = finalize else
            z_out;
    y_in <= Harray(conv_integer(Haddress));
    
    accumlate : process(clock) begin
        if rising_edge(clock) then
            if state = empty then
                accu <= (others => '0');
            elsif state = flush and pipe_ready = '1' then
                accu <= accu xor z_out;
            end if;
       end  if;
    end process;
    
--    registers : process(clock) begin
--        if rising_edge(clock) then
--        end  if;
--    end process;
       
    mac_out <= accu;
    ready_out <= '1' when state = ready else '0';
    
    pipeline_multiplier : multHshortPipe
        Generic Map (log2stages)
        Port Map (reset, clock, pipe_empty, load_pipe, x_in,y_in, pipe_ready, z_out);

end Behavioral;
