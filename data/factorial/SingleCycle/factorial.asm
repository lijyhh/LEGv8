;;;;;;;;;;;;;;; Used for test ;;;;;;;;;;;;;;;
; 0 1st
MOV X1, XZR         ; X1 = 0
; 4 2nd
LDUR SP, [X1, #0]   ; Stack pointer point to address in data_mem[0]
; 8 3rd
LDUR X0, [X1, #8]   ; X0 = data_mem[1], i.e. The number of data is stored in X0.
                    ; e.g. fact(6), X0 = 6
;;;;;;;;;;;;;;; Used for test ;;;;;;;;;;;;;;;

; 15 instrcutions
; 0 1st fact
SUBI SP, SP, #16  ; Save return address and n on stack
; 4 2nd
STUR LR, [SP, #8] 
; 8 3rd
STUR X0, [SP, #0]
; 12 4th 
SUBIS XZR, X0, #1 ; compare n and 1
; 16 5th BRANCH TO L1
B.GE #4           ; if n >= 1, go to L1
; 20 6th
ADDI X1, XZR, #1  ; Else, set return value to 1
; 24 7th
ADDI SP, SP, #16  ; Pop stack, dont bother restoring values
; 28 8th
BR LR             ; Return: Copy LR to PC

; 32 9th L1
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
