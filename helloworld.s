
.data	
hello:
	.string "Hello World!\n"


.text
.globl _start
_start:

	movl $4, %eax
	movl $1, %ebx
	movl $hello, %ecx
	movl $13, %edx 
	int $0x80

	movl $1, %eax
	movl $0, %ebx
	int $0x80

