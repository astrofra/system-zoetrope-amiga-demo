/*  
    3D routines headers. 
*/

#ifndef THREED_ROUTINES
#define THREED_ROUTINES

#include "includes.prl"

#define VERT_COUNT(n) (sizeof(n)/sizeof(n[0])/3)
#define FACE_COUNT(n) (sizeof(n)/sizeof(n[0])/4)
#define MAX_VERTICE_COUNT 2048

#define PREPARE_3D_MESH(OBJECT_HANDLER, OBJECT_VERT_LIST, OBJECT_FACE_LIST, ZOOM_LEVEL, Z_DISTANCE, FLAG_CULL) \
                  OBJECT_HANDLER.verts = (short const *)&OBJECT_VERT_LIST; \
                  OBJECT_HANDLER.nverts = VERT_COUNT(OBJECT_VERT_LIST); \
                  OBJECT_HANDLER.faces = (short const *)&OBJECT_FACE_LIST; \
                  OBJECT_HANDLER.nfaces = FACE_COUNT(OBJECT_FACE_LIST); \
                  OBJECT_HANDLER.zoom = ZOOM_LEVEL; \
                  OBJECT_HANDLER.distance = Z_DISTANCE; \
                  OBJECT_HANDLER.flag_cull_backfaces = FLAG_CULL;

#define vX(I) (3 * I + 0)
#define vY(I) (3 * I + 1)
#define vZ(I) (3 * I + 2)

#define Fc0(I) (4 * I + 0)
#define Fc1(I) (4 * I + 1)
#define Fc2(I) (4 * I + 2)
#define Fc3(I) (4 * I + 3)

#define FIXED_PT_PRE  512
#define FIXED_PT_SHIFT 9

#define QMAX(A, B)    (A>B?A:B)
#define QMIN(A, B)    (A<B?A:B)

struct obj_3d
{
    short const* verts;
    short nverts;
    short const* faces;
    short nfaces;
    short zoom;
    short distance;
    short flag_cull_backfaces;
};

void DrawAALine(struct RastPort *dest_rp, short x1, short y1, short x2, short y2);

void Prepare3DVertexList(void);

void Delete3DVertexList(void);

short Draw3DMesh(struct RastPort *dest_rp, short rx, short ry, const short y_offset);

#endif