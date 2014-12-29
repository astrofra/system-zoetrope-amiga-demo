#ifndef SCREEN_SIZE
#define SCREEN_SIZE

/* ViewPort 1 */
#define WIDTH1   380 /* 320 pixels wide.                              */
#define DISPL_WIDTH1   320 /* 320 pixels wide.                              */
#define HEIGHT1  80 /* 150 lines high.                               */ 
#define DEPTH1     4 /* 5 BitPlanes should be used, gives 32 colours. */
#define COLOURS1  (2 << DEPTH1)

/* ViewPort 2 */
#define ANIM_STRIPE 10
#define WIDTH2   320 /* 640 pixels wide.                             */
#define DISPL_WIDTH2   (320 - 16)
#define DISPL_HEIGHT2   150
#define HEIGHT2 (DISPL_HEIGHT2 * ANIM_STRIPE)                        
#define DEPTH2     1 /* 1 BitPlanes should be used, gives 2 colours. */
#define COLOURS2   (2 << DEPTH2)

/* ViewPort 3 */
#define WIDTH3   320 /* 320 pixels wide.                              */
#define HEIGHT3  16 /* lines high.                               */ 
#define DEPTH3     1 /* 5 BitPlanes should be used, gives 32 colours. */
#define COLOURS3  (2 << DEPTH3)

#endif // #ifndef SCREEN_SIZE