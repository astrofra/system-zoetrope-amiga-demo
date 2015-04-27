#ifndef BOB_BITMAPS
#define BOB_BITMAPS
#include <exec/types.h>
#include <intuition/intuition.h>

extern UWORD bob_32PaletteRGB4[4*6];

struct Image bob_32 =
{
	0, 0,		/* LeftEdge, TopEdge */
	32, 32 * 8, 2,	/* Width, Height, Depth */
	NULL,	/* ImageData */
	0x0003, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

extern UWORD chip bob_32_maskData[64];

struct Image bob_32_mask =
{
	0, 0,		/* LeftEdge, TopEdge */
	32, 32 * 8, 1,	/* Width, Height, Depth */
	NULL,	/* ImageData */
	0x0001, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

extern UWORD clr_patternData[40];
extern UWORD clr_patternData_neg[40];

struct Image clr_pattern =
{
	0, 0,		/* LeftEdge, TopEdge */
	64, 10, 1,	/* Width, Height, Depth */
	clr_patternData,	/* ImageData */
	0x0001, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

extern UWORD morph_iso_0PaletteRGB4[8];

struct Image morph_iso_0 =
{
	0, 0,		/* LeftEdge, TopEdge */
	96, 384, 3,	/* Width, Height, Depth */
	NULL,	/* ImageData */
	0x0007, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

#endif
