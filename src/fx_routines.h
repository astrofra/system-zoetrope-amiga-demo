#ifndef FX_ROUTINES
#define FX_ROUTINES

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

UWORD mixRGB4Colors(UWORD a, UWORD b);
void drawMandarineLogo(struct BitMap *dest_bitmap, USHORT offset_y);
void drawCheckerboard(struct BitMap *dest_bitmap);
void setLogoCopperlist(struct ViewPort *vp);
void setCheckerboardCopperlist(struct ViewPort *vp);
void scrollLogoBackground(void);
void scrollTextViewport(void);
void updateCheckerboard(void);
void loadBobBitmaps(void);
void drawUnlimitedBobs(struct BitMap* dest_bitmap);
void setTextLinerCopperlist(struct ViewPort *vp);
void loadTextWriterFont(void);

#endif // #ifndef FX_ROUTINES