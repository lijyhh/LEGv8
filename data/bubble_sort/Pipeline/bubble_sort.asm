;;;;;;;;;;;;;;; Used for test ;;;;;;;;;;;;;;;
; 0 1st
MOV X10, XZR        ; X10 = 0, first address of data memory
; 4 2nd
NOP
; 8 3rd
NOP
; 12 4th
NOP
; 16 5th
LDUR SP, [X10, #0]  ; Stack pointer point to address in data_mem[0]
; 20 6th
BL #8               ; Go to sort
; 24 7th
LDUR X1, [X10, #8]  ; Number of data to be sorted
; 28 8th
LDUR X0, [X10, #16] ; Base address of v
; 32 9th
NOP
; 36 10th
B #0                ; Jump in place
; 40 11th
NOP
; 44 12th
NOP
; 48 13th
NOP
;;;;;;;;;;;;;;; Used for test ;;;;;;;;;;;;;;;

; 87 instructions
; 0 1st sort
SUBI SP, SP, #40    ; make room on stack for 5 registers
; 4 2nd
NOP
; 8 3rd
NOP
; 12 4th
NOP
; 16 5th
STUR X19, [SP, #0]  ; save X19 on stack
; 20 6th
STUR X22, [SP, #24] ; save X22 on stack
; 24 7th
STUR X21, [SP, #16] ; save X21 on stack
; 28 8th
STUR X20, [SP, #8]  ; save X20 on stack

; 32 9th
MOV X19, XZR        ; i = 0
; 36 10th 
MOV X22, X1         ; copy parameter X1 into X22
; 40 11th
MOV X21, X0         ; copy parameter X0 into X21
; 44 12th
STUR X30, [SP, #32] ; save LR on stack
; 48 13th
NOP

; 52 14th for1tst
CMP X19, X22        ; compare X19 to X22 (i to n)
; 56 15th
B.GE #47            ; go to exit1 if X19 >= X22 (i >= n)
; 60 16th
NOP
; 64 17th
NOP
; 68 18th
NOP

; 72 19th
SUBI X20, X19, #1   ; j = i - 1
; 76 20th
NOP
; 80 21st
NOP
; 84 22nd
NOP
; 88 23rd for2tst
CMP X20, XZR        ; compare X20 to 0 (j to 0)
; 92 24th
B.LT #33            ; go to exit2 if X20 < 0 (j < 0)
; 96 25th
NOP
; 100 26th
NOP
; 104 27th
NOP
; 108 28th
LSL X10, X20, #3    ; reg X10 = j * 8
; 112 29th
NOP
; 116 30th
NOP
; 120 31st
NOP
; 124 32nd
ADD X11, X0, X10    ; reg X11 = v + (j * 8)
; 128 33rd
NOP
; 132 34th
NOP
; 136 35th
NOP
; 140 36th
LDUR X12, [X11, #0] ; reg X12 = v[j]
; 144 37th
LDUR X13, [X11, #8] ; reg X13 = v[j + 1]
; 148 38th
NOP
; 152 39th
NOP
; 156 40th
NOP
; 160 41st
CMP X12, X13        ; compare X12 to X13
; 164 42nd
B.LE #15            ; go to exit2 if X12 <= X13
; 168 43rd
NOP
; 172 44th
NOP
; 176 45th
NOP

; 180 46th
MOV X0, X21         ; first swap parameter is v
; 184 47th
MOV X1, X20         ; second swap parameter is j
; 188 48th
BL #24              ; branch to swap and link to X30
; 192 49th
NOP
; 196 50th
NOP
; 200 51st
NOP

; 204 52nd
SUBI X20, X20, #1   ; j -= 1
; 208 53rd
B #-30              ; branch to test of inner loop( for2tst )
; 212 54th
NOP
; 216 55th
NOP
; 220 56th
NOP

; 224 57th exit2
ADDI X19, X19, #1   ; i += 1
; 228 58th
B #-44              ; branch to test of outer loop( for1tst )
; 232 59th
NOP
; 236 60th
NOP
; 240 61st
NOP

; 244 62nd exit1
LDUR X19, [SP, #0]  ; restore X19 from stack
; 248 63rd
LDUR X20, [SP, #8]  ; restore X20 from stack
; 252 64th
LDUR X21, [SP, #16] ; restore X21 from stack
; 256 65th
LDUR X22, [SP, #24] ; restore X22 from stack
; 260 66th
LDUR X30, [SP, #32] ; restore X30 from stack
; 264 67th
ADDI SP, SP, #40    ; restore stack pointer

; 268 68th
BR LR               ; return to calling routine
; 272 69th
NOP
; 276 70th
NOP
; 280 71st
NOP

; 284 72nd swap
LSL X10, X1, #3     ; reg X10 = k * 8
; 288 73rd
NOP
; 292 74th
NOP
; 296 75th
NOP
; 300 76th
ADD X10, X0, X10    ; reg X10 = v + (k * 8)
                    ; reg X10 has the address of v[k]
; 304 77th
NOP
; 308 78th
NOP
; 312 79th
NOP
; 316 80th
LDUR X9, [X10, #0]  ; reg X9(tmp) = v[k]
; 320 81st
LDUR X11, [X10, #8] ; reg X11 = v[k + 1]
                    ; refers to next element of v
; 324 82nd
NOP
; 328 83rd
NOP

; 332 84th
STUR X9, [X10, #8]  ; v[k + 1] = reg X9(tmp)
; 336 85th
STUR X11, [X10, #0] ; v[k] = reg X11
; 340 86th
BR LR               ; return to calling routine
; 344 87th
NOP
; 348 88th
NOP
; 352 89th
NOP
