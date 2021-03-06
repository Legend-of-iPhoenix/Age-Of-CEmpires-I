#include "includes/ti84pce.inc"
#include "includes/defines.asm"
#include "includes/macros.inc"
#include "includes/relocation.inc"

#include "gfx/bin/AOCEGFX1.inc"
#include "gfx/bin/AOCEGFX2.inc"
#include "gfx/bin/AGE1.inc"
#include "gfx/bin/AGE2.inc"
#include "gfx/bin/AGE3.inc"
#include "gfx/bin/AGE4.inc"

.db tExtTok, tAsm84CECmp
.org UserMem

start:
	jp	AoCEStart
	.db	1
	.db	16,16				; Cesium icon, made by Pieman7373
	.db	000h,000h,000h,000h,020h,061h,081h,0A1h,0A1h,0A0h,0A0h,040h,001h,000h,000h,000h
	.db	000h,000h,000h,020h,061h,0A2h,0C2h,0C1h,0C0h,0A0h,0C0h,061h,021h,021h,021h,000h
	.db	000h,000h,020h,061h,0A1h,0C1h,0A1h,0A0h,061h,0A1h,0C1h,062h,029h,029h,021h,021h
	.db	000h,000h,061h,0A1h,0A1h,0A0h,061h,081h,061h,061h,082h,08Ch,04Ah,04Ah,029h,021h
	.db	000h,020h,060h,0C1h,0A0h,060h,040h,069h,06Ah,06Ah,08Bh,094h,094h,04Ah,049h,021h
	.db	000h,020h,0A0h,0C2h,081h,040h,021h,06Bh,06Bh,094h,0D6h,0B5h,0B5h,06Bh,049h,021h
	.db	000h,020h,081h,0C1h,081h,040h,04Ah,04Bh,04Bh,094h,0DEh,0DEh,094h,06Bh,04Ah,021h
	.db	000h,020h,060h,0A1h,081h,020h,04Bh,04Ah,04Ah,06Bh,0B6h,0DEh,0B5h,06Bh,04Ah,021h
	.db	000h,020h,040h,060h,060h,041h,06Bh,02Ah,02Ah,04Bh,0B4h,0B5h,0B5h,0B5h,06Ch,029h
	.db	000h,020h,060h,0A0h,080h,041h,094h,06Bh,04Ah,029h,049h,06Ch,094h,06Bh,04Ah,06Bh
	.db	000h,0FFh,0FFh,0FFh,0A0h,040h,04Ah,04Ah,04Bh,06Bh,029h,021h,001h,000h,029h,06Bh
	.db	020h,080h,0FFh,0C0h,0A0h,040h,021h,04Ah,04Ah,06Bh,06Bh,08Ch,06Bh,06Ch,08Ch,029h
	.db	040h,0A0h,0FFh,0A0h,080h,020h,000h,04Ah,04Ah,04Bh,04Ah,06Bh,06Bh,08Ch,06Bh,000h
	.db	061h,0A1h,0FFh,060h,040h,000h,000h,021h,04Ah,04Ah,06Bh,08Ch,08Ch,0B4h,06Bh,000h
	.db	081h,0FFh,0FFh,0FFh,020h,000h,000h,021h,04Ah,04Ah,04Bh,094h,0B5h,0D6h,06Bh,000h
	.db	081h,081h,040h,040h,000h,000h,000h,000h,021h,029h,04Ah,04Ah,04Ah,06Bh,029h,000h
	.db	"Age of CEmpires I - By Peter \"PT_\" Tillema", 0
AoCEStart:
	call	_HomeUp
	call	_ClrLCDFull
	call	_RunIndicOff
	ld	hl, LoadingMessage
	call	_PutS
	push	ix
	
; Check if all the appvars exists
	ld	hl, GraphicsAppvar1_
	ld	iyh, 6
_:	call	_Mov9ToOP1
	inc	hl
	push	hl
	call	_ChkFindSym
	jp	c, AppvarNotFound
	pop	hl
	push	hl
	call	_ChkInRAM
	call	nc, _Arc_Unarc
	call	_ChkFindSym
	ex	de, hl
	ld	de, 9
	add	hl, de
	ld	e, (hl)
	add	hl, de
	inc	hl
	ex	de, hl
	ld	a, 6
	sub	a, iyh
	ld	c, a
	ld	b, 3
	mlt	bc
	ld	hl, AppvarsPointersTable
	add	hl, bc
	ld	(hl), de
	pop	hl
	dec	iyh
	jr	nz, -_
	
; Backup RAM
	di
	ld.sis	sp, stackBot & 0FFFFh
	ld	a, FlashMbaseStart
	ld	mb, a
	call.lis fUnlockFlash & 0FFFFh
	call	BackupRAM
	
; Backup stack
	ld	hl, heapBot
	ld	de, vRAM - (stackTop - heapBot)
	ld	bc, stackTop - heapBot
	ldir
	
; Copy AoCE to $D80002 (mirror of $D00002)
	ld	hl, (asm_prgm_size)
	ld	de, AppvarsPointersTable - start
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	ld	de, 0D80002h
	ld	hl, AppvarsPointersTable
	ldir
	
; Set some pointers
	ld	(MapDataPtr), de
	ld	hl, MAP_SIZE * MAP_SIZE * 2
	add	hl, de
	push	hl
	ex	de, hl
	ld	hl, (0D00005h)
	ld	bc, 0
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ldir
	ld	(FixedBuildingsPtr), de
	pop	bc
	ld	hl, RelocationTable2
	call	ModifyRelocationTable
	
	jp	0D00002h + 18
	
AppvarNotFound:
	call	_HomeUp
	call	_ClrLCDFull
	ld	hl, GraphicsAppvarNotFound_
	call	_PutS
	call	_NewLine
	pop	hl
	ld	de, -9
	add	hl, de
	call	_PutS
_:	call	_GetCSC
	or	a, a
	jr	z, -_
	pop	ix
	ld	iy, flags
	ret
	
#include "routines/flash.asm"
	
GraphicsAppvar1_:
	.db	AppVarObj, "AOCEGFX1", 0
	.db	AppVarObj, "AOCEGFX2", 0
	.db	AppVarObj, "AGE1", 0,0,0,0,0
	.db	AppVarObj, "AGE2", 0,0,0,0,0
	.db	AppVarObj, "AGE3", 0,0,0,0,0
	.db	AppVarObj, "AGE4", 0
GraphicsAppvarNotFound_:
	.db	"Can't find appvar:", 0
MissingAppVar:
	.db	"Need"
LibLoadAppVar:
	.db	" LibLoad", 0
	.db	"tiny.cc/clibs", 0
LoadingMessage:
	.db	"Loading..."
	
AppvarsPointersTable:
	.block	18
	
NewStartAddr:
.org $D00002 + 18
; Use the moved stack
	or	a, a
	sbc	hl, hl
	add	hl, sp
	ld	(backupSP), hl
	ld	de, vRAM - stackTop
	add	hl, de
	ld	sp, hl
	
; Get the sprites of the homescreen
	ld	hl, RelocationTable1
	ld	bc, (0D00002h)
	inc	bc			; Skip size bytes
	inc	bc
	call	ModifyRelocationTable
	
; Setup some variables and start the game!
	xor	a, a
	ld	(_FillColor), a
	inc	a
	ld	(_FGColor), a
	call	_Begin
	;call	MainMenu
	call	GenerateMap
	
; Of course, we start with age 1
	ld	c, 1
	ld	hl, RelocationTable3
	ld	de, barracks_1_offset
	call	LoadAgeGraphicsAppvar
	
	ld	iy, _IYOffsets
	xor	a, a
	ld	(iy + OFFSET_X), a
	ld	(iy + OFFSET_Y), a
	
; Copy to cursorImage
	ld	hl, drawfield_loc
	ld	de, DrawField
	ld	bc, DrawFieldEnd - DrawField
	ldir
	
; Set some variables and palette
	ld	hl, vRAM+(320*240)
	ld	(currDrawingBuffer), hl
	ld	(mpLcdBase), hl
	ld	de, mpLcdPalette
	ld	hl, _pal_gfx_pal
	ld	bc, _pal_gfx_pal_size
	ldir
	
#if 1 == 1				; Easier debugging if you have a full pink background
	ld	hl, screenBuffer
	ld	(hl), 255
	push	hl
	pop	de
	inc	de
	ld	bc, 320*240-1
	ldir
#endif

MainGameLoop:
	call	DrawField
	call	DrawGame
	ld	hl, (AmountOfWood)
	inc	hl
	ld	(AmountOfWood), hl
	call	GetKeyFast
	ld	iy, _IYOffsets
CheckKeys369:				; Check [3], [6], [9]
	ld	l, 01Ah
	ld	a, (hl)
	and	a, (1 << kp3) | (1 << kp6) | (1 << kp9)
	jp	z, CheckKeys28
	ScrollFieldRight()
CheckKey3:
	bit	kp3, (hl)
	jr	z, CheckKey9
	ScrollFieldRight()
	ScrollFieldDown()
CheckKey9:
	bit	kp9, (hl)
	jr	z, CheckKeys28
	ScrollFieldRight()
	ScrollFieldUp()
CheckKeys28:				; Check [2], [8]
	ld	l, 018h
	ld	a, (hl)
	and	a, (1 << kp2) | (1 << kp8)
	jr	z, CheckKeys147
CheckKey2:
	bit	kp2, (hl)
	jr	z, CheckKey8
	ScrollFieldDown()
CheckKey8:
	bit	kp8, (hl)
	jr	z, CheckKeys147
	ScrollFieldUp()
CheckKeys147:				; Check [1], [4], [7]
	ld	l, 016h
	ld	a, (hl)
	and	a, (1 << kp1) | (1 << kp4) | (1 << kp7)
	jp	z, CheckClearEnter
	ScrollFieldLeft()
CheckKey1:
	bit	kp1, (hl)
	jr	z, CheckKey7
	ScrollFieldLeft()
	ScrollFieldDown()
CheckKey7:
	bit	kp7, (hl)
	jr	z, CheckClearEnter
	ScrollFieldLeft()
	ScrollFieldUp()
CheckClearEnter:
	ld	l, 01Ch
	bit	kpClear, (hl)
	jp	nz, ForceStopProgram
	bit	kpEnter, (hl)
	jr	z, CheckReleaseEnterKey
	bit	holdDownEnterKey, (iy+AoCEFlags1)
	set	holdDownEnterKey, (iy+AoCEFlags1)
	jr	nz, CheckStop
CreateNewSelectedArea:
	ld	hl, (iy+CursorX)
	ld	(iy+SelectedAreaStartX), hl
	ld	l, (iy+CursorY)
	ld	(iy+SelectedAreaStartY), l
	jr	CheckStop
CheckReleaseEnterKey:
	bit	holdDownEnterKey, (iy+AoCEFlags1)
	res	holdDownEnterKey, (iy+AoCEFlags1)
	jr	z, CheckStop
ParseSelectedArea:
; Yay #not :P
CheckStop:
; Swap buffers
	ld	hl, vRAM
	ld	de, (mpLcdBase)
	or	a, a
	sbc	hl, de
	add	hl, de
	jr	nz, +_
	ld	hl, vRAM+(320*240)
_:	ld	(currDrawingBuffer), de
	ld	(mpLcdBase), hl
	ld	hl, mpLcdIcr
	set	2, (hl)
	ld	l, mpLcdRis & 0FFh
_:	bit	2, (hl)
	jr	z, -_
	jp	MainGameLoop
	
ForceStopProgramFadeOut:
	call	fadeOut
ForceStopProgram:
CleanupCode:
	ld	de, cursorImage
	ld	hl, CleanupCode
	ld	bc, CleanupCodeEnd - CleanupCode
	ldir
	jp	cursorImage + $ + 4 - CleanupCode
	call	_End
	ld	de, 0D80000h
	ld	hl, 03C0000h
	ld	bc, (vRAM - ramStart) - (stackTop - heapBot)
	ldir
	ld	de, heapBot + 008000h			; Prevent crashing because memory protector
	ld	hl, vRAM - (stackTop - heapBot)
	push	hl
	ld	bc, stackTop - heapBot
	ldir
	call.lis fLockFlash & 0FFFFh
	pop	de
backupSP = $+1
	ld	sp, 0
	pop	ix
	ld	a, 0D0h
	ld	mb, a
	ld	hl, 03C0000h + (vRAM - ramStart) - (stackTop - heapBot)
	ld	bc, stackTop - heapBot
	ldir
	ld	iy, flags
	jp	_DrawStatusBar
CleanupCodeEnd:
    
#include "gfx/bin/pal_gfx.asm"
#include "routines/map.asm"
#include "routines/mainmenu.asm"
#include "routines/drawGame.asm"
;#include "routines/pathfinding.asm"
#include "routines/routines.asm"
#include "routines/drawField.asm"
#include "data/tables.asm"
#include "data/data.asm"
#include "relocation_table1.asm"
	.dw	0FFFFh
#include "relocation_table2.asm"
	.dw	0FFFFh
#include "relocation_table3.asm"
	.dw	0FFFFh
#include "relocation_table4.asm"
	.dw	0FFFFh
#include "relocation_table5.asm"
	.dw	0FFFFh
#include "relocation_table6.asm"
	.dw	0FFFFh
	
AoCEEnd:
	
.echo "Total size: ", AoCEEnd - 0D00002h + NewStartAddr - start, " bytes"