ASM=yasm
LD=ld
CFLAGS=-f elf64 # -g dwarf2
LDFLAGS=
LIBS=

SRC=io.asm gcd.asm gcdrun.asm
OBJ=$(SRC:.asm=.o)


all: gcd

gcd: $(OBJ)
	$(LD) -o $@ $^ $(LDFLAGS) $(LIBS)

%.o: %.asm avc.inc
	$(ASM) $(CFLAGS) -l $(@:.o=.lst) -o $@ $<

clean:
	rm *.o
	rm gcd

.PHONY: clean all
