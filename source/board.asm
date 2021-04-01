nextBoard:
	ld a, [scrollFlag]
	cp a, SCROLL_FLAG_0
	ret nz
	ld a, [rSCX]
	cp a, 0
	jr z, .set112
.set0
	ld a, SCROLL_FLAG_0 + 112
	ld [scrollFlag], a
	ret
.set112
	ld a, SCROLL_FLAG_0 - 112
	ld [scrollFlag], a
	ret


	