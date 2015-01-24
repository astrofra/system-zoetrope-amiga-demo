#ifndef CHECKERBOARD_STRIPE
#define CHECKERBOARD_STRIPE
#include <exec/types.h>
#include <intuition/intuition.h>

extern UWORD checkerboard_PaletteRGB4[8];
extern UWORD checkerboard_Data[60000];

struct Image checkerboard = {
	0, 0, 320, 1000, 3, checkerboard_Data,
	7, 0, NULL
};
#endif // #ifndef CHECKERBOARD_STRIPE