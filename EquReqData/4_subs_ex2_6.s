	@ Deliverable: what is the Z flag after execution of each of the two subs instructions
	
	

	.global _start
_start:
	mov	r2, #4            @ r2 = 4
	mov	r3, #2            @ r3 = 2
	mov	r4, #4            @ r4 = 4
	subs	r5, r2, r3        @ r5 = r2 - r3 (r5 = 4 - 2 = 2)
	subs	r5, r2, r4        @ r5 = r2 - r4 (r5 = 4 - 4 = 0)


	mov	r7, #1
	svc	0
