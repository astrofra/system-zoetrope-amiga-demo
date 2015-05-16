/*
	Data for "logo" Image
*/

#include <exec/types.h>
#include <intuition/intuition.h>


UWORD mandarine_logoPaletteRGB4[8] =
{
	0x0000,0x0645,0x0778,0x0689,0x0A9A,0x0DBC,0x0EEE,0x06BC
};

UWORD zoetrope_logoPaletteRGB4[8] =
{
	0x0000,0x0757,0x078A,0x0B9A,0x0F90,0x0DBB,0x0DDE,0x0FFF
};

struct Image mandarine_logo =
{
	0, 0,		/* LeftEdge, TopEdge */
	380, 80, 3,	/* Width, Height, Depth */
	NULL,	/* ImageData */
	0x007, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

struct Image zoetrope_logo =
{
	0, 0,		/* LeftEdge, TopEdge */
	380, 80, 3,	/* Width, Height, Depth */
	NULL,	/* ImageData */
	0x007, 0x0000,	/* PlanePick, PlaneOnOff */
	NULL		/* NextImage */
};

