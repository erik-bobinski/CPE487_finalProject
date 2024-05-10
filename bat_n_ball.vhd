LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.Numeric_Std;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ball_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current ball x position
        serve : IN STD_LOGIC; -- initiates serve
        SW: IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- Switches
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        hits : OUT std_logic_vector (15 DOWNTO 0);
        current_time : OUT std_logic_vector (15 DOWNTO 0)
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    CONSTANT jump_height : INTEGER := 275; -- height of ball jump in pixels
    CONSTANT initial_bat_speed : INTEGER := 12; -- initial bat speed in pixels
    CONSTANT initial_ball_speed : INTEGER := 14; -- initial ball speed in pixels
    CONSTANT bat_h : INTEGER := 10; -- bat height in pixels
    SIGNAL bat_w : INTEGER := 70; -- bat width in pixels

    SIGNAL bat_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(790, 11); -- start on far right of screen offest from others
    SIGNAL bat_x1 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(820, 11); -- start on far right of screen offest from others
    SIGNAL bat_x2 : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(860, 11); -- start on far right of screen offset from others

    -- distance ball moves each frame
    SIGNAL ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(initial_ball_speed, 11); 
    -- distance bat moves each frame
    SIGNAL bat_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(initial_bat_speed, 11); -- starts at 10 and increases by 4 every 10 seconds
    
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
    
    -- timer for game
    signal timer_on : std_logic;
    signal counter_reg : std_logic_vector(29 downto 0);
    signal seconds_one : std_logic_vector(3 downto 0);
    signal seconds_ten : std_logic_vector(3 downto 0);
    signal seconds_hun : std_logic_vector(3 downto 0);
    signal seconds_tho : std_logic_vector(3 downto 0);

BEGIN
    red <= bat_on OR bat_on1 OR bat_on2; -- color setup for red ball and cyan bat on white background
    green <= ball_on;
    blue <= ball_on;

    counter : process (clk)
    begin
        if rising_edge(clk) then
            if serve = '1' AND game_on = '0' then
                counter_reg <= (others => '0');
                seconds_one <= (others => '0');
                seconds_ten <= (others => '0');
                seconds_hun <= (others => '0');
                seconds_tho <= (others => '0');
            end if;
            if game_on = '1' then
                if conv_integer(counter_reg) = 99999999 then
                    counter_reg <= (others => '0');
                    seconds_one <= seconds_one + "0001";  -- Increment seconds directly
                    if seconds_one = "1001" then  -- Reset seconds after reaching 9 (4-bit limit)
                        seconds_one <= (others => '0');
                        seconds_ten <= seconds_ten + "0001";
                        -- increase bat speed by 4  speed every 10 seconds, caps at 40
                        if bat_speed < 40 then
                            bat_speed <= bat_speed + 8;
                        end if;
                        if seconds_ten = "1001" then
                            seconds_ten <= (others => '0');
                            seconds_hun <= seconds_hun + "0001";
                            if seconds_hun = "1001" then
                                seconds_hun <= (others => '0');
                                seconds_tho <= seconds_tho + "0001";
                            end if;
                        end if;
                    end if;
                else
                    counter_reg <= counter_reg + 1;
                end if;
                -- Update to represent current time, display will show it
                current_time(15 downto 12) <= seconds_tho; 
                current_time(11 downto 8) <= seconds_hun;
                current_time(7 downto 4) <= seconds_ten;
                current_time(3 downto 0) <= seconds_one;
            end if;
        end if;
        
    end process;

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
            bat_x <= CONV_STD_LOGIC_VECTOR(810, 11);
            bat_y <= conv_std_logic_vector((conv_integer(rand_platform_y)*7)mod 250 + 325,11);
        ELSE
            bat_x <= bat_x - bat_motion;
        END IF;
    END PROCESS;

    mplatform1 : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        if game_on = '0' OR bat_x1 < 25 THEN
            bat_x1 <= CONV_STD_LOGIC_VECTOR(790, 11);
            bat_y1 <= conv_std_logic_vector((conv_integer(rand_platform_y)*41)mod 250 + 325,11);
        ELSE
            bat_x1 <= bat_x1 - bat_motion;
        END IF;
    END PROCESS;

    mplatform2 : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        if game_on = '0' OR bat_x2 < 25 THEN
            bat_x2 <= CONV_STD_LOGIC_VECTOR(860, 11);
            bat_y2 <= conv_std_logic_vector((conv_integer(rand_platform_y)*29)mod 250 + 325,11);
        ELSE
            bat_x2 <= bat_x2 - bat_motion;
        END IF;
    END PROCESS;

    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        -- Changing ball speed here - reads value from switches
        -- only update ball position if ball is travling up and ball is 
        IF (SW(0) = '1' OR SW(1) = '1' OR SW(2) = '1' OR SW(3) = '1') THEN
            -- map each switch to be a different level of difficulty with sw[0] being easiest and sw[3] being hardest by updating ball gravity (speed)
            if SW(0) = '1' then
                ball_speed <= CONV_STD_LOGIC_VECTOR (8, 11);
            elsif SW(1) = '1' then
                ball_speed <= CONV_STD_LOGIC_VECTOR (initial_bat_speed, 11);
            elsif SW(2) = '1' then 
                ball_speed <= CONV_STD_LOGIC_VECTOR (16, 11);
            elsif SW(3) = '1' then
                ball_speed <= CONV_STD_LOGIC_VECTOR (20, 11);
            end if;
        END IF;
        
        WAIT UNTIL rising_edge(v_sync);
        
        -- if no difficulty is selected, set ball speed to default (level 2)
        IF (ball_speed(0) = '0' AND ball_speed(1) = '0' AND ball_speed(2) = '0' 
        AND ball_speed(3) = '0')  THEN   
            ball_speed <= CONV_STD_LOGIC_VECTOR (initial_bat_speed, 11);
        END IF;
        
        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            -- WHEN GAME RESETS!
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            checker <= '0';
            bat_speed <= CONV_STD_LOGIC_VECTOR(initial_bat_speed, 11); -- rest bat speed
        ELSIF ball_y <= last_contact_y - jump_height THEN -- bounce off top wall (in our case it bounces once it reaches peak height which is 250px above last contact point)
            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
            checker <= '0';
        ELSIF ball_y + bsize >= 600 THEN 
            -- WHEN GAME IS OVER, if ball meets bottom wall
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            checker <= '0';
            game_on <= '0'; -- and make ball disappear.
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
                ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        END IF;
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to and zero ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(200, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
    END PROCESS;
    
    randomizer: PROCESS IS
        VARIABLE rand : INTEGER;      
        BEGIN
        WAIT UNTIL (falling_edge(v_sync));
        rand_clock <= rand_clock + 10; -- increment clock every clock cycle(not sure if a certain increment value would best for max variation)
        -- may need to include an actual counter variable to make it more random actually change
        -- not including bat_x bc it only ever resets once ball_x is at 800 (i think that's how it works?)
        if game_on = '1' then -- only apply randomness to the platforms' y-pos when the game is active; sometimes causes issue where a bat spawns at upper-right of screen
            rand := (conv_integer(counter_reg(10 downto 0) XOR pixel_row 
            XOR pixel_col 
            XOR ball_y
            XOR ball_x 
            XOR hit_counter(10 downto 0) 
            XOR rand_clock) mod 250) + 325; -- random number between 325 and 575
            rand_platform_y <= conv_std_logic_vector(rand, 11);
        end if;
    END PROCESS;
END Behavioral; 