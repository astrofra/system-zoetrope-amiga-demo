#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dos/dos.h>
#include <exec/types.h>             /* The Amiga data types file.         */
#include <exec/memory.h>             /* The Amiga data types file.         */
#include <exec/libraries.h>
#include <intuition/intuition.h>    /* Intuition data strucutres, etc.    */
#include <libraries/dos.h>          /* Official return codes defined here */
#include <devices/keyboard.h>

#include <clib/exec_protos.h>       /* Exec function prototypes           */
#include <clib/alib_protos.h>
#include <clib/graphics_protos.h>       /* Exec function prototypes           */
#include <clib/intuition_protos.h>  /* Intuition function prototypes      */

/* Use lowest non-obsolete version that supplies the functions needed. */
#define INTUITION_REV 33L

/* Keyboard device */
struct MsgPort  *KeyMP;         /* Pointer for Message Port */
struct IOStdReq *KeyIO;         /* Pointer for I/O request */
UBYTE *keyMatrix = NULL;
#define KEY_MATRIX_SIZE 16

#define SCR_WIDTH           320
#define SCR_HEIGHT          256
#define SCR_DEPTH			4

PLANEPTR theRaster;
struct RastPort theRP;
struct BitMap theBitMap;
struct Screen *main_screen = NULL;

struct NewScreen theScreen16 =
{
  0, 0, SCR_WIDTH, SCR_HEIGHT, SCR_DEPTH, 0, 1, 0,
  CUSTOMSCREEN | CUSTOMBITMAP | SCREENQUIET, NULL, NULL, NULL, &theBitMap
};

struct Library *IntuitionBase = NULL;
extern struct Library *SysBase;

void open_main_screen(void)
{
	int i;

	InitBitMap(&theBitMap, SCR_DEPTH, SCR_WIDTH, SCR_HEIGHT);

	for (i = 0; i < SCR_DEPTH; i++)
		theBitMap.Planes[i] = AllocRaster(SCR_WIDTH, SCR_HEIGHT);

	InitRastPort(&theRP);
	theRP.BitMap = &theBitMap;
	SetRast(&theRP, 0);

	main_screen = OpenScreen(&theScreen16);
}

void close_main_screen(void)
{
	// int i;
	// for (i = 0; i < SCR_DEPTH; i++)
	// 	if (theBitMap.Planes[i]) FreeRaster(theBitMap.Planes[i], SCR_WIDTH, SCR_HEIGHT);
	if (main_screen)
	{
		CloseScreen(main_screen);
		main_screen = NULL;
	}

	if (IntuitionBase)
	{
		CloseLibrary(IntuitionBase);
		IntuitionBase = NULL;
	}
}

void close_demo(void)
{
	close_main_screen();

	// /*  Close the keyboard device */
	// if (!(CheckIO((struct IORequest *)KeyIO)))
	// 	AbortIO((struct IORequest *)KeyIO);   //  Ask device to abort request, if pending 

	// WaitIO((struct IORequest *)KeyIO);   /* Wait for abort, then clean up */
	// CloseDevice((struct IORequest *)KeyIO);
	// if (keyMatrix) FreeMem(keyMatrix,KEY_MATRIX_SIZE);

	exit(0);
}

int open_keyboard(void)
{
    if (KeyMP=CreatePort(NULL,NULL))
      if (KeyIO=(struct IOStdReq *)CreateExtIO(KeyMP,sizeof(struct IOStdReq)))
        if (OpenDevice( "keyboard.device",NULL,(struct IORequest *)KeyIO,NULL))
        {
          printf("keyboard.device did not open\n");
          return(0);
        }
        else
        if (!(keyMatrix=AllocMem(KEY_MATRIX_SIZE,MEMF_PUBLIC|MEMF_CLEAR)))
        {
          printf("Cannot allocate keyboard buffer\n");
          return(0);
        }
}

void sys_check_abort(void)
{
  KeyIO->io_Command=KBD_READMATRIX;
  KeyIO->io_Data=(APTR)keyMatrix;
  KeyIO->io_Length = SysBase->lib_Version >= 36 ? KEY_MATRIX_SIZE : 13;
  DoIO((struct IORequest *)KeyIO);

  if (keyMatrix[0x45 >> 3] & (0x20))
    close_demo();
}

int main(void)
{
	IntuitionBase = OpenLibrary( "intuition.library",INTUITION_REV );

	open_keyboard();
	open_main_screen();

	printf("Hello World!\n");

	while(TRUE)
	{
		sys_check_abort();
	}

	close_demo();

	return(1);
}