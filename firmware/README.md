# HP-35-Z80
assembler source files

# arith.asm

basic arithmetic functions:

* `FCOPY` - copy one number to another
* `FSL` - shift left  by 1 digit, decrement exponent
* `FSR` - shift right by 1 digit, increment exponent, preserve sign
* `FALGN` - align numbers, i.e. shift until exponents are equal using fsr
* `FNORM` - normalize until first digit is not 0, using fsl, or if overflow occurs using shr