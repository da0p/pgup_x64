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
TARGETS := write_records read_records add_year_robust 

.PHONY: clean

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $< 

all: $(TARGETS)

write_records: write_record.o write_records.o

read_records: read_record.o write_newline.o count_chars.o read_records.o

add_year_robust: add_year_robust.o read_record.o write_record.o count_chars.o error_exit.o

clean :
	rm -f *.o *.dat $(TARGETS)
