#ifndef BUDDHA_BITMAPS
#define BUDDHA_BITMAPS

#include <exec/types.h>
#include <intuition/intuition.h>

extern UWORD buddhaPaletteRGB4[8];
extern UWORD chip buddhaData[192];

struct Image buddha =
{
	0, 0,		/* LeftEdge, TopEdge */
	32, 32, 3,	/* Width, Height, Depth */
	buddhaData,	/* ImageData */
	0x0007, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

extern UWORD buddha_zzPaletteRGB4[8];
extern UWORD chip buddha_zzData[48];

struct Image buddha_zz =
{
	0, 0,		/* LeftEdge, TopEdge */
	15, 16, 3,	/* Width, Height, Depth */
	buddha_zzData,	/* ImageData */
	0x0007, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

#endif
