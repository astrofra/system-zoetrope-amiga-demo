.prl.gst:
	sc NOLINK CODE=F DATA=F OPTI MGST $*.gst $*.prl

.c.o:
	sc NOLINK CODE=F DATA=F OPTI TO $@ $*.c

OBJ = main.o mandarine_logo.o bitmap_routines.o

main.exe: $(OBJ) includes.gst
	sc LINK CODE=F DATA=F OBJ $(OBJ) TO main.exe

includes.gst: includes.prl
main.o: main.c mandarine_logo.h bitmap_routines.h includes.gst
mandarine_logo.o: mandarine_logo.c
bitmap_routines.o: bitmap_routines.c