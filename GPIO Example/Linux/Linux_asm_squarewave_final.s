@ mmap part taken from by https://bob.cs.sonoma.edu/IntroCompOrg-RPi/sec-gpio-mem.html

@ Constants for blink at GPIO21
@ GPFSEL2 [Offset: 0x08] responsible for GPIO Pins 20 to 29
@ GPCLR0 [Offset: 0x28] responsible for GPIO Pins 0 to 31
@ GPSET0 [Offest: 0x1C] responsible for GPIO Pins 0 to 31

@ GPOI20 Related
.equ    GPFSEL2, 0x08   @ function register offset
.equ    GPCLR0, 0x28    @ clear register offset
.equ    GPSET0, 0x1c    @ set register offset

@ GPIO Selection
.equ    PIN, 20                         @ Select GPIO pin number
.equ    GPFSEL2_GPIO_MASK, 0b111 << ((PIN - 20) * 3) @ Mask for GPIO pin field
.equ    MAKE_GPIO_OUTPUT, 0b001 << ((PIN - 20) * 3) @ Configure pin as output

@ On/Off Time
ON_TIME     .req    r9
@OFF_TIME    .req    r10

.equ    ON_TIME_INPUT, 500000
.equ    OFF_TIME_INPUT, 500000

ldr r0, =ON_TIME_INPUT
ldr r1, [r0]
mov r2, #9
mul r3, r1, r2
mov r2, #10
udiv    ON_TIME, r3, r2
@str r1, [r0]


@ Transfer Function for delay accuracy
@ldr    r0, =500000         @ Load ON_TIME value
@ldr    r1, =500000         @ Load OFF_TIME value

@mov     r2, #9            @ Load the numerator of 0.9 (9)
@mov     r3, #10           @ Load the denominator of 0.9 (10)
@udiv    r2, r2, r3        @ Perform r2 = 9 / 10 (i.e., 0.9)

@muls    r4, r0, r2        @ Multiply r0 (ON_TIME) by 0.9 and store in r4
@muls    r5, r1, r2        @ Multiply r1 (OFF_TIME) by 0.9 and store in r5

@ Set the new On/Off Time values
@.equ    ON_TIME, r4
@.equ    OFF_TIME, r5


@ Args for mmap
.equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
.equ    mem_fd_open, 3
.equ    BLOCK_SIZE, 4096        @ Raspbian memory page
.equ    ADDRESS_ARG, 3          @ device address

@ Misc
.equ    SLEEP_IN_S,1            @ sleep one second

@ The following are defined in /usr/include/asm-generic/mman-common.h:
.equ    MAP_SHARED,1    @ share changes with other processes
.equ    PROT_RDWR,0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)

@ Constant program data
    .section .rodata
device:
    .asciz  "/dev/gpiomem"


@ The program
    .text
    .global main
main:
@ Open /dev/gpiomem for read/write and syncing
    ldr     r1, O_RDWR_O_SYNC   @ flags for accessing device
    ldr     r0, mem_fd          @ address of /dev/gpiomem
    bl      open     
    mov     r4, r0              @ use r4 for file descriptor

@ Map the GPIO registers to a main memory location so we can access them
@ mmap(addr[r0], length[r1], protection[r2], flags[r3], fd[r4])
    str     r4, [sp, #OFFSET_FILE_DESCRP]   @ r4=/dev/gpiomem file descriptor
    mov     r1, #BLOCK_SIZE                 @ r1=get 1 page of memory
    mov     r2, #PROT_RDWR                  @ r2=read/write this memory
    mov     r3, #MAP_SHARED                 @ r3=share with other processes
    mov     r0, #mem_fd_open                @ address of /dev/gpiomem
    ldr     r0, GPIO_BASE                   @ address of GPIO
    str     r0, [sp, #ADDRESS_ARG]          @ r0=location of GPIO
    bl      mmap
    mov     r5, r0           @ save the virtual memory address in r5

@ Set up the GPIO pin funtion register in programming memory
    add     r0, r5, #GPFSEL2            @ calculate address for GPFSEL2
    ldr     r2, [r0]                    @ get entire GPFSEL2 register
    bic     r2, r2, #GPFSEL2_GPIO_MASK@ clear pin field
    orr     r2, r2, #MAKE_GPIO_OUTPUT @ enter function code
    str     r2, [r0]                    @ update register


loop:

@ Turn on
    add     r0, r5, #GPSET0 @ calc GPSET0 address

    mov     r3, #1          @ turn on bit
    lsl     r3, r3, #PIN    @ shift bit to pin position
    orr     r2, r2, r3      @ set bit
    str     r2, [r0]        @ update register

@ Delay ON_TIME
    ldr     r3, ON_TIME
    bl      delay


@ Turn off
    add     r0, r5, #GPCLR0 @ calc GPSET0 address

    mov     r3, #1          @ turn on bit
    lsl     r3, r3, #PIN    @ shift bit to pin position
    orr     r2, r2, r3      @ set bit
    str     r2, [r0]        @ update register

@ Delay OFF_TIME
    ldr     r3, =OFF_TIME_INPUT
    bl      delay

    b   loop

delay:
    mov     r2, #10
dec: subs    r3, r3, #1
    bne     dec
    bx      lr

GPIO_BASE:
    .word   0xfe200000 @GPIO Base address Raspberry pi 4
mem_fd:
    .word   device
O_RDWR_O_SYNC:
    .word   2|256       @ O_RDWR (2)|O_SYNC (256).
