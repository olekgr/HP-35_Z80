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
;	SQRT(XREG)
SQRT:                
;-----------------------------------------------------------------------------
; save exponent	
            LD      a,(XREG) 
            LD      (EXP),a 
            LD      hl,XREG 
            LD      de,AREG 
            CALL    fcopy 
;-----------------------------------------------------------------------------
; multiply by 5
            CALL    fadd 
            CALL    fadd 
            CALL    fadd 
            CALL    fadd 
;-----------------------------------------------------------------------------
; place 5 at correct position in AREG			
            LD      hl,KZERO 
            LD      de,AREG 
            CALL    fcopy 
            LD      a,50h 
            LD      (AREG+2),a 
;-----------------------------------------------------------------------------
; odd, even check -- shift or not	
            LD      a,(XREG) 
            BIT     0,a 
            JR      nz,sqrt0 
            LD      hl,XREG 
            CALL    fsr 
SQRT0:               
;-----------------------------------------------------------------------------
; calling main routine
            CALL    sqrt1 
            LD      hl,AREG ;here is the result
            LD      de,Xreg 
            CALL    fcopy 
;-----------------------------------------------------------------------------
; exponent processing
            LD      hl,XREG 
            CALL    fnorm 
            LD      a,(EXP) 
            SUB     80h 
            JR      c,sqt2 
            SRL     a 
            ADD     a,80h 
            LD      hl,XREG 
            LD      (hl),a 
            JR      sqt1 
SQT2:                
            SRL     a ;this is the trick :)
            LD      hl,XREG 
            LD      (hl),a 
SQT1:                
            LD      hl,XREG 
            RET      
;-----------------------------------------------------------------------------
; and follow HP algorithm now:)
; Jacques Laporte (RIP) diagram
SQRT1:               
            LD      b,1 
            JR      sqt17 
SQT15:               
            CALL    incsd 
SQT16:               
            LD      hl,XREG 
            LD      de,AREG 
            CALL    msub 
            JR      nc,sqt15 
            LD      hl,XREG 
            LD      de,AREG 
            CALL    madd 
            LD      hl,XREG 
            CALL    fsll 
            INC     b 
SQT17:               
            CALL    sr 
            LD      a,b 
            CP      16 
            JR      nz,sqt16 
            RET      
;-----------------------------------------------------------------------------
; function INCSD
; increase single digit in AREG at pointer -- c+1->c[p]
; input b - pointer
;-----------------------------------------------------------------------------
INCSD:               
            PUSH    bc 
            LD      a,b 
            RRA      
            JR      c,sd1 
            DEC     a 
            LD      hl,AREG+2 
            LD      b,0 
            LD      c,a 
            ADD     hl,bc 

            LD      a,(hl) 
            ADD     a,1 
            DAA      
            LD      (hl),a 
            JR      sd2 
SD1:                 
            LD      hl,AREG+2 
            LD      b,0 
            LD      c,a 
            ADD     hl,bc 

            LD      a,(hl) 
            ADD     a,10 
            DAA      
            LD      (hl),a 
SD2:                 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function SR
; shift right number by 1 digit in AREG (including sign) up to pointer -- shift right c[wp]
; input b - pointer
;-----------------------------------------------------------------------------
SR:                  
            PUSH    bc 
            LD      hl,AREG+2 
            LD      a,b 
            RRA      
            JR      c,sr2 
            DEC     a 
            LD      d,a 
            LD      b,0 
            LD      c,a 
            ADD     hl,bc 

            XOR     a 
            RRD      
            LD      c,a 
            XOR     a 
            RLD      
            INC     hl 

            LD      b,d 
            LD      a,8 
            SUB     b 
            LD      b,a 
            DEC     b 
            CP      1 
            JR      z,sr4 
            LD      a,c 
SR1:                 
            RRD      
            INC     hl 
            DJNZ    sr1 
            JR      sr4 
SR2:                 
            LD      hl,AREG+2 
            LD      b,0 
            LD      c,a 
            ADD     hl,bc 
            LD      b,a 
            LD      a,8 
            SUB     b 
            LD      b,a 
            XOR     a 
SR3:                 
            RRD      
            INC     hl 
            DJNZ    sr3 
SR4:                 
            POP     bc 
            RET      
;-----------------------------------------------------------------------------
; function FSLL
; long shift left number 1 digit (including sign), decrement exponent
; input hl
; output hl
;-----------------------------------------------------------------------------
FSLL:                
            PUSH    bc 
            PUSH    hl 
            DEC     (hl) ; decrement exponent
            LD      bc,08h ; number length-2
            ADD     hl,bc 
            LD      b,c 
            INC     hl 
            XOR     a 
            INC     b 
FSLL1:               
            RLD      
            DEC     hl 
            DJNZ    fsll1 
            POP     hl 
            POP     bc 
            RET      
