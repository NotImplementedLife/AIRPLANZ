SECTION "OAM Data", WRAM0[$C300] 

; here goes the OAM data [writeable | Y,X,_,_]
planesOamData:
	DS 160
	
SECTION "Planes Template 0", ROM0, ALIGN[8]
planesTemplate0:        ; CellType |  Pixel coordinates relative to top-left (X,Y)
Board0FacingUp:               ;-----------------------------------------------------------
DB $28, $48, $E0, $00,  ;    H     |	(2,0)
DB $30, $38, $E1, $00,  ;    W0    |	(0,1)
DB $30, $40, $E2, $00,  ;    W1    |	(1,1)
DB $30, $48, $E3, $00,  ;    B0    |	(2,1)
DB $30, $50, $E2, $00,  ;    W1    |	(3,1)
DB $30, $58, $E1, $20,  ;    W0    |	(4,1)
DB $38, $48, $E4, $00,  ;    B1    |	(2,2)
DB $40, $40, $E5, $00,  ;    T0    |	(1,3)
DB $40, $48, $E6, $00,  ;    B2    |	(2,3)
DB $40, $50, $E5, $20,  ;    T0    |	(3,3)
Board0FacingRight:            ;-----------------------------------------------------------
DB $38, $50, $E7, $20,  ;    H     |	(3,2)
DB $28, $48, $E8, $60,  ;    W0    |	(2,0)
DB $30, $48, $E9, $20,  ;    W1    |	(2,1)
DB $38, $48, $EA, $20,  ;    B0    |	(2,2)
DB $40, $48, $E9, $20,  ;    W1    |	(2,3)
DB $48, $48, $E8, $20,  ;    W0    |	(2,4)
DB $38, $40, $EB, $20,  ;    B1    |	(1,2)
DB $30, $38, $EC, $60,  ;    T0    |	(0,1)
DB $38, $38, $ED, $20,  ;    B2    |	(0,2)
DB $40, $38, $EC, $20,  ;    T0    |	(0,3)
Board0FacingDown:             ;-----------------------------------------------------------
DB $40, $48, $E0, $40,  ;    H     |	(2,3)
DB $38, $58, $E1, $60,  ;    W0    |	(0,2)
DB $38, $50, $E2, $40,  ;    W1    |	(1,2)
DB $38, $48, $E3, $40,  ;    B0    |	(2,2)
DB $38, $40, $E2, $40,  ;    W1    |	(3,2)
DB $38, $38, $E1, $40,  ;    W0    |	(4,2)
DB $30, $48, $E4, $40,  ;    B1    |	(2,1)
DB $28, $50, $E5, $60,  ;    T0    |	(1,0)
DB $28, $48, $E6, $40,  ;    B2    |	(2,0)
DB $28, $40, $E5, $40,  ;    T0    |	(3,0)
Board0FacingLeft:
DB $38, $38, $E7, $00,  ;    H     |	(0,2)
DB $28, $40, $E8, $40,  ;    W0    |	(1,0)
DB $30, $40, $E9, $00,  ;    W1    |	(1,1)
DB $38, $40, $EA, $00,  ;    B0    |	(1,2)
DB $40, $40, $E9, $00,  ;    W1    |	(1,3)
DB $48, $40, $E8, $00,  ;    W0    |	(1,4)
DB $38, $48, $EB, $00,  ;    B1    |	(2,2)
DB $30, $50, $EC, $40,  ;    T0    |	(3,1)
DB $38, $50, $ED, $00,  ;    B2    |	(3,2)
DB $40, $50, $EC, $00,  ;    T0    |	(3,3)
							 ;-----------------------------------------------------------
SECTION "Planes Template 1", ROM0, ALIGN[8]
planesTemplate1:        ; CellType |  Pixel coordinates relative to top-left (X,Y)						
Board1FacingUp:               ;-----------------------------------------------------------
DB $38, $38, $E0, $00,  ;    H     |	(2,0)
DB $40, $28, $E1, $00,  ;    W0    |	(0,1)
DB $40, $30, $E2, $00,  ;    W1    |	(1,1)
DB $40, $38, $E3, $00,  ;    B0    |	(2,1)
DB $40, $40, $E2, $00,  ;    W1    |	(3,1)
DB $40, $48, $E1, $20,  ;    W0    |	(4,1)
DB $48, $38, $E4, $00,  ;    B1    |	(2,2)
DB $50, $30, $E5, $00,  ;    T0    |	(1,3)
DB $50, $38, $E6, $00,  ;    B2    |	(2,3)
DB $50, $40, $E5, $20,  ;    T0    |	(3,3)
Board1FacingRight:            ;-----------------------------------------------------------
DB $48, $40, $E7, $20,  ;    H     |	(3,2)
DB $38, $38, $E8, $60,  ;    W0    |	(2,0)
DB $40, $38, $E9, $20,  ;    W1    |	(2,1)
DB $48, $38, $EA, $20,  ;    B0    |	(2,2)
DB $50, $38, $E9, $20,  ;    W1    |	(2,3)
DB $58, $38, $E8, $20,  ;    W0    |	(2,4)
DB $48, $30, $EB, $20,  ;    B1    |	(1,2)
DB $40, $28, $EC, $60,  ;    T0    |	(0,1)
DB $48, $28, $ED, $20,  ;    B2    |	(0,2)
DB $50, $28, $EC, $20,  ;    T0    |	(0,3)
Board1FacingDown:             ;-----------------------------------------------------------
DB $50, $38, $E0, $40,  ;    H     |	(2,3)
DB $48, $48, $E1, $60,  ;    W0    |	(0,2)
DB $48, $40, $E2, $40,  ;    W1    |	(1,2)
DB $48, $38, $E3, $40,  ;    B0    |	(2,2)
DB $48, $30, $E2, $40,  ;    W1    |	(3,2)
DB $48, $28, $E1, $40,  ;    W0    |	(4,2)
DB $40, $38, $E4, $40,  ;    B1    |	(2,1)
DB $38, $40, $E5, $60,  ;    T0    |	(1,0)
DB $38, $38, $E6, $40,  ;    B2    |	(2,0)
DB $38, $30, $E5, $40,  ;    T0    |	(3,0)
Board1FacingLeft:
DB $48, $28, $E7, $00,  ;    H     |	(0,2)
DB $38, $30, $E8, $40,  ;    W0    |	(1,0)
DB $40, $30, $E9, $00,  ;    W1    |	(1,1)
DB $48, $30, $EA, $00,  ;    B0    |	(1,2)
DB $50, $30, $E9, $00,  ;    W1    |	(1,3)
DB $58, $30, $E8, $00,  ;    W0    |	(1,4)
DB $48, $38, $EB, $00,  ;    B1    |	(2,2)
DB $40, $40, $EC, $40,  ;    T0    |	(3,1)
DB $48, $40, $ED, $00,  ;    B2    |	(3,2)
DB $50, $40, $EC, $00,  ;    T0    |	(3,3)
				        ;-----------------------------------------------------------
OAMFiller:
DB $A0, $90, $E7, $80, 
DB $A0, $90, $E8, $80, 
DB $A0, $90, $E9, $80, 
DB $A0, $90, $EA, $80, 
DB $A0, $90, $E9, $80, 
DB $A0, $90, $E8, $80, 
DB $A0, $90, $EB, $80, 
DB $A0, $90, $EC, $80, 
DB $A0, $90, $ED, $80, 
DB $A0, $90, $EC, $80, 

SECTION "Plane Parts Relative Coordinates", ROM0, ALIGN[8]
PPRC_UP:     ; Orientation = 1
DB 0*8+16, 2*8+8,   1*8+16, 0*8+8,   1*8+16, 1*8+8,   1*8+16, 2*8+8,   1*8+16, 3*8+8,   1*8+16, 4*8+8,   2*8+16, 2*8+8,   3*8+16, 1*8+8,   3*8+16, 2*8+8,   3*8+16, 3*8+8
PPRC_RIGHT:  ; Orientation = 2
DB 2*8+16, 3*8+8,   0*8+16, 2*8+8,   1*8+16, 2*8+8,   2*8+16, 2*8+8,   3*8+16, 2*8+8,   4*8+16, 2*8+8,   2*8+16, 1*8+8,   1*8+16, 0*8+8,   2*8+16, 0*8+8,   3*8+16, 0*8+8
PPRC_DOWN:   ; Orientation = 3
DB 3*8+16, 2*8+8,   2*8+16, 4*8+8,   2*8+16, 3*8+8,   2*8+16, 2*8+8,   2*8+16, 1*8+8,   2*8+16, 0*8+8,   1*8+16, 2*8+8,   0*8+16, 3*8+8,   0*8+16, 2*8+8,   0*8+16, 1*8+8
PPRC_LEFT:   ; Orientation = 4
DB 2*8+16, 0*8+8,   0*8+16, 1*8+8,   1*8+16, 1*8+8,   2*8+16, 1*8+8,   3*8+16, 1*8+8,   4*8+16, 1*8+8,   2*8+16, 2*8+8,   1*8+16, 3*8+8,   2*8+16, 3*8+8,   3*8+16, 3*8+8


; Thxx : https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial

SECTION "OAM DMA routine", ROM0
CopyDMARoutine:
  ld  hl, DMARoutine
  ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
  ld  a, [hli]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copy
  ret

DMARoutine:
  ldh [rDMA], a
  
  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

clearOAM:
	ld bc, 40
	ld hl, planesOamData + 0
	ld de, OAMFiller
	call loadMemory	
	ld bc, 40
	ld hl, planesOamData + 40
	ld de, OAMFiller
	call loadMemory	
	ld bc, 40
	ld hl, planesOamData + 80
	ld de, OAMFiller
	call loadMemory	
	ld bc, 40
	ld hl, planesOamData + 120
	ld de, OAMFiller
	call loadMemory		
	ret

SECTION "OAM DMA", HRAM

hOAMDMA::
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

