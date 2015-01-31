#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <hardware/custom.h>

#include "board.h"
#include "screen_size.h"
#include "bitmap_routines.h"
#include "cosine_table.h"
#include "mandarine_logo.h"
#include "checkerboard_strip.h"
#include "bob_bitmaps.h"
#include "buddha_bitmaps.h"
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
extern struct BitMap *bitmap_buddha;
extern struct BitMap *bitmap_zzz;

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
struct UCopList *copper;

UWORD chip blank_pointer[4]=
{
    0x0000, 0x0000,
    0x0000, 0x0000
};

UWORD mixRGB4Colors(UWORD A, UWORD B, UBYTE n)
{
    UWORD r,g,b;

    /*
        Blends A into B, n times
    */
    while(n--)
    {
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

        B = (UWORD)((r << 8) | (g << 4) | b);
    }

    return B;
}

/*
    Preaload (Buddha)
*/
void loadBuddhaBitmaps(void)
{
    bitmap_buddha = load_array_as_bitmap(buddhaData, 192 << 1, buddha.Width, buddha.Height, buddha.Depth);
    bitmap_zzz = load_array_as_bitmap(buddha_zzData, 48 << 1, buddha_zz.Width, buddha_zz.Height, buddha_zz.Depth);
}

void drawBuddha(struct RastPort *dest_rp, struct BitMap *dest_bitmap, UWORD phase)
{
    UWORD x, y, offset_y;
    offset_y = 8 + ((tcos[phase & 0x1FF] + 512) * 8) >> 10;
    x = (DISPL_WIDTH1 - buddha_zz.Width) >> 1;
    y = HEIGHT1 - buddha.Height - buddha_zz.Height - 12 + offset_y;
    SetAPen(dest_rp, 0);
    RectFill(dest_rp, 
       x, y - 1, x + buddha_zz.Width - 1, y + buddha_zz.Height + 2);    
    BLIT_BITMAP_S(bitmap_zzz, dest_bitmap, buddha_zz.Width, buddha_zz.Height, x, y); 
    BLIT_BITMAP_S(bitmap_buddha, dest_bitmap, buddha.Width, buddha.Height, (DISPL_WIDTH1 - buddha.Width) >> 1, HEIGHT1 - buddha.Height - 4); 
}


/*	
	Viewport 1, 
	Mandarine Logo 
*/

/*	Draws the Mandarine Logo */
void drawMandarineLogo(struct BitMap *dest_bitmap, UWORD offset_y)
{
	bitmap_logo = load_array_as_bitmap(mandarine_logoData, 6400 << 1, mandarine_logo.Width, mandarine_logo.Height, mandarine_logo.Depth);
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
    UWORD i, j, k, p, o;

    bitmap_checkerboard = load_array_as_bitmap(checkerboard_Data, 40000 << 1, checkerboard.Width, checkerboard.Height, checkerboard.Depth);

    for(i = 0; i < ANIM_STRIPE; i++)
        BltBitMap(bitmap_checkerboard, 0, 100 * i,
            dest_bitmap, 0, DISPL_HEIGHT2 * i + (DISPL_HEIGHT2 - (100)),
            checkerboard.Width, 100,
            0xC0, 0xFF, NULL);

    // for (k = 0; k < 5 * 8; k += 8)
    //     for(j = 0; j  < HEIGHT2; j++)
    //         for(i = 0; i < k; i++)
    //         {
    //             p = ReadPixel(dest_rp, i, j);
    //             p = checkerboard_pal_dec[p];
    //             SetAPen(dest_rp, p);
    //             WritePixel(dest_rp, i, j);

    //             p = ReadPixel(dest_rp, WIDTH2 - i - 1, j);
    //             p = checkerboard_pal_dec[p];
    //             SetAPen(dest_rp, p);
    //             WritePixel(dest_rp, WIDTH2 - i - 1, j);
    //         }
}

void setCheckerboardCopperlist(struct ViewPort *vp)
{
    UWORD i, c;

    copper = (struct UCopList *)
    AllocMem( sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CHIP|MEMF_CLEAR );

    CINIT(copper, DISPL_HEIGHT2 * 10);

    for(i = 0; i < DISPL_HEIGHT2; i++)
    {
        CWAIT(copper, i, 0);

        if (i == 0) {
            CMOVE(copper, *((UWORD *)SPR0PTH_ADDR), (LONG)&blank_pointer);
            CMOVE(copper, *((UWORD *)SPR0PTL_ADDR), (LONG)&blank_pointer);
        }

        CMOVE(copper, custom.color[0], vcopperlist_checker_1[i + 5]);
        for (c = 1; c < 8; c++)
            CMOVE(copper, custom.color[c], mixRGB4Colors(vcopperlist_checker_0[i + 5], vcopperlist_checker_1[i + 5], (checkerboard_PaletteRGB4[c] & 0xF) / 5));
    }

    CEND(copper);

    vp->UCopIns = copper;
}

__inline void updateCheckerboard(void)
{
    checkerboard_scroll_offset += DISPL_HEIGHT2;
    if (checkerboard_scroll_offset >= HEIGHT2)
        checkerboard_scroll_offset = 0;

    ubob_hscroll_phase += 3;
    ubob_hscroll_phase &= 0x1FF;

    view_port2.RasInfo->RxOffset = 0;
    view_port2.RasInfo->RyOffset = checkerboard_scroll_offset;
    view_port2.RasInfo->Next->RxOffset = (WIDTH2b - DISPL_WIDTH2b) + ((tsin[ubob_hscroll_phase] + 512) * (WIDTH2b - DISPL_WIDTH2b)) >> 10;
    view_port2.RasInfo->Next->RyOffset = ubob_vscroll;

    ScrollVPort(&view_port2);

    ubob_vscroll += DISPL_HEIGHT2b;
    if (ubob_vscroll >= HEIGHT2b)
        ubob_vscroll = 0;    
}

void loadBobBitmaps(void)
{   
    bitmap_bob = load_array_as_bitmap(bob_32Data, 192 << 1, bob_32.Width, bob_32.Height, bob_32.Depth);
    bitmap_bob_mask = load_array_as_bitmap(bob_32_maskData, 64 << 1, bob_32_mask.Width, bob_32_mask.Height, bob_32_mask.Depth);
}


__inline UBYTE drawUnlimitedBobs(struct RastPort *dest_rp, UBYTE *figure_mode) // struct BitMap* dest_bitmap)
{
    UWORD x, y;

    switch(*figure_mode)
    {
        case 0:
            ubob_phase_x += 1;
            ubob_phase_y += 2;
            break;

        case 1:
            ubob_phase_x += 2;
            ubob_phase_y += 1;
            break;

        case 2:
            ubob_phase_x += 3;
            ubob_phase_y += 1;
            break;

        case 3:
            ubob_phase_x += 1;
            ubob_phase_y += 5;
            break;

        case 4:
            ubob_phase_x++;
            ubob_phase_y++;
            break;                         
    }

    if (ubob_phase_x > COSINE_TABLE_LEN && ubob_phase_y > COSINE_TABLE_LEN)
    {
        (*figure_mode)++;
        if (*figure_mode > 4)
            *figure_mode = 0;
        ubob_phase_x = 0;
        ubob_phase_y = 0;
        return 0;
    }    

    x = ((WIDTH2b - DISPL_WIDTH2b) >> 1) + 24 + (((tcos[ubob_phase_x & 0x1FF] + 512) * (DISPL_WIDTH2b - 8 - 64)) >> 10);
    y = ubob_vscroll + 8 + (((tsin[ubob_phase_y & 0x1FF] + 512) * (DISPL_HEIGHT2b - 16 - 32)) >> 10);

    BltMaskBitMapRastPort(bitmap_bob, 0,0,
            dest_rp, x, y,
            bob_32.Width, bob_32.Height,
            (ABC|ABNC|ANBC), bitmap_bob_mask->Planes[0]);

    return 1;
}

__inline UBYTE clearPlayfieldLineByLineFromTop(struct RastPort *dest_rp)
{
    UWORD y;

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
    bitmap_font = load_array_as_bitmap(font_data, 320 << 1, font_image.Width, font_image.Height, font_image.Depth);
}