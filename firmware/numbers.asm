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
;	digits functions
;	one of the most complicated functions :)
;	handle digits entry, dot pressed, chs(change sign mantissa and/or exponent) and also automatic stack_up if required
;-----------------------------------------------------------------------------
NUMBER:              
            PUSH    af ;save key
            LD      a,(MODEEEX) ;check eex mode
            CP      1h 
            JR      z,number1 

            LD      a,(DIGCOUNT) ;if = 0 then clear display
            CP      0 
            JR      nz,number0 
            CALL    clear_buffers 
            LD      a,(LASTKEY) 
            CP      0 
            JR      nz,number0 ;don't move stack when ENTER was pressed
; 
            LD      a,(MODECHS) 
            CP      0 
            JR      z,number02 
            LD      hl,XREG 
            CALL    fneg 
NUMBER02:            
            LD      hl,LASTKEY 
            LD      (hl),0 
            CALL    stack_up 
NUMBER0:             
            LD      a,(MODECHS) 
            CP      0 
            JR      z,number01 
            LD      a,64 ;negative
            LD      (DISP_BUFFER),a 
            LD      (KEYB_BUFFER),a 
NUMBER01:            
            LD      a,(DIGCOUNT) 
            LD      c,a 
            LD      b,0h 
            LD      ix,DISP_BUFFER+1 
            LD      iy,KEYB_BUFFER+1 
            ADD     ix,bc ;hl address is set
            ADD     iy,bc 
            POP     af ;load saved key
            LD      (iy),a ;write digit to KEYB_BUFFER
            CALL    7seg_convert 
            LD      (ix),a ;write digit to DISP_BUFFER
            LD      hl,DIGCOUNT ;inc digcount
            INC     (hl) 
            RET      
NUMBER1:             
            LD      a,(DISP_BUFFER+15) 
            LD      (DISP_BUFFER+14),a 
            LD      a,(KEYB_BUFFER+15) 
            LD      (KEYB_BUFFER+14),a 
; 
            POP     af ;load saved key
            LD      (KEYB_BUFFER+15),a ;write digit to KEYB_BUFFER
            CALL    7seg_convert 
            LD      (DISP_BUFFER+15),a ;write digit to DISP_BUFFER
; 
            LD      a,(KEYB_BUFFER+14) 
            CALL    7seg_convert 
            LD      (DISP_BUFFER+14),a ;display first "0"
; 
            RET      
;-----------------------------------------------------------------------------
;	dot`pressed
DOT:                 
            LD      a,(MODEDOT) ; check dot mode
            CP      1h 
            JP      z,dot1 ;return
            LD      a,(MODEEEX) ; check eex mode
            CP      1h 
            JR      z,dot1 ;return
            LD      a,1h 
            LD      (MODEDOT),a ; set dot mode
; 
            LD      a,(DIGCOUNT) ; first dot pressed
            CP      0 
            JR      nz,dot0 
            CALL    clear_buffers 
            LD      hl,DIGCOUNT 
            INC     (hl) 
            LD      a,(LASTKEY) 
            CP      0 
            JR      nz,dot0 ;dot also move stack!!
            CALL    stack_up 
            LD      hl,LASTKEY 
            LD      (hl),0 
DOT0:                
            LD      a,(DIGCOUNT) ; copy digcount to dotcount (save dot position)
            LD      hl,DOTCOUNT 
            LD      (hl),a 
            LD      c,a 
            LD      b,0 
            LD      hl,DISP_BUFFER 
            ADD     hl,bc 
            LD      a,(hl) 
            ADD     a,80h ;display dot
            LD      (hl),a 
DOT1:                
            RET      
;-----------------------------------------------------------------------------
;	chs pressed
CHS:                 
            LD      a,(DIGCOUNT) 
            CP      0 
            JR      z,chs6 
; 
            LD      a,(MODEEEX) ;check eex mode
            CP      1h 
            JR      z,chs3 

            LD      a,(DISP_BUFFER) 
            CP      0 
            JR      nz,chs1 
            LD      a,64 ;negative
            LD      (DISP_BUFFER),a 
            LD      (KEYB_BUFFER),a 
            JR      chs2 
CHS1:                
            LD      a,0 
            LD      (DISP_BUFFER),a 
            LD      (KEYB_BUFFER),a 
CHS2:                
            RET      
CHS3:                
            LD      a,(DISP_BUFFER+13) 
            CP      0 
            JR      nz,chs4 
            LD      a,64 ;negative
            LD      (DISP_BUFFER+13),a 
            LD      (KEYB_BUFFER+13),a 
            JR      chs5 
CHS4:                
            LD      a,0 
            LD      (DISP_BUFFER+13),a 
            LD      (KEYB_BUFFER+13),a 
CHS5:                
            RET      
CHS6:                
            LD      hl,XREG 
            CALL    fneg 

            LD      a,(DISP_BUFFER) 
            CP      0 
            JR      nz,chs7 
            LD      a,64 ;negative
            LD      (DISP_BUFFER),a 
            LD      (KEYB_BUFFER),a 
            JR      chs8 
CHS7:                
            LD      a,0 
            LD      (DISP_BUFFER),a 
            LD      (KEYB_BUFFER),a 
CHS8:                
            RET      
