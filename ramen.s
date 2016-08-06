
.equ STDOUT, 1
.equ WRITE, 4
.equ LINUX_SYSCALL, 0x80

ramen:
.ascii "I like Ramen, do you?\n\0"
ramenend:
.equ ramenlength, ramenend - ramen

.section .text
.type printf,@function
.globl printf
printf:
	pushl %ebp
	movl %esp, %ebp
	movl ramen, %ebx
	movl ramenlength, %ecx
	movl $STDOUT, %edx
	movl $WRITE, %eax
	int $LINUX_SYSCALL

	movl %ebp, %esp
	popl %ebp

	
