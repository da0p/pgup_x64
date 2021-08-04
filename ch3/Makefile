#
# Linux makefile
# Use with make 
#

AS		:= as
ASFLAGS :=  
CC 		:= ld
LINKER_FLAGS := -dynamic-linker /lib64/ld-linux-x86-64.so.2
CLIB_FLAGS := -lc
LD_FLAGS :=
TARGETS := max 

.PHONY: clean

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $< 

all: $(TARGETS)

max: max.o

clean :
	rm -f *.o *.dat $(TARGETS)
