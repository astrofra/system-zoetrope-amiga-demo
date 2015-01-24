/*
    Misc bitmap routines 
*/

#include "includes.prl"

extern struct DosLibrary *DOSBase;
extern struct GfxBase *GfxBase;

/*
  Image loading 
*/

PLANEPTR load_getchipmem(UBYTE *name, ULONG size)
{
  BPTR fileHandle;
  PLANEPTR mem;

  if (!(fileHandle = Open(name, MODE_OLDFILE)))
    return (NULL);

  if (!(mem = AllocMem(size, MEMF_CHIP)))
    return (NULL);

  Read(fileHandle, mem, size);
  Close(fileHandle);

  return (mem);
}

PLANEPTR load_getmem(UBYTE *name, ULONG size)
{
  BPTR fileHandle;
  PLANEPTR mem;

  if (!(fileHandle = Open(name, MODE_OLDFILE)))
    return (NULL);

  if (!(mem = AllocMem(size, 0L)))
    return (NULL);

  Read(fileHandle, mem, size);
  Close(fileHandle);

  return (mem);
}

struct BitMap *load_file_as_bitmap(UBYTE *name, ULONG byte_size, UWORD width, UWORD height, UWORD depth)
{
  BPTR fileHandle;
  struct BitMap *new_bitmap;
  // PLANEPTR new_plane_ptr;
  UWORD i;

  if (!(fileHandle = Open(name, MODE_OLDFILE)))
    return (NULL);

  new_bitmap = (struct BitMap *)AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR);
  InitBitMap(new_bitmap, depth, width, height);
  // printf("new_bitmap, BytesPerRow = %d, Rows = %d, Depth = %d, pad = %d, byte_size = %i, \n",
  //       (*new_bitmap).BytesPerRow,
  //       (*new_bitmap).Rows,
  //       (*new_bitmap).Depth,
  //       (int)(*new_bitmap).pad,
  //       byte_size);

  for (i = 0; i < depth; i++)
    (*new_bitmap).Planes[i] = (PLANEPTR)AllocMem(RASSIZE(width, height), MEMF_CHIP);

  for (i = 0; i < depth; i++)
    Read(fileHandle, (*new_bitmap).Planes[i], byte_size / depth);
  Close(fileHandle);

  return new_bitmap;
}

struct BitMap *load_array_as_bitmap(UWORD *bitmap_array, ULONG array_size, UWORD width, UWORD height, UWORD depth)
{
  struct BitMap *new_bitmap;
  // PLANEPTR new_plane_ptr;
  UWORD i;
  UBYTE *read_ptr;

  new_bitmap = (struct BitMap *)AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR);
  InitBitMap(new_bitmap, depth, width, height);

  for (i = 0; i < depth; i++)
    (*new_bitmap).Planes[i] = (PLANEPTR)AllocMem(RASSIZE(width, height), MEMF_CHIP);

  for (i = 0, read_ptr = (UBYTE *)bitmap_array; i < depth; i++, read_ptr += (array_size / depth))
    memcpy((UBYTE *)(*new_bitmap).Planes[i], read_ptr, array_size / depth);

  return new_bitmap;
}

void free_allocated_bitmap(struct BitMap *allocated_bitmap)
{
  USHORT i;
  ULONG block_len;

  if (allocated_bitmap)
  {
    // printf("free_allocated_bitmap() allocated_bitmap = %x\n", allocated_bitmap);
    // printf("allocated_bitmap, BytesPerRow = %d, Rows = %d, Depth = %d, pad = %d\n",
    //       (*allocated_bitmap).BytesPerRow,
    //       (*allocated_bitmap).Rows,
    //       (*allocated_bitmap).Depth,
    //       (int)(*allocated_bitmap).pad);

    block_len = RASSIZE((*allocated_bitmap).BytesPerRow * 8, (*allocated_bitmap).Rows);
    for (i = 0; i < (*allocated_bitmap).Depth; i++)
    {
      // printf("FreeMem() plane[%i], block_len = %i\n", i, block_len);
      FreeMem((*allocated_bitmap).Planes[i], block_len); // (*allocated_bitmap).BytesPerRow * (*allocated_bitmap).Rows);
    }

    block_len = (LONG)sizeof(struct BitMap);
    // printf("FreeMem() struct BitMap, block_len = %i\n", block_len);
    FreeMem(allocated_bitmap, block_len);
  }
}

void load_file_into_existing_bitmap(struct BitMap *new_bitmap, BYTE *name, ULONG byte_size, UWORD depth)
{
  BPTR fileHandle;
  UWORD i;

  if (fileHandle = Open(name, MODE_OLDFILE))
  {
    for (i = 0; i < depth; i++)
      Read(fileHandle, (*new_bitmap).Planes[i], byte_size / depth);
    Close(fileHandle);
  }
}

void disp_interleaved_st_format(PLANEPTR data, struct BitMap *dest_BitMap, UWORD width, UWORD height, UWORD src_y, UWORD x, UWORD y, UWORD depth)
{
  PLANEPTR src, dest;
  UWORD i, j, k;
  UWORD x_byte, width_byte;

  while(width != ((width >> 4) << 4))
    width++;

  x_byte = x >> 3;
  width_byte = width >> 3;

  for (i = 0; i < height; i ++)
  {
    for (k = 0; k < depth; k ++)
    {
      for (j = 0; j < width_byte; j ++)
      {
        src = data + (j + (i + src_y) * 40 * depth) + (k * 40);
        dest = (*dest_BitMap).Planes[k] + j + x_byte + (48 * i) + 48 * y;

        *dest = *src;
      }
    }
  }
}