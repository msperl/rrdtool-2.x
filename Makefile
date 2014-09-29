EXE=rrdtool

LIBDIR=./lib
INCDIR=./include
VAPIDIR=./vapi

PKG_USED=gee-0.8 glib-2.0 cairo

include Makefile.common

VALAFLAGS=$(VALAFLAGSBASE)
CFLAGS=$(CFLAGSBASE) -I$(INCDIR) $(PKG_CFLAGS)
LDFLAGS=-g $(PKG_LIBS) -lrt -pthread -lm

VALASRC=$(wildcard *.vala)
VALACSRC=$(addprefix $(BUILDBASE)/,$(VALASRC:.vala=.c))
VALAOBJ=$(VALACSRC:.c=.o)

VALAFLAGS=$(VALAFLAGSBASE) --pkg gee-0.8 --vapidir=$(VAPIDIR) --pkg rrd2_core --pkg rrd2_command --pkg cairo
#-X-Wl,-rpath=lib
VALASHAREDFLAGS=-X -fPIC -X -shared


BASEDIRS=vapi lib include

all: $(BASEDIRS) core command $(EXE)

vapi:
	mkdir -p $@
lib:
	mkdir -p $@
include:
	mkdir -p $@

clean:  clean_core clean_command
	rm -f *.o *.c $(EXE) core.[0-9]*
	rm -rf vapi lib include

core::
	$(MAKE) -C core PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)
clean_core::
	$(MAKE) -C core clean PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

command::
	$(MAKE) -C command PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)
clean_command::
	$(MAKE) -C command clean PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

$(EXE): $(BASEDIRS) core command $(VALASRC)
	$(VALAC) $(VALAFLAGS) $(VALASRC)

test: $(EXE)
	@rm -f core.*
	./$(EXE) --verbose --debug graph --width 600 --height 300 \
		--imagefile /tmp/test.png \
		dEf:test=/tmp/test.rrd:field1:AVG \
		'comment:abc\\:cde'

# we may avoid this by using TypeModule
preload.c: $(VALACSRC)
	grep -Eh "GType rrd_(command|value|rpnop)_.*_get_type" rrd_*.c \
	| sed "s/{/;/" \
	| sort -u \
	| awk '{C[$$2]=$$0;}END{print "#include <glib.h>";print "#include <glib-object.h>";for(i in C) {print "extern",C[i];}print "static void __attribute__((constructor)) init_lib(void) {";print "  GType t;";print "  g_type_init();";for(i in C) {print "  t = "i" ();";};print "}";}' \
	> $@

