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

; 32 for1tst 9th
CMP X19, X1         ; i = 0
; 36 10th
B.GE #17            ; go to exit1 if X19 >= X1 (i >= n)

; 40 11th
SUBI X20, X19, #1   ; j = i - 1
; 44 for2tst 12th
CMP X20, XZR        ; compare X20 to 0 (j to 0)
; 48 13th
B.LT #12            ; go to exit2 if X20 < 0 (j < 0)
; 52 14th
LSL X10, X20, #3    ; reg X10 = j * 8
; 56 15th
ADD X11, X0, X10    ; reg X11 = v + (j * 8)
; 60 16th
LDUR X12, [X11, #0] ; reg X12 = v[j]
; 64 17th
LDUR X13, [X11, #8] ; reg X13 = v[j + 1]
; 68 18th
CMP X12, X13        ; compare X12 to X13
; 72 19th
B.LE #6             ; go to exit2 if X12 <= X13

; 76 20th
MOV X0, X21         ; first swap parameter is v
; 80 21th
MOV X1, X20         ; second swap parameter is j
; 84 22th
BL #12              ; branch to swap and link to X30

; 88 23th
SUBI X20, X20, #1   ; j -= 1
; 92 24th
B #-12              ; branch to test of inner loop( for2tst )

; 96 exit2 25th
ADDI X19, X19, #1   ; i += 1
; 100 26th
B #-17              ; branch to test of outer loop( for1tst )

; 104 exit1 27th
STUR X19, [SP, #0]  ; restore X19 from stack
; 108 28th
STUR X20, [SP, #8]  ; restore X20 from stack
; 112 29th
STUR X21, [SP, #16] ; restore X21 from stack
; 116 30th
STUR X22, [SP, #24] ; restore X22 from stack
; 120 31th
STUR X30, [SP, #32] ; restore X30 from stack
; 124 32th
SUBI SP, SP, #40    ; restore stack pointer

; 128 33th
BR LR               ; return to calling routine

; 132 swap 34th
LSL X10, X1, #3     ; reg X10 = k * 8
; 136 35th
ADD X10, X0, X10    ; reg X10 = v + (k * 8)
                    ; reg X10 has the address of v[k]
; 140 36th
LDUR X9, [X10, #0]  ; reg X9(tmp) = v[k]
; 144 37th
LDUR X11, [X10, #8] ; reg X11 = v[k + 1]
                    ; refers to next element of v
; 148 38th
STUR X11, [X10, #0] ; v[k] = reg X11
; 152 39th
STUR X9, [X10, #8]  ; v[k + 1] = reg X9(tmp)

; 156 40th
BR LR               ; return to calling routine
