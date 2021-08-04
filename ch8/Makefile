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
TARGETS := hello print_examples

.PHONY: clean

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $< 

all: $(TARGETS)

hello: hello.o
	$(CC) $(LINKER_FLAGS) $< -o $@ $(CLIB_FLAGS) 

print_examples: print_examples.o
	$(CC) $(LINKER_FLAGS) $< -o $@ $(CLIB_FLAGS) 


clean :
	rm -f *.o *.dat $(TARGETS)
