#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <hardware/custom.h>

// #include "board.h"
// #include "screen_size.h"
// #include "bitmap_routines.h"
// #include "cosine_table.h"
// #include "mandarine_logo.h"
// #include "checkerboard_strip.h"
// #include "bob_bitmaps.h"
// #include "buddha_bitmaps.h"
// #include "vert_copper_palettes.h"
// #include "font_desc.h"
// #include "font_bitmap.h"

extern struct GfxBase *GfxBase;
extern struct ViewPort view_port1;
extern struct ViewPort view_port2;
extern struct ViewPort view_port3;

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

        A = (UWORD)((r << 8) | (g << 4) | b);
    }

    return A;
}

ULONG RGB4toRGB8(UWORD A)
{
    ULONG r,g,b;
    r = ((ULONG)(A & 0x0f00)) << 12;
    g = (A & 0x00f0) << 8;
    b = (A & 0x000f) << 4;

    return (ULONG)(r|g|b);
}

UWORD RGB8toRGB4(ULONG A)
{
    UWORD r,g,b;
    r = (A & 0xF00000) >> 12; // ((ULONG)(A & 0x0f00)) << 12;
    g = (A & 0x00F000) >> 8;
    b = (A & 0x00F0) >> 4;

    return (UWORD)(r|g|b);
}

ULONG mixRGB8Colors(ULONG A, ULONG B, USHORT n)
{
    ULONG   r,g,b,
            x,y,z;

    if (n == 0)
        return A;

    if (n >= 255)
        return B;

    x = (B & 0xff0000) >> 16;
    y = (B & 0x00ff00) >> 8;
    z = B & 0x000ff;

    x *= n;
    y *= n;
    z *= n;

    n = 255 - n;

    r = (A & 0xff0000) >> 16;
    g = (A & 0x00ff00) >> 8;
    b = A & 0x0000ff;

    r *= n;
    g *= n;
    b *= n;

    r += x;
    g += y;
    b += z;

    r >>= 8;
    g >>= 8;
    b >>= 8;

    if (r > 0xff) r = 0xff;
    if (g > 0xff) g = 0xff;
    if (b > 0xff) b = 0xff;

    r = r & 0xff;
    g = g & 0xff;
    b = b & 0xff;

    return (r << 16) | (g << 8) | b;
}

void fadeRGB4Palette(struct ViewPort *vp, UWORD *pal, UWORD pal_size, UWORD fade)
{
    UBYTE i;
    UWORD col;

    for(i = 0; i < pal_size; i++)
    {
        col = mixRGB4Colors(pal[i], 0x000, fade);
        SetRGB4(vp, i, (col & 0x0f00) >> 8, (col & 0x00f0) >> 4, col & 0x000f);
    }
}