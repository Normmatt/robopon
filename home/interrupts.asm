INCLUDE "home/vblank.asm"
INCLUDE "home/timer.asm"
INCLUDE "home/serial.asm"
INCLUDE "home/hblank.asm"

HandleVideoTransferRequest:: ; 11ce (0:11ce)
	push bc
	push de
	xor a
	ld [wc236], a
	ld c, $4
	ld hl, wVideoTransferQueue
.asm_11d9
	ld a, [hl]
	ld b, a
	or a
	jr z, .asm_1200
	ld a, [wc236]
	add b
	cp $41
	jr nc, .asm_120b
	ld [wc236], a
	push bc
	xor a
	ld [hli], a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	push hl
	ld h, [hl]
	ld l, c
.asm_11f5
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .asm_11f5
	pop hl
	pop bc
	inc hl
	jr .asm_1208

.asm_1200
	ld a, l
	add $5
	ld l, a
	ld a, h
	adc $0
	ld h, a
.asm_1208
	dec c
	jr nz, .asm_11d9
.asm_120b
	pop de
	pop bc
	ret

VBlankReadJoypad:: ; 120e (0:120e)
	push bc
	call ReadJoypad
	ld a, [wJoyLast]
	xor c
	jr z, .asm_121c
	and c
	ld [wJoyHeld], a
.asm_121c
	ld a, c
	ld [wJoyLast], a
	pop bc
	ret

ReadJoypad:: ; 1222 (0:1222)
	ld c, $0
	ld a, $20
	ld [rJOYP], a
	ld a, [rJOYP]
	ld a, [rJOYP]
	and $f
	ld c, a
	ld a, $10
	ld [rJOYP], a
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
	and $f
	swap a
	or c
	cpl
	ld [wJoyPressed], a
	ld c, a
	ld a, $30
	ld [rJOYP], a
	ret
