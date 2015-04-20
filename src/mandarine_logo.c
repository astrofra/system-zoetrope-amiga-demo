/*
	Data for "logo" Image
*/

#include <exec/types.h>
#include <intuition/intuition.h>


UWORD mandarine_logoPaletteRGB4[8] =
{
	0x0000,0x0645,0x0778,0x0689,0x0A9A,0x0DBC,0x0EEE,0x06BC
	// 0x0000,0x0468,0x0C98,0x0034,0x0437,0x0000,0x0000,0x0000
};

struct Image mandarine_logo =
{
	0, 0,		/* LeftEdge, TopEdge */
	380, 80, 3,	/* Width, Height, Depth */
	NULL,	/* ImageData */
	0x007, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

