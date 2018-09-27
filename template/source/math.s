.globl Divide
Divide:         /* r[0] = numerator; r[1] = denominator */
;; mov r2, #0      /* r[2] = 0 */
;; l:
;; sub r0,r1
;; cmp r0,#0       /* Maybe it can't distinguish negative numbers */
;; addhs r2,#1
;; bhs l
;; mov r0,r2
mov r0,#1
mov pc,lr
