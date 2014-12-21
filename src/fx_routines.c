#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#include "screen_size.h"
#include "bitmap_routines.h"
#include "sprites_routines.h"
#include "cosine_table.h"
#include "mandarine_logo.h"
#include "checkerboard_stripe.h"

extern struct GfxBase *GfxBase;
extern struct ViewPort view_port1;

extern struct  BitMap *bitmap_logo;

/*	Viewport 1, Mandarine Logo */
USHORT bg_scroll_phase = 0;

/*	Viewport 2, checkerboard and sprites animation */
USHORT sprite_chain_phase = 0;

/*	
	Viewport 1, 
	Mandarine Logo 
*/

/*	Draws the Mandarine Logo */
void drawMandarineLogo(struct BitMap *dest_bitmap, USHORT offset_y)
{
	bitmap_logo = load_array_as_bitmap(mandarine_logoData, 6400 << 1, mandarine_logo.Width - 8, mandarine_logo.Height, mandarine_logo.Depth);
	BLIT_BITMAP_S(bitmap_logo, dest_bitmap, mandarine_logo.Width, mandarine_logo.Height, (WIDTH1 - mandarine_logo.Width) >> 1, offset_y);
}

/*	Scrolls the Mandarine Logo, ping pong from left to right */
void scrollLogoBackground(void)
{
    bg_scroll_phase += 4;

    if (bg_scroll_phase >= COSINE_TABLE_LEN)
        bg_scroll_phase -= COSINE_TABLE_LEN;

    view_port1.RasInfo->RxOffset = (WIDTH1 - DISPL_WIDTH1) + ((tcos[bg_scroll_phase] + 512) * (WIDTH1 - DISPL_WIDTH1)) >> 10;
    view_port1.RasInfo->RyOffset = 0;
    ScrollVPort(&view_port1);
}

/*	
	Viewport 2, 
	checkerboard and sprites animation
*/
void updateSpritesChain(struct ViewPort *vp)
{
	USHORT i, sprite_phase, sprite_phase2, x, y;
	sprite_chain_phase++;

	if (sprite_chain_phase >= COSINE_TABLE_LEN)
        sprite_chain_phase -= COSINE_TABLE_LEN;

    sprite_phase = sprite_chain_phase;
    for(i = 0; i < MAX_SPRITES; i++)
    {
    	sprite_phase += 32;

    	if (sprite_phase >= COSINE_TABLE_LEN)
    	    sprite_phase -= COSINE_TABLE_LEN;

    	sprite_phase2 = sprite_phase << 1;

    	if (sprite_phase2 >= COSINE_TABLE_LEN)
    	    sprite_phase2 -= COSINE_TABLE_LEN;

      	x = 4 + ((tcos[sprite_phase] + 512) * (WIDTH2 - 8)) >> 10;
      	y = 4 + ((tsin[sprite_phase2] + 512) * (DISPL_HEIGHT2 - 8)) >> 10;

      	MoveSprite(vp, my_sprite[i], x, y );
    }
}