VALASRC=$(wildcard *.vala)
VALACSRC=$(VALASRC:.vala=.c)
CSRC=preload.c
OBJ=$(VALACSRC:.c=.o) $(CSRC:.c=.o)
EXE=rrdtool

VALAC=valac
VALAFLAGS=-g --vapidir vapi -X -Iinclude --pkg gee-1.0 --pkg rrd2_core --pkg rrd2_command -X -Llib -X -lrrd2_core -X -lrrd2_command -X -lm -X -Wl,-rpath=lib

BASEDIRS=vapi lib include

all: $(BASEDIRS) core command $(EXE)

vapi:
	mkdir -p $@
lib:
	mkdir -p $@
include:
	mkdir -p $@

clean:  clean_core clean_command
	rm -f *.o *.c $(EXE)
	rm -rf vapi lib include

core::
	$(MAKE) -C core
clean_core::
	$(MAKE) -C core clean

command::
	$(MAKE) -C command
clean_command::
	$(MAKE) -C command clean

$(EXE): $(BASEDIRS) core command $(VALASRC)
	$(VALAC) $(VALAFLAGS) $(VALASRC)

test: $(EXE)
	@rm -f core.*
	./$(EXE) --verbose --debug graph --width 600 --height 300 \
		dEf:test=/tmp/test.rrd:field1:AVG \
		'comment:abc\\:cde'

# we may avoid this by using TypeModule
preload.c: $(VALACSRC)
	grep -Eh "GType rrd_(command|value|rpnop)_.*_get_type" rrd_*.c \
	| sed "s/{/;/" \
	| sort -u \
	| awk '{C[$$2]=$$0;}END{print "#include <glib.h>";print "#include <glib-object.h>";for(i in C) {print "extern",C[i];}print "static void __attribute__((constructor)) init_lib(void) {";print "  GType t;";print "  g_type_init();";for(i in C) {print "  t = "i" ();";};print "}";}' \
	> $@

