.prl.gst:
	sc NOLINK CODE=F DATA=F OPTI MGST $*.gst $*.prl

.c.o:
	sc NOLINK CODE=F DATA=F OPTI TO $@ $*.c

OBJ = main.o mandarine_logo.o checkerboard_stripe.o ruby_stripe.o font_bitmap.o font_desc.o vert_copper_palettes.o fx_routines.o bitmap_routines.o sprites_routines.o cosine_table.o

main.exe: $(OBJ) includes.gst
	sc LINK CODE=F DATA=F OBJ $(OBJ) TO commonbin:main.exe

includes.gst: includes.prl
main.o: main.c screen_size.h mandarine_logo.h checkerboard_stripe.h ruby_stripe.h font_bitmap.h font_desc.h vert_copper_palettes.h fx_routines.h bitmap_routines.h sprites_routines.h cosine_table.h includes.gst
mandarine_logo.o: mandarine_logo.c
checkerboard_stripe.o: checkerboard_stripe.c
ruby_stripe.o: ruby_stripe.c
font_bitmap.o: font_bitmap.c 
font_desc.o: font_desc.c
vert_copper_palettes.o: vert_copper_palettes.c
fx_routines.o: fx_routines.c screen_size.h
bitmap_routines.o: bitmap_routines.c
sprites_routines.o: sprites_routines.c
cosine_table.o: cosine_table.c