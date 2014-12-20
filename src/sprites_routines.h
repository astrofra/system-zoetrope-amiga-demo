#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#define MAX_SPRITES 8

extern UWORD chip ball_data[28];

extern struct SimpleSprite *my_sprite[MAX_SPRITES];

void initSpriteDisplay(struct RastPort* rast_port);

void closeSpriteDisplay(void);