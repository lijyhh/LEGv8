;;;;;;;;;;;;;;; Used for test ;;;;;;;;;;;;;;;
; 0 1st
MOV X1, XZR         ; X1 = 0
; 4 2nd
NOP
; 8 3rd
NOP
; 12 4th
NOP
; 16 5th
LDUR SP, [X1, #0]   ; Stack pointer point to address in data_mem[0]
; 20 6th
LDUR X0, [X1, #8]   ; X0 = data_mem[1], i.e. The number of data is stored in X0.
                    ; e.g. fact(6), X0 = 6
; 24 7th
NOP
; 28 8th
NOP
;;;;;;;;;;;;;;; Used for test ;;;;;;;;;;;;;;;

; 15 instrcutions
; 0 1st fact
SUBI SP, SP, #16  ; Save return address and n on stack
; 4 2nd
SUBIS XZR, X0, #1 ; compare n and 1
; 8 3rd BRANCH TO L1
B.GE #10          ; if n >= 1, go to L1
; 12 4th 
NOP
; 16 5th 
STUR LR, [SP, #8] 
; 20 6th
STUR X0, [SP, #0]
; 24 7th
ADDI X1, XZR, #1  ; Else, set return value to 1
; 28 8th
ADDI SP, SP, #16  ; Pop stack, dont bother restoring values
; 32 9th
BR LR             ; Return: Copy LR to PC
; 36 10th
NOP
; 40 11th
NOP
; 44 12th
NOP

; 48 13th L1
SUBI X0, X0, #1   ; n = n - 1
; 52 14th
BL #-13           ; call fact(n-1): put PC in LR(X30)
; 56 15th
NOP
; 60 16th
NOP
; 64 17th
NOP

; 68 18th
LDUR X0, [SP, #0] ; Restore caller's n
; 72 19th
LDUR LR, [SP, #8] ; Restore caller's return address
; 76 20th
ADDI SP, SP, #16  ; Pop stack
; 80 21st
NOP
; 84 22nd
MUL X1, X0, X1    ; return n*fact(n-1)
; 88 23rd
BR LR             ; return: Copy LR to PC
; 92 24th
NOP
; 96 25th
NOP
; 100 26th
NOP
