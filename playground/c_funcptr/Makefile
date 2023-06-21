BIN=../../llvm/build/bin
CC=$(BIN)/clang
OPT=$(BIN)/opt

CFLAGS=-m64
LTOCFIFLAGS=$(CFLAGS) -fvisibility=hidden -flto -fsanitize=cfi-icall -fno-sanitize-ignorelist
MYCFIFLAGS=$(CFLAGS)
KCFIFLAGS=$(CFLAGS) -fsanitize=kcfi

all: kcfi mycfi
kcfi: greet.c
	$(CC) $(KCFIFLAGS) -o $@-greet.exe $<
mycfi: greet.c
	$(CC) $(MYCFIFLAGS) -o $@-greet.exe $<
mycfi-debug: greet.c
	#$(CC) $(MYCFIFLAGS) -S -emit-llvm -o $@-greet.ll $<
	#$(OPT) -passes=$@ -o $@-greet.bc $@-greet.ll
	#$(CC) $(MYCFIFLAGS) -o $@-greet.exe $@-greet.bc
clean:
	rm $(wildcard *.exe) $(wildcard *.ll) $(wildcard *.bc) $(wildcard *.o)
