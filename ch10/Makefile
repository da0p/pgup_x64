#
# Linux makefile
# Use with make 
#

AS		:= as
ASFLAGS := -g 
CC 		:= ld
LINKER_FLAGS := -dynamic-linker /lib64/ld-linux-x86-64.so.2
CLIB_FLAGS := -lc
LD_FLAGS :=
TARGETS := conversion_program 

.PHONY: clean

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $< 

all: $(TARGETS)

conversion_program: count_chars.o integer_to_string.o write_newline.o conversion_program.o

clean :
	rm -f *.o *.dat $(TARGETS)
