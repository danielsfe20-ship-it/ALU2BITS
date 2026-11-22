<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

ALU with 3-bit inputs for A and B, and 2-bit input for selecting the operation.
4-bit output counting up to FF hexadecimal
3 flags to indicate: carry (c), zero (z), and division by zero (e)

## How to test

A 3-bit binary value is entered for either A or B, and the operation to be performed is selected: addition (00), subtraction (01), multiplication (10), or division (11).
The output provides the result, with a maximum value of (1111).
If the bit limit is exceeded, a carry flag is triggered; if the result is zero, a zero flag (z) is triggered; and if a division by zero occurs, an error flag (e) is triggered.

## External hardware

We can see the results using LEDs.
