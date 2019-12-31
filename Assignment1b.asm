//File: Assignment1b.asm
//Author: Quenten welch
//Date: sept 26 2019
//Description: This program will find and return the maximum of Y = -2x^3 -22x^2 -11x +57 in the range of -10 <= x <= 4 by iterating through a loop and testing, Macros, add, madd, mul and mov will be used







label:		.string "For X = %d, Y = %d.\n  The current maximum of Y is %d.\n"	//the print statement for values x, y and yman for each iteration of our loops
		.balign 4 								//this aligns instructions by 4 bits
		

		.global main								//makes main visible to the os

main:		stp x29, x30, [sp, -16]!
		mov x29, sp

		define(x_r, x19)							//defines x_r as the our x value and set it to register x19
		mov x_r, -10								//initialize the value associated with our x_r register as -10

		define(y_r, x20)							//defines y_r as our Y value and sets it to register x20
		mov y_r, 0								//initialize the value associated with our y_r register at 0
		

		define(yMax_r, x21)							//defines yMax_r as our Y max and sets it to register x21
		mov yMax_r, -9999							//initialize the register associated with yMax_r to -9999


		define(temp_r, x22)							//defines a temporary variable and sets it to register x22

		define(coef_r, x23)							//defines our first coeffiecient and sets it to register x23
		define(coef2_r, x24)							//defines our second coefficient and sets it to register x24
		define(coef3_r, x25)							//defines our third coefficient and set it to register x25

		mov coef_r, -2								//moves the value -2 into register x23
		mov coef2_r, -22							//moves the value -22 into register x24
		mov coef3_r, 11								//moves the value 11 into register x25

		b test									// unconditional branch to test

loop:
		
		mov y_r, 0								//we need to clear data from previous iterations from our x20 register
		mov temp_r, 0								// resets the value for temp to 0

		
		
		mul temp_r, coef_r, x_r							// does the operation -2*x
		mul temp_r, temp_r, x_r							// continuing operation (-2*x^2)
		madd y_r, temp_r, x_r, y_r						// Y = -2*x^3
		
			
											//start a new operation

		mov temp_r, 0								//resets our temp register to 0
		mul temp_r, coef2_r, x_r						//stores -11*x in temp register
		madd y_r, temp_r, x_r, y_r						// Y = -2x^3 -22x^2
		

											//start a new operation

		mov temp_r, 0								//reset our temp register to 0
		madd y_r, coef3_r, x_r, y_r						//Y = -2x^3 -22x^2 -11x 
		

		add y_r, y_r, 57							//Y = 2x^3 -22x^2 -11x +57

		cmp y_r, yMax_r								// compares current Y to Ymax
		b.gt newYmax								// if Y > ymax branch to newYmax



end:
	adrp x0, label			// set the first argument for printf
	add x0, x0, :lo12:label		// sets the lo12 bits to x0

	mov x1, x_r			//place the value of X into x1 register for printf argument
	mov x2, y_r			//place the value of Y into x2 register for printf argument
	mov x3, yMax_r			//place the value of Ymax into x3 register for printf argument

	bl printf			//calls the printf function

	add x_r, x_r, 1			//increments x by 1
	b test				//unconditional branch to test


newYmax:
	mov x21, x20			//places the new max Y into our max Y register

	b end				//unconditional branch to end			


test:	cmp x_r, 4			//compares x_r, and 4
	b.le loop			// if x <=4 branch to loop


finish:
	mov x0, 0	
	ldp x29, x30, [sp], 16		//restore FP and LR from stack, post-increment sp

	ret				//transfers control to return address on the stack
