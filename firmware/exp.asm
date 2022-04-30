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
;	e(XREG)
EX:          
;-----------------------------------------------------------------------------
;	make fresh copy of LN
			LD hl,KLN
			LD de,LN10
			LD bc,90
			LDIR         
;-----------------------------------------------------------------------------
;	start Meggitt decomposition
            LD      hl,XREG 
            LD      iy,TMP 
            LD      b,09h 
            LD      ix,LN10 
MEGE1:               
            LD      c,0ffh 
            PUSH    ix 
            POP     de 
MEGE2:               
            INC     c 
            CALL    fsub 
            JR      nc,mege2 ; test carry flag from fsub call
            CALL    fadd 
            LD      (iy),c 
            INC     iy 
            LD      de,0ah 
            ADD     ix,de 
            DJNZ    mege1 

;-----------------------------------------------------------------------------
;	reminder +1
            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,ONE 
            CALL    fadd 
            LD      iy,TMP+8h 
;-----------------------------------------------------------------------------
;	*1.0000001
            LD      b,(iy) 
            LD      a,b 
            CP      0h 
            JR      z,EE002 
EE001:               
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            DJNZ    ee001 
EE002:               
            DEC     iy 
;-----------------------------------------------------------------------------
;	*1.000001
            LD      b,(iy) 
            LD      a,b 
            CP      0h 
            JR      z,EE02 
EE01:                
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            DJNZ    ee01 
EE02:                
            DEC     iy 
;-----------------------------------------------------------------------------
;	*1.00001
            LD      b,(iy) 
            LD      a,b 
            CP      0h 
            JR      z,EE2 
EE1:                 
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            DJNZ    ee1 
EE2:                 
            DEC     iy 
;-----------------------------------------------------------------------------
;	*1.0001
            LD      b,(iy) 
            LD      a,b 
            CP      0h 
            JR      z,EE4 
EE3:                 
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            DJNZ    ee3 
EE4:                 
            DEC     iy 
;-----------------------------------------------------------------------------
;	*1.001
            LD      b,(iy) 
            LD      a,b 
            CP      0h 
            JR      z,EE6 
EE5:                 
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            DJNZ    ee5 
EE6:                 
            DEC     iy 
;-----------------------------------------------------------------------------
;	*1.01
            LD      b,(iy) 
            LD      a,b 
            CP      0h 
            JR      z,EE8 
EE7:                 
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            DJNZ    ee7 
EE8:                 
            DEC     iy 
;-----------------------------------------------------------------------------
;	*1.1
            LD      b,(iy) 
            LD      a,b 
            CP      0h 
            JR      z,EE10 
EE9:                 
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            CALL    fadd 
            DJNZ    ee9 
EE10:                
            DEC     iy 
;-----------------------------------------------------------------------------
;	*2
            LD      b,(iy) 
            LD      a,b 
            CP      0h 
            JR      z,EE12 
EE11:                
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            CALL    fadd 
            DJNZ    ee11 
EE12:                
;end
;-----------------------------------------------------------------------------
;	exponent processing
            DEC     iy 
            LD      a,(iy) 
            LD      b,(hl) 
            ADD     a,b 
            LD      (hl),a 

            RET      
