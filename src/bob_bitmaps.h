#ifndef BOB_BITMAPS
#define BOB_BITMAPS
#include <exec/types.h>
#include <intuition/intuition.h>


extern UWORD bob_32PaletteRGB4[8];

extern UWORD chip bob_32Data[192];

struct Image bob_32 =
{
	0, 0,		/* LeftEdge, TopEdge */
	32, 32, 3,	/* Width, Height, Depth */
	bob_32Data,	/* ImageData */
	0x0007, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

#endif
