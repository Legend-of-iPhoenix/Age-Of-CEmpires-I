MAP_SIZE				.equ 144
OFFSET_X				.equ 0
OFFSET_Y				.equ 1
OFFSET_X_TILE0			.equ 0
OFFSET_Y_TILE0			.equ 3

currDrawingBuffer		.equ 0E30014h
screenBuffer			.equ vRAM+(320*240)
mapAddress				.equ pixelShadow
blackBuffer				.equ 0E40000h

need_to_redraw_tiles	.equ 0

kpUp					.equ 3
kpLeft					.equ 1
kpRight					.equ 2
kpDown					.equ 0
kpClear					.equ 6
kpEnter					.equ 0