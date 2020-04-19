----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.01.2020 05:04:19
-- Design Name: 
-- Module Name: aesSpeed - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity aesSpeed is
    Port ( clock : in STD_LOGIC;
           addIn0, addIn1  : in STD_LOGIC_VECTOR (127 downto 0);
           mixOut : out STD_LOGIC_VECTOR (127 downto 0));
end aesSpeed;

architecture Behavioral of aesSpeed is

	signal add, sub, shift, mix : std_logic_vector(127 downto 0);
	signal addReg, subReg, shiftReg : std_logic_vector(127 downto 0);
	type stateRowT is array (0 to 3) of std_logic_vector(7 downto 0);
	type stateT is array (0 to 3) of stateRowT;
	signal shiftInState, shiftOutState: stateT;

begin

process(clock)
begin
    if rising_edge(clock) then
        mixOut <= mix;
        addReg <= add;
        subReg <= sub;
        shiftReg <= shift;
    end if;
end process;

add <= addIn0 xor addIn1;


--SUB BYTES TRANSFORM
--encryption's synchron circuitry
subBytes: for i in 0 to 15 generate
	type subT is array(0 to 255) of std_logic_vector(7 downto 0);
	constant subRam : subT := (
		x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5", x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
		x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0", x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
		x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc", x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
		x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a", x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
		x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0", x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
		x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b", x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
		x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85", x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
		x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5", x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
		x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17", x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
		x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88", x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
		x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c", x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
		x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9", x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
		x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6", x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
		x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e", x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
		x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94", x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
		x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68", x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16");
begin
    sub(8*(i+1)-1 downto 8*i) <= subRam(conv_integer(addReg(8*(i+1)-1 downto 8*i)));
end generate;

--SHIFT ROWS TRANSFORM
shiftGenCol:for row in 0 to 3 generate
begin
	shiftGenRow:for col in 0 to 3 generate
	begin
		--shifter input signals
		shiftInState(3-col)(3-row) <= subReg(32*col+8*(row+1)-1 downto 32*col+8*row);
		--shifter output signals
		shift(32*col+8*(row+1)-1 downto 32*col+8*row) <= shiftOutState(3-col)(3-row);
	end generate;
end generate;
shiftOutState(0)(0) <= shiftInState(0)(0);
shiftOutState(0)(1) <= shiftInState(1)(1);
shiftOutState(0)(2) <= shiftInState(2)(2);
shiftOutState(0)(3) <= shiftInState(3)(3);
shiftOutState(1)(0) <= shiftInState(1)(0);
shiftOutState(1)(1) <= shiftInState(2)(1);
shiftOutState(1)(2) <= shiftInState(3)(2);
shiftOutState(1)(3) <= shiftInState(0)(3);
shiftOutState(2)(0) <= shiftInState(2)(0);
shiftOutState(2)(1) <= shiftInState(3)(1);
shiftOutState(2)(2) <= shiftInState(0)(2);
shiftOutState(2)(3) <= shiftInState(1)(3);
shiftOutState(3)(0) <= shiftInState(3)(0);
shiftOutState(3)(1) <= shiftInState(0)(1);
shiftOutState(3)(2) <= shiftInState(1)(2);
shiftOutState(3)(3) <= shiftInState(2)(3);

--MIX COLUMNS TRANSFORM
mixColumns : for i in 0 to 3 generate
	signal xi, xo : std_logic_vector(31 downto 0);
	signal s0i, s1i, s2i, s3i, s0o, s1o, s2o, s3o : std_logic_vector(7 downto 0);
	signal s0x2, s1x2, s2x2, s3x2, s0x3, s1x3, s2x3, s3x3 : std_logic_vector(7 downto 0);
begin
	xi <= shiftReg(32*(i+1)-1 downto 32*i);
	s0i <= xi(31 downto 24);
	s1i <= xi(23 downto 16);
	s2i <= xi(15 downto 8);
	s3i <= xi(7 downto 0);
	--multiplication by two over Galois field
	s0x2 <= s0i(6 downto 0) & '0' when s0i(7) = '0' else (s0i(6 downto 0) & '0') xor "00011011";
	s1x2 <= s1i(6 downto 0) & '0' when s1i(7) = '0' else (s1i(6 downto 0) & '0') xor "00011011";
	s2x2 <= s2i(6 downto 0) & '0' when s2i(7) = '0' else (s2i(6 downto 0) & '0') xor "00011011";
	s3x2 <= s3i(6 downto 0) & '0' when s3i(7) = '0' else (s3i(6 downto 0) & '0') xor "00011011";
	--multiplication by three over Galois field: addition of times 1 and times 2
	s0x3 <= s0i xor s0x2;
	s1x3 <= s1i xor s1x2;
	s2x3 <= s2i xor s2x2;
	s3x3 <= s3i xor s3x2;
	--addition over Galois field
	s0o <= s0x2 xor s1x3 xor s2i xor s3i;
	s1o <= s0i xor s1x2 xor s2x3 xor s3i;
	s2o <= s0i xor s1i xor s2x2 xor s3x3;
	s3o <= s0x3 xor s1i xor s2i xor s3x2;
	xo <= s0o & s1o & s2o & s3o;
	mix(32*(i+1)-1 downto 32*i) <= xo;
end generate;

end Behavioral;
