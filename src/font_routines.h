#ifndef FONT_ROUTINES
#define FONT_ROUTINES

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

/*  
    Fonts routines headers
*/

UBYTE font_blit_string(struct BitMap *font_BitMap, struct BitMap *font_BitMap_dark, struct BitMap *dest_BitMap, const char *glyph_array, const short *x_pos_array, int x, int y, UBYTE *text_string);
short font_get_string_width(const char *glyph_array, const short *x_pos_array, UBYTE *text_string);

#endif