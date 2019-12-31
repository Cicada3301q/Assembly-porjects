//name:Assign2c
//Author: Quenten Welch (30054505)
//date:oct 09 2019
//Overview: This code is a translation from the C language to ARMv8 a64 assembly
//Cont'd: I will use logical bitwise and shift operations to compute and return the result after multiplying 2 integers


	define(mult_r, w19)                                             //defining multiplier as "mult_r" and set it to register w19
        define(multiplicand_r, w20)                                     //defines our multiplicand and sets it to register w20
        define(product_r, w21)                                          //defines our product and sets it to register w21
        define(i_r, w22)                                                // defines our iteration counter "i" and sets it to register w22
        define(is_negative_r, w23)                                      //defines our boolean checker for if something is negative and sets it to register w24
        define(temp1_r, x24)                                            //defines a temp variable and set it to regster x24
        define(temp2_r, x25)                                            // defines a second temp variable and sets it to register x25
        define(result_r, x26)                                           //defines our result and sets it to register x26




print_1: .string "Multiplier = 0x%08x (%d) Multiplicand = 0x%08x (%d)\n\n"		//first print label for values of: "multiplier", and "multiplicand", displaying in hex and in decimal
	 .balign 4									//aligns instuctions by 4bits

print_2: .string "Product = 0x%08x multiplier = 0x%08x\n"				//second print label for the values of:"product", and "muliplier", after some bitwise operations have been performed 
	 .balign 4									//aligns instructions by 4bits

print_3: .string "64-bit result = 0x%016lx (%ld)\n"					//third print label for the 64-bit version for te value of: "product" 
	 .balign 4									//aligns instructions by 4bits

	 .global main									//makes main visible to the OS


main:	stp x29, x30, [sp, -16]						//save FP and LR to stack, allocation 16 bytes, preincrement SP
	mov x29, sp							// update FP to current SP



								//initialize values begins

	movk multiplicand_r, 0xF0F0, lsl 0				//initialize multiplier macro with the value -16843010, store first half in mult_r
	movk multiplicand_r, 0xF0F0, lsl 16				//places the second half of the hex representation of -16843010 in mult_r
	mov mult_r, -256							//moves 70 into our multiplicand register
	mov product_r, 0						//inialize and move 0 into our product register
	

									//first print statement begins
	adrp x0, print_1						//sets the first argument for printf
	add x0, x0, :lo12:print_1					//add the lo12 bits to x0
	mov w1, mult_r							//place the value of the multipler into the w1 register
	mov w2, mult_r							//plce the value of the multiplier into the w2 register
	mov w3, multiplicand_r						//places the value of the multiplcand into the w3 register
	mov w4, multiplicand_r						//places the value of the multiplicand into the w4 register
			

	bl printf							//printf function call


	cmp mult_r, wzr						//compares multiplier to zero register to set flags
	b.ge else						//branches to else: if multiplier is positive

	mov is_negative_r, 1					//sets is_negative to true if the previous branch condition fails
	b first							//branches to first, diving past our "else" branch





else:	mov is_negative_r, 0			//sets the boolean to false(0)




first:		 mov i_r, 0				//sets i to 0
		 b test					//unconditional branch to test:



loop:		 tst mult_r, 0x1				//ands immidiate allias to compare mult_r and 0x1 after and operation
		// cmp w27, 0					//compare result of the and operation with 0
		 b.eq second					//if result = 0 branch to second
		 add product_r, product_r, multiplicand_r	//new product = product + multiplicand




second:		asr mult_r, mult_r, 1			// arithmetic shift right by 1 bits
		tst product_r, 0x1			//using ands alias for immidiate comparison between product and 0x1 after and operation
	//	cmp w27, 0				//check to see if the result from the and operation is 0
		b.eq third				//if the result = 0 branch to third:

		orr mult_r, mult_r, 0x80000000		//completes an orr operation and stores result in mult_r register
		b fourth				//unconditional branch to fourth (step)


third:		and  mult_r, mult_r, 0x7FFFFFFF		//if zero was returned in our second branch then this will be reached, performing an and operation on mult_r 


fourth:		asr product_r, product_r, 1			//arithmetic shift right by 1
		add i_r, i_r, 1					//increment i by 1





test:		cmp i_r, 32					//compares i to 32, used to run a while loop here
		b.lt loop					//while i < 32 branch to loop
		cmp is_negative_r, 0				//checks boolean 
		b.eq fifth					//if boolean is false (number is positive) skip next instruction and branch to fifth

		sub product_r, product_r, multiplicand_r	//if mult is negative then do operation product = product - multiplicand


fifth:		adrp x0, print_2			//set first argument for printf
		add x0, x0, :lo12:print_2		//add lo12 bits to x0
		mov w1, product_r			//place value in product into w1 register
		mov w2, mult_r				//place value of our multiplier into the w2 register
		bl printf				//printf function call

		
							//combine product and multiplier
		
		sxtw temp1_r, product_r			//extend product into temp1
		and temp1_r, temp1_r, 0xFFFFFFFF	//move result of and operation on temp1 and 0xFFFFFFFF into temp1 register
		lsl temp1_r, temp1_r, 32		//shift values in temp1 to the left by 32 bits
		

		
		sxtw temp2_r, mult_r				//place multiplier into temp2 register
		and temp2_r, temp2_r, 0xFFFFFFFF		//do and operation between multiplier value and oxFFFFFFFF stores result in temp2 register
		
		add result_r, temp1_r, temp2_r		/// result = temp1 + temp 2

		adrp x0, print_3			// set the first argument for printf
		add x0, x0, :lo12:print_3		//add the lo12 bits to x0 register
		mov x1, result_r			//store the result in the x1 register
		mov x2, result_r			//store the result in the x2 register
		bl printf				//printf function call
	
	
done:
	mov x0, 0
	ldp x29, x30, [sp], 16			//restore FP and LR from stack
	ret					//return control to caller
