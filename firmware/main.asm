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

			.ORG    8000H
            LD      sp,memory_top 
            DI      
            JP      main


MEMORY_TOP  EQU     0fc00h 
;MEMORY_TOP  EQU     0a000h 


include arith.asm
include romtables.asm
include mult.asm
include display.asm
include pack.asm
include sqrt.asm
include ln.asm
include exp.asm
include atan.asm
include meggitt.asm
include numbers.asm
include stack.asm
include trig.asm
include utils.asm

;-----------------------------------------------------------------------------
;	main program starts here :)
MAIN:                
			;LD hl,ROM
			;LD de,KEY
			;LD bc,01bdh
			;LDIR
			;STO :)
			LD hl,KZERO
			CALL display
MAIN1:
            CALL key_scan
			call key_exec
            JP   main1

;-----------------------------------------------------------------------------
;	keyboard scanning high level
KEY_SCAN:            
            CALL    scan 
            LD      a,(KEY) 
            CP      0ffh 
            JR      nz,key_scan
            ;CALL    deb

KEY_SCAN1:           
            CALL    scan 
            LD      a,(KEY) 
            CP      0ffh 
            JR      z,key_scan1 
            ;CALL    deb 
            RET      
;-----------------------------------------------------------------------------
;	keyboard debounce
DEB:            
            LD      b,0 
DEB1:           
            DEC     b 
            JR      nz,deb1 
            RET      

;-----------------------------------------------------------------------------
;	keyboard scanning and display multiplexing low level
SCAN:                
            LD      c,16 
            LD      e,0
            LD      d,0 
            LD      a,0ffh 
            LD      (KEY),a 
            LD      hl,DISP_BUFFER 
SCAN1:               
            LD      a,e 
            OUT     (1),a 
            LD      a,(hl) 
            OUT     (0),a 
            LD      b,80 ;ON 
WAIT1:               
            DEC     b 
            JR      nz,wait1 
            XOR     a 
            OUT     (0),a ;OFF

            IN      a,(3) 
			IN      a,(3) 
			IN      a,(3) ;monitor errorr :)
            LD      b,8
SHIFT_KEY:           
            RRA      
            JR      c,next_key 
            PUSH    af 
            LD      a,d 
            LD      (KEY),a 
            POP     af 
NEXT_KEY:            
            INC     d 
            DEC     b 
            JR      nz,shift_key 
			inc 	e
            INC     hl 
            DEC     c 
            JR      nz,scan1 
            RET      

;-----------------------------------------------------------------------------
;	key execution
KEY_EXEC:            
            CP      0 ;pi
            JR      nz,code1 
            CALL    stack_up 
            LD      hl,KPI 
            LD      de,XREG 
            CALL    fcopy ;copy PI to XREG
            LD      hl,XREG 
            CALL    fround 
            CALL    display ;write XREG to DISP_BUFFER
            CALL    clear_flags 
            RET      
CODE1:               
            CP      8 ;dot
            JR      nz,code2 
            CALL    dot 
            RET      
CODE2:               
            CP      16 ;0
            JR      nz,code3 
            LD      a,0 
            CALL    number 
            RET      
CODE3:               
            CP      24 ;/
            JR      nz,code4 
            CALL    pack_keyb_buffer 
            LD      hl,XREG+2 
            LD      b,08h 
            XOR     a 
CODE3_1:             
            OR      (hl) 
            INC     hl 
            DJNZ    code3_1 
            JR      z,code3_2 ;zero check :)
            LD      hl,YREG 
            LD      de,XREG 
            CALL    div 
            LD      hl,YREG 
            LD      de,XREG 
            CALL    fcopy 
            CALL    stack_down 
            LD      hl,XREG 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE3_2:             
            CALL    error 
            RET      

CODE4:               
            CP      1 ;3
            JR      nz,code5 
            LD      a,3 
            CALL    number 
            RET      
CODE5:               
            CP      9 ;2
            JR      nz,code6 
            LD      a,2 
            CALL    number 
            RET      
CODE6:               
            CP      17 ;1
            JR      nz,code7 
            LD      a,1 
            CALL    number 
            RET      
CODE7:               
            CP      25 ;*
            JR      nz,code8 
            CALL    pack_keyb_buffer 
            LD      hl,XREG 
            LD      de,YREG 
            CALL    mult 
            CALL    stack_down 
            LD      hl,XREG 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE8:               
            CP      2 ;6
            JR      nz,code9 
            LD      a,6 
            CALL    number 
            RET      
CODE9:               
            CP      10 ;5
            JR      nz,code10 
            LD      a,5 
            CALL    number 
            RET      
CODE10:              
            CP      18 ;4
            JR      nz,code11 
            LD      a,4 
            CALL    number 
            RET      
CODE11:              
            CP      26 ;+
            JR      nz,code12 
            CALL    pack_keyb_buffer 
            LD      hl,XREG 
            LD      de,YREG 
            CALL    fadd 
            CALL    stack_down 
            LD      hl,XREG 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE12:              
            CP      3 ;9
            JR      nz,code13 
            LD      a,9 
            CALL    number 
            RET      
CODE13:              
            CP      11 ;8
            JR      nz,code14 
            LD      a,8 
            CALL    number 
            RET      
CODE14:              
            CP      19 ;7
            JR      nz,code15 
            LD      a,7 
            CALL    number 
            RET      
CODE15:              
            CP      27 ;-
            JR      nz,code16 
            CALL    pack_keyb_buffer 
            LD      hl,YREG 
            LD      de,XREG 
            CALL    fsub 
            LD      hl,YREG 
            LD      de,XREG 
            CALL    fcopy 
            CALL    stack_down 
            LD      hl,XREG 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE16:              
            CP      4 ;clx
            JR      nz,code17 
            LD      hl,KZERO 
            LD      de,XREG 
            CALL    fcopy 
            LD      hl,XREG 
            CALL    display 
            CALL    clear_flags 
            LD      hl,LASTKEY 
            LD      (hl),1 
            RET      
CODE17:              
            CP      12 ;eex
            JR      nz,code18 
            LD      a,1h 
            LD      (MODEEEX),a
            RET      
CODE18:              
            CP      20 ;chs
            JR      nz,code19 
            LD      a,(MODECHS) 
            CP      0 
            JR      z,code18_1 
            LD      a,0 
            JR      code18_2 
CODE18_1:            
            LD      a,1 
CODE18_2:            
            LD      (MODECHS),a 
            CALL    chs 
            RET      
CODE19:              
            CP      28 ;enter
            JR      nz,code20 
            CALL    pack_keyb_buffer 
            CALL    stack_up 
            LD      hl,XREG 
            CALL    display 
            CALL    clear_flags 
            LD      hl,LASTKEY 
            LD      (hl),1 
            RET      
CODE20:              
            CP      5 ; rcl
            JR      nz,code21 
            CALL    pack_keyb_buffer 
            CALL    stack_up 
            LD      hl,SREG 
            LD      de,XREG 
            CALL    fcopy 
            LD      hl,XREG 
            CALL    display 
            CALL    clear_flags 
            LD      hl,LASTKEY 
            LD      (hl),1 
            RET      
CODE21:              
            CP      13 ;sto
            JR      nz,code22 
;call pack_keyb_buffer
;ld hl,XREG
;ld de,SREG
;call fcopy
;ld hl,XREG
;call display
;call clear_flags
;ld hl,LASTKEY
;ld (hl),1
            PUSH    bc 
            PUSH    af 
            LD      a,(DISP_BUFFER+1) 
            LD      (DISP_BUFFER),a 
            LD      a,(DISP_BUFFER+2) 
            LD      (DISP_BUFFER+1),a 
            LD      a,(DISP_BUFFER+3) 
            LD      (DISP_BUFFER+2),a 
            LD      a,(DISP_BUFFER+4) 
            LD      (DISP_BUFFER+3),a 
            LD      a,(DISP_BUFFER+5) 
            LD      (DISP_BUFFER+4),a 
            LD      a,(DISP_BUFFER+6) 
            LD      (DISP_BUFFER+5),a 
            LD      a,(DISP_BUFFER+7) 
            LD      (DISP_BUFFER+6),a 
            LD      a,(DISP_BUFFER+8) 
            LD      (DISP_BUFFER+7),a 
            LD      a,(DISP_BUFFER+9) 
            LD      (DISP_BUFFER+8),a 
            LD      a,(DISP_BUFFER+10) 
            LD      (DISP_BUFFER+9),a 
            LD      a,(DISP_BUFFER+11) 
            LD      (DISP_BUFFER+10),a 
            LD      a,(DISP_BUFFER+12) 
            LD      (DISP_BUFFER+11),a 
            LD      a,(DISP_BUFFER+13) 
            LD      (DISP_BUFFER+12),a 
            LD      a,(DISP_BUFFER+14) 
            LD      (DISP_BUFFER+13),a 
            LD      a,(DISP_BUFFER+15) 
            LD      (DISP_BUFFER+14),a 
            POP     af 
            POP     bc 
            RET      
CODE22:              
            CP      21 ;R down
            JR      nz,code23 
            CALL    pack_keyb_buffer 
            CALL    stack_rotate 
            LD      hl,XREG 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE23:              
            CP      29 ;x-y
            JR      nz,code24 
            CALL    pack_keyb_buffer 
            LD      hl,XREG 
            LD      de,AREG 
            CALL    fcopy ;store XREG

            LD      hl,YREG 
            LD      de,XREG 
            CALL    fcopy 

            LD      hl,AREG 
            LD      de,YREG 
            CALL    fcopy 

            LD      hl,XREG 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE24:              
            CP      37 ;1/x
            JR      nz,code25 
            CALL    pack_keyb_buffer 
            LD      hl,XREG+2 
            LD      b,08h 
            XOR     a 
CODE24_1:            
            OR      (hl) 
            INC     hl 
            DJNZ    code24_1 
            JR      z,code24_2 ;zero check :)
            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 
            LD      hl,ONE 
            LD      de,XREG 
            CALL    div 
            LD      hl,ONE 
            LD      de,XREG 
            CALL    fcopy 
            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 
            LD      hl,XREG 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE24_2:            
            CALL    error 
            RET      
; 
CODE25:              
            CP      6 ;tan
            JR      nz,code26 
            CALL    pack_keyb_buffer 
            LD      a,(MODEARC) 
            CP      1 
            JR      z,code25_1 
            CALL    convert_to_rad 
			CALL	scale
            CALL    tan 
            CALL    tan_div 
            JR      code25_2 
CODE25_1:            
            CALL    atan 
            CALL    convert_to_deg 
CODE25_2:            
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE26:              
            CP      14 ;cos
            JR      nz,code27 
            CALL    pack_keyb_buffer 
            LD      a,(MODEARC) 
            CP      1 
            JR      z,code26_1 
            CALL    convert_to_rad 
            CALL    scale 
            CALL    trig_sgn_in 
            CALL    cos 
            JR      code26_2 
CODE26_1:    
            LD      a,(XREG)
            SUB     80h 
            JR      nc,code26_3         
            CALL    acos 
            CALL    convert_to_deg 
CODE26_2:            
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET   
CODE26_3:            
            CALL    error 
            RET			
CODE27:              
            CP      22 ;sin
            JR      nz,code28 
            CALL    pack_keyb_buffer 
            LD      a,(MODEARC) 
            CP      1 
            JR      z,code27_1 
            CALL    convert_to_rad 
            CALL    scale 
            CALL    trig_sgn_in 
            CALL    sin 
            JR      code27_2 
CODE27_1:   
            LD      a,(XREG)
            SUB     80h 
            JR      nc,code27_3         
            CALL    asin 
            CALL    convert_to_deg 
CODE27_2:            
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET 
CODE27_3:            
            CALL    error 
            RET			
CODE28:              
            CP      30 ;arc
            JR      nz,code29 
            LD      a,1h 
            LD      (MODEARC),a ; set arc mode
            RET      
CODE29:              
            CP      38 ;sqrt
            JR      nz,code30 
            CALL    pack_keyb_buffer 
            LD      a,(XREG+1) 
            CP      9 
            JR      z,code29_1 
            CALL    sqrt 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE29_1:            
            CALL    error 
            RET      
CODE30:              
            CP      7 ;clr
            JR      nz,code31 
            LD      hl,KZERO 
            LD      de,XREG 
            CALL    fcopy 

            LD      hl,KZERO 
            LD      de,YREG 
            CALL    fcopy 

            LD      hl,KZERO 
            LD      de,ZREG 
            CALL    fcopy 

            LD      hl,KZERO 
            LD      de,TREG 
            CALL    fcopy 
; 
            LD      hl,KZERO 
            LD      de,SREG 
            CALL    fcopy 

            LD      hl,XREG 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE31:              
            CP      15 ;ex
            JR      nz,code32 
            CALL    pack_keyb_buffer 
            CALL    ex 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      

CODE32:              
            CP      23 ;ln
            JR      nz,code33 
            CALL    pack_keyb_buffer 
            LD      a,(XREG+1) 
            CP      9 
            JR      z,code32_1 
            LD      hl,XREG+2 
            LD      b,08h 
            XOR     a 
CODE32_2:            
            OR      (hl) 
            INC     hl 
            DJNZ    code32_2 
            JR      z,code32_1 ;zero check
            CALL    lnx 
            LD      hl,XREG 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE32_1:            
            CALL    error 
            RET      

CODE33:              
            CP      31 ;log
            JR      nz,code34 
            CALL    pack_keyb_buffer 
            LD      a,(XREG+1) 
            CP      9 
            JR      z,code33_1 
            LD      hl,XREG+2 
            LD      b,08h 
            XOR     a 
CODE33_2:            
            OR      (hl) 
            INC     hl 
            DJNZ    code33_2 
            JR      z,code33_1 ;zero check
            LD      hl,LN10 
            LD      de,AREG 
            CALL    fcopy 
            CALL    lnx 
            LD      hl,XREG 
            LD      de,AREG 
            CALL    div 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE33_1:            
            CALL    error 
            RET      
CODE34:              
            CALL    pack_keyb_buffer ; xy last call, no key checking needed
            LD      hl,YREG+2 
            LD      b,08h 
            XOR     a 
CODE34_2:            
            OR      (hl) 
            INC     hl 
            DJNZ    code34_2
            JR      z,code34_3
            LD      a,(XREG+1) 
            CP      9 
            JR      z,code34_1
			ld a,(YREG+1)
			cp 9
			jr z,code34_4
            CALL    lnx 
            LD      hl,XREG 
            LD      de,YREG 
            CALL    mult 
            CALL    stack_down 
            CALL    ex 
            LD      hl,XREG 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      
CODE34_1:            
            CALL    error 
            RET      
CODE34_3: ;x^0
			ld hl,KONE
			ld de,XREG
			call fcopy
			call display
			call clear_flags
			ret
CODE34_4: ;x^-y
			ld hl,YREG
			call fneg
			CALL    lnx 
            LD      hl,XREG 
            LD      de,YREG 
            CALL    mult 
            CALL    stack_down 
            CALL    ex 
			LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 
            LD      hl,ONE 
            LD      de,XREG 
            CALL    div 
            LD      hl,ONE 
            LD      de,XREG 
            CALL    fcopy 
            LD      hl,KONE 
            LD      de,ONE 
            CALL    fcopy 
            LD      hl,XREG 
            CALL    fround 
            CALL    display 
            CALL    clear_flags 
            RET      



CODE35:              
            LD      a,0ffh ;none
            RET      


include fvar.asm