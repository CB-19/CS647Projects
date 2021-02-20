.data
	msg_prompt:
		.asciz "Please enter the plaintext: "
	len_msg_prompt = .-msg_prompt
	shift_prompt:
		.asciz "Please enter the shift value: "
	len_shift_prompt = .-shift_prompt
	cipher_prompt:
		.asciz "Your ciphertext is: "
	len_cipher_prompt = .-cipher_prompt

.bss
	.comm msg_pla, 100		# place holder for plaintext
        .comm len_msg_pla, 4		# place holder for len of plaintext
        .comm shift_num, 4		# place holder for shift number
	.comm len_shift_num, 4		# place holder for len of shift number
.text

	.global _start
	.type Print, @function		
	.type Read, @function
	.type Exit, @function

	Print:				#prints output to screen
		pushl %ebp		#pushes value of ebp to the stack
		movl %esp, %ebp		#move value of stack pointer to EBP
		
		movl $4, %eax		#move 4 to eax
		movl $1, %ebx		#move 1 to ebx
		movl 8(%ebp), %ecx	#moves the text to to be printed to ecx (located at EBP + 8)
		movl 12(%ebp), %edx	#move the length of the text to be printed to edx (located at EBP + 12)
		int $0x80		#system interupt to print
		
		movl %ebp, %esp		#move value of ebp back to esp
		popl %ebp		#remove ebp from stack
		ret			#return to the line of code after this function is called
	Read:
		pushl %ebp		
		movl %esp, %ebp		#move value of stack pointer to EBP
		movl $3, %eax		#move 3 to eax
		movl $0, %ebx		#move 0 to ebx
		movl 8(%ebp), %ecx	#moves the text to to be printed to ecx (located at EBP + 8)
		movl 12(%ebp), %edx	#move the length of the text to be printed to edx (located at EBP + 12)
		int $0x80		#system interupt to read

		movl %ebp, %esp		#move value of ebp back to esp
		popl %ebp		#remove ebp from stack
		ret			#return to the line of code after this function is called

	Exit:
		movl $1, %eax		#move 1 to eax
		movl $0, %ebx		#move 0 to ebx
		int $0x80		#system interupt to exit
		ret			#return to the line of code after this function is called

	_start:
		PROMPT1:				#This prints to the screen the prompt asking for plaintext
			pushl $len_msg_prompt		#pushes length of the message to the stack
			pushl $msg_prompt		#pushes message to the stack
			call Print			#calls print
			addl $8, %esp			#after print finishes, the program returns here and adds 8 to ESP

		ReadText:
			pushl $100			#pushes the value 100 to the stack (max length of message)
			pushl $msg_pla			#pushes the placeholder value of the plaintext to the stack (to be overwitten)
			call Read			#calls read
			addl $8, %esp			#after read finishes, the program returns here and adds 8 to ESP
			mov %eax, len_msg_pla(,1)	#the length of input is store at eax, move to the corresponding variable and subtract 1

		PROMPT2:				#This prints to the screen the prompt asking for the shift value
			pushl $len_shift_prompt		#pushes the length of text to be presented to the stack
			pushl $shift_prompt		#pushes the prompt to the stack 
			call Print			#calls print
			addl $8, %esp			#after print finishes, the program returns here and adds 8 to ESP 			

		ReadShift:
			pushl $4			#pushes the vaue 4 to the stack (max length of shift value)
			pushl $shift_num		#pushes the placeholder value of the shift number to the stack
			call Read			#calls read
			addl $8, %esp			#after read finishes, the program returns here and adds 8 to ESP

   			mov %eax, len_shift_num(,1)	#the length of input is store at eax, move to the corresponding variable and subtract 1	

			# the input shift_num is in ascii characters
			# e.g '10\n'
			# convert string number to actual number (stoi)
		
		stoi:
			leal shift_num, %esi          	# load shift_num that in ascii
			movl len_shift_num, %ecx      	# ecx = len_shift_num, length of shift_num in ascii
			sub $1, %ecx			# ecx = ecx - 1
			movl $0, %edx 			# reserved edx for computation

		stoi_loop:
			lodsb				# load a single digit
				
 			sub $48, %al			# actual decimal value = ascii value - ascii value of '0'
			imul $10, %edx, %edx		# multiply edx by 10 and store in edx
			add %eax, %edx			# after this step and the previous edx = 10*edx+eax
			
		stoi_end:
                        dec %ecx			#decrement ecx by 1

 			jecxz save_shift_num		#jump to save_shift_num if ecx = 0 (when done looping through)
                        jmp stoi_loop			#jump to stoi_loop because ecx > 0 which means more values to convert
		
		
		save_shift_num:
			# edx contain the rot number
			mov %edx, shift_num(,1)

   		compute_shift:
                	# shift_num = shift_num%26
                	mov shift_num, %eax		# eax = shift_num
			xor %edx, %edx			# edx = 0
                        mov $26, %ecx			# ecx = 26
                        div %ecx			# eax = eax/ecx, remainder are saved in edx

                        mov %edx, shift_num(,1)		# save mode value to shift_num

			leal msg_pla, %esi		
                        leal msg_pla, %edi

                     	movl len_msg_pla, %ecx
                     	sub $1, %ecx   

		Loop:
                        lodsb		   # load one byte to eax
			cmp $0x20, %al     # check character is a space
			jne Shift          # shift if it is not space
			jmp Spa            # otherwise, skip this character

		Shift:
			# Shift character
                        add shift_num, %al
                        cmp $90, %al 	   # check if greater than value than 'Z' (90 in ascii) after shift
                        ja Gtr		   # jump to Gtr if al is greater than 90
                        jmp Spa		   # jump to Spa 
                
                Gtr:
                        sub $26, %al	   # rotate to get actual character by subtract 26

		Spa:
                        stosb
                        dec %ecx

 			jecxz PrintResult
                        jmp Loop
                        
                PrintResult:
			pushl $len_cipher_prompt
			pushl $cipher_prompt
			call Print
			addl $8, %esp
			
			pushl $len_msg_pla
			pushl $msg_pla
			call Print
			addl $8, %esp

			call Exit



