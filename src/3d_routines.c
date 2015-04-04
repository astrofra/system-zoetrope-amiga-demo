/* 
    3D routines. 
*/

#include "3d_routines.h"
#include "cosine_table.h"
#include "screen_size.h"

extern struct GfxBase *GfxBase;

struct  obj_3d o;
short   *verts_tr = NULL;

#define BB_3D_DRAW_OUTLINE    8

/********* 3D Code *********/

void DrawAALine(struct RastPort *dest_rp, short x1, short y1, short x2, short y2)
{
  short xo = 0, yo = 0;
  if (2 * abs(x1 - x2) > abs(y1 - y2))
  {
    xo = 1;
    yo = 0;
  }

  if (abs(x1 - x2) < 2 * abs(y1 - y2))
  {
    xo = 0;
    yo = 1;
  }

  if (xo || yo)
  {
    SetAPen(dest_rp, 1);
    Move(dest_rp, x1 + xo, y1 + yo);
    Draw(dest_rp, x2 + xo, y2 + yo);
    Move(dest_rp, x1 - xo, y1 - yo);
    Draw(dest_rp, x2 - xo, y2 - yo);
  }
}

void Prepare3DVertexList(void)
{  printf("Prepare3DVertexList()\n");
  verts_tr = (short *)AllocMem(sizeof(short) * MAX_VERTICE_COUNT * 3, 0L); } // (short *)malloc(sizeof(short) * MAX_VERTICE_COUNT * 3); }

void Delete3DVertexList(void)
{  
  printf("Delete3DVertexList()\n");
  if (verts_tr != NULL)
  {
    FreeMem(verts_tr, sizeof(short) * MAX_VERTICE_COUNT * 3); // free(verts_tr);
    verts_tr = NULL;
  }
}

short Draw3DMesh(struct RastPort *dest_rp, short rx, short ry, const short y_offset)
{

  short i,tx,ty,
  x1,x2,x3,x4, 
  y1,y2,y3,y4,
  hidden = 0;

  short XC,YC;

  short cs, ss, cc, sc;

  XC = WIDTH2b >> 1;
  YC = (DISPL_HEIGHT2b >> 1) + y_offset;

  /*  
      Transform & project the vertices 
      pre-rotations
  */
  cs = (tcos[rx] * tsin[ry]) >> FIXED_PT_SHIFT;
  ss = (tsin[ry] * tsin[rx]) >> FIXED_PT_SHIFT;
  cc = (tcos[rx] * tcos[ry]) >> FIXED_PT_SHIFT;
  sc = (tsin[rx] * tcos[ry]) >> FIXED_PT_SHIFT;

  for (i = 0; i < o.nverts; ++i)
  {
    /* 
        Rotation on 3 axis of each vertex
    */
    verts_tr[vX(i)] = (o.verts[vX(i)] * tsin[rx] + o.verts[vY(i)] * tcos[rx]) >> FIXED_PT_SHIFT;
    verts_tr[vY(i)] = (o.verts[vX(i)] * cs - o.verts[vY(i)] * ss + o.verts[vZ(i)] * tcos[ry]) >> FIXED_PT_SHIFT;
    verts_tr[vZ(i)] = (o.verts[vX(i)] * cc - o.verts[vY(i)] * sc - o.verts[vZ(i)] * tsin[ry]) >> FIXED_PT_SHIFT;

    /*
      Classic 3D -> 2D projection
    */
    tx = (verts_tr[vX(i)] * o.zoom) / (verts_tr[vZ(i)] + o.distance);
    ty = (verts_tr[vY(i)] * o.zoom) / (verts_tr[vZ(i)] + o.distance);
    verts_tr[vX(i)] = tx;
    verts_tr[vY(i)] = ty;
  }

  for (i = 0; i < o.nfaces; ++i)
  {
    x1 = verts_tr[vX(o.faces[Fc0(i)])];
    y1 = YC + verts_tr[vY(o.faces[Fc0(i)])];

    x2 = verts_tr[vX(o.faces[Fc1(i)])];
    y2 = YC + verts_tr[vY(o.faces[Fc1(i)])];

    x3 = verts_tr[vX(o.faces[Fc2(i)])];
    y3 = YC + verts_tr[vY(o.faces[Fc2(i)])];

    x4 = verts_tr[vX(o.faces[Fc3(i)])];
    y4 = YC + verts_tr[vY(o.faces[Fc3(i)])];

    x1 += XC;
    x2 += XC;
    x3 += XC;
    x4 += XC;

    /* should we draw the face ? */
    hidden = (x3 - x1) * (y2 - y1) - (x2 - x1) * (y3 - y1);

    if (hidden > 0)
    {           
      SetAPen(dest_rp, 2);

      Move(dest_rp, x1, y1);
      Draw(dest_rp, x2, y2);
      Draw(dest_rp, x3, y3);
      Draw(dest_rp, x4, y4);
      Draw(dest_rp, x1, y1);
    }
    else
    {
      if (!o.flag_cull_backfaces)
      {
        SetAPen(dest_rp, 1);

        Move(dest_rp, x1, y1);
        Draw(dest_rp, x2, y2);
        Draw(dest_rp, x3, y3);
        Draw(dest_rp, x4, y4);
        Draw(dest_rp, x1, y1);        
      }
    }
  }

  return 0;
}