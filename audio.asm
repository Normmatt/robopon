INCLUDE "includes.asm"

INCLUDE "audio/engine.asm"

SECTION "Audio Data 1", ROMX [$4c12], BANK [$1c]
Data_70c12: ; $70c12
	dw $c17b

Data_70c14: ; $70c14
	dw $c187

Data_70c16: ; $70c16
	dw $c193

Data_70c18: ; $70c18
	dw $c19f

Data_70c1a: ; $70c1a
	dr $70c1a, $70c22

Data_70c22: ; $70c22
	dr $70c22, $70ccc

Data_70ccc: ; $70ccc
	dr $70ccc, $70de4

Data_70de4: ; $70de4
	dr $70de4, $70fa4

Data_70fa4: ; $70fa4
	dr $70fa4, $7122e

Data_7122e: ; $7122e
	dr $7122e, $7129b

Data_7129b: ; $7129b
	dr $7129b, $7129c

Data_7129c: ; $7129c
	dr $7129c, $712b9

Data_712b9: ; $712b9
	dr $712b9, $74000

SECTION "Audio Data 2", ROMX [$6a37], BANK [$1d]
Data_76a37:
	db $6c

Data_76a38:
	dr $76a38, $76c72

Data_76c72:
	dr $76c72, $78000