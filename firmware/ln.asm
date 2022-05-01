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
; LN(XREG)
LNX:                 
;-----------------------------------------------------------------------------
;	make fresh copy of LN
            LD      hl,KLN 
            LD      de,LN10 
            LD      bc,90 
            LDIR     
;-----------------------------------------------------------------------------
;	exponent processing			
            LD      hl,XREG 
            LD      c,0h 
            LD      a,(hl) 
            SUB     80h 
            JR      nc,L01 
            LD      c,1h ; set negative exp flag
L01:                 
            LD      (EXP),a ; save exp
            LD      (hl),80h ; set exp 0
            PUSH    bc 

;-----------------------------------------------------------------------------
;	1-M/10
; 
            LD      iy,TMP 
            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 
            LD      hl,ONE 
            INC     (hl) 
            LD      de,XREG 
            CALL    fsub 
            DEC     (hl) 
            LD      de,XREG 
            CALL    fcopy 
            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 

;-----------------------------------------------------------------------------
;	start decomposition *2 ; loops are unrolled
            LD      c,0ffh 
LN01:                
            INC     c 
            LD      hl,XREG 
            LD      de,XX 
            CALL    fcopy 
            CALL    fadd ; *2
            LD      de,ONE 
            CALL    fsub 
            JR      nc,ln01 ; test carry flag from fsub call
            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 
            LD      (iy),c 
            INC     iy 
;-----------------------------------------------------------------------------
;	*1.1
            LD      c,0ffh 
            LD      hl,XREG 
            INC     (hl) ; *10
LN02:                
            INC     c 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            CALL    fadd ; *1.1
            LD      de,ONE 
            CALL    fsub 
            JR      nc,ln02 
            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 
            LD      (iy),c 
            INC     iy 
;-----------------------------------------------------------------------------
;	*1.01
            LD      c,0ffh 
            LD      hl,XREG 
            INC     (hl) ; *10
LN03:                
            INC     c 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            LD      de,ONE 
            CALL    fsub 
            JR      nc,ln03 
            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 
            LD      (iy),c 
            INC     iy 
;-----------------------------------------------------------------------------
;	*1.001
            LD      c,0ffh 
            LD      hl,XREG 
            INC     (hl) ; *10
LN04:                
            INC     c 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            LD      de,ONE 
            CALL    fsub 
            JR      nc,ln04 
            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 
            LD      (iy),c 
            INC     iy 
;-----------------------------------------------------------------------------
;	*1.0001
            LD      c,0ffh 
            LD      hl,XREG 
            INC     (hl) ; *10
LN05:                
            INC     c 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            LD      de,ONE 
            CALL    fsub 
            JR      nc,ln05 
            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 
            LD      (iy),c 
            INC     iy 
;-----------------------------------------------------------------------------
;	*1.00001
            LD      c,0ffh 
            LD      hl,XREG 
            INC     (hl) ; *10
LN06:                
            INC     c 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            LD      de,ONE 
            CALL    fsub 
            JR      nc,ln06 
            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 
            LD      (iy),c 
            INC     iy 
;-----------------------------------------------------------------------------
;	*1.000001
            LD      c,0ffh 
            LD      hl,XREG 
            INC     (hl) ; *10
LN07:                
            INC     c 
            LD      de,XX 
            CALL    fcopy 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            CALL    fadd 
            LD      de,ONE 
            CALL    fsub 
            JR      nc,ln07 
            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 
            LD      (iy),c 
            INC     iy 
;-----------------------------------------------------------------------------
;	*1.0000001
            LD      c,0ffh 
            LD      hl,XREG 
            INC     (hl) ; *10
LN08:                
            INC     c 
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
            LD      de,ONE 
            CALL    fsub 
            JR      nc,ln08 
            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 
            LD      (iy),c 
            INC     iy 

;-----------------------------------------------------------------------------
;	part 2, start adding; XREG - reminder

            LD      hl,XREG 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
            DEC     (hl) 
; 
            LD      iy,TMP 
            LD      ix,LN2 
            PUSH    ix 
            POP     de 
            LD      b,8h 
E3:                  
            LD      a,(iy) 
            LD      c,a 
            OR      a 
            JR      z,e5 ; skip if 0
E4:                  
            CALL    fadd 
            DEC     c 
            JR      nz,e4 
E5:                  
            INC     iy 
            LD      de,0ah 
            ADD     ix,de 
            PUSH    ix 
            POP     de 
            DEC     b 
            JR      nz,e3 

;-----------------------------------------------------------------------------
;	LN10 substract	

            LD      hl,LN10 ; save ln10
            LD      de,XX 
            CALL    fcopy 

            LD      hl,LN10 
            LD      de,XREG 
            CALL    fsub 

            LD      hl,ln10 
            LD      de,XREG 
            CALL    fcopy 

            LD      hl,XX ; load ln10
            LD      de,LN10 
            CALL    fcopy 

;-----------------------------------------------------------------------------
;	final scaling

            POP     bc 
            LD      a,c 
            CP      0 
            JR      nz,L02 ; jump if negative
            LD      a,(EXP) ; eg. 5
            CP      0h 
            JR      z,L03 
            LD      b,a 
            LD      hl,XREG ; positive
            LD      de,LN10 
L04:                 
            CALL    fadd 
            DJNZ    L04 
            JR      L03 
L02:                 
            LD      a,(EXP) 
            ADD     a,80h 
            LD      b,a 
            LD      a,80h 
            SUB     b 
            LD      b,a 
            LD      hl,XREG ; negative
            LD      de,LN10 
L05:                 
            CALL    fsub 
            DJNZ    L05 
L03:                 
            RET      
