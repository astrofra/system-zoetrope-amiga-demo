#ifndef CHECKERBOARD_STRIPE
#define CHECKERBOARD_STRIPE
#include <exec/types.h>
#include <intuition/intuition.h>

extern UWORD checkerboard_PaletteRGB4[2];
extern UWORD checkerboard_Data[19000];

struct Image checkerboard = {
	0, 0, 292, 1000, 1, checkerboard_Data,
	1, 0, NULL
};
 #endif // #ifndef CHECKERBOARD_STRIPE
