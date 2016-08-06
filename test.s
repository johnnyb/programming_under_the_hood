	.equ PERSON_SIZE, 84
	.equ PERSON_FIRSTNAME_OFFSET, 0
	.equ PERSON_LASTNAME_OFFSET, 40
	.equ PERSON_AGE_OFFSET, 80
.section .text
.globl _start
_start:
	nop
	nop
	nop
	movl $3, %eax
	movl $2, %ecx
	pushl $3
	imull %ecx, (%esp)
	movl (%esp), %ebx
	movl $1, %eax
	int $0x80

.globl foo
.type foo,@function
foo:
	pushl %ebp
	movl  %esp, %ebp

	subl  $PERSON_SIZE, %esp
	.equ  P_VAR, 0-PERSON_SIZE

	movl  $30, P_VAR + PERSON_AGE_OFFSET(%ebp)

	movl %ebp, %esp
	popl %ebp
	ret

	imull %eax


