#ifndef SPRITES_ROUTINES
#define SPRITES_ROUTINES

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#define MAX_SPRITES 4
#define SPR_H 28

// extern UWORD chip ball_data[28];

extern struct SimpleSprite *my_sprite[MAX_SPRITES];

void initSpriteDisplay(void);
void closeSpriteDisplay(void);

#endif // #ifndef SPRITES_ROUTINES