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
;	variables
;	RAM
			;.org 8000h
KEY:        DB      00h 
DISP_BUFFER: DB     00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h 
KEYB_BUFFER: DB     00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h 
TMP:        DB      00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h 
ROTBUF:     DB      00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h 

MODEEEX:    DB      00h ; set eex mode
MODEARC:    DB      00h ; set arc mode
MODEDOT:    DB      00h ; set dot mode
MODECHS:    DB      00h ; set chs mode

DIGCOUNT:   DB      00h ; digit counter (from keyboard)
DOTCOUNT:   DB      00h ; dot counter (from keyboard)
EXP:        DB      00h ; save exponent
LASTKEY:    DB      00h ; last key for stack manipulating (similar hp35 s7 flag)
SGN:        DB      00h ; sign for mult, div function
SGN1:       DB      00h ; sign for sin, cos function

SEG7:       DB      3fh,6h,5bh,4fh,66h,6dh,7dh,7h,7fh,6fh ;convert single digit to 7 segment code

;-----------------------------------------------------------------------------
;	main regs
XREG:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
YREG:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
ZREG:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
TREG:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
SREG:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h			
AREG:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
BREG:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
ONE:                 
            DB      80h 
            DB      00h 
            DB      10h,00h,00h,00h,00h,00h,00h,00h 
ZERO:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
;-----------------------------------------------------------------------------
;	rotation regs
XX:                  
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
YY:                  
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
XACT:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
YACT:                
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
;-----------------------------------------------------------------------------
;	some constans and useful numbers :)
ATAN10: 
            DB      7fh,00h,78h,53h,98h,16h,33h,97h,44h,83h
			DB      7eh,00h,99h,66h,86h,52h,49h,11h,62h,03h
			DB      7dh,00h,99h,99h,66h,66h,86h,66h,52h,38h
			DB      7ch,00h,99h,99h,99h,66h,66h,66h,86h,67h
			DB      7bh,00h,99h,99h,99h,99h,66h,66h,66h,67h
			DB      7ah,00h,99h,99h,99h,99h,99h,66h,66h,67h
			DB      79h,00h,99h,99h,99h,99h,99h,99h,66h,67h
LN10:
            DB      80h,00h,23h,02h,58h,50h,92h,99h,40h,46h
LN2:
			DB      7fh,00h,69h,31h,47h,18h,05h,59h,94h,53h
			DB      7eh,00h,95h,31h,01h,79h,80h,43h,24h,86h
			DB      7dh,00h,99h,50h,33h,08h,53h,16h,80h,83h
			DB      7ch,00h,99h,95h,00h,33h,30h,83h,53h,32h
			DB      7bh,00h,99h,99h,50h,00h,33h,33h,08h,34h
			DB      7ah,00h,99h,99h,95h,00h,00h,33h,33h,31h
			DB      79h,00h,99h,99h,99h,50h,00h,00h,33h,33h
			DB      78h,00h,99h,99h,99h,95h,00h,00h,00h,33h
KONE:                
            DB      80h 
            DB      00h 
            DB      10h,00h,00h,00h,00h,00h,00h,00h 
KZERO:               
            DB      80h 
            DB      00h 
            DB      00h,00h,00h,00h,00h,00h,00h,00h 
KPI:
            DB      80h 
            DB      00h 
            DB      31h,41h,59h,26h,53h,58h,97h,93h 
KPI180:
            DB      7eh 
            DB      00h 
            DB      17h,45h,32h,92h,51h,99h,43h,30h 
K180PI:
			DB      81h 
            DB      00h 
            DB      57h,29h,57h,79h,51h,30h,82h,32h
KPI2:
			DB      80h 
            DB      00h 
            DB      15h,70h,79h,63h,26h,79h,48h,97h
K2PI:
			DB      80h 
            DB      00h 
            DB      62h,83h,18h,53h,07h,17h,95h,86h

