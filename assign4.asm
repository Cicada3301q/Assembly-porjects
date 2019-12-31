//Assignment 4 asm file
//date: nov 04
//author: Quenten Welch 30054505
//Description: translation from provided C code to implement various structures 
//refereced: edwinckc.com/CPSC355/ lecture notes on nested structures




print_1:		.string "initial cuboid values:\n"
main_print:		.string "Cuboid %s origin = (%d, %d) length = width = %d, height = %d volume = %d\n"
first_m:		.string "first"
second_m:		.string "second"
changed:		.string	"\nChanged cuboid values: \n"
		.balign 4






//struct point
x_point = 0		//offset to x_point = 0
y_point = 4		//offset to y_point = 4
point_size = 8		//total size = 8 bytes for 2 ints
point_origin = 0


//struct dimension
dimension_width = 0	//offset to dimention_width = 0 
dimension_height = 4	//offset to dimention_height = 4
dimension_size = 8	//total size = 8 bytes for 2 ints
volume = 16

//struct cuboid
cuboid_origin = 0	//offset to origin = 0
cuboid_length = 4	//offset to length = 4, note can use for width aswell as width = length for a cuboid
cuboid_height = 8

offset = 16
FALSE	= 0		//will be used during equates subroutine
true = 1		//will be used for equates subroutine

box_1 = 16		//each box uses 16 bytes of data 
box_2 = 36

ALLOC = -(16+40) & -16
DEALLOC = -ALLOC


define(base, x19)
	.global main

main:	stp	x29,	x30,	[sp, ALLOC]!		//allocating memory on stack
	mov	x29,	sp				// move stack pointer into x29

	ldr	x0,	=print_1			//prints initial box values
	bl	printf					//branch and link to printf function


	//making first box
	add	base,	x29,	box_1			//moving total offset for 1st box into "base" register
	mov	x8,	x19
	bl	new_box					// branch and link to new_box

	//printing box 1
	ldr	x0,	=first_m
	mov 	x8,	x19				//moving offset value into x8
	bl	print_box				//breanch and link to print box

	//making second box
	add	 x20,	x29,	box_2			//calculate and move offset for second box into x20
	mov	x8,	x20				//move offset into x8
	bl new_box					//branch and link to new_box

	//printing box 2
	ldr	x0,	=second_m			//address of next string
	mov	x8,	x20				//mov base address of box 2 into x8
	bl 	print_box				//branch and link to print_box


	//testing for equality
	mov 	x0,	x19				//move address of x19 into x0
	mov 	x8,	x20				//move address of x20 into x8
	bl 	equates					// branch and link to equates
	mov 	w9,	w0				//moving w0 into w9,

	cmp	w9,	wzr				//comparing contents of w9 to wzr
	b.eq	print_changed				//conditional branch testing for equality, branched to print_changed

	mov	x8,	x19				//move offset for box 1 into x8 for use in subroutine
	mov 	w1,	3				//deltaX
	mov	w2,	-6				//deltaY
	bl	move 					//branch and link to move

	mov	x8,	x20				//move offset for box 2 into x8
	mov	w1,	4				//expansion factor

	bl expand					//branch and link to expand

print_changed:
	ldr	x0,	=changed			//feed the address of out desired string
	bl printf					//branch and link to printf

	ldr	x0,	=first_m				//load address of first into x0
	mov	x8,	x19				//mov offset for box 1 into x8
	bl	print_box				//branch and link to print_box


	ldr	x0,	=second_m
	mov	x8,	x20
	bl	print_box

	ldp	x29,	x30,		[sp],	DEALLOC //deallocate mem on stack
	ret						//return

new_box:
	stp	x29,	x30,	[sp, -(16+20) & -16]!		//allocate new mem on stack
	mov 	x29,	sp				//move sp into x29

	add 	x29,	x29,	16

	mov	w0,	0				//move origin.x and origin.y into w0
	mov	w1,	2				//length and width = 2 move 2 into w1
	mov	w2,	3				//height = 3 move height into w2

	str	w0,	[x29, 16]		//store contents of w0 into stack
	str	w0,	[x29, 20]		//store contents of w0 onto stack for b.origin.y
	str	w1,	[x29, 24]		//store contents of w1 onto stack for width and length
	str	w2,	[x29, 28]			//b.height
	mul	w1,	w1,	w1			//w1 = width * length
	mul	w1,	w1,	w2			//w1 = width * height * length
	str	w1,	[x29, 32]			//stores volume

	//load local variables

	ldr	w11,	[x29, 16]			//origin for x
	ldr	w12,	[x29, 20]			//loads origin y into w12
	ldr	w13,	[x29, 24]			//loads width and length into w13
	ldr	w14,	[x29, 28]			//loads height into w14
	ldr	w15,	[x29, 32]			// loads volume into w15

	//store values back onto stack
	str	w11,	[x8, point_origin + x_point]		//stores b.origin.x
	str	w12,	[x8, point_origin + y_point]		//stores b.origin.y
	str	w13,	[x8, dimension_size + dimension_width]	//stores b.dimension.width
	str	w14,	[x8, dimension_size + dimension_height] // stores b.dimension/height
	str	w15,	[x8, volume]				//stores volume

	ldp	x29,	x30,	[sp],	48
	ret


move:
	stp	x29,	x30,	[sp, -16]!			//allocate mem onto stack
	mov	x29,	sp					// move sp into x29

	mov	x9,	x8
	mov	w8,	w1					//value for move in x axis
	mov 	w7,	w2					//value for move in y axis

	ldr	w24,	[x9, point_origin + x_point]		//load current x value into w24
	add	w24,	w24,	w8				//x = x + move value
	str	w24,	[x9, point_origin + x_point]		//store new x value into w24

	ldr	w25,	[x9, point_origin + y_point]		//loads current y value into w24
	add	w25,	w25,	w7				//add move to y
	str	w25,	[x9, point_origin + y_point]		//store new value of y into w25

	ldp	x29,	x30,	[sp],	16			//deallocating memory
	ret

expand:
	stp	x29,	x30,	[sp, -16]!			//allocate memory onto stack
	mov	x29,	sp					//mov sp into x29

	mov	x22,	x8					//base for box2
	mov	w2,	w1					//expansion factor

	ldr	w11,	[x22, dimension_size + dimension_width]	//load width into w11
	mul	w11,	w11,	w2				//size = size* expansion factor
	str	w11,	[x22, dimension_size + dimension_width]	//stores expanded value into stack

	ldr	w12,	[x22, dimension_size + dimension_height]//load height into w12
	mul	w12, 	w12,	w2				//multiply height by expansion factor
	str	w12,	[x22, dimension_size + dimension_height]//store new value into the stack

	mul	w13,	w11,	w11				//w13 = width * length
	mul	w13,	w13,	w12				//= width * length + height
	str	w13,	[x22, volume]				//store new volume in mem

	ldp	x29,	x30,	[sp], 16			//deallocate memory
	ret


print_box:
	stp	x29,	x30,	[sp, -16]!			//allocate memory
	mov	x29,	sp					//mov sp into x29

	mov	x1,	x0					//first or second box string
	mov	x21,	x8					//base for box struct

	ldr	w2,	[x21, point_origin + x_point]		//load base for struct
	ldr	w3,	[x21,	point_origin + y_point]		//load base for origin.y
	ldr	w4,	[x21, dimension_size + dimension_width]	//load base for dimension.width
	ldr	w5,	[x21, dimension_size + dimension_height]//load base for dimension.height
	ldr	w6,	[x21, volume]				//loads volume address

	ldr	x0, =main_print					//address for main print statment
	bl printf						//branch and link to printf function

	ldp	x29,	x30,	[sp], 16			//deallocate memory
	ret


equates:
	stp	x29,	x30,	[sp, -16]!			//allocate memory
	mov	x29,	sp					//mov sp into x29

	mov	x9,	x0					//base for box 1
	mov	x10,	x8					//base for box 2

	mov	w0, 	0					//initialize to false

	ldr	x4,	[x9, point_origin + x_point]		//loadspoint x of box 1 into x4
	ldr	x5,	[x10,point_origin + x_point]		//load point origin of box 2 into x5
	cmp	x4, x5						//comparison
	b.ne	false						//conditional branch to false

	ldr	x4,	[x9, point_origin + y_point]		//load box 1 origin.y into x4
	ldr	x5,	[x10, point_origin + y_point]		//load box 2 origin.y into x5
	cmp	x4, x5
	b.ne	false						//conditional branch to false

	ldr	x4,	[x9, dimension_size + dimension_width]	//width of box 1 loaded into x4
	ldr	x5,	[x10, dimension_size +dimension_width]	//width of box 2 loaded into w5
	cmp	x4,	x5					//compare
	b.ne	false						//conditional branch to false

	ldr	x4,	[x9, dimension_size +dimension_height]	//loads box 1's height into x4
	ldr	x5,	[x10, dimension_size + dimension_height]//loads box 2's height into x5
	cmp	x4, x5
	b.ne	false						//conditional branch to false

	mov w0, 1 						//passed test equals is true
	b	done

false:
	mov w0, 0				//set w0 to false

done:
	ldp	x29,	x30,	[sp],	16	//deallocate memory
	ret
