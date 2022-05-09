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
; Pack keyboard buffer into XREG
PACK_KEYB_BUFFER:    
            PUSH    af 
            PUSH    hl 
            PUSH    bc 
            PUSH    ix 
            PUSH    iy 

            LD      a,(DIGCOUNT) 
            CP      0 
            JP      z,pack8 ;there is nothing in mantissa to pack
            LD      hl,XREG 
            LD      (hl),80h ;default exponent
            INC     hl 
            LD      (hl),00h ;default sign
            LD      b,6h ;12 digits
            LD      hl,KEYB_BUFFER+1 
            LD      de,XREG+2 
PACK1:               
            LD      a,(hl) 
            SLA     a 
            SLA     a 
            SLA     a 
            SLA     a 
            INC     hl 
            OR      (hl) 
            LD      (de),a 
            INC     hl 
            INC     de 
            DJNZ    pack1 
            XOR     a ;clear the rest of XREG
            LD      (de),a 
            INC     de 
            LD      (de),a 
;-----------------------------------------------------------------------------
; set sign
            LD      a,(KEYB_BUFFER) 
            CP      0 
            JR      z,pack2 
            LD      hl,XREG 
            CALL    fneg 
;-----------------------------------------------------------------------------
; pack exponent
PACK2:               
            LD      hl,KEYB_BUFFER+14 
            LD      a,(hl) 
            SLA     a 
            SLA     a 
            SLA     a 
            SLA     a 
            INC     hl 
            OR      (hl) 
            CP      0 
            JR      z,pack3 ;jump if 00
;-----------------------------------------------------------------------------
; convert to hex
            LD      c,a 
            AND     0f0h 
            SRL     a 
            LD      b,a 
            SRL     a 
            SRL     a 
            ADD     a,b 
            LD      b,a 
            LD      a,c 
            AND     0fh 
            ADD     a,b ;end conversion
;-----------------------------------------------------------------------------
; save exponent
            LD      b,a 
            LD      a,(KEYB_BUFFER+13) ;exponent sign
            CP      0 
            JR      z,pack4 
            LD      a,80h 
            SUB     b 
            JR      pack5 
PACK4:               
            LD      a,b 
            ADD     a,80h 
PACK5:               
            LD      hl,XREG 
            LD      (hl),a ;write exponent
PACK3:               
;-----------------------------------------------------------------------------
; check dot mode - set correct exponent
            LD      a,(MODEDOT) 
            CP      0 
            JR      z,pack7 
            LD      a,(DOTCOUNT) 
            CP      1 
            JR      z,pack11 ;skip
            LD      hl,XREG 
            DEC     a 
            LD      b,a 
PACK6:               
            INC     (hl) 
            DJNZ    pack6 
            JR      pack11 
PACK7:               
;-----------------------------------------------------------------------------
;   set correct exponent
            LD      a,(DIGCOUNT) 
            CP      1 
            JR      z,pack11 
            LD      hl,XREG 
            DEC     a 
            LD      b,a 
PACK9:               
            INC     (hl) 
            DJNZ    pack9 
            JR      pack10 ;end

;-----------------------------------------------------------------------------
; use XREG now; DIGCOUNT = 0
PACK8:               
            LD      a,(MODEEEX) 
            CP      0 
            JR      z,pack11 ;no exponent entry, skip the rest

;-----------------------------------------------------------------------------
; pack exponent			
            LD      hl,KEYB_BUFFER+14 ;pack exponent
            LD      a,(hl) 
            SLA     a 
            SLA     a 
            SLA     a 
            SLA     a 
            INC     hl 
            OR      (hl) 
            CP      0 
            JR      z,pack10 ;skip if 00
;-----------------------------------------------------------------------------
; convert to hex
            LD      c,a 
            AND     0f0h 
            SRL     a 
            LD      b,a 
            SRL     a 
            SRL     a 
            ADD     a,b 
            LD      b,a 
            LD      a,c 
            AND     0fh 
            ADD     a,b ;end conversion
;-----------------------------------------------------------------------------
; set sign
            LD      b,a ;save exponent
            LD      a,(KEYB_BUFFER+13) ;exponent sign
            CP      0 
            JR      z,pack14 
            LD      a,(XREG) 
            SUB     b 
            JR      pack15 
PACK14:              
            LD      a,(XREG) 
            ADD     a,b 
PACK15:              
            LD      hl,XREG 
            LD      (hl),a ;write exponent
;-----------------------------------------------------------------------------
; end :)

PACK10:              
            XOR     a 
            LD      (MODEEEX),a 
            LD      (KEYB_BUFFER+13),a ;exponent sign
            LD      (KEYB_BUFFER+14),a 
            LD      (KEYB_BUFFER+15),a 
PACK11:              
            LD      hl,XREG 
            CALL    fnorm 
            POP     iy 
            POP     ix 
            POP     bc 
            POP     hl 
            POP     af 
            RET      


