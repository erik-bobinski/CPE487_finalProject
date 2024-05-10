
# Lateral Leap (README WORK IN PROGRESS)

Authors: Erik Bobinski, Rumi Loghmani, Shawn Aviles


## Description and Requirements

*insert an image here of the game running*

- The game consists of three platforms that spawn on the right side of the screen, move to the left side of the screen, then respawn on the right side in a loop. Each time the platforms appear on the right side of the screen, it will respawn with a pseudo-random vertical position. Your objective is to control the lateral movement of the ball as you bounce on these moving platforms to survive as long as possible. You lose the game if the ball falls to the bottom of the screen. A counter of how many bounces you make are stored on the counter of your FPGA.

-  In order to run this game you will need:
    1. Nexys FPGA
    2. A Display, and a VGA cable (or VGA adapter if needed)
    3. Computer with Vivado program, and a micro-USB cable to connect the FPGA to your computer

## High-Level System Diagram

*insert a high-level block diagram here of the components in our program to show how it generally works, any drawing program could do this*

*description of said diagram*

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

*Prof. Yett's Words: Description of inputs from and outputs to the Nexys board from the Vivado project (10 points of the Submission category).*
*As part of this category, if using starter code of some kind, you should add at least one input and at least one output appropriate to your project to demonstrate your understanding of modifying the ports of your various architectures and components in VHDL as well as the separate .xdc constraints file.*


## Project Creation

*Talk about how we created our project by modifying Lab 6; mention all modifications such as signals, processes, etc.*
*Including images of each step we talk about would be best, Yett emphasized having images throughout the readme*

## Summary

*Conclude with a summary of the process itself. Talk about who did what, a general timeline of how we completed the work, any major difficulties encountered, etc.*
