LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec16 IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- which digit to currently display
		data : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 16-bit (4-digit) data, which is the timer information
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	); -- segment code for current digit
END leddec16;

ARCHITECTURE Behavioral OF leddec16 IS
	-- data1-3 are only used for displaying the remaining digits of a 4-digit base 10 number
	-- data4 is the binary value of the current digit
	SIGNAL data1 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL data2 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL data3 : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL data4 : STD_LOGIC_VECTOR (3 DOWNTO 0); -- binary value of current digit
BEGIN
	-- Select digit data to be displayed in this mpx period
	data4 <= 	data(3 downto 0) WHEN dig = "000" ELSE -- digit 0
		data(7 downto 4) WHEN dig = "001" ELSE -- digit 1
		data(11 downto 8) WHEN dig = "010" ELSE -- digit 2
		data(15 downto 12); -- digit 3
	data1 <= data(7 DOWNTO 4);
	data2 <= data(11 DOWNTO 8);
	data3 <= data(15 DOWNTO 12); 
	
	-- Turn on segments corresponding to 4-bit data word
	seg <= 	"0000001" when data4 = "0000" else -- 0
					"1001111" when data4 = "0001" else -- 1
					"0010010" when data4 = "0010" else -- 2
					"0000110" when data4 = "0011" else -- 3
					"1001100" when data4 = "0100" else -- 4
					"0100100" when data4 = "0101" else -- 5
					"0100000" when data4 = "0110" else -- 6
					"0001111" when data4 = "0111" else -- 7
					"0000000" when data4 = "1000" else -- 8
					"0000100" when data4 = "1001" else -- 9
					"0001000" when data4 = "1010" else -- A
					"1100000" when data4 = "1011" else -- B
					"0110001" when data4 = "1100" else -- C
					"1000010" when data4 = "1101" else -- D
					"0110000" when data4 = "1110" else -- E
					"0111000" when data4 = "1111" else -- F
					"1111111";

	-- Turn on anode of 7-segment display addressed by 3-bit digit selector dig
	anode <= "11111110" WHEN dig = "000" ELSE -- 0
					"11111101" WHEN (dig = "001" AND data1 /= "0000") OR (dig ="001" AND data1 = "0000" AND data2  /= "0000") OR (dig ="001" AND data1 = "0000" AND data3  /= "0000")  ELSE  -- 1
					"11111011" WHEN (dig = "010" AND data2 /= "0000") OR (dig = "010" AND data2 = "0000" AND data3 /= "0000")  ELSE -- 2
					"11110111" WHEN dig = "011" AND data3 /= "0000" ELSE -- 3  
	        "11111111";
END Behavioral;