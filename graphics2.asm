start2:
#define db .db
#define equ .equ
#include "gfx2/Buildings/gfx_buildings.inc"
#include "gfx2/Tiles/gfx_tiles.inc"
#include "gfx2/Game/gfx_gameplay.inc"

size_graphics_appv = $-start2+8+8

.echo "Size of graphics appvar 2:  ",size_graphics_appv

#IF size_graphics_appv > 0FFFFh
.error "Graphics appvar too large!"
#ENDIF
