LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec16 IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- which digit to currently display
		data : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 16-bit (4-digit) data
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- segment code for current digit
END leddec16;

ARCHITECTURE Behavioral OF leddec16 IS
	SIGNAL data4 : STD_LOGIC_VECTOR (3 DOWNTO 0); -- binary value of current digit
BEGIN
	-- Select digit data to be displayed in this mpx period
	data4 <= data(3 DOWNTO 0) WHEN dig = "000" ELSE -- digit 0
	         data(7 DOWNTO 4) WHEN dig = "001" ELSE -- digit 1
	         data(11 DOWNTO 8) WHEN dig = "010" ELSE -- digit 2
	         data(15 DOWNTO 12); -- digit 3
	-- Turn on segments corresponding to 4-bit data word
	seg <= "0000001" WHEN data4 = "0000" ELSE -- 0
	       "0000010" WHEN data4 = "0001" ELSE -- 1
	       "0000011" WHEN data4 = "0010" ELSE -- 2
	       "0000100" WHEN data4 = "0011" ELSE -- 3
	       "0000101" WHEN data4 = "0100" ELSE -- 4
	       "0000110" WHEN data4 = "0101" ELSE -- 5
	       "0000111" WHEN data4 = "0110" ELSE -- 6
	       "0001000" WHEN data4 = "0111" ELSE -- 7
	       "0001001" WHEN data4 = "1000" ELSE -- 8 here
	       "0000100" WHEN data4 = "1001" ELSE -- 9
	       "0001000" WHEN data4 = "1010" ELSE -- A
	       "1100000" WHEN data4 = "1011" ELSE -- B
	       "0110001" WHEN data4 = "1100" ELSE -- C
	       "1000010" WHEN data4 = "1101" ELSE -- D
	       "0110000" WHEN data4 = "1110" ELSE -- E
	       "0111000" WHEN data4 = "1111" ELSE -- F
	       "1111111";
	-- Turn on anode of 7-segment display addressed by 3-bit digit selector dig
	anode <= "11111110" WHEN dig = "000" ELSE -- 0
	         "11111101" WHEN dig = "001" ELSE -- 1
	         "11111011" WHEN dig = "010" ELSE -- 2
	         "11110111" WHEN dig = "011" ELSE -- 3
--	         "11101111" WHEN dig = "100" ELSE -- 4
--	         "11011111" WHEN dig = "101" ELSE -- 5 
--	         "10111111" WHEN dig = "110" ELSE -- 6
--	         "01111111" WHEN dig = "111" ELSE -- 7
	         "11111111";
END Behavioral;

-- Previously leddec.vhd was leddec entity, now it is leddec16 entity

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;

-- ENTITY leddec IS
-- 	PORT (
-- 		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
-- 		data : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- FIXME: Updated to 6 bits
-- 		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
-- 		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
-- 	);
-- END leddec;

-- ARCHITECTURE Behavioral OF leddec IS
-- BEGIN
-- 	-- Turn on segments corresponding to data word
-- 	seg <= data;
-- 	-- 				"0000001" WHEN data = "000000" ELSE -- 0
-- 	-- 				"1001111" WHEN data = "000001" ELSE -- 1
-- 	-- 				"0010010" WHEN data = "000010" ELSE -- 2
-- 	-- 				"0000110" WHEN data = "000011" ELSE -- 3
-- 	-- 				"1001100" WHEN data = "000100" ELSE -- 4
-- 	-- 				"0100100" WHEN data = "000101" ELSE -- 5
-- 	-- 				"0100000" WHEN data = "000110" ELSE -- 6
-- 	-- 				"0001111" WHEN data = "000111" ELSE -- 7
-- 	-- 				"0000000" WHEN data = "001000" ELSE -- 8
-- 	-- 				"0000100" WHEN data = "001001" ELSE -- 9
-- 	-- 				"0001000" WHEN data = "001010" ELSE -- 10
-- 	-- 				"1100000" WHEN data = "001011" ELSE -- 11
-- 	-- 				"0110001" WHEN data = "001100" ELSE -- 12
-- 	-- 				"1000010" WHEN data = "001101" ELSE -- 13
-- 	-- 				"0110000" WHEN data = "001110" ELSE -- 14
-- 	-- 				"0111000" WHEN data = "001111" ELSE -- 15
-- 	-- 				"1000000" WHEN data = "010000" ELSE -- 16
-- 	-- 				"1111001" WHEN data = "010001" ELSE -- 17
-- 	-- 				"1000011" WHEN data = "010010" ELSE -- 18
-- 	-- 				"1100110" WHEN data = "010011" ELSE -- 19
-- 	-- 				"0010011" WHEN data = "010100" ELSE -- 20
-- 	-- 				"0000111" WHEN data = "010101" ELSE -- 21
-- 	-- 				"1001000" WHEN data = "010110" ELSE -- 22
-- 	-- 				"1100001" WHEN data = "010111" ELSE -- 23
-- 	-- 				"0111001" WHEN data = "011000" ELSE -- 24
-- 	-- 				"1001001" WHEN data = "011001" ELSE -- 25
-- 	-- 				"1101000" WHEN data = "011010" ELSE -- 26
-- 	-- 				"0110010" WHEN data = "011011" ELSE -- 27
-- 	-- 				"1110000" WHEN data = "011100" ELSE -- 28
-- 	-- 				"1111000" WHEN data = "011101" ELSE -- 29
-- 	-- 				"1001100" WHEN data = "011110" ELSE -- 30
-- 	-- 				"1110100" WHEN data = "011111" ELSE -- 31
-- 	-- 				"1111100" WHEN data = "100000" ELSE -- 32
-- 	-- 				"1111111"; -- Default case
-- 	--        "1111111";
-- END Behavioral;
