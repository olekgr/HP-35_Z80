# HP-35-Z80
assembler source files, please compile with <a href="http://48k.ca/zmac.html">zmac</a>.

`zmac main.asm -o main.hex`

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

* `MULT` - multiply hl = hl * de, long hand method
* `DIV` - divide hl = hl / de, also long hand method
* `CHK_SGN_IN` - check signs before mult/div
* `CHK_SGN_OUT` - check/sets signs after mult/div, as mult/div works with only positive numbers

# sqrt.asm

square root function:

* `SQRT` - square root of XREG, follows HP algorithm

and three auxiliary functions, as Z80 (and most likely no other one) does not provide direct access to single digit in packed BCD form

* `INCSD` - increase single digit in AREG at pointer --  similar to HP c+1->c[p]
* `SR` - shift right number by 1 digit in AREG (including sign) up to pointer -- shift right c[wp]
* `FSLL` - long shift left number 1 digit (including sign), decrement exponent