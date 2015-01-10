#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#include "sprites_routines.h"
#include "ruby_stripe.h"

extern struct GfxBase *GfxBase;

/*
	Sprites
*/
struct SimpleSprite *my_sprite[MAX_SPRITES];

/*
	VSprites
*/
WORD nextline[8];
WORD *lastcolor[8];
struct VSprite head, tail, vsprite[MAX_SPRITES];
BOOL vsprite_on = FALSE;
struct GelsInfo ginfo;

void initSpriteDisplay(void)
{
  int i, j, spr_want, spr_got;

  printf("initSpriteDisplay()\n");

  for(i = 0; i < MAX_SPRITES; i++)
  {
    my_sprite[i] = (struct SimpleSprite *)malloc(sizeof(struct SimpleSprite));
    my_sprite[i]->posctldata = (USHORT *)&ruby_stripe_img[i];
    my_sprite[i]->height = SPR_H;
    my_sprite[i]->x = i << 4; 
    my_sprite[i]->y = i << 2;
    // my_sprite[i]->num = i;  
  }

  for(i = 0; i < MAX_SPRITES; i++)
  {
      spr_want = 7 - i;
      spr_got = GetSprite(my_sprite[i], spr_want);
      printf("Asked for sprite #%d, got sprite #%d\n", spr_want, spr_got);
  }
}

void closeSpriteDisplay(void)
{
  int i;
  for(i = 0; i < MAX_SPRITES; i++)
  {
    FreeSprite(my_sprite[i]->num);
    free(my_sprite[i]);
  }
}

// /*
//   VSprites
// */

void initVSpriteDisplay(struct RastPort* rast_port)
{
	// int i;

	// /* All sprites except the first two may be used to draw */
	// /* the VSprites: ( 11111100 = 0xFC ) */
	// ginfo.sprRsrvd = 0xFC;
	// /* If we do not exclude the first two sprites, the mouse */
	// /* pointer's colours may be affected. */


	// /* Give the GelsInfo structure some memory: */
	// ginfo.nextLine = nextline;
	// ginfo.lastColor = lastcolor;


	// /* Give the Rastport a pointer to the GelsInfo structure: */
	// rast_port->GelsInfo = &ginfo;


	// /* Give the GelsInfo structure to the system: */
	// InitGels( &head, &tail, &ginfo );

	// for(i = 0; i < MAX_SPRITES; i++)
	// {
	// 	/* Set the VSprite's colours: */
	// 	// colour_table[i][0] = i; /* Blue */
	// 	// colour_table[i][1] = i << 4; /* Green */
	// 	// colour_table[i][2] = i << 8; /* Red */

	// 	vsprite[i].Flags = VSPRITE; /* It is a VSprite. */
	// 	vsprite[i].X = 0; /* X position. */
	// 	vsprite[i].Y = 0; /* Y position. */
	// 	vsprite[i].Height = SPR_H; /* 16 lines tall. */
	// 	vsprite[i].Width = 2; /* 2 words wide. */
	// 	vsprite[i].Depth = 2; /* 2 bitpl, 4 colours. */

	// 	/* Pointer to the sprite data: */
	// 	vsprite[i].ImageData = (USHORT *)&ruby_stripe_img[i]; // vsprite_data;

	// 	/* Pointer to the colour table: */
	// 	// vsprite[i].SprColors = colour_table[ i ];


	// 	/* 8. Add the VSprites to the VSprite list: */
	// 	AddVSprite(&vsprite[i], rast_port);
	// }


	// /* The VSprites are in the list. */
	// vsprite_on = TRUE;
}

void closeVSpriteDisplay(void)
{
	if( vsprite_on )
		RemVSprite( &vsprite );

	vsprite_on = FALSE;
}