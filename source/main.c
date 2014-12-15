/* Example 4                                                            */
/* This example demonstrates how to open two different ViewPorts on the */
/* same display. The first ViewPort is in low resolution and use 32     */
/* colours, while the second ViewPort is in high resolution and only    */
/* use 2 colours.                                                       */

#include "includes.prl"
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>

/*
Custom routines
*/
#include "bitmap_routines.h"

/*
Graphic assets
*/
#include "mandarine_logo.h"


/* ViewPort 1 */
#define WIDTH1   320 /* 320 pixels wide.                              */
#define HEIGHT1  80 /* 150 lines high.                               */ 
#define DEPTH1     5 /* 5 BitPlanes should be used, gives 32 colours. */
#define COLOURS1  32 /* 2^5 = 32                                      */

/* ViewPort 2 */
#define WIDTH2   320 /* 640 pixels wide.                             */
#define HEIGHT2   250-80 /* 45 lines high.                               */
#define DEPTH2     3 /* 1 BitPlanes should be used, gives 2 colours. */
#define COLOURS2   8 /* 2^1 = 2                                      */


struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;


struct View my_view;
struct View *my_old_view;


/* ViewPort 1 */
struct ViewPort view_port1;
struct RasInfo ras_info1;
struct BitMap bit_map1;
struct RastPort rast_port1;
UWORD color_table1[] =
{
	0x000, 0xFFF, 0xDDD, 0xBBB, 0x999, 0x777, 0x555, 0x333,
	0xF00, 0xD00, 0xB00, 0x900, 0x700, 0x500, 0x300, 0x100,
	0x0F0, 0x0D0, 0x0B0, 0x090, 0x070, 0x050, 0x030, 0x010,
	0x00F, 0x00D, 0x00B, 0x009, 0x007, 0x005, 0x003, 0x001
};


/* ViewPort 2 */
struct ViewPort view_port2;
struct RasInfo ras_info2;
struct BitMap bit_map2;
struct RastPort rast_port2;
UWORD color_table2[] = { 0x000, 0xFFF, 0xFFF, 0xFFF, 0xFFF, 0xFFF, 0xFFF, 0xFFF };

void drawMandarineLogo(struct BitMap *dest_bitmap, USHORT offset_y, USHORT clip_y)
{
	/*
	Logo
	*/
	struct  BitMap *bitmap_logo;
	// if (bitmap_logo == NULL)
	bitmap_logo = load_array_as_bitmap(mandarine_logoData, 8000 << 1, mandarine_logo.Width - 8, mandarine_logo.Height, mandarine_logo.Depth);
	BLIT_BITMAP_S(bitmap_logo, dest_bitmap, mandarine_logo.Width, mandarine_logo.Height, 0, 0);
}

void clean_up(STRPTR message);

void main()
{
	UWORD *pointer;
	int loop;

	/* Open the Intuition library: */
	IntuitionBase = (struct IntuitionBase *)
	OpenLibrary( "intuition.library", 0 );
	if( !IntuitionBase )
		clean_up( "Could NOT open the Intuition library!" );

	/* Open the Graphics library: */
	GfxBase = (struct GfxBase *)
	OpenLibrary( "graphics.library", 0 );
	if( !GfxBase )
		clean_up( "Could NOT open the Graphics library!" );

	/* Save the current View, so we can restore it later: */
	my_old_view = GfxBase->ActiView;

	/* 1. Prepare the View structure, and give it a pointer to */
	/*    the first ViewPort:                                  */
	InitView( &my_view );
	my_view.ViewPort = &view_port1;

	/* 2. Prepare the ViewPort structures, and set some important values: */

	/* ViewPort 1 */
	InitVPort( &view_port1 );
	view_port1.DWidth = WIDTH1;      /* Set the width.                */
	view_port1.DHeight = HEIGHT1;    /* Set the height.               */
	view_port1.DxOffset = 0;         /* X position.                   */
	view_port1.DyOffset = 0;         /* Y position.                   */
	view_port1.RasInfo = &ras_info1; /* Give it a pointer to RasInfo. */
	view_port1.Modes = NULL;         /* Low resolution.               */
	view_port1.Next = &view_port2;   /* Pointer to next ViewPort.     */

	/* ViewPort 2 */
	InitVPort( &view_port2 );
	view_port2.DWidth = WIDTH2;      /* Set the width.                */
	view_port2.DHeight = HEIGHT2;    /* Set the height.               */
	view_port2.DxOffset = 0;         /* X position.                   */
	view_port2.DyOffset = HEIGHT1+5; /* Y position (5 lines under).   */
	view_port2.RasInfo = &ras_info2; /* Give it a pointer to RasInfo. */
	view_port2.Modes = NULL;        /* High resolution.              */
	view_port2.Next = NULL;          /* Last ViewPort in the list.    */

	/* 3. Get a colour map, link it to the ViewPort, and prepare it: */

	/* ViewPort 1 */
	view_port1.ColorMap = (struct ColorMap *) GetColorMap( COLOURS1 );
	if( view_port1.ColorMap == NULL )
		clean_up( "Could NOT get a ColorMap!" );
	/* Get a pointer to the colour map: */
	pointer = (UWORD *) view_port1.ColorMap->ColorTable;
	/* Set the colours: */
	for( loop = 0; loop < COLOURS1; loop++ )
		*pointer++ = mandarine_logoPaletteRGB4[ loop ];

	/* ViewPort 2 */
	view_port2.ColorMap = (struct ColorMap *) GetColorMap( COLOURS2 );
	if( view_port2.ColorMap == NULL )
		clean_up( "Could NOT get a ColorMap!" );
	/* Get a pointer to the colour map: */
	pointer = (UWORD *) view_port2.ColorMap->ColorTable;
	/* Set the colours: */
	for( loop = 0; loop < COLOURS2; loop++ )
		*pointer++ = color_table2[ loop ];



	/* 4. Prepare the BitMap: */

	/* ViewPort 1 */
	InitBitMap( &bit_map1, DEPTH1, WIDTH1, HEIGHT1 );
	/* Allocate memory for the Raster: */ 
	for( loop = 0; loop < DEPTH1; loop++ )
	{
		bit_map1.Planes[ loop ] = (PLANEPTR) AllocRaster( WIDTH1, HEIGHT1 );
		if( bit_map1.Planes[ loop ] == NULL )
			clean_up( "Could NOT allocate enough memory for the raster!" );
	/* Clear the display memory with help of the Blitter: */
		BltClear( bit_map1.Planes[ loop ], RASSIZE( WIDTH1, HEIGHT1 ), 0 );
	}

	/* ViewPort 2 */
	InitBitMap( &bit_map2, DEPTH2, WIDTH2, HEIGHT2 );
	/* Allocate memory for the Raster: */ 
	for( loop = 0; loop < DEPTH2; loop++ )
	{
		bit_map2.Planes[ loop ] = (PLANEPTR) AllocRaster( WIDTH2, HEIGHT2 );
		if( bit_map2.Planes[ loop ] == NULL )
			clean_up( "Could NOT allocate enough memory for the raster!" );
		/* Clear the display memory with help of the Blitter: */
		BltClear( bit_map2.Planes[ loop ], RASSIZE( WIDTH2, HEIGHT2 ), 0 );
	}



	/* 5. Prepare the RasInfo structure: */

	/* ViewPort 1 */
	ras_info1.BitMap = &bit_map1; /* Pointer to the BitMap structure.  */
	ras_info1.RxOffset = 0;       /* The top left corner of the Raster */
	ras_info1.RyOffset = 0;       /* should be at the top left corner  */
	              /* of the display.                   */
	ras_info1.Next = NULL;        /* Single playfield - only one       */
	              /* RasInfo structure is necessary.   */

	/* ViewPort 2 */
	ras_info2.BitMap = &bit_map2; /* Pointer to the BitMap structure.  */
	ras_info2.RxOffset = 0;       /* The top left corner of the Raster */
	ras_info2.RyOffset = 0;       /* should be at the top left corner  */
	              /* of the display.                   */
	ras_info2.Next = NULL;        /* Single playfield - only one       */
	              /* RasInfo structure is necessary.   */



	/* 6. Create the display: */
	MakeVPort( &my_view, &view_port1 ); /* Prepare ViewPort 1 */
	MakeVPort( &my_view, &view_port2 ); /* Prepare ViewPort 2 */
	MrgCop( &my_view );



	/* 7. Prepare the RastPort, and give it a pointer to the BitMap. */

	/* ViewPort 1 */
	InitRastPort( &rast_port1 );
	rast_port1.BitMap = &bit_map1;

	/* ViewPort 2 */
	InitRastPort( &rast_port2 );
	rast_port2.BitMap = &bit_map2;



	/* 8. Show the new View: */
	LoadView( &my_view );

	drawMandarineLogo(&bit_map1, 0, mandarine_logo.Height);

	/* Set the draw mode to JAM1. FgPen's colour will be used. */
	SetDrMd( &rast_port1, JAM1 );
	SetDrMd( &rast_port2, JAM1 );

	/* Set FgPen's colour to 1 (white). */
	SetAPen( &rast_port2, 1 );
	/* Draw some pixels in the second ViewPort: */
	for( loop = 0; loop < 500; loop++ )
		WritePixel( &rast_port2, rand() % WIDTH2, rand() % HEIGHT2 );

	/* Print some text into the second ViewPort: */
	Move( &rast_port2, 0, 10 );
	Text( &rast_port2, "This text is written on a single high resolution BitMap. The ViewPort above use ", 80 );
	Move( &rast_port2, 0, 20 );
	Text( &rast_port2, "a 32-colour low resolution BitMap.                                              ", 80 );

	/* Draw 10000 pixels in seven different colours, randomly. */ 
	for( loop = 0; loop < 1000; loop++ )
	{
		WaitTOF();
		/* Set FgPen's colour (1-31, 0 used for the the background). */
		SetAPen( &rast_port1, rand() % (COLOURS1-1) + 1 );
		/* Write a pixel somewere on the display: */
		WritePixel( &rast_port1, rand() % WIDTH1, rand() % HEIGHT1 );
	}



	/* 9. Restore the old View: */
	LoadView( my_old_view );


	/* Free all allocated resources and leave. */
	clean_up( "THE END" );
}


/* Returns all allocated resources: */
void clean_up(STRPTR message)
{
	int loop;

	/* Free automatically allocated display structures: */
	FreeVPortCopLists( &view_port1 );
	FreeVPortCopLists( &view_port2 );
	FreeCprList( my_view.LOFCprList );

	/* Deallocate the display memory, BitPlane for BitPlane: */
	for( loop = 0; loop < DEPTH1; loop++ )
		if( bit_map1.Planes[ loop ] )
			FreeRaster( bit_map1.Planes[ loop ], WIDTH1, HEIGHT1 );
	for( loop = 0; loop < DEPTH2; loop++ )
		if( bit_map2.Planes[ loop ] )
			FreeRaster( bit_map2.Planes[ loop ], WIDTH2, HEIGHT2 );

	/* Deallocate the ColorMap: */
	if( view_port1.ColorMap ) FreeColorMap( view_port1.ColorMap );
	if( view_port2.ColorMap ) FreeColorMap( view_port2.ColorMap );

// /* Close the Graphics library: */
// if( GfxBase ) CloseLibrary( GfxBase );

//  Close the Intuition library: 
// if( IntuitionBase ) CloseLibrary( IntuitionBase );

	/* Print the message and leave: */
	printf( "%s\n", message ); 
	exit(0);
}
