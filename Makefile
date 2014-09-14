VALASRC=$(wildcard *.vala)
VALACSRC=$(VALASRC:.vala=.c)
CSRC=preload.c
OBJ=$(VALACSRC:.c=.o) $(CSRC:.c=.o)
EXE=rrdtool

VALAC=valac
VALAFLAGS=-g --pkg gee-1.0
CC=gcc
CFLAGS=-I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/gee-1.0 -Wall -g
LDFLAGS=-pthread -lgee -lgobject-2.0 -lgthread-2.0 -lrt -lglib-2.0 -g

all: $(EXE)
clean:
	rm -f *.o *.c $(EXE)

test: $(EXE)
	@rm -f core.*
	./$(EXE) --verbose --debug graph --width 600 --height 300 \
		dEf:test=/tmp/test.rrd:field1:AVG \
		'comment:abc\\:cde'

# we may avoid this by using TypeModule
preload.c: $(VALACSRC)
	grep -Eh "GType rrd_(command|rpn)_.*_get_type" rrd_*.c \
	| sed "s/{/;/" \
	| sort -u \
	| awk '{C[$$2]=$$0;}END{print "#include <glib.h>";print "#include <glib-object.h>";for(i in C) {print "extern",C[i];}print "static void __attribute__((constructor)) init_lib(void) {";print "  GType t;";print "  g_type_init();";for(i in C) {print "  t = "i" ();";};print "}";}' \
	> $@

$(EXE): $(OBJ)

.SECONDARY: $(COBJ)

# this does compile too often - no idea yet how to do it correctly...
%.c: %.vala
	$(VALAC) $(VALAFLAGS) -C $(VALASRC)
