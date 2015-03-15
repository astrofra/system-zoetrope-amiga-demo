.prl.gst:
	sc NOLINK CODE=F DATA=F OPTI MGST $*.gst $*.prl

.c.o:
	sc NOLINK CODE=F DATA=F OPTI TO $@ $*.c

OBJ = main.o mandarine_logo.o checkerboard_strip.o bob_bitmaps.o font_bitmap.o font_desc.o vert_copper_palettes.o \
color_routines.o fx_routines.o bitmap_routines.o font_routines.o sound_routines.o cosine_table.o demo_strings.o

main.exe: $(OBJ) includes.gst
	sc LINK CODE=F DATA=F OBJ $(OBJ) TO commonbin:main.exe

includes.gst: includes.prl
main.o: main.c screen_size.h mandarine_logo.h checkerboard_strip.h bob_bitmaps.h font_bitmap.h font_desc.h vert_copper_palettes.h \
sound_routines.h fx_routines.h bitmap_routines.h color_routines.h font_routines.h cosine_table.h demo_strings.h includes.gst
mandarine_logo.o: mandarine_logo.c
checkerboard_strip.o: checkerboard_strip.c
bob_bitmaps.o: bob_bitmaps.c
font_bitmap.o: font_bitmap.c screen_size.h
font_desc.o: font_desc.c
vert_copper_palettes.o: vert_copper_palettes.c
color_routines.o: color_routines.c
bitmap_routines.o: bitmap_routines.c
fx_routines.o: fx_routines.c fx_routines.h screen_size.h bob_bitmaps.h bitmap_routines.o
font_routines.o: font_routines.c
sound_routines.o: sound_routines.c sound_routines.h
cosine_table.o: cosine_table.c
demo_strings.o: demo_strings.c