AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/pianificatore.o 
	ld $(LD_FLAGS)  obj/pianificatore.o -o bin/pianificatore

obj/pianificatore.o: src/pianificatore.s
	as $(AS_FLAGS) $(DEBUG) src/pianificatore.s -o obj/pianificatore.o


clean:
	rm -f obj/*.o bin/pianificatore
