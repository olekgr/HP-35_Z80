# HP-35-Z80
build hp-35 scientic calculator replica with Z80 cpu from scratch


## Number format
# Number format

* Number format *
** Number format **

For HP-35, I chose a BCD floating point format. It uses an exponent byte, a sign byte and eight mantissa bytes. 

The sign byte holds 0x00 for positive numbers and 0x09 for negative, this byte also can be 0x01 for positive overflow and 0x08 for negative overflow.

The exponent byte is the number’s signed power of ten, plus the offset 0x80. This greatly simplified addition and substraction algorithms. Range is limited to 10^-99 and 10^99.

The mantissa is represented as 16 BCD digits packed two per byte, with an implied decimal point after the first digit (normalized form).

Only the first 12 digits are always displayed to the user; the last 4 digits exists to maintain precision (guard digits). All internal calculations are done with 16 digits, next the displayed result is always rounded to 12 digits.

As an examples:

1 is stored as 80_00_10_00_00_00_00_00_00_00

0.1 is stored as 7f_00_10_00_00_00_00_00_00_00

123 is stored as 82_00_12_30_00_00_00_00_00_00

pi/4 is stored  as 7f_00_78_53_98_16_33_97_44_83
