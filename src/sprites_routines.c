#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#include "sprites_routines.h"
#include "ruby_stripe.h"

extern struct GfxBase *GfxBase;

struct SimpleSprite *my_sprite[MAX_SPRITES];
#define SPR_H 28

void initSpriteDisplay(struct RastPort* rast_port)
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
      spr_want = i + 1;
      spr_got = GetSprite(my_sprite[i], spr_want);
      // printf("Asked for sprite #%d, got sprite #%d\n", spr_want, spr_got);
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