# Lab 3: Electronic Door Lock System using ATmega328P

## Overview

This project implements a 5-digit hexadecimal electronic door lock system using an ATmega328P microcontroller. The system utilizes a rotary pulse generator (RPG) for input, a pushbutton for digit selection, and a 7-segment display for user feedback. It also includes a lock/unlock indicator (yellow LED). All code is written in Assembly language.

This lab demonstrates skills in digital I/O, timers, rotary encoders, debounce logic, and program memory lookup tables.

## Features

- **5-digit Hexadecimal Code Entry via RPG**
- **Pushbutton for Digit Confirmation and Reset**
- **7-Segment Display Output with Shift Register**
- **Unlock Success Display (".") and 4-Second Timer**
- **Failure Display ("_") and 7-Second Timer**
- **Pushbutton Long Press Reset (≥ 2 sec)**
- **Hardware-based Debouncing**
- **Lookup Table for Segment Encoding**

## How It Works

### On Power-Up

- The display shows a dash `"–"` indicating readiness for new code entry.

### RPG Navigation

- **Clockwise (CW):** Increases current digit (e.g., `-` → `0` → `1` … `F`)
- **Counter-Clockwise (CCW):** Decreases digit (e.g., `F` → … → `0`)
- RPG input is debounced to avoid erratic behavior.

### Pushbutton Input

| Press Duration | Behavior |
|----------------|----------|
| < 1 second     | Confirm current digit and move to next |
| ≥ 2 seconds    | Reset code entry and return display to `–` |

- Button input is processed **on release**.
- Once 5 digits are entered, they are compared to the pre-programmed unlock code.

### Unlock Logic

- **Correct Code:**
  - Display shows `"."`
  - Yellow LED is turned ON for 4 seconds
  - Display resets to `–` after unlock
- **Incorrect Code:**
  - Display shows `"_"` for 7 seconds
  - System then resets for new code entry

## Hardware Components

- ATmega328P Microcontroller
- Rotary Pulse Generator (RPG)
- 8-bit Shift Register (e.g., 74HC595)
- 7-Segment Common Cathode Display
- Pushbutton with debounce circuit
- Yellow LED (for successful unlock indicator)
- Resistors (limit segment current ≤ 6 mA)
- Breadboard and jumper wires

## Code Implementation

- Uses 8-bit `Timer/Counter0` (without interrupts) to manage:
  - Debounce timing
  - Button press duration measurement
  - Unlock and lockout timing sequences
- Segment patterns for hexadecimal values (0–F) are stored in a lookup table in program memory.
- Code entry is stored in registers and compared to the assigned group unlock code (see appendix).
- Display and LED outputs are driven using a shift register.

## Setup Instructions

1. Wire the RPG, pushbutton, shift register, 7-segment display, and LED to the ATmega328P as per lab schematic.
2. Implement debounce circuitry for both RPG and pushbutton.
3. Assemble and upload the `.asm` code to the microcontroller.
4. On power-up, follow the procedure to test correct/incorrect unlock codes and reset functionality.

## Mid-Lab Review (March 5)

- Demonstrate RPG input functionality with interactive updates to the display.
- Show working debounce logic and digit navigation using RPG.

## Final Submission (March 12)

Submit:
- One `.asm` source file
- One team report
- Checkoff appointment required if grading in person (ICON signup)

## Group Unlock Code

> Replace this with your actual lab group unlock code from the appendix.  
> Example: **Lab3_15 → Unlock Code: 22725**

## Authors

- Thomas Tsilimigras
- Joshua Abello
