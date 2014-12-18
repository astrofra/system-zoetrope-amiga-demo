#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#include "sprites_routines.h"

UWORD chip vsprite_data[]=
{
  0x0180, 0x0000,
  0x03C0, 0x0000,
  0x07E0, 0x0000,
  0x0FF0, 0x0000,
  0x1FF8, 0x0000,
  0x3FFC, 0x0000,
  0x7FFE, 0x0000,
  0x0000, 0xFFFF,
  0x0000, 0xFFFF,
  0x7FFE, 0x7FFE,
  0x3FFC, 0x3FFC,
  0x1FF8, 0x1FF8,
  0x0FF0, 0x0FF0,
  0x07E0, 0x07E0,
  0x03C0, 0x03C0,
  0x0180, 0x0180,
};

extern struct GfxBase *GfxBase;

WORD nextline[8];
WORD *lastcolor[8];

/* 2. Declare three VSprite structures. One will be used, */
/*    the other two are "dummies":                        */
struct VSprite head, tail, vsprite[MAXVSPRITES];


/* 3. Declare the VSprites' colour tables:     */
WORD colour_table[MAXVSPRITES][3];


/* 4. Declare a GelsInfo structure: */
struct GelsInfo ginfo;


/* This boolean variable will tell us if the VSprites are */
/* in the list or not:                                    */
BOOL vsprite_on = FALSE;

void initSpriteDisplay(struct RastPort* rast_port)
{
  int i;

  /* All sprites except the first two may be used to draw */
  /* the VSprites: ( 11111100 = 0xFC )                    */
  ginfo.sprRsrvd = 0xFC;
  /* If we do not exclude the first two sprites, the mouse */
  /* pointer's colours may be affected.                    */


  /* Give the GelsInfo structure some memory: */
  ginfo.nextLine = nextline;
  ginfo.lastColor = lastcolor;


  /* Give the Rastport a pointer to the GelsInfo structure: */
  rast_port->GelsInfo = &ginfo;

  
  /* Give the GelsInfo structure to the system: */
  InitGels( &head, &tail, &ginfo );

  for(i = 0; i < MAXVSPRITES; i++)
  {
    /* Set the VSprite's colours: */
    colour_table[i][0] = i;      /* Blue  */
    colour_table[i][1] = i << 4; /* Green */
    colour_table[i][2] = i << 8; /* Red   */

    vsprite[i].Flags = VSPRITE;    /* It is a VSprite.    */
    vsprite[i].X = 10 + 20 * i; /* X position.         */
    vsprite[i].Y = 10 + 20 * i; /* Y position.         */
    vsprite[i].Height = 16;        /* 16 lines tall.      */
    vsprite[i].Width = 2;          /* 2 words wide.       */
    vsprite[i].Depth = 2;          /* 2 bitpl, 4 colours. */

    /* Pointer to the sprite data: */
    vsprite[i].ImageData = vsprite_data;

    /* Pointer to the colour table: */
    vsprite[i].SprColors = colour_table[ i ];


    /* 8. Add the VSprites to the VSprite list: */
    AddVSprite(&vsprite[i], rast_port);
  }
  
  
  /* The VSprites are in the list. */
  vsprite_on = TRUE;
}