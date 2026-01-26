# Adress map for the BE6502

| Name       | Pins             | Hex             |NOTES             |
|------------|------------------|-----------------|------------------|
| RAM        | 0 0 X X X X X X  | 0x0000 - 0x3FFF |                  |
| ACIA*      | 0 1 0 1 X X X X  | 0x5000 - 0x5003 | bit 3 ignored    |
| VIA        | 0 1 1 0 X X X X  | 0x6000 - 0x600F |                  |
| INVALID*   | 0 1 1 1 X X X X  | 0x7000 - 0x7FFF | DO NOT ADDRESS   |
| ROM        | 1 X X X X X X X  | 0x8000 - 0xFFFF |                  |


**\* = only applicable to serial connection variant**