// Author: Quenten Welch
// UCID: 30054505
// Date: oct 24th, 2019
// The program first allocates 50 random integers, from 0 to 255, onto the stack and then uses
// an insertion algorithm to sort them in ascending order (lowest to highest)
// Both the unsorted and sorted algorithm are displayed, respectively.



size = 4				// int array int takes 4 bits so size = 4
array_elements = 50			// 50 elements in array

ALLOC = -(32+size * array_elements)&-16 			//space required to store all digits. Since it's 0xFF that means it uses 8 bits = 1 byte. since FF is hexa and each hexa takes up 4 bits
	DEALLOC = -ALLOC		// size of the array - contains 50 elements

//macros
define(counter, x19)	  // counter used for filling the stack with random numbers and later used for printing the sorted array
define(arrayBase, x20)	  // the frame record containing the frame pointer + stack pointer
define(counter_i, x21)    // Used for the insertion sort on the "outer" loop 
define(counter_J, x22)    // Used on the "nested" loop where it shares the same value as i
define(pre_J_Element, w25)// will hold the element in v[J-1]
define(temp, w26)	  // will hold the element v[i]


// note j = i + 1 is the same as j - 1 = i
unsorted:	.string	"\n Unsorted Array:\n"		// print statement for Unsorted Array
output1:	.string "array v[%d]=%d \n"		// This statement will print the index of the unsorted array as well as the value in it
		.balign 4				// organizes it into 4 bits

Sorted:		.string "\n Sorted Array: \n"		// To distinguish where the sorted array will begin
output2:	.string "Sorted v[%d]=%d \n"		// This print statement will print the index and the value in the array from the Sorted Array
		.balign 4

	.global main

main:
	stp	x29,	x30,	[sp, ALLOC]!		// Recall that ALLOC is actually negative, since when we create space, we r going "backwards"
	mov	x29,	sp				//fp = sp

	mov	counter,	0			// counter gets initiated to 0
	mov 	arrayBase,	x29			// base address
	add 	arrayBase,	arrayBase,	16 	// Frame pointer + Stack pointer will occupy 16 bits, so our base adress gets bumped up by 16
	mov	counter_i,	1			// i=1. counter for sorting loop starts at 1 since nested j loop will compare it to i=0 = j-1.

	ldr	x0,	=unsorted			// To distinguish where our Sorted Arrays begins
	bl	printf					// calls print function

fill:
	bl	rand				// calling the random function
	and 	x2,	x0,	0xFF		// using the "and" is an alias for modulus, where x0 is the value we receive from the rand function and x2 is where we store. 0xFF is 255(highest possible).
	strb	w2,	[arrayBase, counter]    // storing it on the stack using 32 bits only

	ldr	x0,	=output1  		// redirecting to where print statement is 
	mov	x1,	counter			// The counter (x1) will print the index, and  w2 will print the value in it?
	bl 	printf

	add 	counter,	counter,	1	// add one so that we can place the next random number
	cmp	counter,	50			// only up to 50 (50 values)
	b.lt	fill					// iterations will be 0 to 49


// SORTING IT*/
loop1:
	cmp	counter_i,	50			 // counter i started at 1 and will be at most 49
	b.ge	restarting_counter 			 // all iterations, outer and inner loop would be done, so let's print the sorted array
	ldrb	temp,	[arrayBase, counter_i]		 // load the temp value to later compare it to v[J-1]
	mov	counter_J, 	counter_i 		 // j=i

inner_loop:
	cmp	counter_J,	0			// The first condition in the loop is for J>0
	b.le	next_i_iteration			// If it's less than or equal to 0 - go to the next "i" iteration

	sub	counter_J,	counter_J,	1     	// subtract so that we can get v[J-1] value
	ldrb	pre_J_Element,	[arrayBase, counter_J]  // obtaining v[J-1] from the stack
	add 	counter_J,	counter_J,	1	// return J to where it was 

	cmp	temp,	pre_J_Element			// cmp temp = v[i] to v[J-1]
	b.ge	next_i_iteration			// temp must be less than v[J-1]. Otherwise go to the next iteration 

	strb	pre_J_Element,	[arrayBase, counter_J]   // v[j] = v[j-1]
	sub	counter_J,	counter_J,	1	 // taking 1 out (j--) before iterating again.
	bl	inner_loop				 // directing it to iterate it again (J inner  loop)

next_i_iteration:
	strb	temp,	[arrayBase, counter_J]  	// v[j] = temp. Whateve value is in temp place it where v[J] is.
	add	counter_i,	counter_i,	1	// add 1 to the counter i
	bl	loop1					// loop back to the outer loop (where iterative is i)

// Printing sorted array portion
restarting_counter:
	mov	counter,	0		// restarting counter to 0 because I want to print array values in ascending order
	ldr	x0,	=Sorted			// A print statement to distinguish where Sorted Array begins
	bl	printf

printloop:
	cmp	counter,	50		// 50 elements we must print out
	b.ge	done				// if the counter is greater than or equal to 50 then go to "done" section.
	ldrb	w2,	[arrayBase, counter]	// Load the element value onto w2

	ldr	x0,	=output2			// shows which print statement we want to print
	mov	x1,	counter  			// element number (counter) will be printed inside square brackets while its value (in the stack) will be in register w2 and printed to the right side of it.
	bl 	printf					// print each value iteratively
	add	counter,	counter,	1 	// add one to the counter so that we may access the next element in the array
	bl 	printloop				// repeat the loop

done:							// finish the program
	ldp	x29,	x30,	[sp],	DEALLOC		// DEALLOC = -ALLOC, get rid of the space we had previously made
	ret						// return
