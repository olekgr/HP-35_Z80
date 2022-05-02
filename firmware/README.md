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

* `MULT` - multiply hl = hl * de, "long hand" method
* `DIV` - divide hl = hl / de, also "long hand" method