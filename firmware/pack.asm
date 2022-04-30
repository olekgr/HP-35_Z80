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
			ld a,(XREG)
			ld (EXP),a ;save exponent
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

            LD      a,(KEYB_BUFFER) ;sign
            CP      0 
            JR      z,pack2 
            LD      hl,XREG 
            CALL    fneg 
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
            LD      c,a ;convert to hex
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
            LD      b,a ;save exponent
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
            LD      (hl),a ;write ezponent
PACK3:               
            LD      a,(MODEDOT) ;check dot mode
            CP      0 
            JR      z,pack7 
            LD      a,(DOTCOUNT) 
            CP      1 
            JR      z,pack8 ;skip
            LD      hl,XREG 
            DEC     a 
            LD      b,a 
PACK6:               
            INC     (hl) 
            DJNZ    pack6 
            JR      pack8 
PACK7:               
            LD      a,(DIGCOUNT) 
            CP      1 
            JR      z,pack8 ;skip;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            LD      hl,XREG 
            DEC     a 
            LD      b,a 
PACK9:               
            INC     (hl) 
            DJNZ    pack9 
PACK8:       
			ld a,(MODEEEX) ;check eex mode
			cp 0h
			jr z,pack10 ;end
			
			
            LD      hl,KEYB_BUFFER+14 
            LD      a,(hl) 
            SLA     a 
            SLA     a 
            SLA     a 
            SLA     a 
            INC     hl 
            OR      (hl) 
            CP      0 
            JR      z,pack10 ;jump if 00
            LD      c,a ;convert to hex
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
            LD      b,a ;save exponent
            LD      a,(KEYB_BUFFER+13) ;exponent sign
            CP      0 
            JR      z,pack11 
            LD      a,(EXP) 
            SUB     b 
            JR      pack12
PACK11:               
            LD      a,(EXP)
            ADD     a,b
PACK12:               
            LD      hl,XREG 
            LD      (hl),a ;write exponent
			
			xor a
			ld (MODEEEX),a
			ld (KEYB_BUFFER+13),a ;exponent sign
			ld (KEYB_BUFFER+14),a
			ld (KEYB_BUFFER+15),a

PACK10:        
            LD      hl,XREG 
            CALL    fnorm 
            POP     iy 
            POP     ix 
            POP     bc 
            POP     hl 
            POP     af 
            RET      

