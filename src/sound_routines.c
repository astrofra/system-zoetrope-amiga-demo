/*   EasySound.c

     EEEEE  AAA   SSS Y   Y       SSS   OOO  U   U N   N DDD
     E     A   A S     Y Y       S     O   O U   U NN  N D  D
     EEEE  AAAAA  SSS   Y   ===   SSS  O   O U   U N N N D   D
     E     A   A     S  Y            S O   O U   U N  NN D  D
     EEEEE A   A SSSS   Y        SSSS   OOO   UUU  N   N DDD


     EASY-SOUND   V2.00   1990-09-23   ANDERS BJERIN

     AMIGA C CLUB (ACC)
     Anders Bjerin
		 Tulevagen 22
		 181 41  LIDINGO
		 SWEDEN
*/



/* Include some important header files: */
#include "includes.prl"
#include <exec/types.h>
#include <exec/memory.h>
#include <devices/audio.h> 
#include <stdio.h>
#include <string.h>

#include "sound_routines.h"


#define CLOCK_CONSTANT 3579545
#define MUSIC_PRIORITY 0


/* Structure containing all necessary information about the sound: */
struct SoundInfo
{
  BYTE *SoundBuffer;   /* WaveForm Buffers */
  UWORD RecordRate;    /* Record Rate */
  ULONG FileLength;    /* WaveForm Lengths */
};


/* An IOAudio pointer to each sound channel: */
struct IOAudio *IOA[ 4 ] = { NULL, NULL, NULL, NULL };


typedef LONG Fixed;
typedef struct
{
  ULONG  oneShotHiSamples;  /* #samples in the high octave 1-shot part */
  ULONG  repeatHiSamples;   /* #samples in the high octave repeat part */
  ULONG  samplesPerHiCycle; /* #samples/cycle in high octave, else 0   */
  UWORD  samplesPerSec;     /* Data sampling rate */
  UBYTE  ctOctave;          /* Number of octaves of waveforms */
  UBYTE  sCompression;      /* Data compression technique used */
  Fixed  volume;            /* Playback volume from 0 to 0x10000 */
} Voice8Header;


/* Declare the functions we are going to use: */
struct SoundInfo *PrepareSound(STRPTR file);
BOOL PlaySound(struct SoundInfo *info, UWORD volume, UBYTE channel, WORD delta_rate, UWORD repeat);
void StopSound(UBYTE channel);
void RemoveSound();

BOOL PrepareIOA( UWORD period,UWORD volume,UWORD cycles, UBYTE channel, struct SoundInfo *info);
UWORD LoadSound( STRPTR filename, struct SoundInfo *info );
ULONG GetSize(STRPTR filename);
ULONG SizeIFF( STRPTR filename );
UWORD ReadIFF( STRPTR filename, struct SoundInfo *info );
BOOL MoveTo( STRPTR check_string, FILE *file_ptr );



/* PrepareSound()                                                       */
/* PrepareSound() loads a sampled sound file (IFF or FutureSound) into  */
/* a buffer that is automatically allocated. All information about the  */
/* sound (record rate, length, buffersize etc) is put into an SoundInfo */
/* structure. If PrepareSound() has successfully prepared the sound it  */
/* returns a pointer to a SoundInfo structure, otherwise it returns     */
/* NULL.                                                                */
/*                                                                      */
/* Synopsis: pointer = PrepareSound( filename );                        */
/* pointer:  (CPTR) Actually a pointer to a SoundInfo structure, but    */
/*           since we do not want to confuse the user, we simply use a  */
/*           normal memory pointer.                                     */
/* filename: (STRPTR) Pointer to a string containing the name of the    */
/*           sound file. For example "df0:Explosion.snd".               */

struct SoundInfo *PrepareSound(STRPTR file)
{
  /* Declare a pointer to a SoundInfo structure: */
  struct SoundInfo *info;

  /* Allocate memory for a SoundInfo structure: (The memory can be of */
  /* any type, and should be cleared.                                 */
  info = (struct SoundInfo *) AllocMem( sizeof( struct SoundInfo ),
                                        MEMF_PUBLIC|MEMF_CLEAR );


  if( info )
  {
    /* The memory have been successfully allocated. */ 
    
    /* Get the size of the file, and store it in the SoundInfo struct.: */
    if( info->FileLength = GetSize( file ) )
    {
      /* Allocate enough memory for the sampled sound, and store a */
      /* pointer to the buffer in the SoundInfo structure:         */
      info->SoundBuffer = (BYTE *) AllocMem( info->FileLength,
                                          MEMF_CHIP|MEMF_CLEAR );

      if( info->SoundBuffer )
      {
        /* The memory have been successfully allocated. */ 

		    /* Load the sound, and store the record rate in the SoundInfo  */
				/* structure. If the sound could not be loaded, 0 is returned: */
        if( info->RecordRate = LoadSound( file, info ) )
        {
					/* OK! The sound has successfully been loaded. */
          
					/* Old FutureSound files were saved in kHz. If the record rate */
					/* is less than one hundered, we know it is an old FutureSound */
					/* file, and simply multiply the rate with one thousand:       */
          /* Astrofra : removed suspicious patch inherited from the past century */
          /* if( info->RecordRate < 100 )
            info->RecordRate *= 1000;
          */
          
					/* Return a pointer to the SoundInfo structure. (We return a */
					/* normal memory pointer.)                                   */
					return(info); // return( (CPTR) info ); /* OK! */
        }
				else
        {
					/* ERROR! We could not load the sound! */
					
          /* Deallocate the memory for the sound buffer: */
          FreeMem( info->SoundBuffer, info->FileLength );
        }
      }
    }
    /* Deallocate the memory the SoundInfo structure: */
    FreeMem( info, sizeof( struct SoundInfo ) );
  }
	
	/* We have not been able to prepare the sound. All allocated memory */
	/* have been deallocated, and we return NULL.                       */
  return( NULL ); /* ERROR! */
}



/* PlaySound()                                                          */
/* PlaySound() plays one already prepared sound effect. You can decide  */
/* what volume, which channel should, what rate, and how many times the */
/* sound should be played.                                              */ 
/*                                                                      */
/* Synopsis: ok = PlaySound( pointer, volume, channel, drate, times );  */
/* ok:       (BOOL) If the sound was played successfully TRUE is        */
/*           returned, else FALSE.                                      */
/* pointer:  (CPTR) Actually a pointer to a SoundInfo structure. This   */
/*           pointer was returned by PrepareSound().                    */
/* volume:   (UWORD) Volume, 0 to 64.                                   */
/* channel:  (UBYTE) Which channel should be used. (LEFT0, RIGHT0,      */
/*           RIGHT1 or LEFT1)                                           */
/* drate:    (WORD) Delta rate. When the sound is prepared, the record  */
/*           rate is automatically stored in the SoundInfo structure,   */
/*           so if you do not want to change the rate, write 0.         */
/* times:    (UWORD) How many times the sound should be played. If you  */
/*           want to play the sound forever, write 0. (To stop a sound  */
/*           call the function StopSound().)                            */ 

BOOL PlaySound(struct SoundInfo *info, UWORD volume, UBYTE channel, WORD delta_rate, UWORD repeat)
{
  /* Before we may play the sound, we must make sure that the sound is */
	/* not already being played. We will therefore call the function     */
	/* StopSound(), in order to stop the sound if it is playing:         */
  StopSound( channel );

  /* Call the PrepareIOA() function that will declare and initialize an */
	/* IOAudio structure:                                                 */
  if( PrepareIOA( CLOCK_CONSTANT / info->RecordRate + delta_rate, volume,
              repeat, channel, info ) )
  {
    /* We will now start playing the sound: */
    BeginIO((struct IORequest*)IOA[ channel ] );
    return( TRUE );  /* OK! */
	}
  else
    return( FALSE ); /* ERROR! */
}



/* StopSound()                                                         */
/* StopSound() will stop the specified audio channel from continuing   */
/* to play the sound. It will also close all devices and ports that    */
/* have been opened, and deallocate some memory that have been         */
/* allocated.                                                          */
/*                                                                     */
/* Synopsis: StopSound( channel );                                     */
/* channel:  (UBYTE) The audio channel that should be stopped. (LEFT0, */
/*           LEFT1, RIGHT0 or RIGHT1.)                                 */

void StopSound(UBYTE channel)
{
	/* Check if the IOAudio structure exist: */
  if( IOA[ channel ] )
  {
		/* 1. Stop the sound: */
    AbortIO((struct IORequest*)IOA[ channel ] );
    
    /* 2. If there exist a Sound Device, close it: */
    if( IOA[ channel ]->ioa_Request.io_Device )
      CloseDevice((struct IORequest*)IOA[ channel ] );

    /* 3. If there exist a Message Port, delete it: */
    if( IOA[ channel ]->ioa_Request.io_Message.mn_ReplyPort )
      DeletePort( IOA[ channel ]->ioa_Request.io_Message.mn_ReplyPort );

    FreeMem( IOA[ channel ], sizeof( struct IOAudio ) );
    IOA[ channel ] = NULL;
  }
}



/* RemoveSound()                                                        */
/* RemoveSound() will stop playing the sound, and deallocate all memory */
/* that was allocated by the PrepareSound() function. Before your       */
/* program terminates, all sound that has been prepared, MUST be        */
/* removed.                                                             */
/*                                                                      */
/* IMPORTANT! The each channel that is currently playing the sound must */
/* be stopped! (Use the StopSound() function.)                          */

/* Synopsis: RemoveSound( pointer );                                    */
/* pointer:  (CPTR) Actually a pointer to a SoundInfo structure.        */

void RemoveSound(struct SoundInfo *info)
{
  /* IMPORTANT! The sound must have been */
	/* stopped before you may remove it!!! */

  /* Have we allocated a SoundInfo structure? */
  if( info )
  {
    /* Deallocate the sound buffer: */
    FreeMem( info->SoundBuffer, info->FileLength );

    /* Deallocate the SoundInfo structure: */
    FreeMem( info, sizeof( struct SoundInfo ) );
    info = NULL;
  }
}



/* PrepareIOA()                                                           */
/* PrepareIOA() allocates and initializes an IOAudio structure.           */
/*                                                                        */
/* Synopsis: ok = PrepareIOA( period, volume, cycles, channel, pointer ); */
/*                                                                        */
/* ok:       (BOOL) If the IOAudio structure was allocated and            */
/*           initialized successfully, TRUE is returned, else FALSE.      */
/* period:   (UWORD) Period time.                                         */
/* volume:   (UWORD) Volume, 0 to 64.                                     */
/* cycles:   (UWORD) How many times the sound should be played.           */
/*           (0 : forever)                                                */
/* channel:  (UBYTE) Which channel should be used. (LEFT0, RIGHT0,        */
/*           RIGHT1 or LEFT1)                                             */
/* pointer:  (CPTR) Actually a pointer to a SoundInfo structure.          */

BOOL PrepareIOA( UWORD period,UWORD volume,UWORD cycles, UBYTE channel, struct SoundInfo *info)
{
	UBYTE ch;

	/* Declare a pointer to a MsgPort structure: */ 
  struct MsgPort *port;

  /* Allocate space for an IOAudio structure: */
  IOA[ channel ] = (struct IOAudio *) AllocMem( sizeof( struct IOAudio ),
                      MEMF_PUBLIC|MEMF_CLEAR );

  /* Could we allocate enough memory? */
  if( IOA[ channel ] )
  {
    /* Create Message port: */
    if((port = (struct MsgPort *) CreatePort( "Sound Port", 0 )) == NULL)
    {
      /* ERROR! Could not create message port! */
			/* Deallocate the IOAudio structure: */
      FreeMem( IOA[ channel ], sizeof(struct IOAudio) );
      IOA[ channel ] = NULL;
      
			return( FALSE ); /* ERROR! */
    }
    else
    {
      /* Port created successfully! */
      /* Initialize the IOAudion structure: */
			
			/* Priority: */
      IOA[ channel ]->ioa_Request.io_Message.mn_Node.ln_Pri = MUSIC_PRIORITY;
      
			/* Port: */
			IOA[ channel ]->ioa_Request.io_Message.mn_ReplyPort = port;
      
			/* Channel: */
      ch = 1<<channel;
			IOA[ channel ]->ioa_Data = &ch;
      
			/* Length: */
			IOA[ channel ]->ioa_Length = sizeof( UBYTE );
      
      /* Open Audio Device: */
      if( OpenDevice( AUDIONAME, 0,(struct IORequest*)IOA[ channel ], 0) )
      {
        /* ERROR! Could not open the device! */
        /* Delete Sound Port: */
				DeletePort( port );

				/* Deallocate the IOAudio structure: */
        FreeMem( IOA[ channel ], sizeof(struct IOAudio) );
        IOA[ channel ] = NULL;

				return( FALSE ); /* ERROR! */
      }
      else
      {
        /* Device opened successfully! */
        /* Initialize the rest of the IOAudio structure: */
        IOA[ channel ]->ioa_Request.io_Flags = ADIOF_PERVOL;
        IOA[ channel ]->ioa_Request.io_Command = CMD_WRITE;
        IOA[ channel ]->ioa_Period = period;
        IOA[ channel ]->ioa_Volume = volume;
        IOA[ channel ]->ioa_Cycles = cycles;

        /* The Audio Chip can of some strange reason not play sampled  */
				/* sound that is longer than 131KB. So if the sound is too long, */
				/* we simply cut it off:                                        */
        if( info->FileLength > 131000 )
          IOA[ channel ]->ioa_Length = 131000;
        else
          IOA[ channel ]->ioa_Length = info->FileLength;

        // printf("PrepareIOA() ioa_Length = %d\n", IOA[ channel ]->ioa_Length);

        IOA[ channel ]->ioa_Data = info->SoundBuffer;

        return( TRUE ); /* OK! */
      }
    }
  }
  return( FALSE ); /* ERROR! */
}



/* LoadSound()                                                         */
/* LoadSound() will load sampled sound that was either saved in IFF or */
/* FutureSound format.                                                 */
/*                                                                     */
/* Synopsis: rate = LoadSound( filename, pointer );                    */
/* rate:     (UWORD) The record rate is returned if the sound was      */
/*           successfully loaded, else 0.                              */
/* filename: (STRPTR) Pointer to a string containing the name of the   */
/*           sound file. For example "df0:Explosion.snd".              */
/* pointer:  (CPTR) Actually a pointer to a SoundInfo structure.       */


UWORD LoadSound( STRPTR filename, struct SoundInfo *info )
{
  FILE  *file_ptr;   /* Pointer to a file. */
  ULONG length;      /* Data Length. */
  UWORD record_rate; /* Record rate. */


  /* Check if it is an IFF File: */
  if( SizeIFF( filename ) )
  {
    /* Yes, it is an IFF file. Read it: */
    return( ReadIFF( filename, info ) );
  }
  else
  {
    /* No, then it is probably a FutureSound file. */
    /* Open the file so we can read it:            */
    if( (file_ptr = fopen( filename, "r" )) == 0 )
      return( 0 ); /* ERROR! Could not open the file! */

    /* Read the data length: */
    if( fread( (char *) &length, sizeof( ULONG ), 1, file_ptr ) == 0 )
    {
			/* ERROR! Could not read the data length! */
			/* Close the file, and return zero:       */
      fclose( file_ptr );
      return( 0 );
    }

    /* Read the record rate: */
    if( fread( (char *) &record_rate, sizeof( UWORD ), 1, file_ptr ) == 0 )
    {
			/* ERROR! Could not read the record rate! */
			/* Close the file, and return zero:       */
      fclose( file_ptr );
      return( 0 );
    }

    /* Read the sampled sound data into the buffer: */
    if( fread( (char *) info->SoundBuffer, length, 1, file_ptr ) == 0 )
    {
			/* ERROR! Could not read the data!  */
			/* Close the file, and return zero: */		
      fclose( file_ptr );
      return( 0 );
    }

    /* Close the file: */
    fclose( file_ptr );

    /* Return the record rate: */
    // printf("LoadSound() record_rate = %d\n", record_rate);    
    return( record_rate );
  }
}




/* GetSize()                                                         */
/* GetSize() returns the size of the file which was saved in either  */
/* IFF or FutureSound format.                                        */
/*                                                                   */
/* Synopsis: length = GetSize( filename );                           */
/* length:   (ULONG) Data length.                                    */
/* filename: (STRPTR) Pointer to a string containing the name of the */
/*           sound file. For example "df0:Explosion.snd".            */

ULONG GetSize(STRPTR filename)
{
  FILE *file_ptr; /* Pointer to a file. */
  ULONG length;  /* Data length. */


  /* Check if it is an IFF File: */
  if( ( length = SizeIFF( filename ) ) == 0 )
  {
    /* No, then it is probably a FutureSound file. */
    /* Open the file so we can read it:            */
    if( ( file_ptr = fopen( filename, "r" ) ) == 0 )
      return( 0 ); /* ERROR! Could not open the file! */

    /* Read the data length: */
    if( fread( (char *) &length, sizeof( ULONG ), 1, file_ptr ) == 0)
    {
			/* ERROR! Could not read the data length! */
			/* Close the file, and return zero:       */
      fclose( file_ptr );
      return( 0 );
    }
		
    /* Close the file: */
    fclose( file_ptr );
  }
  // printf("GetSize() length = %d\n", length);
  return( length );
}



/* SizeIFF()                                                         */
/* SizeIFF() returns the size of an IFF file, or zero if something   */
/* went wrong (for example, It was not an IFF file).                 */
/*                                                                   */
/* Synopsis: length = SizeIFF( filename );                           */
/* length:   (ULONG) Data length.                                    */
/* filename: (STRPTR) Pointer to a string containing the name of the */
/*           IFF file. For example "df0:Explosion.snd".              */

ULONG SizeIFF( STRPTR filename )
{
  FILE  *file_ptr;              /* Pointer to a file. */
  STRPTR empty_string = "    "; /* Four spaces. */ 
  LONG dummy;                   /* A dummy variable. */
  Voice8Header Header;          /* Voice8Header structure. */


  /* Try to open the file: */
  if( file_ptr = fopen( filename, "r" ) )
  {
    fread( (char *) empty_string, 4, 1, file_ptr );
    if( strcmp( empty_string, "FORM" ) == 0)
    {
			/* Read twice: */
      fread( (char *) empty_string, 4, 1, file_ptr );
      fread( (char *) empty_string, 4, 1, file_ptr );

      /* Check if it is a "8SVX" file, or not: */
			if( strcmp( empty_string, "8SVX" ) == 0 )
      {
        MoveTo( "VHDR", file_ptr );
        fread( (char *) &dummy, sizeof( LONG ), 1, file_ptr );
        fread( (char *) &Header, sizeof( Header ), 1, file_ptr );

    		/* Close the file, and return the length: */
        fclose( file_ptr );

        // printf("SizeIFF() oneShotHiSamples + repeatHiSamples = %d\n", Header.oneShotHiSamples + Header.repeatHiSamples);        
        return( Header.oneShotHiSamples + Header.repeatHiSamples );
      }
    }
		/* Close the file: */
    fclose( file_ptr );
  }
	/* Return zero: (ERROR) */
  return( 0 );
}



/* ReadIFF()                                                           */
/* ReadIFF() reads an IFF file into the buffer, and returns the record */
/* rate.                                                               */
/*                                                                     */
/* Synopsis: rate = ReadIFF( filename, pointer );                      */
/* rate:     (UWORD) The record rate is returned if the sound was      */
/*           successfully loaded, else 0.                              */
/* filename: (STRPTR) Pointer to a string containing the name of the   */
/*           sound file. For example "df0:Explosion.snd".              */
/* pointer:  (CPTR) Actually a pointer to a SoundInfo structure.       */

UWORD ReadIFF( STRPTR filename, struct SoundInfo *info )
{
  FILE  *file_ptr;              /* Pointer to a file. */
  STRPTR empty_string = "    "; /* Four spaces. */ 
  LONG dummy;                   /* A dummy variable. */
  Voice8Header Header;          /* Voice8Header structure. */


  /* Try to open the file: */
  if( file_ptr = fopen( filename, "r" ) )
  {
    fread( (char *) empty_string, 4, 1, file_ptr );
    if( strcmp( empty_string, "FORM" ) == 0 )
    {
			/* Read twice: */
      fread( (char *) empty_string, 4, 1, file_ptr );
      fread( (char *) empty_string, 4, 1, file_ptr );

      /* Check if it is a "8SVX" file, or not: */
      if( strcmp( empty_string, "8SVX" ) == 0 )
      {
        MoveTo( "VHDR", file_ptr );
        fread( (char *) &dummy, sizeof( LONG ), 1, file_ptr );
        fread( (char *) &Header, sizeof( Header ), 1, file_ptr );

        MoveTo( "BODY", file_ptr );
        fread( (char *) &dummy, sizeof( LONG ), 1, file_ptr );
        fread( (char *) info->SoundBuffer, Header.oneShotHiSamples +
                                 Header.repeatHiSamples, 1, file_ptr );

    		/* Close the file, and return the record rate: */
        fclose( file_ptr );

        // printf("ReadIFF() samplesPerSec = %d\n", Header.samplesPerSec);
        return( Header.samplesPerSec );
      }
    }
		/* Close the file: */
    fclose( file_ptr );
  }
	/* Return zero: (ERROR) */
  return( 0 );
} 



/* MoveTo()                                                  */
/* MoveTo() walks through an IFF file, and looks for chunks. */
/*                                                           */
/* Synopsis: MoveTo( chunk, file_ptr );                      */
/* chunk:    (STRPTR) The chunk we want to get to.           */
/* file_ptr: (FILE *) Pointer to an already opened file.     */

BOOL MoveTo( STRPTR check_string, FILE *file_ptr )
{
  STRPTR empty_string = "    "; /* Four spaces. */ 
  int skip, loop;               /* How much data should be skiped. */
  LONG dummy;                   /* A dummy variable. */


  /* As long as we have not reached the EOF, continue: */
  while( !feof( file_ptr ) )
  {
    fread( (char *) empty_string, 4, 1, file_ptr);

    /* Have we found the right chunk? */    
		if( strcmp( check_string, empty_string ) ==0 )
      return( 0 ); /* YES! Return nothing. */

    /* Move foreward: */
    fread( (char *) &skip, sizeof( LONG ), 1, file_ptr );
    for( loop = 0; loop < skip; loop++ )
      fread( (char *) &dummy, 1, 1, file_ptr);
  }
}
