; 15 instrcutions
; 0 fact
SUBI SP, SP, #16
; 4
STUR LR, [SP, #8]
; 8
STUR X0, [SP, #0]
; 12
SUBIS XZR, X0, #1
; 16 BRANCH TO L1
B.GE #32
; 20
ADDI X1, XZR, #1
; 24
ADDI SP, SP, #16
; 28
BR LR

; 32 L1
SUBI X0, X0, #1
; 36
BL #0

; 40
LDUR X0, [SP, #0]
; 44
LDUR LR, [SP, #8]
; 48
ADDI SP, SP, #16
; 52
MUL X1, X0, X1
; 56
BR LR
