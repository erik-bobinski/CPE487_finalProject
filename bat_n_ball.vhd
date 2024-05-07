LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.Numeric_Std;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ball_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current ball x position
        serve : IN STD_LOGIC; -- initiates serve
        SW: IN STD_LOGIC_VECTOR (4 DOWNTO 0); -- Switches
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        hits : OUT std_logic_vector (15 DOWNTO 0)
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    SIGNAL bat_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(800, 11); -- start on far right of screen
    SIGNAL bat_x1 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(800, 11); -- start on far right of screen
    SIGNAL bat_x2 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(800, 11); -- start on far right of screen

    SIGNAL bat_w : INTEGER := 50; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 10; -- bat height in pixels
    -- distance ball moves each frame
    SIGNAL ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (16, 11); 
    -- distance bat moves each frame
    SIGNAL bat_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (15, 11); 
    
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL bat_on1 : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL bat_on2 : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    -- current ball position - intitialized to center of screen
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(250, 11);
    -- bat vertical position, there are 3 bats
    SIGNAL bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    SIGNAL bat_y1 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(550, 11);
    SIGNAL bat_y2 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);

    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    -- current bat motion - initialized to (+ bat_speed) pixels/frame in X direction
    SIGNAL bat_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := bat_speed;
    
    SIGNAL hit_counter : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL checker : STD_LOGIC := '0'; --force to wait until ball bounce

    -- keep track of last y contact so they can't counce too high
    SIGNAL last_contact_y: STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);

    -- randomizer for platform
    SIGNAL rand_platform_y : STD_LOGIC_VECTOR(10 downto 0);
    SIGNAL rand_clock : STD_LOGIC_VECTOR(10 downto 0); -- a clock that increments every clock cycle to assist RNG
BEGIN
    red <= bat_on OR bat_on1 OR bat_on2; -- color setup for red ball and cyan bat on white background
    green <= ball_on;
    blue <= ball_on;

    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    platformdraw : PROCESS (bat_x, bat_x1, bat_x2, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;

        -- added for 2nd bats
        IF ((pixel_col >= bat_x1 - bat_w) OR (bat_x1 <= bat_w)) AND
         pixel_col <= bat_x1 + bat_w AND
             pixel_row >= bat_y1 - bat_h AND
             pixel_row <= bat_y1 + bat_h THEN
                bat_on1 <= '1';
        ELSE
            bat_on1 <= '0';
        END IF;

        -- added for 3rd bats
        IF ((pixel_col >= bat_x2 - bat_w) OR (bat_x2 <= bat_w)) AND
         pixel_col <= bat_x2 + bat_w AND
             pixel_row >= bat_y2 - bat_h AND
             pixel_row <= bat_y2 + bat_h THEN
                bat_on2 <= '1';
        ELSE
            bat_on2 <= '0';
        END IF;

    END PROCESS;

    mplatform : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        -- process to move bat from left to right side of screen
        if game_on = '0' OR bat_x < 25 THEN
            bat_x <= CONV_STD_LOGIC_VECTOR(800, 11);
            bat_y <= rand_platform_y;
        ELSE
            bat_x <= bat_x - bat_motion;
        END IF;
    END PROCESS;

    mplatform1 : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        if game_on = '0' OR bat_x1 < 25 THEN
            bat_x1 <= CONV_STD_LOGIC_VECTOR(750, 11);
            bat_y1 <= rand_platform_y+20;
        ELSE
            bat_x1 <= bat_x1 - bat_motion;
        END IF;
    END PROCESS;

    mplatform2 : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        if game_on = '0' OR bat_x2 < 25 THEN
            bat_x2 <= CONV_STD_LOGIC_VECTOR(600, 11);
            bat_y2 <= rand_platform_y - 20;
        ELSE
            bat_x2 <= bat_x2 - bat_motion;
        END IF;
    END PROCESS;

    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        -- FIXME: Changing ball speed here - reads value from switches
        -- only update ball position if ball is travling up and ball is 
        ball_speed <= "00000000001";
        IF (SW(0) = '1' OR SW(1) = '1' OR SW(2) = '1'  OR SW(3) = '1' OR SW(4) = '1') THEN
            ball_speed(0) <= SW(0);
            ball_speed(1) <= SW(1);
            ball_speed(2) <= SW(2);
            ball_speed(3) <= SW(3);
            ball_speed(4) <= SW(4);
        END IF;
        
        WAIT UNTIL rising_edge(v_sync);
        
        IF (ball_speed(0) = '0' AND ball_speed(1) = '0' AND ball_speed(2) = '0' 
        AND ball_speed(3) = '0' AND ball_speed(4) = '0')  THEN
            
            ball_speed <= ball_speed + 1;
            
        END IF;
        
        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            hit_counter <= "0000000000000001";
            hits <= hit_counter;
            checker <= '0';
        ELSIF ball_y <= last_contact_y - 250 THEN -- bounce off top wall (in our case it bounces once it reaches peak height which is 250px above last contact point)
            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
            checker <= '0';
        ELSIF ball_y + bsize >= 600 THEN -- if ball meets bottom wall
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            checker <= '0';
            game_on <= '0'; -- and make ball disappear.
            hit_counter <= "0000000000000000";
            hits <= hit_counter;
        END IF;
        -- allow for bounce off bat, bat1, and bat2
        IF  ((ball_x + bsize/2) >= (bat_x - bat_w) AND
            (ball_x - bsize/2) <= (bat_x + bat_w) AND
            (ball_y + bsize/2) >= (bat_y - bat_h) AND
            (ball_y - bsize/2) <= (bat_y + bat_h) AND checker = '0') OR 
            ((ball_x + bsize/2) >= (bat_x1 - bat_w) AND
            (ball_x - bsize/2) <= (bat_x1 + bat_w) AND
            (ball_y + bsize/2) >= (bat_y1 - bat_h) AND
            (ball_y - bsize/2) <= (bat_y1 + bat_h) AND checker = '0') OR
            ((ball_x + bsize/2) >= (bat_x2 - bat_w) AND
            (ball_x - bsize/2) <= (bat_x2 + bat_w) AND
            (ball_y + bsize/2) >= (bat_y2 - bat_h) AND
            (ball_y - bsize/2) <= (bat_y2 + bat_h) AND checker = '0') THEN
                last_contact_y <= ball_y;
                checker <= '1';
                hit_counter <= hit_counter + 1;
                hits <= hit_counter;
                --hits <="0000000000111111";
                ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        END IF;
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close toand  zero ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(250, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
    END PROCESS;

    -- create a function to generate random values
    -- FUNCTION Random_Int (Min, Max: INTEGER) RETURN INTEGER IS
    -- BEGIN
    --     RETURN Min + TRUNC((Max - Min + 1) * RANDOM);
    -- END FUNCTION Random_Int;
    
    
    -- TODO: FIX this randomizer
    randomizer: PROCESS IS
        VARIABLE rand : INTEGER;      
        BEGIN
        WAIT UNTIL (falling_edge(v_sync));
        rand_clock <= rand_clock + 10; -- increment clock every clock cycle(not sure if a certain increment value would best for max variation)
        -- may need to include an actual counter variable to make it more random actually change
        -- not including bat_x bc it only ever resets once ball_x is at 800 (i think that's how it works?)
        if game_on = '1' then -- only apply randomness to the platforms' y-pos when the game is active; sometimes causes issue where a bat spawns at upper-right of screen
            rand := (conv_integer(pixel_row XOR pixel_col XOR ball_y XOR ball_x XOR hit_counter(10 downto 0) XOR rand_clock) mod 250) + 325; -- random number between 325 and 575
            rand_platform_y <= conv_std_logic_vector(rand,11);
        end if;
    END PROCESS;
END Behavioral; 