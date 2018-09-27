.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp,#0x8000

;; /* Old */
;; ldr r0,=0x20200000      /* r[0] = @GPIO */

/* Enable output */
pinNum .req r0
pinFunc .req r1
mov pinNum,#16
mov pinFunc,#1          /* #1 "on" or enable */
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

ptrn .req r4            /* name register r4 `ptrn` */
ldr ptrn,=pattern
ldr ptrn,[ptrn]
seq .req r5
mov seq,#0              /* this is our counter */

l:

bl morse
bl incrementCounter
bl switch

/* Busy by looping from 0x3f000 to 0 */
bl busy                 /* LR = PC + 1; PC = @busy */

b l

/* Busy by looping from 0x3f000 to 0 */
busy:
ldr  r3,=0x20003000 /* constant address of counter */
ldr  r4,=0x3D090   /* time to wait in microseconds */
ldrd r0,r1,[r3,#4] /* read counter value into r[0] */
add  r2,r0,r4 /* add constant wait time to r[0] */
loop2:  /* branch somewhere */
ldrd r0,r1,[r3,#4] /* read counter value into r[1] */
cmp r2,r0 /* if r[1] > r[0] then stop branching */
bhi loop2
mov pc,lr

morse:
mov r6,#1
lsl r6,seq
and r6,ptrn
mov pc,lr

switch:
pinNum .req r0
pinVal .req r1
mov pinNum,#16
mov pinVal,r6
bl SetGpio
.unreq pinNum
.unreq pinVal
mov pc,lr

incrementCounter:
add seq,#1
;; cmp seq,#31
;; addls seq,#1              /* increment our count */
;; movhi seq,#0
mov pc,lr

.section .data
.align 2
pattern:
.int 0b11111111101010100010001000101010
