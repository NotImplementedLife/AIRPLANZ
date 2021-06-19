SECTION "Copy string method", ROM0

copyString:: 
    ld a, [de]
    ld [hli],a
    inc de
    and a                 
    jr nz, copyString  
	ret

