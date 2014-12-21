#ifndef FX_ROUTINES
#define FX_ROUTINES

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

/*	Draws the Mandarine Logo */
extern void drawMandarineLogo(struct BitMap *dest_bitmap, USHORT offset_y);

/*	Scrolls the Mandarine Logo, ping pong from left to right */
extern void scrollLogoBackground(void);

extern void updateSpritesChain(struct ViewPort *vp);

#endif // #ifndef FX_ROUTINES