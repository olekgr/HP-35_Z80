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
;	tan(XREG)
TAN:                 
;-----------------------------------------------------------------------------
;	make fresh copy of ATAN
            LD      hl,KATAN10 
            LD      de,ATAN10 
            LD      bc,70 
            LDIR     
;-----------------------------------------------------------------------------
;	start Meggitt decomposition
            LD      hl,XREG 
            LD      iy,TMP 
            LD      b,07h 
            LD      ix,ATAN10 
MEG1:                
            LD      c,0ffh 
            PUSH    ix 
            POP     de 
MEG2:                
            INC     c 
            CALL    fsub 
            JR      nc,meg2 ; test carry flag from fsub call
            CALL    fadd 

            LD      (iy),c 
            INC     iy 
            LD      de,0ah 
            ADD     ix,de 
            DJNZ    meg1 
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
            LD      ix,TMP 
            LD      b,07h ; number of stages
            LD      c,0h 
ROT1:                
            PUSH    bc 
            LD      a,(ix) 
            CP      0h 
            JR      z,rot3 ; skip if 0
            LD      b,a ; start inner loop
ROT2:                
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

            LD      a,(Xact) ; shift X
            SUB     c 
            LD      (Xact),a 

            LD      a,(Yact) ; shift Y
            SUB     c 
            LD      (Yact),a 

            LD      hl,XX 
            LD      de,Yact 
            CALL    fsub 
            LD      hl,YY 
            LD      de,Xact 
            CALL    fadd 

            DJNZ    ROT2 
ROT3:                
            POP     bc 
            INC     c ; shift variable
            INC     ix 
            DEC     b ; main loop
            JR      nz,rot1 
            RET      
;-----------------------------------------------------------------------------
;	final division
TAN_DIV:             
            LD      hl,YY 
            LD      de,XX 
            CALL    div 

            LD      hl,YY 
            LD      de,XREG 
            CALL    fcopy 

            LD      hl,XREG 
            RET      
;-----------------------------------------------------------------------------
;	final division
CTG_DIV:             
            LD      hl,XX 
            LD      de,YY 
            CALL    div 

            LD      hl,XX 
            LD      de,XREG 
            CALL    fcopy 

            LD      hl,XREG 
            RET      

