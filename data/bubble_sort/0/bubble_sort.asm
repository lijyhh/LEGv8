;;;;;;;;;;;;;;; Used for test ;;;;;;;;;;;;;;;
; 0 1st
ADDI X0, XZR, #8 ; data memory[1]
; 4 2nd
ADDI X1, XZR, #5    ; 5 values to be sorted
; 8 3rd
ADDI SP, XZR, #1020 ; stack pointer pointer to 1020
; 12 4th
BL #6               ; go to sort
; 16 5th
LDUR X9, [X0, #0]   ; v[0]
; 20 6th
LDUR X9, [X0, #8]   ; v[1]
; 24 7th
LDUR X9, [X0, #16]  ; v[2]
; 28 8th
LDUR X9, [X0, #24]  ; v[3]
; 32 9th
LDUR X9, [X0, #32]  ; v[4]
;;;;;;;;;;;;;;; Used for test ;;;;;;;;;;;;;;;

; 41 instructions
; 0 sort 1st
SUBI SP, SP, #40    ; make room on stack for 5 registers
; 4 2nd
STUR X30, [SP, #32] ; save LR on stack
; 8 3rd
STUR X22, [SP, #24] ; save X22 on stack
; 12 4th
STUR X21, [SP, #16] ; save X21 on stack
; 16 5th
STUR X20, [SP, #8]  ; save X20 on stack
; 20 6th
STUR X19, [SP, #0]  ; save X19 on stack
 
; 24 7th
MOV X21, X0         ; copy parameter X0 into X21
; 28 8th
MOV X22, X1         ; copy parameter X1 into X22

; 32 9th
MOV X19, XZR        ; i = 0
; 36 for1tst 10th
CMP X19, X22         ; compare X19 to X22 (i to n)
; 40 11th
B.GE #17            ; go to exit1 if X19 >= X22 (i >= n)

; 44 12th
SUBI X20, X19, #1   ; j = i - 1
; 48 for2tst 13th
CMP X20, XZR        ; compare X20 to 0 (j to 0)
; 52 14th
B.LT #12            ; go to exit2 if X20 < 0 (j < 0)
; 56 15th
LSL X10, X20, #3    ; reg X10 = j * 8
; 60 16th
ADD X11, X0, X10    ; reg X11 = v + (j * 8)
; 64 17th
LDUR X12, [X11, #0] ; reg X12 = v[j]
; 68 18th
LDUR X13, [X11, #8] ; reg X13 = v[j + 1]
; 72 19th
CMP X12, X13        ; compare X12 to X13
; 76 20th
B.LE #6             ; go to exit2 if X12 <= X13

; 80 21st
MOV X0, X21         ; first swap parameter is v
; 84 22nd
MOV X1, X20         ; second swap parameter is j
; 88 23rd
BL #12              ; branch to swap and link to X30

; 92 24th
SUBI X20, X20, #1   ; j -= 1
; 96 25th
B #-12              ; branch to test of inner loop( for2tst )

; 100 exit2 26th
ADDI X19, X19, #1   ; i += 1
; 104 27th
B #-17              ; branch to test of outer loop( for1tst )

; 108 exit1 28th
LDUR X19, [SP, #0]  ; restore X19 from stack
; 112 29th
LDUR X20, [SP, #8]  ; restore X20 from stack
; 116 30th
LDUR X21, [SP, #16] ; restore X21 from stack
; 120 31st
LDUR X22, [SP, #24] ; restore X22 from stack
; 124 32nd
LDUR X30, [SP, #32] ; restore X30 from stack
; 128 33rd
ADDI SP, SP, #40    ; restore stack pointer

; 132 34th
BR LR               ; return to calling routine

; 136 swap 35th
LSL X10, X1, #3     ; reg X10 = k * 8
; 140 36th
ADD X10, X0, X10    ; reg X10 = v + (k * 8)
                    ; reg X10 has the address of v[k]
; 144 37th
LDUR X9, [X10, #0]  ; reg X9(tmp) = v[k]
; 148 38th
LDUR X11, [X10, #8] ; reg X11 = v[k + 1]
                    ; refers to next element of v
; 152 39th
STUR X11, [X10, #0] ; v[k] = reg X11
; 156 40th
STUR X9, [X10, #8]  ; v[k + 1] = reg X9(tmp)

; 160 41th
BR LR               ; return to calling routine
