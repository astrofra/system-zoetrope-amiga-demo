#ifndef SCREEN_SIZE
#define SCREEN_SIZE

#define DEFAULT_DISP_WIDTH 320
/* ViewPort 1 */
#define WIDTH1   384
#define DISPL_WIDTH1   DEFAULT_DISP_WIDTH
#define HEIGHT1  80
#define DEPTH1     3
#define COLOURS1  (1 << DEPTH1)

/* ViewPort 2 */
#define ANIM_STRIPE 10
#define WIDTH2   320
#define DISPL_WIDTH2   DEFAULT_DISP_WIDTH
#define DISPL_HEIGHT2   150
#define HEIGHT2 (DISPL_HEIGHT2 * ANIM_STRIPE)                        
#define DEPTH2     2
#define COLOURS2   (1 << DEPTH2)

/* ViewPort 2b */
#define ANIM_STRIPEb 1
#define WIDTH2b   384
#define DISPL_WIDTH2b   DEFAULT_DISP_WIDTH
#define DISPL_HEIGHT2b   150
#define HEIGHT2b (DISPL_HEIGHT2b * ANIM_STRIPEb)                        
#define DEPTH2b     2
#define COLOURS2b   (1 << DEPTH2b)

/* ViewPort 3 */
#define WIDTH3   DEFAULT_DISP_WIDTH
#define DISPL_HEIGHT3   12
#define HEIGHT3  (DISPL_HEIGHT3 << 1)
#define DEPTH3     1
#define COLOURS3  (1 << DEPTH3)

#define COLOUR_PURPLE_DARK (ULONG)0x2a1221
#define COLOUR_PURPLE (ULONG)0x4a2251
#define COLOUR_PURPLE_LIGHT (ULONG)0x5F004B

#endif // #ifndef SCREEN_SIZE