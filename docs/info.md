<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections. The document uses Markdown syntax. For more information see:

https://github.com/tinytapeout/tinytapeout-template/blob/main/docs/info.md

--->

## How it works

This project implements a **2-bit Arithmetic Logic Unit (ALU)** with four basic arithmetic operations: Addition, Subtraction, Multiplication and Division.

The design is fully combinational. It takes two 3-bit operands (A and B) and a 2-bit operation code, and produces a 4-bit result along with three status flags: Carry/Borrow (C), Zero (Z) and Error (E).

### Pin mapping

**Inputs** (`ui_in[7:0]`):
- `ui_in[2:0]` → Operand A (a2 a1 a0)
- `ui_in[5:3]` → Operand B (b2 b1 b0)
- `ui_in[7:6]` → Operation code (op1 op0)

**Outputs** (`uo_out[7:0]`):
- `uo_out[3:0]` → Result Y (y3 y2 y1 y0)
- `uo_out[4]`   → Carry / Borrow flag (C)
- `uo_out[5]`   → Zero flag (Z)
- `uo_out[6]`   → Error flag (E) – active when dividing by zero
- `uo_out[7]`   → Not used (tied to 0)

Bidirectional pins (`uio`) are not used.

### Operations and flags

| op[1:0] | Operation      | Description                                      | Flags affected      |
|---------|----------------|--------------------------------------------------|---------------------|
| `00`    | Addition       | Y = A + B                                        | Z                   |
| `01`    | Subtraction    | Y = A − B                                        | C (borrow), Z       |
| `10`    | Multiplication | Y = A × B (lower 4 bits)                         | C (overflow), Z     |
| `11`    | Division       | Y = A / B (integer quotient)                     | E (div by zero), Z  |

**Flag details:**
- **C (Carry/Borrow)**: 
  - In subtraction: 1 when A < B (borrow occurred)
  - In multiplication: 1 when the product needs more than 4 bits
- **Z (Zero)**: 1 when the result Y is zero **and** there is no carry and no error
- **E (Error)**: 1 only when trying to divide by zero (B = 0)

### Function select (op) specification

| op[1:0] | Binary | Operation       | Result                          |
|---------|--------|-----------------|---------------------------------|
| 0       | `00`   | ADD             | Y = A + B                       |
| 1       | `01`   | SUB             | Y = A − B                       |
| 2       | `10`   | MUL             | Y = (A × B)[3:0]                |
| 3       | `11`   | DIV             | Y = A / B  (E=1 if B=0)         |

## How to test

1. Apply power and set `ena = 1`.
2. Set the desired values on the input pins:
   - `ui_in[2:0]` = Operand A (0 to 7)
   - `ui_in[5:3]` = Operand B (0 to 7)
   - `ui_in[7:6]` = Operation code
3. Observe the result on `uo_out[3:0]` and the flags on `uo_out[6:4]`.

**Example tests:**

| A | B | op  | Expected Y | C | Z | E | Description              |
|---|---|-----|------------|---|---|---|--------------------------|
| 3 | 2 | 00  | 5          | 0 | 0 | 0 | 3 + 2 = 5                |
| 5 | 2 | 01  | 3          | 0 | 0 | 0 | 5 − 2 = 3                |
| 2 | 5 | 01  | 13*        | 1 | 0 | 0 | 2 − 5 (borrow)           |
| 3 | 3 | 10  | 9          | 0 | 0 | 0 | 3 × 3 = 9                |
| 5 | 5 | 10  | 9          | 1 | 0 | 0 | 5 × 5 = 25 → overflow    |
| 6 | 2 | 11  | 3          | 0 | 0 | 0 | 6 / 2 = 3                |
| 4 | 0 | 11  | 0          | 0 | 0 | 1 | Division by zero → Error |

\* In 4-bit two’s complement representation of the difference.

## External hardware

No specialized external hardware is required. The ALU is fully self-contained.

Optional:
- DIP switches or microcontroller to drive the 8 input bits (`ui_in`)
- LEDs to display the 4-bit result and the 3 status flags (C, Z, E)
