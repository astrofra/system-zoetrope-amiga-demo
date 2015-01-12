#include <intuition/intuition.h>

extern UWORD helix_strip_palRGB4[2];
extern UWORD helix_strip_img[12760];

struct Image helix_strip_image = {
	0, 0, 160, 1276, 1, helix_strip_imdata,
	1, 0, NULL
};
