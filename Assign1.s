//File: Assignment1b.asm
//Author: Quenten welch
//Date: sept 26 2019
//Description: This program will find and return the maximum of Y = -2x^3 -22x^2 -11x +57 in the range of -10 <= x <= 4 by iterating through a loop and testing, only mul, add and mov will be used (no macros)







label:		.string "For X = %d, Y = %d.\n  The current maximum of Y is %d.\n"	//the print statement for values x, y and yman for each iteration of our loops
		.balign 4 								//this aligns instructions by 4 bits
		

		.global main								//makes main visible to the os

main:		stp x29, x30, [sp, -16]!
		mov x29, sp
		
		mov x19, -10								//initialize the value associated with our x19 register as -10 this is our x value
		mov x20, 0								//initialize the value associated with our x20 register at 0 this is our current y
		mov x21, -9999								//initialize the value associated with our x21 register at -9999 this is our y max

	

loop:
		cmp x19, 4
		b.gt finish								// conditional branch to finish


		mov x20, 0								//we need to clear data from previous iterations from our x20 register
		

		
		mov x22, -2
		mul x22, x23, x19							// does the operation -2*x
		mul x22, x22, x19							// continuing operation (-2*x^2)
		mul x22, x22, x19							//continuing operation Y = -2*x^3
		add x20, x20, x22							// places -2*x^3 in the y register
		
			
											//start a new operation

		mov x22, -22								// places -22 into the x22 register
		mul x22, x22, x19							// does the operation -22*x
		mul x22, x22, x19							// = -22*x^2
		add x20, x20, x22							//Y = -2x^3 -22x^2
		

											//start a new operation

		mov x22, -11								//reset our temp register to -11
		mul x22, x22, x19							//Y = -2x^3 -22x^2 -11x 
		add x20, x20, x19							//put the value into our y register

		add x20, x20, 57							//Y = 2x^3 -22x^2 -11x +57

		cmp x20, x21								// compares current Y to Ymax
		b.gt newYmax								// if Y > ymax branch to newYmax



end:
	adrp x0, label			//set the first argument for printf
	add x0, x0, :lo12:label		// add the lo12 bits to x0 
	mov x1, x19			//place the value of X into x1 register for printf argument
	mov x2, x20			//place the value of Y into x2 register for printf argument
	mov x3, x21			//place the value of Ymax into x3 register for printf argument

	bl printf			//calls the printf function

	add x19, x19, 1			//increments x by 1
	b loop				//unconditional branch to loop


newYmax:
	mov x21, x20			//places the new max Y into our max Y register

	b end				//unconditional branch to end			




finish:
	mov x0, 0	
	ldp x29, x30, [sp], 16		//restore FP and LR from stack, post-increment sp

	ret				//transfers control to return address on the stack

