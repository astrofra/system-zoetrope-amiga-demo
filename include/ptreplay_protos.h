/*** PROTOS FOR PTREPLAY.LIBRARY ***/

struct Module *PTLoadModule(STRPTR);
VOID PTUnloadModule(struct Module *);
ULONG PTPlay(struct Module *);
ULONG PTStop(struct Module *);
ULONG PTPause(struct Module *);
ULONG PTResume(struct Module *);
/* New in V2 */
VOID PTFade(struct Module *, UBYTE);
/* New in V3 */
VOID PTSetVolume(struct Module *, UBYTE);
/* New in V4 */
UBYTE PTSongPos(struct Module *);
UBYTE PTSongLen(struct Module *);
UBYTE PTSongPattern(struct Module *,UWORD);
UBYTE PTPatternPos(struct Module *);
APTR PTPatternData(struct Module *, UBYTE, UBYTE);
void PTInstallBits(struct Module *, BYTE, BYTE, BYTE, BYTE);
struct Module *PTSetupMod(APTR);
void PTFreeMod(struct Module *);
void PTStartFade(struct Module *, UBYTE);