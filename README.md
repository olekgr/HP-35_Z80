# HP-35-Z80
Build HP35 scientic calculator clone with Z80 cpu from scratch.

## Intro

This DIY page is about building a HP35 clone. But without using emulators, HP microcode etc. I have always wanted to write original algorithms, created by David S. Cochran and provided by William E. Egbert in 4 editions of 1977's HP Journal, please see <a href="https://github.com/olekgr/HP-35_Z80/tree/main/arch">arch</a>.

As the original HP35 was built 50 years ago, this is a good time to do the same.

All fuctions are written with BCD arithmetic, I haven't used BCD - to binary conversion.

## Number format

For this HP35 clone, I chose a BCD floating point format. It uses an exponent byte, a sign byte and eight bytes of fractional part  (80 bits total). 

The sign byte holds 0x00 for positive numbers and 0x09 for negative, this byte also can hold other values in case of positive or negative overflow.

The exponent byte is the number’s signed power of 10, plus the offset 0x80. Note that exponent is not in BCD form, but binary. This greatly simplifies addition and substraction algorithms. Range is limited to 10^-99 and 10^99.

The fractional part is represented as 16 BCD digits packed two per byte, with an implied decimal point after the first digit (normalized form).

Only the first 12 digits are always displayed to the user; the last 4 digits exists to maintain precision (guard digits). All internal calculations are done with 16 digits, next the displayed result is always rounded to 12 digits.

As an examples:

1 is stored as 80_00_10_00_00_00_00_00_00_00

0.1 is stored as 7f_00_10_00_00_00_00_00_00_00

123 is stored as 82_00_12_30_00_00_00_00_00_00

pi/4 is stored  as 7f_00_78_53_98_16_33_97_44_83

## Negative numbers

Negative numbers are always stored as their U'10 complement, with 0x09 at sign position. For example:

-1 is stored as 80_09_90_00_00_00_00_00_00_00

-12 is stored as 81_09_88_00_00_00_00_00_00_00

## Why Z80?

Z80 has few instruction useful for making BCD arithmetic:

* RLD - rotate left decimal (used for shifting BCD numbers to the left)

* RRD - rotate right decimal (used for shifting BCD numbers to the right)

* DAA - decimal accumulator adjust (addition and substraction of BCD numbers)

## Speed

Calculations are fast, very fast, we get the result immediately after pressing the key.

## Operating

I have made every effort to make this calculator work exactly like the original. Some functions were simple, others (most notably the CHS key which changes the sign of a number before or after it was entered) difficult. Either way, the calculator executes all the examples in the HP35 manual the same way. I have to say I use this calculator every day and it does a great job.