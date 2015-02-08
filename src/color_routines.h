#ifndef COLOR_ROUTINES
#define COLOR_ROUTINES

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

UWORD mixRGB4Colors(UWORD A, UWORD B, UBYTE n);
void fadeRGB4Palette(struct ViewPort *vp, UWORD *pal, UWORD pal_size, UWORD fade);
void fadeRGB4PaletteToRGB8Color(struct ViewPort *vp, UWORD *pal, UWORD pal_size, ULONG rgb8color, UWORD fade);
ULONG RGB4toRGB8(UWORD A);
UWORD RGB8toRGB4(ULONG A);
ULONG mixRGB8Colors(ULONG A, ULONG B, USHORT n);
ULONG addRGB8Colors(ULONG A, ULONG B);
ULONG divideRGB8Color(ULONG A, UWORD n);

#endif