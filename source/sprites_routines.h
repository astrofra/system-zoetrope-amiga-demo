#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

#define MAXVSPRITES 15

extern WORD nextline[8];
extern WORD *lastcolor[8];

extern struct VSprite head, tail, vsprite[MAXVSPRITES];

void initSpriteDisplay(struct RastPort* rast_port);