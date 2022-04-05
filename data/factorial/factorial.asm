; 15 instrcutions
; 0 fact 1st
SUBI SP, SP, #16  ; Save return address and n on stack
; 4 2nd
STUR LR, [SP, #8] 
; 8 3rd
STUR X0, [SP, #0]
; 12 4th 
SUBIS XZR, X0, #1 ; compare n and 1
; 16 BRANCH TO L1 5th 
B.GE #4           ; if n >= 1, go to L1
; 20 6th
ADDI X1, XZR, #1  ; Else, set return value to 1
; 24 7th
ADDI SP, SP, #16  ; Pop stack, dont bother restoring values
; 28 8th
BR LR             ; Return: Copy LR to PC

; 32 L1 9th
SUBI X0, X0, #1   ; n = n - 1
; 36 10th
BL #-9            ; call fact(n-1): put PC in LR(X30)

; 40 11th
LDUR X0, [SP, #0] ; Restore caller's n
; 44 12th
LDUR LR, [SP, #8] ; Restore caller's return address
; 48 13th
ADDI SP, SP, #16  ; Pop stack
; 52 14th
MUL X1, X0, X1    ; return n*fact(n-1)
; 56 15th
BR LR             ; return: Copy LR to PC
