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
;	trig functions

;-----------------------------------------------------------------------------
;	sin(XREG)
;	macro program
SIN:                 
            CALL    tan 
            CALL    tan_div 
            LD      hl,XREG 
            LD      de,BREG ;store tan
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,BREG 
            CALL    mult 

            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,ONE 
            CALL    fadd 

            LD      hl,XREG 
            CALL    sqrt 

            LD      hl,BREG 
            LD      de,XREG 
            CALL    div 

            LD      hl,BREG 
            LD      de,XREG 
            CALL    fcopy 
;-----------------------------------------------------------------------------
;	sign set				
            LD      a,(SGN1) 
            CP      0 
            JR      nz,chk1 
            NOP      
            JR      chk_end 
CHK1:                
            CP      1 
            JR      nz,chk2 
            NOP      
            JR      chk_end 
CHK2:                
            CP      2 
            JR      nz,chk3 
            LD      hl,XREG 
            CALL    fneg 
            JR      chk_end 
CHK3:                
            LD      hl,XREG 
            CALL    fneg 
CHK_END:             
            LD      hl,XREG 
            RET      
;-----------------------------------------------------------------------------
;	cos(XREG)
;	macro program
COS:                 
            CALL    tan 
            CALL    ctg_div 
            LD      hl,XREG 
            LD      de,BREG ;store ctg
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,BREG 
            CALL    mult 

            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,ONE 
            CALL    fadd 

            LD      hl,XREG 
            CALL    sqrt 

            LD      hl,BREG 
            LD      de,XREG 
            CALL    div 

            LD      hl,BREG 
            LD      de,XREG 
            CALL    fcopy 
;-----------------------------------------------------------------------------
;	sign set	
            LD      a,(SGN1) 
            CP      0 
            JR      nz,cchk1 
            NOP      
            JR      cchk_end 
CCHK1:               
            CP      1 
            JR      nz,cchk2 
            LD      hl,XREG 
            CALL    fneg 
            JR      cchk_end 
CCHK2:               
            CP      2 
            JR      nz,cchk3 
            LD      hl,XREG 
            CALL    fneg 
            JR      cchk_end 
CCHK3:               
            NOP      
CCHK_END:            
            LD      hl,XREG 
            RET      
;-----------------------------------------------------------------------------
;	arc sin(XREG)
;	macro program
ASIN:                
            LD      hl,XREG 
            LD      de,AREG 
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,BREG 
            CALL    fcopy 

            LD      hl,AREG 
            LD      de,XREG 
            CALL    mult 

            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 

            LD      hl,ONE 
            LD      de,AREG 
            CALL    fsub 

            LD      hl,ONE 
            LD      de,XREG 
            CALL    fcopy 
            CALL    sqrt 

            LD      hl,BREG 
            LD      de,XREG 
            CALL    div 

            LD      hl,BREG 
            LD      de,XREG 
            CALL    fcopy 

            CALL    atan 
            RET      
;-----------------------------------------------------------------------------
;	arc cos(XREG)
;	macro program		
ACOS:                
            CALL    asin 
            LD      hl,KPI2 
            LD      de,AREG 
            CALL    fcopy 

            LD      hl,AREG 
            LD      de,XREG 
            CALL    fsub 
            LD      hl,AREG 
            LD      de,XREG 
            CALL    fcopy 
            RET      
;-----------------------------------------------------------------------------
;	convert degrees to radians
CONVERT_TO_RAD:      
            LD      hl,KPI180 
            LD      de,AREG 
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,AREG 
            CALL    mult 
            RET      
;-----------------------------------------------------------------------------
;	convert radians to degrees
CONVERT_TO_DEG:      
            LD      hl,K180PI 
            LD      de,AREG 
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,AREG 
            CALL    mult 
            RET      
;-----------------------------------------------------------------------------
;	set sign between 0 <-> 2pi
TRIG_SGN_IN:         
            LD      hl,XREG 
            LD      de,AREG 
            CALL    fcopy 

            LD      hl,KPI2 
            LD      de,BREG 
            CALL    fcopy 

            LD      hl,AREG 
            LD      de,BREG 
            LD      c,0ffh 
TRIG1:               
            INC     c 
            CALL    fsub 
            JR      nc,trig1 
            CALL    fadd 
            LD      a,c 
            LD      (SGN1),a 
            RET      
;-----------------------------------------------------------------------------
;	trig function input scaling down
SCALE:               
            LD      hl,K2PI 
            LD      de,BREG 
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,BREG 

            LD      a,(XREG+1) ;sign check
            CP      9 
            JR      z,scale2 
SCALE1:              
            CALL    fsub 
            JR      nc,scale1 
            CALL    fadd 
            JR      scale3 
SCALE2:              
            CALL    fadd 
            LD      a,(XREG+1) 
            OR      a 
            JR      nz,scale2 
SCALE3:              
            RET      

