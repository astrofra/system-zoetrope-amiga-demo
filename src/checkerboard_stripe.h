/*
	Data for "checkerboard_stripe" Image
*/

#include <exec/types.h>
#include <intuition/intuition.h>


extern UWORD checkerboard_PaletteRGB4[2];

extern UWORD checkerboard_Data[16000];

struct Image checkerboard =
{
	0, 0,		/* LeftEdge, TopEdge */
	320, 800, 1,	/* Width, Height, Depth */
	checkerboard_Data,	/* ImageData */
	0x0001, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};
