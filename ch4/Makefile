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
TARGETS := fib power factorial 

.PHONY: clean

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $< 

all: $(TARGETS)

factorial: factorial.o

fib: fib.o

power: power.o

clean :
	rm -f *.o *.dat $(TARGETS)
