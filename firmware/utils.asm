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
;	clear keyboard and display buffers
CLEAR_BUFFERS:       
            PUSH    af 
            PUSH    hl 
            PUSH    bc 
            LD      b,16 
            LD      hl,DISP_BUFFER 
            XOR     a 
CLEAR_BUFFER1:       
            LD      (hl),a 
            INC     hl 
            DJNZ    clear_buffer1 
 
            LD      b,16 
            LD      hl,KEYB_BUFFER 
            XOR     a 
CLEAR_BUFFER2:       
            LD      (hl),a 
            INC     hl 
            DJNZ    clear_buffer2 
            POP     bc 
            POP     hl 
            POP     af 
            RET      
;-----------------------------------------------------------------------------
;	clear flags
CLEAR_FLAGS:         
            PUSH    af 
            XOR     a 
            LD      hl,DIGCOUNT 
            LD      (hl),a 
            LD      hl,DOTCOUNT 
            LD      (hl),a 
            LD      hl,MODEEEX 
            LD      (hl),a 
            LD      hl,MODEARC 
            LD      (hl),a 
            LD      hl,MODEDOT 
            LD      (hl),a 
            LD      hl,LASTKEY 
            LD      (hl),a 
            LD      hl,MODECHS 
            LD      (hl),a 
            POP     af 
            RET      
;-----------------------------------------------------------------------------
;	display error
ERROR:               
            CALL    clear_buffers 
            LD      a,79h ;E
            LD      (DISP_BUFFER+1),a 
            LD      a,50h ;r
            LD      (DISP_BUFFER+2),a 
            LD      a,50h ;r
            LD      (DISP_BUFFER+3),a 
            CALL    clear_flags 
            RET      


