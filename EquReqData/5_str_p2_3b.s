@Deliverable 1: Describe the str instruction and the addressing type with the str instruction.
@Deliverable 2: Show the register values after running the program (prior to program exit).

	.text
	.global _start
_start:
	@ r1 = a
	ldr	r0, =a
	ldr	r1, [r0]
	
	@ r2 = b
	ldr	r0, =b
	ldr	r2,[r0]

	@ c = r1 + r2 (c = a + b)
	add	r3, r1, r2
	ldr	r0, =c
	str	r3, [r0]

	mov	r7, #1
	svc	0

	.data
a:	.word	5
b:	.word	4
c:	.word	0
