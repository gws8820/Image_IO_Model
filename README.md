# Image I/O Model
SNU AI System Hardware Design Project - Lab 01, Lecture 7


## Overview
* A Verilog Image I/O Simulator
* Take Bitmap Image using OV7670 and Arduino
* Convert Bitmap Image to HEX file
* Read HEX file and save it to the memory (SensorModel)
* Read HEX file and write a new Bitmap Image (DisplayModel)


## Prerequisites
* Icarus Verilog (https://github.com/steveicarus/iverilog)
* GTKWave (https://gtkwave.sourceforge.net/)


## Usage
### Common
1. Upload getImage.ino to Arduino
2. Run ReadSerialPortWin.exe to generate image.bmp
3. Run image2hex.c or .m to generate image.hex
### SensorModel
```
iverilog -o module fsm_image_sensor.v fsm_image_sensor_tb.v && vvp module && gtkwave wave.vcd
```
### DisplayModel
```
iverilog -o module display_model.v display_model_tb.v && vvp module
```

## Components
### GetImage
_Generates Bitmap Image_
#### getImage.ino
* Upload to Arduino (Tested with Arduino R3)
#### ReadSerialPortWin.exe
* Run on Windows to get bitmap image (240*320, 32-bit)
* You should save captured image to the same folder as 'image.bmp'
---
### Image2Hex
_Generates Hexfile to the same folder_
#### image2hex.m
* A MatLab Code that converts bitmap image to RGB24 hexcode.
#### image2hex.c
* A C Code that converts bitmap image to RGB24 hexcode.
---
### SensorModel
_Read Hexfile and save it to the memory_
#### sensor_model.v
* Read Hexcode from '../Image2Hex/image.hex' and loads it into the memory (org_R, org_G, org_B)
* Reads 2 pixels in a single cycle
* RGB Values will be always same since image.bmp is a grayscale image
* Generates ctrl_done when the task completed.
#### fsm_controller.v
* Defines FSM state transitions, moving from ST_IDLE to ST_VSYNC, ST_HSYNC, and ST_DATA sequentially.
* START_UP_DELAY and HSYNC_DELAY to ensure stable running.
#### fsm_image_sensor.v
* Integrate sensor_model and fsm_controller to a fsm_image_sensor
#### fsm_image_sensor_tb.v
* Generates 50MHz Clock
* Controls HRESETn signal
---
### DisplayModel
_Read Hexfile and write a new Bitmap Image_
#### display_model.v
* Read Hexcode from '../Image2Hex/image.hex'
* Generates buffer header
* Write buffer header and pixel data to the 'image_out.bmp'
#### display_model_tb.v
* Generates 50MHz Clock
* Controls HRESETn signal


## License
See [LICENSE](LICENSE) for details.