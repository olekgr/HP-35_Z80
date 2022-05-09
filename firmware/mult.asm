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
; function mult
; multiply hl = hl * de
; input hl, de
; output hl
;-----------------------------------------------------------------------------
MULT:                
            CALL    chk_sgn_in 

            EX      de,hl 
            CALL    fsr 
            EX      de,hl 

            PUSH    hl 
            PUSH    hl 
            PUSH    hl 

            LD      a,(de) ; adjust exponent
            SUB     90h 
            ADD     a,(hl) 
            LD      (hl),a 

            LD      iy,TMP ; start unpacking hl
            INC     hl 
            INC     hl 
            LD      b,08h 
            XOR     a 
MULT1:               
            LD      a,(hl) 
            RR      a 
            SRA     a 
            SRA     a 
            SRA     a 
            LD      (iy),a 
            INC     iy 
            LD      a,(hl) 
            AND     0fh 
            LD      (iy),a 
            INC     iy 
            INC     hl 
            DJNZ    mult1 

            POP     hl ; zero hl
            INC     hl 
            INC     hl 
            XOR     a 
            LD      b,08h 
MULT2:               
            LD      (hl),a 
            INC     hl 
            DJNZ    mult2 

            LD      b,10h ; start adding and shifting
            LD      iy,TMP+0fh 
            POP     hl 
MULT3:               
            CALL    fsr 
            LD      a,(iy) 
            LD      c,a 
            OR      a 
            JR      z,mult5 
MULT4:               
            CALL    madd 
            DEC     c 
            JR      nz,mult4 
MULT5:               
            DEC     iy 
            DEC     b 
            JR      nz,mult3 

            POP     hl 
            CALL    fnorm 
            EX      de,hl 
            CALL    fsl 
            EX      de,hl 
            CALL    chk_sgn_out 
			;CALL	clear_tmp
            RET      
;-----------------------------------------------------------------------------
; function div
; division hl = hl / de
; input hl, de
; output hl
;-----------------------------------------------------------------------------
DIV:                 
            CALL    chk_sgn_in 
            PUSH    bc 
            EX      de,hl 
            CALL    fsr 
            EX      de,hl 
            CALL    fsr 
            PUSH    hl 

            LD      a,(de) ; exponent
            LD      b,a 
            LD      a,(hl) 
            SUB     b 
            ADD     a,90h 
            LD      (hl),a 

            LD      iy,TMP 
            LD      b,10h 
DIV1:                
            LD      c,0ffh 
DIV2:                
            INC     c 
            CALL    msub 
            JR      nc,div2 
            CALL    madd 
            LD      (iy),c 
            INC     iy 
            CALL    fsl 
            DJNZ    div1 

            LD      b,08h 
            LD      ix,TMP 
            INC     hl 
            INC     hl 
            PUSH    hl ; only mantissa
            POP     iy 
            XOR     a 
DIV3:                
            LD      a,(ix) 
            RL      a 
            SLA     a 
            SLA     a 
            SLA     a 
            INC     ix 
            OR      (ix) 
            LD      (iy),a 
            INC     ix 
            INC     iy 
            DJNZ    div3 

            POP     hl 
            CALL    fnorm 
            EX      de,hl 
            CALL    fsl 
            EX      de,hl 
            POP     bc 
            CALL    chk_sgn_out 
			CALL	clear_tmp
            RET      
;-----------------------------------------------------------------------------
; function chk_sgn_in
; check signs before mult/div
; input hl, de
; output hl
;-----------------------------------------------------------------------------
CHK_SGN_IN:          
            PUSH    hl 
            PUSH    de 
            XOR     a 
            LD      (SGN),a 
            INC     hl 
            LD      a,(hl) ;sign position
            CP      0 
            JR      z,chk_sgn_in1 
            DEC     hl 
            CALL    fneg 
            LD      hl,SGN 
            INC     (hl) 
CHK_SGN_IN1:         
            INC     de 
            LD      a,(de) 
            CP      0 
            JR      z,chk_sgn_in2 
            DEC     de 
            EX      de,hl 
            CALL    fneg 
            LD      hl,SGN 
            INC     (hl) 
CHK_SGN_IN2:         
            POP     de 
            POP     hl 
            RET      
;-----------------------------------------------------------------------------
; function chk_sgn_out
; check/sets signs after mult/div, mult/div works with only positive numbers
; input hl, de
; output hl
;-----------------------------------------------------------------------------
CHK_SGN_OUT:         
            LD      a,(SGN) 
            CP      0 
            JR      z,chk_sgn_out1 
            CP      2 
            JR      z,chk_sgn_out1 
            CALL    fneg 
CHK_SGN_OUT1:        
            RET      

;-----------------------------------------------------------------------------
;	clear
CLEAR_TMP:
            PUSH    af 
            PUSH    hl 
            PUSH    bc 
            LD      b,16 
            LD      hl,tmp 
            XOR     a 
CLEAR_TMP1:           
            LD      (hl),a 
            INC     hl 
            DJNZ    clear_tmp1 
 
            POP     bc 
            POP     hl 
            POP     af 
			RET