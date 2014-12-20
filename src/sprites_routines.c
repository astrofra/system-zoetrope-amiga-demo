#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#include "sprites_routines.h"

extern struct GfxBase *GfxBase;

UWORD chip ball_data[28]=
{
    0x0000, 0x0000,

    0xFFF8, 0x0000,
    0x0200, 0x0000,
    0x877C, 0x0000,
    0x8786, 0x027C,
    0xBFBF, 0x02C6,
    0xEDFF, 0x1AC2,
    0xA57D, 0x1AFE,
    0xBF19, 0x02FE,
    0x8F12, 0x00FC,
    0x04FC, 0x0000,
    0x0809, 0x0000,
    0x3FFE, 0x0000,

    0x0000, 0x0000
};

struct SimpleSprite *my_sprite[MAX_SPRITES];

void initSpriteDisplay(struct RastPort* rast_port)
{
  int i, spr_want, spr_got;

  printf("initSpriteDisplay()\n");

  for(i = 0; i < MAX_SPRITES; i++)
  {
    my_sprite[i] = (struct SimpleSprite *)malloc(sizeof(struct SimpleSprite));
    my_sprite[i]->posctldata = (unsigned short *)&ball_data[0];
    my_sprite[i]->height = 12;
    my_sprite[i]->x = i << 4; 
    my_sprite[i]->y = i << 2;
    // my_sprite[i]->num = i;  
  }

  for(i = 0; i < MAX_SPRITES; i++)
  {
      spr_want = i + 1;
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