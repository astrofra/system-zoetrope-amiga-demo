#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <hardware/custom.h>

#include "board.h"
#include "screen_size.h"
#include "color_routines.h"
#include "bitmap_routines.h"
#include "cosine_table.h"
#include "mandarine_logo.h"
#include "checkerboard_strip.h"
#include "bob_bitmaps.h"
// #include "buddha_bitmaps.h"
#include "vert_copper_palettes.h"
#include "font_desc.h"
#include "font_bitmap.h"

extern struct GfxBase *GfxBase;
extern struct ViewPort view_port1;
extern struct ViewPort view_port2;
extern struct ViewPort view_port3;

extern struct  BitMap *bitmap_logo;
extern struct  BitMap *bitmap_checkerboard;
extern struct  BitMap *bitmap_bob;
extern struct  BitMap *bitmap_bob_mask;

extern struct Custom far custom;

extern struct BitMap *bitmap_font;

/*	Viewport 1, Mandarine Logo */
UWORD bg_scroll_phase = 0;

/*  Viewport 2, checkerboard and sprites animation */
UWORD ubob_phase_x = 0, ubob_phase_y = 0;
UWORD clr_screen_y = 0;
UWORD ubob_vscroll = 0;
UWORD ubob_hscroll_phase = 0;
UWORD checkerboard_scroll_offset = 0;
UWORD scrolltext_y_offset = 0;
UWORD ubob_scale = 0;
UBYTE ubob_morph_idx = 0;
struct UCopList *copper;

UWORD chip blank_pointer[4]=
{
    0x0000, 0x0000,
    0x0000, 0x0000
};

/*	
	Viewport 1, 
	Mandarine Logo 
*/

/*	Draws the Mandarine Logo */
void drawMandarineLogo(struct BitMap *dest_bitmap, UWORD offset_y)
{
	// bitmap_logo = load_array_as_bitmap(mandarine_logoData, 6400 << 1, mandarine_logo.Width, mandarine_logo.Height, mandarine_logo.Depth);

    bitmap_logo = load_file_as_bitmap("assets/mandarine_logo.bin", 5760 << 1, mandarine_logo.Width, mandarine_logo.Height, mandarine_logo.Depth);
	BLIT_BITMAP_S(bitmap_logo, dest_bitmap, mandarine_logo.Width, mandarine_logo.Height, (WIDTH1 - mandarine_logo.Width) >> 1, offset_y);
}

/*	Scrolls the Mandarine Logo, ping pong from left to right */
__inline void scrollLogoBackground(void)
{
    bg_scroll_phase += 4;
    bg_scroll_phase &= 0x1FF;

    view_port1.RasInfo->RxOffset = (WIDTH1 - DISPL_WIDTH1) + ((tcos[bg_scroll_phase] + 512) * (WIDTH1 - DISPL_WIDTH1)) >> 10;
    view_port1.RasInfo->RyOffset = 0;
    ScrollVPort(&view_port1);
}

__inline UBYTE scrollTextViewport(UWORD y_target)
{
 
    if (scrolltext_y_offset > y_target)
        scrolltext_y_offset--;
    else
    if (scrolltext_y_offset < y_target)
        scrolltext_y_offset++;

    view_port3.RasInfo->RxOffset = 0;
    view_port3.RasInfo->RyOffset = scrolltext_y_offset;
    ScrollVPort(&view_port3);

    if (scrolltext_y_offset == y_target)
        return 0;

    return 1;
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
__inline void drawCheckerboard(struct BitMap *dest_bitmap, struct RastPort *dest_rp)
{
    UWORD i;

    // bitmap_checkerboard = load_array_as_bitmap(checkerboard_Data, 60000 << 1, checkerboard.Width, checkerboard.Height, checkerboard.Depth);
    bitmap_checkerboard = load_file_as_bitmap("assets/checkerboard_strip.bin", 40000 << 1, checkerboard.Width, checkerboard.Height, checkerboard.Depth);

    for(i = 0; i < ANIM_STRIPE; i++)
        BltBitMap(bitmap_checkerboard, 0, 100 * i,
            dest_bitmap, 0, DISPL_HEIGHT2 * i + (DISPL_HEIGHT2 - (100)),
            checkerboard.Width, 100,
            0xC0, 0xFF, NULL);
}

void setCheckerboardCopperlist(struct ViewPort *vp)
{
    UWORD i, c, r, g, b;
    ULONG *pal;
    ULONG c0;

    copper = (struct UCopList *)
    AllocMem( sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CHIP|MEMF_CLEAR );

    pal = (ULONG *)malloc(sizeof(ULONG) * 256);
    memset(pal, 0xFF00FF, 256);

    CINIT(copper, DISPL_HEIGHT2 * 2 * 16);

    for(i = 0; i < DISPL_HEIGHT2; i++)
    {
        CWAIT(copper, i, 0);

        if (i == 0) {
            CMOVE(copper, *((UWORD *)SPR0PTH_ADDR), (LONG)&blank_pointer);
            CMOVE(copper, *((UWORD *)SPR0PTL_ADDR), (LONG)&blank_pointer);
        }

        /*
            Create the palette
        */
        /*
            Background color
        */
        r = 0;
        g = 0;
        b = 0;

        for(c = 0; c < 8; c++)
        {
            c0 = RGB4toRGB8(vcopperlist_checker_1[i + c]);
            r += (c0 & 0xff0000) >> 16;
            g += (c0 & 0x00ff00) >> 8;
            b += c0 & 0x0000ff;
        }

        r >>= 3;
        g >>= 3;
        b >>= 3;

        pal[0] = (r << 16) | (g << 8) | b;

        pal[0] = mixRGB8Colors(pal[0], RGB4toRGB8(vcopperlist_checker_1[i + 2]), 127);
        pal[0] = mixRGB8Colors(pal[0], 0x22AAFF, 16);

        for(c = 1; c < COLOURS2b; c++)
        {
            pal[c] = 
            mixRGB8Colors(pal[0], RGB4toRGB8(vcopperlist_checker_0[i + 5]), (checkerboard_PaletteRGB4[c] & 0xF) * 16);
        }
        // printf("c0 = %x\n", pal[0]);

        /*
            Convert the palette
            into a user copper list
        */
        for (c = 0; c < COLOURS2b; c++)
            CMOVE(copper, custom.color[c], RGB8toRGB4(addRGB8Colors(pal[c], COLOUR_PURPLE)));

        // CMOVE(copper, custom.color[(COLOURS2 * 2) + 2], RGB8toRGB4(addRGB8Colors(pal[0], COLOUR_PURPLE)));
    }

    CEND(copper);

    vp->UCopIns = copper;

    free(pal);
}

__inline void updateCheckerboard(void) // UBYTE update_sw)
{
    // if (update_sw)
    // {
        checkerboard_scroll_offset += DISPL_HEIGHT2;
        if (checkerboard_scroll_offset >= HEIGHT2)
            checkerboard_scroll_offset = 0;
        view_port2.RasInfo->RxOffset = 0;
        view_port2.RasInfo->RyOffset = checkerboard_scroll_offset;
    // }

    ubob_hscroll_phase += 3;
    ubob_hscroll_phase &= 0x1FF;

    view_port2.RasInfo->Next->RxOffset = (WIDTH2b - DISPL_WIDTH2b) + ((tsin[ubob_hscroll_phase] + 512) * (WIDTH2b - DISPL_WIDTH2b)) >> 10;
    view_port2.RasInfo->Next->RyOffset = ubob_vscroll;

    ScrollVPort(&view_port2);

    ubob_vscroll += DISPL_HEIGHT2b;
    if (ubob_vscroll >= HEIGHT2b)
        ubob_vscroll = 0;    
}

void loadBobBitmaps(void)
{   
    bitmap_bob = load_file_as_bitmap("assets/bob_sphere.bin", 256, bob_32.Width, bob_32.Height, bob_32.Depth);
    bitmap_bob_mask = load_file_as_bitmap("assets/bob_sphere_mask.bin", 128, bob_32_mask.Width, bob_32_mask.Height, bob_32_mask.Depth);
}

__inline UBYTE drawUnlimitedBobs(struct RastPort *dest_rp, UBYTE *figure_mode) // struct BitMap* dest_bitmap)
{
    UWORD x, y;

    switch(*figure_mode)
    {
        case 0:
            ubob_phase_x += 3;
            ubob_phase_y += 2;
            // ubob_morph_idx = 3;
            break;

        case 1:
            ubob_phase_x += 2;
            ubob_phase_y += 3;
            // ubob_morph_idx = 2;
            break;

        case 2:
            ubob_phase_x += 3;
            ubob_phase_y += 1;
            // ubob_morph_idx = 1;
            break;

        case 3:
            ubob_phase_x += 1;
            ubob_phase_y += 5;
            // ubob_morph_idx = 3;         
            break;

        case 4:
            ubob_phase_x += 1;
            ubob_phase_y += 2;
            // ubob_morph_idx = 0;         
            break;

        case 5:
            ubob_phase_x++;
            ubob_phase_y++;
            // ubob_morph_idx = 3;
            break;                             
    }

    if (ubob_phase_x > (COSINE_TABLE_LEN << 1) && ubob_phase_y > (COSINE_TABLE_LEN << 1))
        return 0;

    if ((ubob_phase_x & 0x7F) == 0 || (ubob_phase_y & 0x7F) == 0)
        ubob_scale++;

    x = ((WIDTH2b - DISPL_WIDTH2b) >> 1) + 24 + ubob_scale + (((tcos[ubob_phase_x & 0x1FF] + 512) * (DISPL_WIDTH2b - 8 - 64 - ubob_scale - ubob_scale)) >> 10);
    y = 8 + ubob_scale + (((tsin[ubob_phase_y & 0x1FF] + 512) * (DISPL_HEIGHT2b - 16 - 32 - ubob_scale - ubob_scale)) >> 10);

    BltMaskBitMapRastPort(bitmap_bob, 0, 0,
            dest_rp, x, y + ubob_vscroll,
            32, 32,
            (ABC|ABNC|ANBC), bitmap_bob_mask->Planes[0]);

    return 1;
}

__inline void setNextUnlimitedBobs(UBYTE *figure_mode)
{
    (*figure_mode)++;
    if (*figure_mode > 5)
        *figure_mode = 0;
    
    ubob_phase_x = 0;
    ubob_phase_y = 0;
    ubob_scale = 0;
}

__inline UBYTE clearPlayfieldLineByLineFromTop(struct RastPort *dest_rp)
{
    UWORD y;

    // printf("clearPlayfieldLineByLineFromTop()\n");

    if (clr_screen_y >= DISPL_HEIGHT2b - 8)
    {
        clr_screen_y = 0;
        return 0;
    }

    SetAPen(dest_rp, 0);

    for (y = 8; y < HEIGHT2b; y += DISPL_HEIGHT2b)
    {
        RectFill(dest_rp, 
            0, y + clr_screen_y - 8, WIDTH2b - 1, y + clr_screen_y - 1);
        BltPattern(dest_rp, (PLANEPTR)&clr_patternData, 
            0, y + clr_screen_y, WIDTH2b - 1, y + clr_screen_y + 7, 
            32);
    }        

    clr_screen_y += 8;
    return 1;
}

__inline UBYTE clearPlayfieldLineByLineFromBottom(struct RastPort *dest_rp)
{
    UWORD y, bottom_y;

    // printf("clearPlayfieldLineByLineFromBottom()\n");

    if (clr_screen_y >= DISPL_HEIGHT2b - 8)
    {
        clr_screen_y = 0;
        return 0;
    }

    SetAPen(dest_rp, 0);
    bottom_y = DISPL_HEIGHT2b - clr_screen_y - 16;

    for (y = 8; y < HEIGHT2b; y += DISPL_HEIGHT2b)
    {
        BltPattern(dest_rp, (PLANEPTR)&clr_patternData_neg, 
            0, y + bottom_y - 8, WIDTH2b - 1, y + bottom_y - 1,
            32);
        RectFill(dest_rp, 
            0, y + bottom_y, WIDTH2b - 1, y + bottom_y + 7);
    }        

    clr_screen_y += 8;
    return 1;
}

/*  
    Viewport 3, 
    text liner
*/
void setTextLinerCopperlist(struct ViewPort *vp)
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

void loadTextWriterFont(void)
{
    bitmap_font = load_array_as_bitmap(font_data, 288 << 1, font_image.Width, font_image.Height, font_image.Depth);
}