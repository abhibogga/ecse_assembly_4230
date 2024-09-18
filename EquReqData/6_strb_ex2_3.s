	@ Deliverable: State the contents of memory locations at data_store after the program is executed (prior to program exit).  Add instructions prior to the 
 	@ program exit to show the contents of data_store in registers R2 and R3 with the upper lower 4 bytes into R2 and the upper into R3.
	@ Deliverable: What does the strb instruction do (be specific.  which byte is always stored using strb?)
 	@ Deliverable: What does the .space compiler directive do?

	.global _start
_start:
	mov	r1, #0x99	@ r1 = 0x99
	ldr	r6, =data_store	@ r6 = data_store pointer
	strb	r1, [r6]	@ store r1 into location pointed to by r6 
				@ 
	add	r6, r6, #1	@ r6 = r6 + 1
	mov	r1, #0x85	@ r1 = 0x85
	strb	r1, [r6]	@ store r1 into location pointed to by r6 
				@ 
	add	r6, r6, #1	@ r6 = r6 + 1
	mov	r1, #0x3f	@ r1 = 0x3f
	strb	r1, [r6]	@ store r1 into location pointed to by r6 

	add	r6, r6, #1	@ r6 = r6 + 1
	mov	r1, #0x63	@ r1 = 0x63
	strb	r1, [r6]	@ store r1 into location pointed to by r6 

	add	r6, r6, #1	@ r6 = r6 + 1
	mov	r1, #0x12	@ r1 = 0x12
	strb	r1, [r6]	

	mov	r7, #1
	svc	0
 
	.data
 data_store: .space 8
