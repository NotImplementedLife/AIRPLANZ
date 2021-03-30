SECTION "OAM Data", WRAM0[$C100] ;, ALIGN[8] 

; here goes the OAM data [writeable | Y,X,_,_]
planesOamData:
	DS 40

; planeXData:
;
; byte 0: exists ? 1 : 0
; byte 1: Y (0-9)
; byte 2: X (0-9)
; byte 3: Orientation (0=Up 1=Right 2=Down 3=Left)
plane1Data:
	DS 4
plane2Data:
	DS 4
plane3Data:
	DS 4
	
SECTION "Planes Template", ROM0

planesTemplate:         ; CellType |  Pixel coordinates relative to top-left (X,Y)
FacingUp:               ;-----------------------------------------------------------
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
FacingRight:            ;-----------------------------------------------------------
DB $60, $78, $E7, $20,  ;    H     |	(3,2)
DB $50, $70, $E8, $60,  ;    W0    |	(2,0)
DB $58, $70, $E9, $20,  ;    W1    |	(2,1)
DB $60, $70, $EA, $20,  ;    B0    |	(2,2)
DB $68, $70, $E9, $20,  ;    W1    |	(2,3)
DB $70, $70, $E8, $20,  ;    W0    |	(2,4)
DB $60, $68, $EB, $20,  ;    B1    |	(1,2)
DB $58, $60, $EC, $60,  ;    T0    |	(0,1)
DB $60, $60, $ED, $20,  ;    B2    |	(0,2)
DB $68, $60, $EC, $20,  ;    T0    |	(0,3)
FacingDown:             ;-----------------------------------------------------------
DB $68, $48, $E0, $40,  ;    H     |	(2,3)
DB $60, $58, $E1, $60,  ;    W0    |	(0,2)
DB $60, $50, $E2, $40,  ;    W1    |	(1,2)
DB $60, $48, $E3, $40,  ;    B0    |	(2,2)
DB $60, $40, $E2, $40,  ;    W1    |	(3,2)
DB $60, $38, $E1, $40,  ;    W0    |	(4,2)
DB $58, $48, $E4, $40,  ;    B1    |	(2,1)
DB $50, $50, $E5, $60,  ;    T0    |	(1,0)
DB $50, $48, $E6, $40,  ;    B2    |	(2,0)
DB $50, $40, $E5, $40,  ;    T0    |	(3,0)
FacingLeft:
DB $38, $60, $E7, $00,  ;    H     |	(0,2)
DB $28, $68, $E8, $40,  ;    W0    |	(1,0)
DB $30, $68, $E9, $00,  ;    W1    |	(1,1)
DB $38, $68, $EA, $00,  ;    B0    |	(1,2)
DB $40, $68, $E9, $00,  ;    W1    |	(1,3)
DB $48, $68, $E8, $00,  ;    W0    |	(1,4)
DB $38, $70, $EB, $00,  ;    B1    |	(2,2)
DB $30, $78, $EC, $40,  ;    T0    |	(3,1)
DB $38, $78, $ED, $00,  ;    B2    |	(3,2)
DB $40, $78, $EC, $00,  ;    T0    |	(3,3)
				        ;-----------------------------------------------------------


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

SECTION "OAM DMA", HRAM

hOAMDMA::
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

