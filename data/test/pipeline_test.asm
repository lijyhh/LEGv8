; 0 1st
ADDI X0, XZR, #1    ; X0 = 0 + 1 = 1
; 4 2nd 
ADDI X1, XZR, #2    ; X1 = 0 + 2 = 2
; 8 3rd
NOP
; 12 4th
NOP
; 16 5th
NOP
; 20 6th
ADD X2, X0, X1      ; X2 = X0 + X1 = 1 + 2 = 3
; 24 7th
B #5                ; branch to L1
; 28 8th
NOP
; 32 9th
NOP
; 36 10th
NOP
; 40 11th
NOP
; 44 12th L1
ADD X1, X0, X2      ; X1 = X0 + X2 = 1 + 3 = 4
