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
;	stack operations
;-----------------------------------------------------------------------------
STACK_UP:            
            LD      hl,ZREG 
            LD      de,TREG 
            CALL    fcopy 

            LD      hl,YREG 
            LD      de,ZREG 
            CALL    fcopy 

            LD      hl,XREG 
            LD      de,YREG 
            CALL    fcopy 
            RET      
 
STACK_DOWN:          
            LD      hl,ZREG 
            LD      de,YREG 
            CALL    fcopy 

            LD      hl,TREG 
            LD      de,ZREG 
            CALL    fcopy 
            RET      

STACK_ROTATE:        
            LD      hl,XREG 
            LD      de,AREG 
            CALL    fcopy

            LD      hl,YREG 
            LD      de,XREG 
            CALL    fcopy 

            LD      hl,ZREG 
            LD      de,YREG 
            CALL    fcopy 

            LD      hl,TREG 
            LD      de,ZREG 
            CALL    fcopy 

            LD      hl,AREG 
            LD      de,TREG 
            CALL    fcopy 
            RET      
