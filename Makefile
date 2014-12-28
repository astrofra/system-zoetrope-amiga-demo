# project directories
EXE_DIR = $(CURDIR)/bin
INC_DIR = -I$(CURDIR)/../m68k-amigaos/os-include/ -I$(CURDIR)/include/
OBJ_DIR = $(CURDIR)/build
SRC_DIR = $(CURDIR)/src

# implicit rule variables
CC = m68k-amigaos-gcc
CFLAGS = -noixemul -s -Os -Wall -fomit-frame-pointer -m68000 -msmall-code
LDLIBS = -lnix13

# other
OBJS = $(patsubst %.c,%.o,$(wildcard $(SRC_DIR)/*.c))

main: $(OBJS)
	@mkdir -p $(EXE_DIR)
	$(CC) $(CFLAGS) $(LDLIBS) $(OBJS) -o $(EXE_DIR)/main 

-include $(OBJS:.o=.d) # include dependency makefile
	
%.o: %.c
	$(CC) -c $(CFLAGS) $(INC_DIR) $*.c -o $*.o
	$(CC) -MM $(CFLAGS) $*.c > $*.d

.PHONY: clean purge
	
clean:
	rm -f $(SRC_DIR)/*.o $(SRC_DIR)/*.d

purge:
	rm -rf $(EXE_DIR)
	rm -rf $(OBJ_DIR)
	rm -f $(SRC_DIR)/*.o $(SRC_DIR)/*.d

