/*
	Data for "logo" Image
*/

#include <exec/types.h>
#include <intuition/intuition.h>


UWORD mandarine_logoPaletteRGB4[8] =
{
	0x0000,0x0344,0x0456,0x0678,0x0789,0x09AB,0x0ABC,0x0EFF
};

struct Image mandarine_logo =
{
	0, 0,		/* LeftEdge, TopEdge */
	320, 80, 3,	/* Width, Height, Depth */
	NULL,	/* ImageData */
	0x007, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

