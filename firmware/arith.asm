;Copyright (c) 2022 Aleksander Grodzki
; 
;Permission is hereby granted, free of charge, to any person obtaining a copy
;of this software and associated documentation files (the "Software"), to deal
;in the Software without restriction, including without limitation the rights
;to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;copies of the Software, and to permit persons to whom the Software is
;furnished to do so, subject to the following conditions:
; 
;The above copyright notice and this permission notice shall be included in all
;copies or substantial portions of the Software.
; 
;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;SOFTWARE.

;-----------------------------------------------------------------------------
;	basic arithmetic functions
; 

;-----------------------------------------------------------------------------
; function FCOPY
; copy reg
; input hl - source
; input de - destination
;-----------------------------------------------------------------------------
FCOPY:               
            PUSH    bc 
            PUSH    hl 
            PUSH    de 
            LD      bc,0ah 
            LDIR     
            POP     de 
            POP     hl 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function FSL
; shift left number by 1 digit, decrement exponent
; input hl
; output hl
;-----------------------------------------------------------------------------
FSL:                 
            PUSH    bc 
            PUSH    hl 
            DEC     (hl) ; decrement exponent
            LD      bc,08h ; number length-2
            ADD     hl,bc 
            LD      b,c 
            INC     hl 
            XOR     a 
FSL1:                
            RLD      
            DEC     hl 
            DJNZ    fsl1 
            POP     hl 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function FSR
; shift right by 1 digit, increment exponent, save sign
; input hl
; output hl
;-----------------------------------------------------------------------------
FSR:                 
            PUSH    bc 
            INC     (hl) ;exp+1
            INC     hl 
            LD      b,(hl) ;save sign
            PUSH    hl 
            XOR     a 
            RRD      
            INC     hl 
            RRD      
            INC     hl 
            RRD      
            INC     hl 
            RRD      
            INC     hl 
            RRD      
            INC     hl 
            RRD      
            INC     hl 
            RRD      
            INC     hl 
            RRD      
            INC     hl 
            RRD      
            POP     hl 
            LD      (hl),b ;restore sign
            DEC     hl 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function FALGN
; shift mantissas until exponents are equal using fsr
; input hl, de
; output hl, de
;-----------------------------------------------------------------------------
FALGN:               
            PUSH    bc 
            PUSH    de 
ALGN0:               
            LD      a,(de) 
            LD      b,a 
            LD      a,(hl) 
            CP      b ; compare exponents
            JR      z,algn2 
            JR      c,algn1 
            EX      de,hl 
            CALL    fsr ; shift de
            EX      de,hl 
            JR      algn0 
ALGN1:               
            CALL    fsr ; shift hl
            JR      algn0 
ALGN2:               
            POP     de 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function FNORM
; normalize until first digit is not 0, using fsl
; or if overflow using fsr
; input hl
; output hl
;-----------------------------------------------------------------------------
FNORM:               
            PUSH    bc 
            PUSH    de 
            LD      d,h ; save address
            LD      e,l 

            INC     hl 
            LD      a,(hl) 
            CP      8h ;negative overflow
            JR      z,norm4 

            CP      1h ;positive overflow
            JR      z,norm5 

            CP      9h ; test negative
            JR      z,norm3 ; jump if negative
            INC     hl 
            LD      b,08h 
            XOR     a 
NORM0:               
            OR      (hl) 
            INC     hl 
            DJNZ    norm0 
            JR      nz,norm2 
            LD      a,80h ; offset
            LD      h,d ; restore address
            LD      l,e 
            LD      (hl),a 
            INC     hl 
            XOR     a 
            LD      (hl),a 
            DEC     hl 
            POP     de 
            POP     bc 
            RET      
NORM1:               
            LD      h,d ; restore address
            LD      l,e 
            CALL    fsl 
NORM2:               
            LD      h,d ; restore address
            LD      l,e 
            INC     hl 
            INC     hl 
            LD      a,(hl) 
            AND     0f0h 
            JR      z,norm1 
            LD      h,d ; restore address
            LD      l,e 
            POP     de 
            POP     bc 
            RET      
NORM3:               
            INC     hl 
            LD      b,08h 
            XOR     a 
NORM30:              
            OR      (hl) 
            INC     hl 
            DJNZ    norm30 
            JR      nz,norm31 
            LD      h,d ; restore address
            LD      l,e 
            INC     (hl) ;"-1"
            INC     hl 
            LD      (hl),09h 
            INC     hl 
            LD      (hl),90h 
NORM31:              
            LD      h,d ; restore address
            LD      l,e 
            CALL    fneg 
            CALL    fnorm 
            CALL    fneg 
            LD      h,d ; restore address
            LD      l,e 
            POP     de 
            POP     bc 
            RET      
NORM4:               ;negative overflow
            DEC     hl 
            CALL    fsr 
            INC     hl 
            LD      (hl),09h 
            DEC     hl 
            POP     de 
            POP     bc 
            RET      
NORM5:               ;positive overflow
            DEC     hl 
            CALL    fsr 
            INC     hl 
            LD      (hl),00h 
            DEC     hl 
            POP     de 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function FNEG
; negate number using U'10
; input hl
; output hl
;-----------------------------------------------------------------------------
FNEG:                
            PUSH    hl 
            PUSH    bc 
            PUSH    de 
            LD      b,08h 
            LD      d,h ; save hl
            LD      e,l 
            INC     hl 
            INC     hl 
            XOR     a 
FNEG0:               
            OR      (hl) ; check if number is zero
            INC     hl 
            DJNZ    fneg0 
            JR      nz,fneg3 
            LD      h,d 
            LD      l,e 
            INC     hl 
            LD      (hl),a ; write zero to sign - set positive
            POP     de 
            POP     bc 
            POP     hl 
            RET      
FNEG3:               
            LD      h,d 
            LD      l,e 
            INC     hl 
            LD      a,(hl) ;load sign
            XOR     0x09 ; invert the sign bit
            LD      (hl),a ; save sign
            XOR     a ; bc of carry
            LD      b,08h ; 
FNEG1:               
            INC     hl ; start substracting 99
            LD      a,99h 
            SBC     a,(hl) 
            DAA      
            LD      (hl),a 
            DJNZ    fneg1 

            LD      b,08h 
            XOR     a 

            LD      a,01h ; start adding 1
            ADD     a,(hl) 
            DAA      
            LD      (hl),a 
            DEC     hl 
FNEG2:               
            LD      a,0h ; transport carry; start ading 0h with carry
            ADC     a,(hl) 
            DAA      
            LD      (hl),a 
            DEC     hl 
            DJNZ    fneg2 
            POP     de 
            POP     bc 
            POP     hl 
            RET      
;-----------------------------------------------------------------------------
; function MADD
; add fractional parts hl := hl + de
; input hl, de
; output hl
;-----------------------------------------------------------------------------
MADD:                
            PUSH    bc 
            LD      bc,09h ; number length-1 (we are adding with sign)
            ADD     hl,bc 
            EX      de,hl 
            ADD     hl,bc 
            EX      de,hl ; ok set address
            LD      b,c 
            XOR     a 
MADD0:               
            LD      a,(de) 
            ADC     a,(hl) 
            DAA      
            LD      (hl),a 
            DEC     hl 
            DEC     de 
            DJNZ    madd0 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function FADD
; add two bcd numbers hl := hl + de
; input hl, de
; output hl
;-----------------------------------------------------------------------------
FADD:                
            CALL    falgn 
            CALL    madd 
            INC     hl 
            LD      a,(hl) 
            AND     0fh 
            LD      (hl),a 
            DEC     hl 
            CALL    fnorm 
            RET      
;-----------------------------------------------------------------------------
; function MSUB
; substract fractional parts hl := hl - de
; input hl, de
; output hl
;-----------------------------------------------------------------------------
MSUB:                
            PUSH    bc 
            LD      bc,09h ; number length-1 (we are adding with sign)
            ADD     hl,bc 
            EX      de,hl 
            ADD     hl,bc 
            EX      de,hl ; ok set address
            LD      b,c 
            XOR     a 
MSUB0:               
            EX      de,hl 
            LD      a,(de) 
            SBC     a,(hl) 
            DAA      
            EX      de,hl 
            LD      (hl),a 
            DEC     hl 
            DEC     de 
            DJNZ    msub0 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function FSUB
; substract two bcd numbers hl := hl - de
; input hl, de
; output hl
;-----------------------------------------------------------------------------
FSUB:                
            CALL    falgn 
            CALL    msub 
            PUSH    af ;save carry
            INC     hl 
            LD      a,(hl) 
            AND     0fh 
            LD      (hl),a 
            DEC     hl 
            CALL    fnorm 
            POP     af 
            RET      
;-----------------------------------------------------------------------------
; function fround
; round number to 12 digits
; input XREG
;-----------------------------------------------------------------------------
FROUND:     LD      hl,XREG 
            PUSH    bc 
            PUSH    de 
            LD      d,h ;save address
            LD      e,l 
            INC     hl 
            LD      a,(hl) 
            CP      9h ;test negative
            JR      z,fround3 ;jump if negative
            DEC     hl 

            LD      bc,08h 
            ADD     hl,bc 
            LD      b,07h ;adding to sign position

            LD      a,50h ;start adding 5 at "13" digit
            ADD     a,(hl) 
            DAA      
            LD      (hl),a 
            DEC     hl 
FROUND2:             
            LD      a,0h ;propagate carry
            ADC     a,(hl) 
            DAA      
            LD      (hl),a 
            DEC     hl 
            DJNZ    fround2 

            LD      bc,09h 
            ADD     hl,bc 
            LD      (hl),0h ;write 0 at 15-16 pos.
            DEC     hl 
            LD      (hl),0h ;write 0 at 13-14 pos.

            LD      h,d ;restore address
            LD      l,e 
            INC     hl ; check positive overflow
            LD      a,(hl) 
            OR      a 
            JR      z,fround4 
            DEC     hl 
            CALL    fsr 
            INC     hl 
            LD      (hl),00h ;write sign +
            DEC     hl 
FROUND4:             
            LD      h,d ;restore address
            LD      l,e 
            POP     de 
            POP     bc 
            RET      
FROUND3:             
            DEC     hl 
            CALL    fneg 
            CALL    fround 
            CALL    fneg 
            LD      h,d ;restore address
            LD      l,e 
            POP     de 
            POP     bc 
            RET      
; 
