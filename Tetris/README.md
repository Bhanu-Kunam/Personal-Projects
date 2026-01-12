# FPGA Tetris (SystemVerilog)

This project is a hardware-based implementation of the classic game Tetris, developed in SystemVerilog for my ECE 385 final project. It utilizes a VGA-to-HDMI interface for video output, USB HID for keyboard input, and PWM-based audio.

## Project Overview

The system is built around a MicroBlaze/SoC block design that handles USB communication, while the core game logic, video generation, and audio synthesis are implemented in custom SystemVerilog hardware modules.

### Key Features
* **Resolution:** 640x480 @ 60Hz (via HDMI).
* **Game Logic:** Complete implementation of Tetris mechanics including gravity, collision detection, line clearing, and scoring.
* **Input:** USB Keyboard support for game controls.
* **Audio:** PWM audio engine with background music and sound effects (lock thud, line clear ding).
* **UI:** Start screen, score display, and game over screen using a bitmap font ROM.

## Controls

The game accepts input via a USB keyboard connected to the development board.

| Key | Function | Hex Code |
| :--- | :--- | :--- |
| **Space** | Start Game | `0x2C` |
| **W** | Rotate Piece | `0x1A` |
| **A** | Move Left | `0x04` |
| **D** | Move Right | `0x07` |
| **S** | Fast Drop | `0x16` |
| **Enter** | Restart (Game Over) | `0x28` |

## Module Architecture

### Top Level
* **`mb_usb_hdmi_top.sv`**: The top-level entity. It instantiates the MicroBlaze block (`mb_block`), Clock Wizard, VGA Controller, HDMI Transmitter, Audio Unit, and the Tetris Game Controller. It ties the hardware I/O (buttons, switches, HDMI, USB) to the internal logic.

### Game Logic
* **`tetris_game_controller.sv`**: The core logic engine. It manages the 10x28 game board grid, active piece coordinates, rotation, and collision detection. It also handles gravity timing and input delays.
* **`tetris_control.sv`**: A Finite State Machine (FSM) that controls the high-level game state.
    * **States**: `Start` -> `Spawn` -> `Play` -> `Check Lines` -> `Game Over`.

### Video & Graphics
* **`VGA_controller.sv`**: Generates standard VGA timing signals (HSync, VSync) and pixel coordinates (`drawX`, `drawY`) based on a 25MHz pixel clock.
* **`Color_Mapper.sv`**: Determines the color of the pixel at the current (`drawX`, `drawY`). It handles the drawing of:
    * The 7 Tetromino shapes (Cyan, Blue, Orange, Yellow, Green, Purple, Red).
    * Text elements (Start, Game Over, Score) using bitmapped fonts.
    * Borders and Backgrounds.
* **`font_rom.sv`**: A Read-Only Memory containing bitmasks for numbers (0-9) and specific ASCII characters used in the UI (e.g., "TETRIS", "SCORE", "GAME OVER").

### Audio
* **`audio.sv`**: Manages audio playback. It cycles through a 4-note music loop and overrides the output with sound effects when a block locks or a line is cleared.
* **`audio_pwm.sv`**: Converts the requested audio period/frequency into a 1-bit Pulse Width Modulation signal for the audio output jack.

### Utilities
* **`hex_driver.sv`**: Drives the 7-segment displays on the board, used for debugging keycodes or other status signals.

## Hardware Requirements
* **FPGA Board**: Designed for the ECE 385 development board (Xilinx-based platform compatible with `mb_block`).
* **Peripherals**:
    * HDMI Monitor.
    * USB Keyboard.
    * Speakers/Headphones (via Audio Out).

## Scoring System
The game maintains a score that increments when lines are cleared. The score is displayed in hexadecimal format on the game screen.

## Installation & Build
1.  Open the project in Xilinx Vivado.
2.  Ensure the Block Design (`mb_block`) is generated and the IP sources (Clock Wizard, HDMI TX) are properly configured.
3.  Run Synthesis, Implementation, and Generate Bitstream.
4.  Export Hardware and launch Vitis (if software drivers are required for the USB/MicroBlaze interaction).
5.  Program the device.
