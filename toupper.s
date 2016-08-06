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

	.section .data  #we actually don't put anything in the data section in
	                #this program, but it's here for completeness
	
#######CONSTANTS########

	#system call numbers
	.equ OPEN, 5
	.equ WRITE, 4
	.equ READ, 3
	.equ CLOSE, 6
	.equ EXIT, 1

	#options for open   (look at /usr/include/asm/fcntl.h for
	#                    various values.  You can combine them
	#                    by adding them)
	.equ O_RDONLY, 0                  #Open file options - read-only
	.equ O_CREAT_WRONLY_TRUNC, 03101  #Open file options - these options are:
	                                  #CREAT - create file if it doesn't exist
	                                  #WRONLY - we will only write to this file
	                                  #TRUNC - destroy current file contents, if any exist 

	#system call interrupt
	.equ LINUX_SYSCALL, 0x80

	#end-of-file result status
	.equ END_OF_FILE, 0  #This is the return value of read() which
	                     #means we've hit the end of the file

#######BUFFERS#########

.section .bss
	#This is where the data is loaded into from
	#the data file and written from into the output file.  This
	#should never exceed 16,000 for various reasons.
	.equ BUFFER_SIZE, 500
	.lcomm BUFFER_DATA, BUFFER_SIZE


#######PROGRAM CODE###

	.section .text

	#STACK POSITIONS
	.equ ST_SIZE_RESERVE, 8
	.equ ST_FD_IN, 0
	.equ ST_FD_OUT, 4
	.equ ST_ARGC, 8      #Number of arguments
	.equ ST_ARGV_0, 12   #Name of program
	.equ ST_ARGV_1, 16   #Input file name
	.equ ST_ARGV_2, 20   #Output file name

	.globl _start
_start:
	###INITIALIZE PROGRAM###
	subl  $ST_SIZE_RESERVE, %esp       #Allocate space for our pointers on the stack
	movl  %esp, %ebp

open_files:
open_fd_in:
	###OPEN INPUT FILE###
	movl  ST_ARGV_1(%ebp), %ebx  #input filename into %ebx
	movl  $O_RDONLY, %ecx        #read-only flag
	movl  $0666, %edx            #this doesn't really matter for reading
	movl  $OPEN, %eax            #open syscall
	int   $LINUX_SYSCALL         #call Linux

store_fd_in:
	movl  %eax, ST_FD_IN(%ebp)   #save the given file descriptor

open_fd_out:
	###OPEN OUTPUT FILE###
	movl  ST_ARGV_2(%ebp), %ebx        #output filename into %ebx
	movl  $O_CREAT_WRONLY_TRUNC, %ecx  #flags for writing to the file
	movl  $0666, %edx                  #permission set for new file (if it's created)
	movl  $OPEN, %eax                  #open the file
	int   $LINUX_SYSCALL               #call Linux

store_fd_out:
	movl  %eax, ST_FD_OUT(%ebp)       #store the file descriptor here

	###BEGIN MAIN LOOP###	
read_loop_begin:

	###READ IN A BLOCK FROM THE INPUT FILE###
	movl  ST_FD_IN(%ebp), %ebx     #get the input file descriptor
	movl  $BUFFER_DATA, %ecx       #the location to read into
	movl  $BUFFER_SIZE, %edx       #the size of the buffer
	movl  $READ, %eax
	int   $LINUX_SYSCALL           #Size of buffer read is
	                               #returned in %eax

	###EXIT IF WE'VE REACHED THE END###
	cmpl  $END_OF_FILE, %eax       #check for end of file marker
	jle   end_loop                 #if found, go to the end

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
	jmp   read_loop_begin

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

#####FUNCTION convert_to_upper
#
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
#           %cl - current byte being examined (%cl is the first byte of %ecx)
#

	###CONSTANTS##
	.equ  LOWERCASE_A, 'a'              #The lower boundary of our search
	.equ  LOWERCASE_Z, 'z'              #The upper boundary of our search
	.equ  UPPER_CONVERSION, 'A' - 'a'   #Conversion between upper and lower case

	###STACK POSITIONS###
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
