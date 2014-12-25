#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <hardware/custom.h>

#include "board.h"
#include "screen_size.h"
#include "bitmap_routines.h"
#include "sprites_routines.h"
#include "cosine_table.h"
#include "ruby_stripe.h"
#include "mandarine_logo.h"
#include "checkerboard_stripe.h"
#include "vert_copper_palettes.h"

extern struct GfxBase *GfxBase;
extern struct ViewPort view_port1;
extern struct ViewPort view_port2;

extern struct  BitMap *bitmap_logo;
extern struct  BitMap *bitmap_checkerboard;

extern struct Custom far custom;

/*	Viewport 1, Mandarine Logo */
USHORT bg_scroll_phase = 0;

/*	Viewport 2, checkerboard and sprites animation */
USHORT sprite_chain_phase = 0;
USHORT checkerboard_scroll_offset = 0;
struct UCopList *copper;

UWORD chip blank_pointer[32]=
{
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
};

UWORD mixRGB4Colors(UWORD A, UWORD B)
{
    UWORD r,g,b;

    r = (A & 0x0f00) >> 8;
    g = (A & 0x00f0) >> 4;
    b = A & 0x000f;

    r += (B & 0x0f00) >> 8;
    g += (B & 0x00f0) >> 4;
    b += B & 0x000f;

    r = r >> 1;
    g = g >> 1;
    b = b >> 1;

    if (r > 0xf) r = 0xf;
    if (g > 0xf) g = 0xf;
    if (b > 0xf) b = 0xf;

    r = r & 0xf;
    g = g & 0xf;
    b = b & 0xf;

    return (UWORD)((r << 8) | (g << 4) | b);
    //(image_bg_fishPaletteRGB4[c] & 0x0f00) >> 8, (image_bg_fishPaletteRGB4[c] & 0x00f0) >> 4, (image_bg_fishPaletteRGB4[c] & 0x000f));
}


/*	
	Viewport 1, 
	Mandarine Logo 
*/

/*	Draws the Mandarine Logo */
void drawMandarineLogo(struct BitMap *dest_bitmap, USHORT offset_y)
{
	bitmap_logo = load_array_as_bitmap(mandarine_logoData, 6400 << 1, mandarine_logo.Width, mandarine_logo.Height, mandarine_logo.Depth);
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

void setLogoCopperlist(struct ViewPort *vp)
{
    copper = (struct UCopList *)
    AllocMem( sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CHIP|MEMF_CLEAR );

    CINIT(copper, 16);
    CWAIT(copper, 0, 0);

    CMOVE(copper, *((UWORD *)SPR0PTH_ADDR), (LONG)&blank_pointer);
    CMOVE(copper, *((UWORD *)SPR0PTL_ADDR), (LONG)&blank_pointer);

    CEND(copper);

    vp->UCopIns = copper;
}

/*	
	Viewport 2, 
	checkerboard and sprites animation
*/
void drawCheckerboard(struct BitMap *dest_bitmap)
{
    USHORT i;

    bitmap_checkerboard = load_array_as_bitmap(checkerboard_Data, 19000 << 1, checkerboard.Width, checkerboard.Height, checkerboard.Depth);

    for(i = 0; i < ANIM_STRIPE; i++)
        BltBitMap(bitmap_checkerboard, 0, 100 * i,
            dest_bitmap, 0, DISPL_HEIGHT2 * i + 60,
            checkerboard.Width, 100,
            0xC0, 0xFF, NULL);
        // BLIT_BITMAP_S(bitmap_checkerboard, dest_bitmap, checkerboard.Width, 100, 0, DISPL_HEIGHT2 * i + 60);
}

void setCheckerboardCopperlist(struct ViewPort *vp)
{
    USHORT i, j;

    copper = (struct UCopList *)
    AllocMem( sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CHIP|MEMF_CLEAR );

    CINIT(copper, DISPL_HEIGHT2 * 10);

    for(i = 0; i < DISPL_HEIGHT2; i++)
    {
        CWAIT(copper, i, 0);
        CMOVE(copper, custom.color[0], vcopperlist_checker_1[i]);
        CMOVE(copper, custom.color[1], mixRGB4Colors(vcopperlist_checker_0[i], vcopperlist_checker_1[i]));

        if (i == 0)
        {
            CMOVE(copper, *((UWORD *)SPR0PTH_ADDR), (LONG)&blank_pointer);
            CMOVE(copper, *((UWORD *)SPR0PTL_ADDR), (LONG)&blank_pointer);
        }

        if (i < 4)
            for(j = 0; j < 4; j++)
                CMOVE(copper, custom.color[16 + i * 4 + j], ruby_stripe_palRGB4[j]);

        CWAIT(copper, i, 74);
        CMOVE(copper, custom.color[1], mixRGB4Colors(vcopperlist_checker_0[i], mixRGB4Colors(vcopperlist_checker_0[i], mixRGB4Colors(vcopperlist_checker_1[i], vcopperlist_checker_0[i]))));
        CWAIT(copper, i, 80);
        CMOVE(copper, custom.color[1], vcopperlist_checker_0[i]);

        CWAIT(copper, i, 200);
        CMOVE(copper, custom.color[1], mixRGB4Colors(vcopperlist_checker_0[i], mixRGB4Colors(vcopperlist_checker_0[i], mixRGB4Colors(vcopperlist_checker_1[i], vcopperlist_checker_0[i]))));
        CWAIT(copper, i, 208);
        CMOVE(copper, custom.color[1], mixRGB4Colors(vcopperlist_checker_0[i], vcopperlist_checker_1[i]));
    }

    CEND(copper);

    vp->UCopIns = copper;
}

void updateCheckerboard(void)
{
    checkerboard_scroll_offset += DISPL_HEIGHT2;
    if (checkerboard_scroll_offset >= HEIGHT2)
        checkerboard_scroll_offset = 0;

    view_port2.RasInfo->RyOffset = checkerboard_scroll_offset;

    ScrollVPort(&view_port2);
}

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

      	x = 16 + (((tcos[sprite_phase] + 512) * (DISPL_WIDTH2 - 8 - 32)) >> 10);
      	y = 4 + (((tsin[sprite_phase2] + 512) * (DISPL_HEIGHT2 - 16 - 32)) >> 10);

      	MoveSprite(vp, my_sprite[i], x, y );
        ChangeSprite(vp, my_sprite[i], (PLANEPTR)ruby_stripe_img[(sprite_chain_phase + i) & 0xF]);
    }
}