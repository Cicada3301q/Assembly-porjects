//file name: a6.asm
//Author: Quenten Welch 30054505
//date december 03 2019
//description: an assembly language program tgat uses series expanion to compute ln(x), reads from file using double precision or 8 bytes at a time

//begin macros
define(i_r, w9)						//define egister for current index value
define(sum_r, d8)					//define register to store reoccuring sum
define(x_r, d9)						//define register for argument x
define(dif_r, d10)					//define register for comparison in loop test
define(one_r, d11)					//define register for constant = 1
define(value_r, d12)					//define register for the current calculated term
define(base_r, d13)					//define register for exponent




//initialize floats
dif_m:	.double	0r1.0e-13					// Double float for the amount of error in the result
one_m:	.double	0r1.0						// double float storing 1.0


//set up for prints
title_print:		.string "(x)\t\t\tln(x)\n"				// String for title
print:			.string "%.10f\t\t%.10f\n"					// string for output

open_err_print:		.string "Error opening the input file.\n"		// print error for unsuccessful open attempt
cmd_err_print:		.string "Enter file name in the command line.\n"	// cmd error print


	.balign 4						// ensure instructions are quad word aligned

	define(fd_r, w19)					// define file descriptor register
	define(buff_base_r, x20)				// define buffer address registers
	define(x_r, d18)					// define register for x read from file, double float precision is used

	buff_size = 8						// Input buffer is 8 bytes
	buff_s = 16						// Buffer offset
	alloc = -(16 + 8) & -16				// setting up alloc for stack mem allocation
	dealloc = -alloc					// dealloc for mem deallocation

//main function
	.global main						//makes main visible to os
main:	stp	x29, x30, [sp, alloc]!				// usual store pair instruction
	mov	x29, sp						// mov sp into fp

	mov	x21, x1						//move x1(input) ino x28

	cmp	w0, 2						//checking number of cmd line arguments
	b.ge	open						// If there are 2 cmd line args try to open file

	adrp	x0, cmd_err_print				//set up cmd error print
	add	x0, x0, :lo12:cmd_err_print			// Add low order bits
	bl 	printf						// Call printf function
	b	end						// Branch to end of main
//open file
open:

	adrp	x0, title_print					// Get address of title print out
	add	x0, x0, :lo12:title_print			// Add low order bits of title address
	bl	printf						// Call print function

	mov	w0, -100					// 1st arg: cwd
	ldr	x1, [x21, 8]

	mov	w2, 0						// 3rd arg: read-only
	mov	w3, 0						// 4th arg: not used but is neccassary
	mov	x8, 56						// openat request
	svc	0						// Call system function
	mov	fd_r, w0					// Store file descriptor
	cmp	fd_r, 0						// check for error
	b.ge	open_next						// branch to open_next if no issue

	adrp	x0, open_err_print					// Address of error message string
	add	x0, x0, :lo12:open_err_print				// Add low order bits
	bl	printf						// Call print function
	b	end						// Branch to end of function

open_next:							// Read from file
	add	buff_base_r, x29, buff_s			// Calculate buf base address

top:	mov	w0, fd_r					// 1st arg: file descriptor
	mov	x1, buff_base_r					// 2nd arg: buffer base address
	mov	w2, buff_size					// 3rd arg: buffer size
	mov	x8, 63						// Read i/o request
	svc 	0						// Call sys function

	cmp	x0, buff_size					// Compare bytes read to buff size
	b.ne	close						// if not equal branch to close

	ldr	d21, [buff_base_r]				// Load x read from file
	fmov	d0, d21						// ln_x arg: x
	bl	ln_x						// Branch and link to ln_x subroutine

	fmov	d1, d0						// 3rd arg: returned ln(x)
	fmov	d0, d21						// 2nd arg: x
	adrp	x0, print					// Address of fmt string
	add	x0, x0, :lo12:print				// Add low order bits

	bl 	printf						// Call print function
	b	top
//close file we read from
close:	mov	w0, fd_r					// Close file
	mov 	x8, 57						// Close request
	svc 	0						// Call sys function

	mov	w0, 0						// return 0

end:	ldp	x29, x30, [sp], dealloc				// deallocate mem from stack
	ret							// Return to OS

//begin ln function


ln_x:	stp	x29, x30, [sp, -16]!				// allocate mem to stack
	mov	x29, sp						// mov sp into fp

	fmov	x_r, d0						// Store passed argument x

	adrp	x9, dif_m					// Get address of comparison value
	add	x9, x9, :lo12:dif_m				// Add low order bits
	ldr	dif_r, [x9]					// Load value into dif register

	adrp	x9, one_m					// Get address of one_m
	add	x9, x9, :lo12:one_m				// Add low order bits to x9
	ldr	one_r, [x9]					// Also load one into one register
	ldr	sum_r, [x9]					// Load 1.0 into sum
	fsub	sum_r, sum_r, one_r				// Decrement sum back to 0.0

	fmov	value_r, one_r					// init value to 1.0

	mov	i_r, 1						// i = 1

	fsub	base_r, x_r, one_r				// value = x - 1
	fdiv	base_r, base_r, x_r				// value = (term - 1) / x

	b	test						// Branch to loop test

loop:	mov	w10, 1						// w10 = 1
	fmov	value_r, base_r
	b	ftest						// Branch to for test

for_loop:	fmul	value_r, value_r, base_r			// value = value * value
		add	w10, w10, 1					// w10++

ftest:	cmp	w10, i_r					// Compare w10 to i
	b.lt	for_loop					// Branch to for loop if w10 < i

	scvtf	d14, i_r					// Convert i to nearest float
	fdiv	value_r, value_r, d14				// value / d14

	fadd	sum_r, sum_r, value_r				// sum += value

	add	i_r, i_r, 1					// i++

test:	fabs	d14, value_r					// d13 = abs(sum_r)
	fcmp	d14, dif_r					// Compare d13 to dif (1.0e-13)
	b.ge	loop						// branch to loop if sum > dif

	fmov	d0, sum_r					// Return sum which is the ln(x)

nln_x:	ldp	x29, x30, [sp], 16				// Load fp, lr and decrement sp
	ret
