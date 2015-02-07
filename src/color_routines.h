#ifndef COLOR_ROUTINES
#define COLOR_ROUTINES

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

UWORD mixRGB4Colors(UWORD A, UWORD B, UBYTE n);
void fadeRGB4Palette(struct ViewPort *vp, UWORD *pal, UWORD pal_size, UWORD fade);
ULONG RGB4toRGB8(UWORD A);
UWORD RGB8toRGB4(ULONG A);
ULONG mixRGB8Colors(ULONG A, ULONG B, USHORT n);

#endif