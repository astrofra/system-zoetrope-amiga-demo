#ifndef FX_ROUTINES
#define FX_ROUTINES

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

extern void drawMandarineLogo(struct BitMap *dest_bitmap, USHORT offset_y);
extern void drawCheckerboard(struct BitMap *dest_bitmap);
extern void setCheckerboardCopperlist(struct ViewPort *vp);
extern void scrollLogoBackground(void);
extern void updateCheckerboard(void);
extern void updateSpritesChain(struct ViewPort *vp);

#endif // #ifndef FX_ROUTINES