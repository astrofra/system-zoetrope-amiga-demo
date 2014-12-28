/*  
    Unusual Suspects 
    Fonts routines 
*/

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#include "font_desc.h"
#include "font_bitmap.h"

extern struct GfxBase *GfxBase;

short font_glyph_find_index(char glyph, const char *glyph_array)
{
	short i = 0,
		r = -1;

	while(glyph_array[i])
	{
		if (glyph == glyph_array[i])
		{
			r = i;
			break;
		}

		i++;
	}

	return(r);
}

void blit_font_char(void)
{

}

void blit_font_string(struct BitMap *font_BitMap, struct BitMap *font_BitMap_dark, struct BitMap *dest_BitMap, const char *glyph_array, const short *x_pos_array, short x, short y, UBYTE *text_string)
{
	// UBYTE *current_char;
	short i = 0, j, glyph_index, cur_x,
		line_feed = 0,
		glyph_w, glyph_h;

	struct BitMap *default_font;

	// printf("%s\n", text_string);

	cur_x = x;
	glyph_h = font_BitMap->Rows;
	default_font = font_BitMap;

	while(text_string[i] != '\0')
	{
		// WaitTOF();
		/*	Space */
		switch(text_string[i])
		{
			/*	Space	*/
			case ' ':
				cur_x += 4;
				// WaitTOF();
				// WaitTOF();			
				break;

			/*	Switch to the default font	*/
			case '\1':
				default_font = font_BitMap;
				break;

			/*	Switch to a darker font	*/
			case '\2':
				default_font = font_BitMap_dark;
				break;

			/*	Line feed + carriage return	*/
			case '\n':
				// for(j = 0; j < 8; j++)
				// 	WaitTOF();
	
				line_feed++;		
				if (line_feed == 1)
					y += (glyph_h + 5);
				else
					y += (glyph_h + 1);

				cur_x = x;

				if (line_feed > 4)
					cur_x -= 50;

				break;

			/*	Write glyph */
			default:
				glyph_index = font_glyph_find_index((char)text_string[i], glyph_array);
				if (glyph_index >= 0)
				{
					glyph_w = x_pos_array[glyph_index + 1] - x_pos_array[glyph_index];
					BltBitMap(default_font, x_pos_array[glyph_index], 0,
					            dest_BitMap, cur_x, y,
					            glyph_w, glyph_h,
					            0xC0, 0xFF, NULL);
					// printf("[c = %c,i = %d,x = %d],", text_string[i], glyph_index, x_pos_array[glyph_index]);

					cur_x += (glyph_w);
				}			
				break;
		};

		i++;
	}

	// printf("\n");
}