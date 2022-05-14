# HP-35-Z80
EAGLE PCB source files

## Hardware
The hardware is made as simple as possible. It consists of a Z80 CPU, 8k RAM, 8k ROM, input and output buffers and a simple address decoder. The main program takes about 6k, so it fits easily in 8k EEPROM. I chose 8k RAM (6264) only and because of availability, not need, I think 1-2k would be enough for stack and variables.

## BOM
* IC1 - Z80 - main CPU
* IC2 - AT28C64 - ROM
* IC3 - 6264 - RAM
* IC4 - 74HCT32 - control signals
* IC5 - 74HCT154 - display multiplexer
* IC6 - 74HCT138 - address decoder (only 3 periph used)
* IC7 - 74HCT541 - keyboard input
* IC8, IC9 - 74HCT573 - digit and position for 7-seg display
* OSC - 8MHz DIL14 - main clock

All SMT components in 1206 case (except C11)
* C1 - 10u 
* R1..R9 - 10k 
* C2..C10 100n
* R10..R17 - 220R (HP used inductors here for power saving :)
* DIS1..4 - common cathode 4x7 segment (eg. SH5461AS)
* X1,X2 - USB MINI sockets
* keys 1..35 Cherry MX switches

## Errors

None found, till now :)