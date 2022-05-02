# HP-35-Z80
assembler source files, please compile with <a href="http://48k.ca/zmac.html">zmac</a>.

`zmac main.asm -o main.hex`

**All math functions described bellow are completely unrelated to hardware, except they are written for Z80 :)**

# arith.asm

basic arithmetic functions:

* `FCOPY` - copy one number to another
* `FSL` - shift left  by 1 digit, decrement exponent
* `FSR` - shift right by 1 digit, increment exponent, preserve sign
* `FALGN` - align numbers, i.e. shift until exponents are equal using fsr
* `FNORM` - normalize until first digit is not 0, using fsl, or if overflow occured, using shr
* `FNEG` - negate number using U'10
* `MADD` - add fractional parts hl := hl + de
* `FADD` - add two bcd numbers hl := hl + de
* `MSUB` - substract fractional parts hl := hl - de
* `FSUB` - substract two bcd numbers hl := hl - de
* `FROUND` - round number to 12 digits

# mult.asm

multiply / divide functions:

* `MULT` - multiply hl = hl * de, long hand method, like in the HP35
* `DIV` - divide hl = hl / de, also long hand method

and two auxiliary functions, as mult/div works only with  positive numbers

* `CHK_SGN_IN` - check signs before mult/div
* `CHK_SGN_OUT` - check/sets signs after mult/div

# sqrt.asm

square root function:

* `SQRT` - square root of XREG, follows HP algorithm

and three auxiliary functions, as Z80 (and most likely no other one) does not provide direct access to single digit in packed BCD form

* `INCSD` - increase single digit in AREG at pointer --  similar to HP c+1->c[p]
* `SR` - shift right number by 1 digit in AREG (including sign) up to pointer -- shift right c[wp]
* `FSLL` - long shift left number 1 digit (including sign), decrement exponent -- shift left c[w]

# meggitt.asm

trigonometric tangent function:

* `TAN` - tangent of XREG, follows the HP algorithm, which is based on J.E. Meggitt works (IBM Journal april 1962) and J.E. Volder - The CORDIC Trigonometric Computing Technique (The Institute of Radio Engineers, Inc. 1959).

I've increased the numbers of stages, from five (like original HP) to seven for better accuracy.

# atan.asm

trigonometric inverse tangent function:

* `ATAN` - inverse tangent of XREG, follows HP algorithm, which is basicly vector cordic rotation

# trig.asm

rest of trigonometric functions:

* `SIN` - sine of XREG
* `COS` - cosine of XREG
* `ASIN` - inverse sine of XREG
* `ACOS` - inverse cosine of XREG

and auxiliary functions:

* `CONVERT_TO_RAD` - convert degrees to radians
* `CONVERT_TO_DEG` - convert radians to degrees
* `TRIG_SGN_IN` - set sign between 0 <-> 2pi
* `SCALE` - trig function input scaling down (large angles)

# exp.asm

e^x function:

* `EX` - e raised to power X, follows HP algorithm

# ln.asm

ln function:

* `LNX` - the natural logarithm X, follows HP algorithm

# fvar.asm and romtables.asm

variables and tables in RAM and ROM

 

**All operating functions described bellow are completely related to hardware**

# display.asm

* `DISPLAY` - display reg in scientific format hl - pointer to reg; DISPLAY` has two modes: "normal" display and "scientific" exactly like HP35

# pack.asm

* `PACK_KEYB_BUFFER` - pack keyboard buffer to XREG

# numbers.asm

* `NUMBER` - handle digits entry from keyboard 0..9

* `DOT` - key "." pressed

* `CHS` - key "CHS`" pressed

# stack.asm

working stack manipulation (X, Y, Z, T)

# main.asm

has only two function:

* `KEY_SCAN` - keyboard scanning and 7-seg display (not my concept, I've seen this idea elsewere in the internet, don't remember where)
* `KEY_EXECUTE` - megafunction, each key press goes there :)