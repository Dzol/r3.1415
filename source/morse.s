.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp,#0x8000

GPIOAddress .req r4
SOSPattern .req r5
Counter .req r6        

ldr GPIOAddress,=0x20200000      /* r[4] = @[GPIO Base Address] */

ldr SOSPattern,=SOSPatternData
ldr SOSPattern,[SOSPattern]        

bl EnableOutput
bl InitializeCounter            /* r[6] = 0 */

forever:

/* bl IsCounterOdd */                 /* r[0] = 0 OR 1 */
bl ReadMorsePattern
bl IncrementCounter             /* r[6] = 0 if r[6] == 32 else r[6] += 1 */
bl SwitchOnOrOff                /* @[GPIO Base Address] + offset = ON if r[0] == 0 else OFF */
bl busy

b forever

EnableOutput:
mov r1,#1               /* r[1] = 1 */
lsl r1,#18              /* r[1] = r[1] << 18 */
str r1,[GPIOAddress,#4]          /* @GPIO + 4 = r[1] */
mov pc,lr               /* PC = LR */

SwitchOnOrOff:
mov r1,#1                       /* r[1] = 1 */
lsl r1,#16                      /* r[1] = r[1] << 16 */
teq r0,#1
streq r1,[GPIOAddress,#40]      /* @GPIO + 40 = r[1] */
teq r0,#0
streq r1,[GPIOAddress,#28]      /* @GPIO + 28 = r[1] */
mov pc,lr                       /* PC = LR */

/* Busy by looping from 0x3f000 to 0 */
busy:
mov r2,#0x3F0000        /* r[2] = 0x3f0000 */
loop:
sub r2,#1               /* r[2] -= 1 */
cmp r2,#0               /* r[2] == 0 */
bne loop
mov pc,lr               /* PC = LR */

IsCounterOdd:
mov r0,Counter
and r0,#1
mov pc,lr

ReadMorsePattern:
mov r0,#1
lsl r0,Counter
and r0,SOSPattern
teq r0,#0
movne r0,#1        
mov pc,lr

InitializeCounter:
mov Counter,#0
mov pc,lr
        
IncrementCounter:
teq Counter,#31
addne Counter,#1
push {lr}
bleq InitializeCounter
pop {lr}
mov pc,lr

.section .data
.align 2
SOSPatternData:
.int 0b11111111101010100010001000101010
