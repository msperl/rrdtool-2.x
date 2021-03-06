LIBNAME=rrd2_core

LIBDIR=../lib
INCDIR=../include
VAPIDIR=../vapi

PKG_USED=gee-0.8 glib-2.0

include ../Makefile.common

VALAFLAGS=$(VALAFLAGSBASE)
CFLAGS=$(CFLAGSBASE) -I$(INCDIR) $(PKG_CFLAGS)
LDFLAGS=-g $(PKG_LIBS) -lrt -pthread -lm

VALASRC=$(wildcard *.vala)
VALACSRC=$(addprefix $(BUILDBASE)/,$(VALASRC:.vala=.c))
VALAOBJ=$(VALACSRC:.c=.o)

PRELINK=$(BUILDBASE)/prelink.c

CSRC=$(PRELINK)
COBJ=$(CSRC:.c=.o)

LIBSO=lib$(LIBNAME).so
LIBH=$(LIBNAME).h
LIBVAPI=$(LIBNAME).vapi

VALAFLAGS=$(VALAFLAGSBASE) --pkg gee-0.8
VALASHAREDFLAGS=-X -fPIC -X -shared

all: library

clean:
	rm -rf .build

library: $(LIBSO)
$(LIBSO): $(INCDIR)/$(LIBH) $(COBJ) $(VALAOBJ)
	$(CC) -o $(LIBDIR)/$@ -shared $(COBJ) $(VALAOBJ) $(LDFLAGS)

$(LIBH): .build $(VALAC)

$(INCDIR)/$(LIBH): $(VALASRC)
	$(VALAC) $(VALAFLAGS) $(VALASHAREDFLAGS) --directory $(BUILDBASE) -C -H $(BUILDBASE)/$(LIBH) --vapi $(LIBVAPI) $(VALASRC)
	cp $(BUILDBASE)/$(LIBH) $(INCDIR)
	cp $(BUILDBASE)/$(LIBVAPI) $(VAPIDIR)

$(BUILDBASE)/%.o: $(BUILDBASE)/%.c
$(BUILDBASE)/%.c: %.vala
	$(VALAC) $(VALAFLAGS) $(VALASHAREDFLAGS) --directory $(BUILDBASE) -C -H $(BUILDBASE)/$(LIBH) --vapi $(LIBVAPI) $(VALASRC)

$(BUILDBASE):
	mkdir -p $(BUILDBASE)

$(BUILDBASE)/prelink.c: $(LIBH)
	grep -Eh "GType rrd_(command|value|rpnop)_.*_get_type" .build/$(LIBH) \
	| sed "s/{/;/" \
	| sort -u \
	| awk '{C[$$2]=$$0;}END{print "#include <glib.h>";print "#include <glib-object.h>";for(i in C) {print "extern",C[i];}print "static void __attribute__((constructor)) init_lib(void) {";print "  GType t;";print "  g_type_init();";for(i in C) {print "  t = "i" ();";};print "}";}' \
	> $(PRELINK)

.c.o:
