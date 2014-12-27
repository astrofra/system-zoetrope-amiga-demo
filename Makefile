EXE_DIR = bin
INC_DIR = -I../m68k-amigaos/os-include/ -I./include/
OBJ_DIR =
SRC_DIR = src
LIB_DIR = 

CC = m68k-amigaos-gcc -noixemul -s
CFLAGS = -Os -Wall -fomit-frame-pointer -m68000 -msmall-code
LDLIBS = -lnix13


LIBS =
OBJS = $(patsubst %.c,%.o,$(wildcard $(SRC_DIR)/*.c))

main: $(OBJS)
	@mkdir -p $(EXE_DIR)
	$(CC) $(OBJS) -o $(EXE_DIR)/main

# include dependency makefile
-include $(OBJS:.o=.d)
	
%.o: %.c
	$(CC) -v -c $(CFLAGS) $(INC_DIR) $*.c -o $*.o
	$(CC) -MM $(CFLAGS) $*.c > $*.d

.PHONY: clean purge
	
clean:
	rm -f *.o *.d

purge:
	rm -rf $(EXE_DIR)
	rm -rf $(OBJ_DIR)
	rm -f *.o *.d

