//Quenten Welch
//30054505
//CPSC 355
//assign5b.asm program takes inout from the shell and outputs the a date using the corresponding month and correct suffix for the day

define(month, w19)                              //defining macro for month
define(day, w20)                                //defining macro for day
define(year, w21)                               //defining macro for year
define(argc, w22)                               //defining macro for argc
define(argv, x23)                               //defining macro for argv

fmt1:   .string "%s %d%s, %d\n"                 //first print statement displays month, day year
fmt2:   .string "usage: a5b mm dd yyyy\n"       //prints the error message 

months: .dword  jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec      //a list of months
suf:    .dword  st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st      //a list of suffixs

        .text                                   //text data
jan:    .string "January"                       //.string for january
feb:    .string "Febuary"                       //.string for febuary
mar:    .string "March"                         //.string for march
apr:    .string "April"                         //.string for april
may:    .string "May"                           //.string for may
jun:    .string "June"                          //.string for june
jul:    .string "July"                          //.string for july
aug:    .string "August"                        //.string for august
sep:    .string "September"                     //.string for september
oct:    .string "October"                       //.string for october
nov:    .string "November"                      //.string for novenber
dec:    .string "December"                      //.string for december

st:     .string "st"                            //the suffix of st
th:     .string "th"                            //the suffix of th
nd:     .string "nd"                            //the suffix of nd
rd:     .string "rd"                            //the suffix of rd

        .balign 4                               // ensures quad word alignmentt
        .global main                            //make main visible to os
main:   stp     x29, x30, [sp, -16]!            //allocate stack memory 
        mov     x29, sp                         //moving sp into x29

        mov     argc, w0                        //argc
        mov     argv, x1                        //argv

        cmp     argc, 4                         //compairing argc to 4
        b.ne    error                           //branch to error

	//handle arg 1 month
	mov 	month, 1			//load arg position into month
	ldr	x0, [argv, month, sxtw 3]	//load address for string
	bl	atoi				// branch and link to atoi for number to string conversion
	mov	month,	w0			//placing argument value into month

	//test range for month 1-12
        cmp     month, 1                        //compairing month to 1
        b.lt    error                           //branch to error
        cmp     month, 12                       //compairing month to 12
        b.gt    error                           //branch to error

	//handle arg 2 day
        mov     day, 2                          //load arg position into day
        ldr     x0, [argv, day, sxtw 3]         //load address of strng entered
        bl      atoi                            //calling atoi
        mov     day, w0                         //placing arg value into day

	//test range for day 1-31
        cmp     day, 1                          //compairing day to 1
        b.lt    error                           //branch to error
        cmp     day, 31                         //compairing day to 31
        b.gt    error                           //branch to error

	//handle arg 3 or year
        mov     year, 3                         //input arg position into year
        ldr     x0, [argv, year, sxtw 3]        //load address of string entered
        bl      atoi                            //calling atoi
        mov     year, w0                        //place value of arg into year

	//test year range
        cmp     year, 0                         //compairing year to 0
        b.lt    error                           //branch to error

        adrp    x0, fmt1                        //setting up to print the output
        add     x0, x0, :lo12:fmt1              //printing the output

        adrp    x24, months                     //getting the base address of months
        add     x24, x24, :lo12:months          //finding the proper month for the input
        sub     month, month, 1                 //becuase the array of months starts at 0 we adjust
        ldr     x1, [x24, month, sxtw 3]        //putting the month into the print statement

        mov     w2, day                         //loading day into the print statement


	//suffix for day
        adrp    x25, suf                        //getting the base address of suf
        add     x25, x25, :lo12:suf             //finding the proper suffix for the day
        sub     day, day, 1                     //because the array for days starts at 0 we adjust
        ldr     x3, [x25, day, sxtw 3]          //adding suffix to print

        mov     w4, year                        //loading year into print statement
        bl      printf                          //branch and link to printf

        b       done                            //branch to done
error:
        adrp    x0, fmt2                        //setting up to print error statement
        add     x0, x0, :lo12:fmt2              //loading print
        bl      printf                          //call to printf function

done:   ldp     x29, x30, [sp], 16              //deallocating stack mem
        ret                                     //returning control to os
