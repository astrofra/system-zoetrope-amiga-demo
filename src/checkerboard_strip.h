#ifndef CHECKERBOARD_STRIPE
#define CHECKERBOARD_STRIPE
#include <exec/types.h>
#include <intuition/intuition.h>

extern UWORD checkerboard_PaletteRGB4[8];
extern UBYTE checkerboard_pal_match[8];
extern UBYTE checkerboard_pal_dec[8];

struct Image checkerboard = {
	0, 0, 320, 1000, 3, NULL, // checkerboard_Data,
	0x0007, 0, NULL
};
#endif // #ifndef CHECKERBOARD_STRIPE