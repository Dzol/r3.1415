.section .init
.globl _start
_start:

ldr r0,=0x20200000      /* r[0] = @GPIO */

/* Enable output */
mov r1,#1               /* r[1] = 1 */
lsl r1,#18              /* r[1] = r[1] << 18 */
str r1,[r0,#4]          /* @GPIO + 4 = r[1] */

l:

/* Switch LED on */
mov r1,#1               /* r[1] = 1 */
lsl r1,#16              /* r[1] = r[1] << 16 */
str r1,[r0,#40]         /* @GPIO + 40 = r[1] */

/* Busy by looping from 0x3f000 to 0 */
bl busy                 /* LR = PC + 1; PC = @busy */

/* Switch LED off */
mov r1,#1
lsl r1,#16
str r1,[r0,#28]

bl busy                 /* LR = PC + 1; PC = @busy */

b l

/* Busy by looping from 0x3f000 to 0 */
busy:
mov r2,#0x3F0000        /* r[2] = 0x3f0000 */
loop:
sub r2,#1               /* r[2] -= 1 */
cmp r2,#0               /* r[2] == 0 */
bne loop
mov pc,lr               /* PC = LR */
