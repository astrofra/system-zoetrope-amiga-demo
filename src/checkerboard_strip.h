#ifndef CHECKERBOARD_STRIPE
#define CHECKERBOARD_STRIPE
#include <exec/types.h>
#include <intuition/intuition.h>

extern UWORD checkerboard_PaletteRGB4[8];
extern UWORD checkerboard_Data[40000];

struct Image checkerboard = {
	0, 0, 320, 1000, 2, checkerboard_Data,
	0x0003, 0, NULL
};
#endif // #ifndef CHECKERBOARD_STRIPE