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
;	arctan(XREG)
ATAN:
;-----------------------------------------------------------------------------
;	setup rotation		
            LD      hl,XREG ; reminder
            LD      de,YY 
            CALL    fcopy 
 
            LD      hl,KONE 
            LD      de,XX 
            CALL    fcopy 
;-----------------------------------------------------------------------------
;	start rotation			
            LD      ix,ROTBUF 
            LD      b,0h ; number of stages
AROT1:               
            LD      c,0ffh 

AROT2:               
            PUSH    bc 
            LD      bc,0ah ; save X
            LD      hl,XX 
            LD      de,Xact 
            LDIR     

            LD      bc,0ah ; save Y
            LD      hl,YY 
            LD      de,Yact 
            LDIR     
            POP     bc 

            LD      a,(Xact) ; shift X div by 10, 100 ... etc :)
            SUB     b 
            LD      (Xact),a 

            LD      a,(Yact) ; shift Y
            SUB     b 
            LD      (Yact),a 

            LD      hl,XX 
            LD      de,Yact 
            CALL    fadd 
            LD      hl,YY 
            LD      de,Xact 
            CALL    fsub 
            INC     c 
            JR      nc,arot2 
            LD      hl,XX 
            LD      de,Yact 
            CALL    fsub 
            LD      hl,YY 
            LD      de,Xact 
            CALL    fadd 
            LD      (ix),c 
            INC     ix 
            INC     b 

            LD      a,b 
            CP      7 
            JR      nz,arot1 

;-----------------------------------------------------------------------------
;	reminder division
            LD      hl,YY 
            LD      de,XX 
            CALL    div ; div use tmp buffer
			
            LD      hl,YY 
            LD      de,XREG 
            CALL    fcopy 
;-----------------------------------------------------------------------------
;	start adding			
            LD      hl,XREG 
            LD      iy,ROTBUF
            LD      ix,ATAN10 
            PUSH    ix 
            POP     de 
            LD      b,7h ;
AE3:                 
            LD      a,(iy) 
            LD      c,a 
            OR      a 
            JR      z,ae5 ; skip if 0
AE4:                 
            CALL    fadd 
            DEC     c 
            JR      nz,ae4 
AE5:                 
            INC     iy 
            LD      de,0ah 
            ADD     ix,de 
            PUSH    ix 
            POP     de 
            DEC     b 
            JR      nz,ae3 
			LD 		hl,XREG
			ret
	
