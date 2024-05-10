
# Lateral Leap (README WORK IN PROGRESS)

Authors: Erik Bobinski, Rumi Loghmani, Shawn Aviles


## Description and Requirements

![IMG_3586](https://github.com/erik-bobinski/CPE487_finalProject/assets/123090127/5501a6f9-430f-40ba-8ee8-3706e47d8123)


- The game consists of three platforms that spawn on the right side of the screen, move to the left side of the screen, then respawn on the right side in a loop. Each time the platforms appear on the right side of the screen, it will respawn with a pseudo-random vertical position. Your objective is to control the lateral movement of the ball as you bounce on these moving platforms to survive as long as possible. You lose the game if the ball falls to the bottom of the screen. A counter of how many bounces you make are stored on the counter of your FPGA.

-  In order to run this game you will need:
    1. Nexys FPGA
    2. A Display, and a VGA cable (or VGA adapter if needed)
    3. Computer with Vivado program, and a micro-USB cable to connect the FPGA to your computer

## File Descriptors

 **_bat_n_ball.vhd_** module is what draws the bats/platforms and the ball, and dictates all of their movements. 
  * Sets the color of the background to black, and the bats to red
  * The *platformdraw* process draws the three different bats if the current pixel row and column overlaps the position of each bat<br>
  * The *mplatform* sets the inital values of each platform and moves them. We set the intial value for y as a pseudo-random number; The x-values of each platform are offset from one another as well.

 **_leddec16.vhd_** is the module that controls what is on the seven segment display. We pass in time information, which are 4 sets of 4 bits that contain the value of each tens place for the timer, in seconds, which we use as the score of the game

 **_pong_2.vhd_* is the top-level module that handles a variety of in-game interactions and edge-cases, and connects the various components of the game together. It establishes horizontal bounds for the ball, since we don't want a player to be able to move off-screen. 

 **_pong_2.xdc_** is the module that holds all the constraints such as: left button, right button, restart button, the difficulty switches, and the display.


## Steps Required to Run Program in Vivado

 ### 1. Create a new RTL project _pong_ in Vivado Quick Start

* Create six new source files of file type VHDL called **_clk_wiz_0_**, **_clk_wiz_0_clk_wiz_**, **_vga_sync_**, **_bat_n_ball_**, **_leddec16_**, and **_pong_2_**

  * clk_wiz_0.vhd and clk_wiz_0_clk_wiz.vhd is similar to Lab 3
 
  * leddec16.vhd is similar to lab 4
  
  * vga_sync.vhd, bat_n_ball.vhd, adc_if.vhd, and pong.vhd are similar to Lab 6

* Create a new constraint file of file type XDC called **_pong_2**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

* Click design sources and copy the VHDL code from clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync.vhd, bat_n_ball.vhd, adc_if.vhd, pong.vhd (or pong_2.vhd)

* Click constraints and copy the code from pong.xdc (or pong_2.xdc)

* As an alternative, you can instead download files from Github and import them into your project when creating the project. The source file or files would still be imported during the Source step, and the constraint file or files would still be imported during the Constraints step.

### 2. Run synthesis

### 3. Run implementation

### 3b. (optional, generally not recommended as it is difficult to extract information from and can cause Vivado shutdown) Open implemented design

### 4. Generate bitstream, open hardware manager, and program device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download pong.bit to the Nexys A7-100T board

* NOW IT'S TIME TO GAME
* ![image](https://github.com/erik-bobinski/CPE487_finalProject/assets/102829545/0fb6dc7b-2105-44d5-924f-b70e6691af50)


* Push BTNC to start the bouncing ball and use BTNR and BTNL in order to move left and right, be sure to try and avoid the ground while using the incoming platforms to stay alive!

## Inputs and Outputs to the Nexys Board

Affects the VGA ports, the buttons, the switches used to modulate difficulty via speed of the game, as well as the segs and anodes for the seven-segment display.

## Project Creation

Using Lab 6 as our base program, all we had to work with initially was a ball and one bat, so the first thing we did was introduce two more bats. All bats share the same width *bat_w*, speed *bat_speed*, as well as three different flags, *bat_on*, *bat_on1*, *bat_on2*, which indicate where to draw each bat. 
![image](https://github.com/erik-bobinski/CPE487_finalProject/assets/123090127/335c2463-3bd9-4bf3-94b0-2349377abf8f)

Instead of controlling the bat, we switches the buttons to control the ball, and have the bats move from right to left and respawn when they hit the left wall. The bats spawn at pseudo-random y locations that are in a range where the ball can reach it.
![image](https://github.com/erik-bobinski/CPE487_finalProject/assets/123090127/b7375ff0-a822-481d-ba2d-70e524b99fef)

Each bat's randomized y position is then multiplied by a prime number, then re-modulo'd in order to introduce more vertical spread on average, while still maintaing reasonable vertical bounds to where the ball can reach it.
![image](https://github.com/erik-bobinski/CPE487_finalProject/assets/123090127/555150a1-cde1-435f-8f27-de58dfd56265)

Below is the final major modification we made, where we track the score of the player based on how long they lasted in their run. The counter keeps track of how long the player is alive for, in seconds. We created a counter that increments each second via the clockrate of the program, which is currently 100MHz. This means that every 100 million clock cycles, we need to increment our counter to account for each passing second. One our score reaches 9 seconds, we set the current digit to 0, then increment the digit in the next slot to the left, to display 10 seconds. The maximum score a player can achieve is 9,999 second. However, the speed of the bat increases by 8 pixels/second every 10 seconds.
![image](https://github.com/erik-bobinski/CPE487_finalProject/assets/123090127/18a856b1-6573-4ac8-a7b3-673556ad7044)


## Difficulties and Conclusion

The program was created based off of the Lab 6 code, so we started with one movable bat and one ball bouncing on it. From there, we needed to implement two additional bats, an incrementing counter each second to track score, pseudo-random bat y location generation.

The counter was the most difficult feature to implement by far. In the base code, the counter was not able to increment each second, and the values were in hexadecimal.
