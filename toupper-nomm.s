#PURPOSE:    This program converts an input file to an output file with all
#            letters converted to uppercase.
#
#PROCESSING: 1) Open the input file
#            2) Open the output file
#            4) While we're not at the end of the input file
#               a) read part of the file into our piece of memory
#               b) go through each byte of memory
#                    if the byte is a lower-case letter, convert it to uppercase
#               c) write the piece of memory to the output file

	.section .data

#######CHANGEABLE CONSTANTS#########

	###ERROR MESSAGES###
	.equ ERR_WRONG_NR_ARGS, 1
ERR_WRONG_NR_ARGS_MSG:
	.ascii "ERROR: Wrong number of arguments\n"
ERR_WRONG_NR_ARGS_MSG_END:
	.equ ERR_WRONG_NR_ARGS_MSG_LEN, ERR_WRONG_NR_ARGS_MSG_END - ERR_WRONG_NR_ARGS_MSG

	.equ ERR_OPEN_INPUT, 2
ERR_OPEN_INPUT_MSG:
	.ascii "ERROR: Unable to open input file\n"
ERR_OPEN_INPUT_MSG_END:
	.equ ERR_OPEN_INPUT_MSG_LEN, ERR_OPEN_INPUT_MSG_END - ERR_OPEN_INPUT_MSG

	.equ ERR_OPEN_OUTPUT, 3
ERR_OPEN_OUTPUT_MSG:
	.ascii "ERROR: Unable to open output file\n"
ERR_OPEN_OUTPUT_MSG_END:
	.equ ERR_OPEN_OUTPUT_MSG_LEN, ERR_OPEN_OUTPUT_MSG_END - ERR_OPEN_OUTPUT_MSG

	.equ ERR_NO_MEM, 4
ERR_NO_MEM_MSG:
	.ascii  "ERROR: Out of memory\n"
ERR_NO_MEM_MSG_END:
	.equ ERR_NO_MEM_MSG_LEN, ERR_NO_MEM_MSG_END - ERR_NO_MEM_MSG

	.equ ERR_READ_INPUT, 4
ERR_READ_INPUT_MSG:
	.ascii "ERROR: Unable to read from input file\n"
ERR_READ_INPUT_MSG_END:
	.equ ERR_READ_INPUT_MSG_LEN, ERR_READ_INPUT_MSG_END - ERR_READ_INPUT_MSG

	.equ ERR_WRITE_OUTPUT, 5
ERR_WRITE_OUTPUT_MSG:
	.ascii "ERROR: Unable to write to output file\n"
ERR_WRITE_OUTPUT_MSG_END:
	.equ ERR_WRITE_OUTPUT_MSG_LEN, ERR_WRITE_OUTPUT_MSG_END - ERR_WRITE_OUTPUT_MSG

#######CONSTANTS########

	#system call numbers
	.equ OPEN, 5
	.equ WRITE, 4
	.equ READ, 3
	.equ CLOSE, 6
	.equ EXIT, 1

	#options for open() (look at /usr/include/asm/fcntl.h for
	#                    various values.  You can combine them
	#                    by adding them)
	.equ O_RDONLY, 0
	.equ O_CREAT_WRONLY_TRUNC, 03101 

	#standard file descriptors
	.equ STDIN, 0
	.equ STDOUT, 1
	.equ STDERR, 2

	#system call interrupt
	.equ LINUX_SYSCALL, 0x80

	.equ END_OF_FILE, 0  #This is the return value of read() which
	                     #means we've hit the end of the file

	.equ NUMBER_ARGUMENTS, 2

.section .bss
	#Buffer - this is where the data is loaded into from
	#         the data file and written from into the output file.  This
	#         should never exceed 16,000 for various reasons.
	.equ BUFFER_SIZE, 500
	.lcomm BUFFER_DATA, BUFFER_SIZE
	
	.section .text

	#STACK POSITIONS
	.equ ST_SIZE_RESERVE, 12
	.equ ST_FD_IN, 0
	.equ ST_FD_OUT, 4
	.equ ST_ARGC, 12     #Number of arguments
	.equ ST_ARGV_0, 16   #Name of program
	.equ ST_ARGV_1, 20   #Input file name
	.equ ST_ARGV_2, 24   #Output file name

	.globl _start
_start:
	###INITIALIZE PROGRAM###
	subl  $ST_SIZE_RESERVE, %esp       #Allocate space for our pointers on the stack
	movl  %esp, %ebp
	#set up memory manager

	#initialize files to use
	cmpl  $1, ST_ARGC(%ebp)
	je    use_standard_files
	cmpl  $3, ST_ARGC(%ebp)
	je    open_files
	pushl $ERR_WRONG_NR_ARGS
	pushl $ERR_WRONG_NR_ARGS_MSG
	pushl $ERR_WRONG_NR_ARGS_MSG_LEN
	call  error_exit
	

use_standard_files:
	movl  $STDIN, ST_FD_IN(%ebp)
	movl  $STDOUT, ST_FD_OUT(%ebp)
	jmp   read_loop_begin

open_files:
open_fd_in:
	###OPEN INPUT FILE###
	movl  ST_ARGV_1(%ebp), %ebx  #input filename into %ebx
	movl  $O_RDONLY, %ecx        #read-only flag
	movl  $0666, %edx            #this doesn't really matter for reading
	movl  $OPEN, %eax            #open syscall
	int   $LINUX_SYSCALL         #call Linux

	cmpl  $0, %eax               #check for errors
	jge   store_fd_in            #continue to store_fd_in if none found

	pushl $ERR_OPEN_INPUT        #otherwise do an error exit
	pushl $ERR_OPEN_INPUT_MSG
	pushl $ERR_OPEN_INPUT_MSG_LEN
	call  error_exit

store_fd_in:
	movl  %eax, ST_FD_IN(%ebp)   #save the given file descriptor

open_fd_out:
	###OPEN OUTPUT FILE###
	movl  ST_ARGV_2(%ebp), %ebx        #output filename into %ebx
	movl  $O_CREAT_WRONLY_TRUNC, %ecx  #flags for writing to the file
	movl  $0666, %edx                  #permission set for new file (if it's created)
	movl  $OPEN, %eax                  #open the file
	int   $LINUX_SYSCALL               #call Linux

	cmpl  $0, %eax                     #check for errors
	jge   store_fd_out                 #continue to store_fd_out if none found

	pushl $ERR_OPEN_OUTPUT             #otherwise do an error exit
	pushl $ERR_OPEN_OUTPUT_MSG
	pushl $ERR_OPEN_OUTPUT_MSG_LEN
	call  error_exit

store_fd_out:
	movl  %eax, ST_FD_OUT(%ebp)       #store the file descriptor here

	###BEGIN MAIN LOOP###	
read_loop_begin:

	###READ IN A BLOCK FROM THE INPUT FILE###
	movl  ST_FD_IN(%ebp), %ebx     #get the input file descriptor
	movl  $BUFFER_DATA, %ecx       #the location to read into
	movl  $BUFFER_SIZE, %edx       #the size of the buffer
	movl  $READ, %eax
	int   $LINUX_SYSCALL

	###EXIT IF WE'VE REACHED THE END###
	cmpl  $END_OF_FILE, %eax       #check for end of file marker
	je    end_loop                 #if found, go to the end
	jg    continue_read_loop       #otherwise, check for errors, and go
	                               #to continue_read_loop if none found
	
	pushl $ERR_READ_INPUT          #otherwise do an error exit
	pushl $ERR_READ_INPUT_MSG
	pushl $ERR_READ_INPUT_MSG_LEN
	call  error_exit

continue_read_loop:
	###CONVERT THE BLOCK TO UPPER CASE###
	pushl $BUFFER_DATA             #location of the buffer
	pushl %eax                     #size of the buffer
	call  convert_to_upper
	popl  %eax
	popl  %ebx

	###WRITE THE BLOCK OUT TO THE OUTPUT FILE###
	movl  ST_FD_OUT(%ebp), %ebx    #file to use
	movl  $BUFFER_DATA, %ecx       #location of the buffer
	movl  %eax, %edx               #size of the buffer
	movl  $WRITE, %eax
	int   $LINUX_SYSCALL
	
	###CONTINUE THE LOOP###
	cmpl  $0, %eax                  #check for error conditions
	jge   read_loop_begin           #if none found, go back through the loop

	pushl $ERR_WRITE_OUTPUT         #otherwise do an error exit
	pushl $ERR_WRITE_OUTPUT_MSG
	pushl $ERR_WRITE_OUTPUT_MSG_LEN
	call  error_exit

end_loop:
	###CLOSE THE FILES###
	#NOTE - we don't need to do error checking on these, because 
	#       error conditions don't signify anything special here
	movl  ST_FD_OUT(%ebp), %ebx
	movl  $CLOSE, %eax
	int   $LINUX_SYSCALL

	movl  ST_FD_IN(%ebp), %ebx
	movl  $CLOSE, %eax
	int   $LINUX_SYSCALL

	###EXIT###
	movl  $0, %ebx
	movl  $EXIT, %eax
	int   $LINUX_SYSCALL


#PURPOSE:   This function actually does the conversion to upper case for a block
#
#INPUT:     The first parameter is the length of that buffer
#           The second parameter is the location of the block of memory to convert
#
#OUTPUT:    This function overwrites the current buffer with the upper-casified
#           version.
#
#VARIABLES:
#           %eax - beginning of buffer
#           %ebx - length of buffer
#           %edi - current buffer offset
#           %cl - current byte being examined (first part of %ecx)
#

	###CONSTANTS##
	.equ  LOWERCASE_A, 'a'              #The lower boundary of our search
	.equ  LOWERCASE_Z, 'z'              #The upper boundary of our search
	.equ  UPPER_CONVERSION, 'A' - 'a'   #Conversion between upper and lower case

	###STACK STUFF###
	.equ  ST_BUFFER_LEN, 8              #Length of buffer
	.equ  ST_BUFFER, 12                 #actual buffer
convert_to_upper:
	pushl %ebp
	movl  %esp, %ebp

	###SET UP VARIABLES###
	movl  ST_BUFFER(%ebp), %eax
	movl  ST_BUFFER_LEN(%ebp), %ebx
	movl  $0, %edi

	#if a buffer with zero length was given us, just leave
	cmpl  $0, %ebx
	je    end_convert_loop

convert_loop:
	#get the current byte
	movb  (%eax,%edi,1), %cl

	#go to the next byte unless it is between 'a' and 'z'
	cmpb  $LOWERCASE_A, %cl
	jl    next_byte
	cmpb  $LOWERCASE_Z, %cl
	jg    next_byte

	#otherwise convert the byte to uppercase
	addb  $UPPER_CONVERSION, %cl
	#and store it back
	movb  %cl, (%eax,%edi,1)  
next_byte:
	incl  %edi              #next byte
	cmpl  %edi, %ebx        #continue unless we've reached the end
	jne   convert_loop

end_convert_loop:
	#no return value, just leave
	movl  %ebp, %esp
	popl  %ebp
	ret

#PURPOSE:  This makes doing error exits simple
#
#INPUTS:   %eax - status code to return
#          %ebx - error message to print
#          %ecx - length of error message
#
#PROCESSING: Note that since we're exiting the program, we
#          don't need to save the current stack position
#
#NOTE:     This function never returns.  Only call here
#          when wanting to print an error and exit
error_exit:
	popl  %eax          #This is the return address - it is unused

	#Write the message to the error file
	popl  %edx          #%edx has the size of the error message
	popl  %ecx          #%ecx holds the message to print
	movl  $STDERR, %ebx #%ebx holds the file descriptor
	movl  $WRITE, %eax
	int   $LINUX_SYSCALL

	#Exit the program
	popl  %ebx
	movl  $EXIT, %eax
	int   $LINUX_SYSCALL
