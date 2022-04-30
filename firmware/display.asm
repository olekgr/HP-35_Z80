;-----------------------------------------------------------------------------
;	display reg in scientific format hl - pointer
;-----------------------------------------------------------------------------
DISPLAY:             
            LD      de,AREG 
            CALL    fcopy 
 
            LD      d,h ; save hl in de
            LD      e,l 
 ;-----------------------------------------------------------------------------
;	first negate
            INC     hl ;sign position
            LD      a,(hl) 
            CP      9h 
            JR      z,donegate 
            JR      notnegate 
DONEGATE:            
            DEC     hl ; return to first position
            CALL    fneg 
            INC     hl 
            LD      a,09h 
            LD      (hl),a ; write minus
NOTNEGATE:           
            DEC     hl 
;-----------------------------------------------------------------------------
;	jump to display "normal"
            LD      a,(hl) 
            CP      08bh 
            JR      nc,display1 
            CP      07eh 
            JR      c,display1 
            CALL    display_norm 
            JP      disp_end 
DISPLAY1:            
;-----------------------------------------------------------------------------
;	unpack mantissa
            CALL    unpack 
;-----------------------------------------------------------------------------
;	convert buffer to 7 segment code	
            LD      hl,DISP_BUFFER+1 
            LD      b,0ch ;12 digits
7S:                  
            LD      a,(hl) 
            CALL    7seg_convert 
            LD      (hl),a 
            INC     hl 
            DJNZ    7s 
;-----------------------------------------------------------------------------
;	put sign
            CALL    putsign 
;-----------------------------------------------------------------------------
;	put first digit	with dot		
            LD      a,(DISP_BUFFER+1) ; first digit
            ADD     a,80h ;put dot
            LD      (DISP_BUFFER+1),a 
; 
;-----------------------------------------------------------------------------
; 	blanking zeros now
            CALL    blank_zeros 
;-----------------------------------------------------------------------------
;	put exponent
            LD      h,d ; load hl
            LD      l,e 

            LD      a,(hl) ; load exponent to A
            CP      80h 
            JR      c,dsp1 

            SBC     a,80h 
            LD      hl,DISP_BUFFER+13 
            LD      (hl),0 
            JR      dsp2 
DSP1:                
            LD      b,a 
            LD      a,80h 
            SUB     b 
            LD      hl,DISP_BUFFER+13 
            LD      (hl),64 ;"-" code
DSP2:                
            LD      c,a 
            LD      b,8 
            XOR     a 
DSP3:                
            SLA     c 
            ADC     a,a 
            DAA      
            DJNZ    dsp3 

            LD      b,a 
            AND     0fh 
            LD      hl,DISP_BUFFER+15 
            CALL    7seg_convert 
            LD      (hl),a 

            LD      a,b 
            RRA      
            RRA      
            RRA      
            RRA      
            AND     0fh 
            LD      hl,DISP_BUFFER+14 
            CALL    7seg_convert 
            LD      (hl),a 

;-----------------------------------------------------------------------------
;	return	
DISP_END:            
            LD      hl,AREG 
            LD      de,XREG 
            CALL    fcopy ;restore XREG
            EX      de,hl ;change address on exit
            RET      

;-----------------------------------------------------------------------------
;	convert to 7 segment code
;	input A, output A
7SEG_CONVERT:        
            PUSH    hl 
            PUSH    bc 
            LD      hl,seg7 
            LD      c,a 
            LD      b,0 
            ADD     hl,bc 
            LD      a,(hl) 
            POP     bc 
            POP     hl 
            RET      

;-----------------------------------------------------------------------------
;	display in "normal" mode
DISPLAY_NORM:        
;-----------------------------------------------------------------------------
;	shift hl eg 0.02
            LD      a,(hl) 
            CP      7fh 
            JR      z,nunpack1 
            JR      nunpack2 
NUNPACK1:            
            CALL    fsr ;0.2
            INC     hl 
            INC     hl 
            LD      a,(hl) 
            AND     0fh 
            LD      (hl),a 
            DEC     hl 
            DEC     hl 
            JR      nunpack4 
NUNPACK2:            
            LD      a,(hl) 
            CP      7eh 
            JR      z,nunpack3 
            JR      nunpack4 
NUNPACK3:            
            CALL    fsr ;0.02 :)
            CALL    fsr 
            INC     hl 
            INC     hl 
            XOR     a 
            LD      (hl),a 
            DEC     hl 
            DEC     hl 
NUNPACK4:            

;-----------------------------------------------------------------------------
;	unpack mantissa		
            CALL    unpack 
;-----------------------------------------------------------------------------
;	convert buffer to 7 segment code	
            LD      hl,DISP_BUFFER+1 
            LD      b,0ch ;12 digits
N7S:                 
            LD      a,(hl) 
            CALL    7seg_convert 
            LD      (hl),a 
            INC     hl 
            DJNZ    n7s 
;-----------------------------------------------------------------------------
;	put sign
            CALL    putsign 
;-----------------------------------------------------------------------------
;	put dot
            LD      h,d ; load hl
            LD      l,e 
            LD      a,(hl) 
            CP      81h 
            JR      nc,nskip1 
            LD      a,(DISP_BUFFER+1) 
            ADD     a,80h ;put dot
            LD      (DISP_BUFFER+1),a 
            JR      nskip2 
NSKIP1:              
            LD      a,(hl) 
            SUB     80h 
            LD      hl,DISP_BUFFER+1 
            LD      c,a 
            LD      b,0 
            ADD     hl,bc 
            LD      a,(hl) 
            ADD     a,80h ;put dot
            LD      (hl),a 
NSKIP2:              
;-----------------------------------------------------------------------------
; 	blanking zeros now
            CALL    blank_zeros 
			LD      hl,DISP_BUFFER+13 
            LD      (hl),0
			LD      hl,DISP_BUFFER+14 
            LD      (hl),0
			LD      hl,DISP_BUFFER+15 
            LD      (hl),0
;-----------------------------------------------------------------------------
;	return	
            RET      
 


BLANK_ZEROS:         
            LD      a,(DISP_BUFFER+12) ;last digit
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+12),a 
            LD      a,(DISP_BUFFER+11) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+11),a 
            LD      a,(DISP_BUFFER+10) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+10),a 
            LD      a,(DISP_BUFFER+9) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+9),a 
            LD      a,(DISP_BUFFER+8) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+8),a 
            LD      a,(DISP_BUFFER+7) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+7),a 
            LD      a,(DISP_BUFFER+6) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+6),a 
            LD      a,(DISP_BUFFER+5) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+5),a 
            LD      a,(DISP_BUFFER+4) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+4),a 
            LD      a,(DISP_BUFFER+3) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+3),a 
            LD      a,(DISP_BUFFER+2) 
            CP      3fh 
            JR      nz,skip 
            XOR     a 
            LD      (DISP_BUFFER+2),a 
SKIP:                
            RET      
; 

;-----------------------------------------------------------------------------
;	unpack reg mantissa to buffer
UNPACK:              
            LD      iy,DISP_BUFFER+1 ;place for sign
            INC     hl 
            INC     hl 
            LD      b,06h ;12 digits
            XOR     a 
UNPACK1:             
            LD      a,(hl) 
            RR      a 
            SRA     a 
            SRA     a 
            SRA     a 
            LD      (iy),a 
            INC     iy 
            LD      a,(hl) 
            AND     0fh 
            LD      (iy),a 
            INC     iy 
            INC     hl 
            DJNZ    unpack1 
            RET      
; 
;-----------------------------------------------------------------------------
;	put sign
PUTSIGN:             
            LD      h,d ; load hl
            LD      l,e 
            INC     hl ; sign position
            LD      a,(hl) 
            CP      9h 
            JR      z,putminus 
            LD      hl,DISP_BUFFER 
            LD      a,0 ;none "+" code
            LD      (hl),a 
            JR      putend 
PUTMINUS:            
            LD      hl,DISP_BUFFER 
            LD      a,64 ;"-" code
            LD      (hl),a 
PUTEND:              
            RET      
