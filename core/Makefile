LIBNAME=rrd2_core

BUILDBASE=.build

CC=gcc
CFLAGS=-g -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/gee-1.0 -Wall -g -fPIC
LDFLAGS=-g -pthread -lgee -lgobject-2.0 -lgthread-2.0 -lrt -lglib-2.0 -lm

VALASRC=$(wildcard *.vala)
VALACSRC=$(addprefix $(BUILDBASE)/,$(VALASRC:.vala=.c))
VALAOBJ=$(VALACSRC:.c=.o)

PRELINK=$(BUILDBASE)/prelink.c

CSRC=$(PRELINK)
COBJ=$(CSRC:.c=.o)

LIBDIR=../lib
INCDIR=../include
VAPIDIR=../vapi

LIBSO=lib$(LIBNAME).so
LIBH=$(LIBNAME).h
LIBVAPI=$(LIBNAME).vapi

VALAC=valac
VALAFLAGS=-g --pkg gee-1.0
VALASHAREDFLAGS=-X -fPIC -X -shared

all: library

clean:
	rm -rf .build

library: $(LIBSO)
$(LIBSO): $(COBJ) $(VALAOBJ)
	$(CC) -o $(LIBDIR)/$@ -shared $^ $(LDFLAGS)

$(LIBH): .build $(VALASRC)
	$(VALAC) --directory $(BUILDBASE) -C -H $(BUILDBASE)/$(LIBH) --vapi $(LIBVAPI) $(VALAFLAGS) $(VALASHAREDFLAGS) $(VALASRC)
	cp $(BUILDBASE)/$(LIBH) $(INCDIR)
	cp $(BUILDBASE)/$(LIBVAPI) $(VAPIDIR)

$(BUILDBASE):
	mkdir -p $(BUILDBASE)

$(PRELINK): $(LIBH)
	grep -Eh "GType rrd_(command|value|rpnop)_.*_get_type" .build/$(LIBH) \
	| sed "s/{/;/" \
	| sort -u \
	| awk '{C[$$2]=$$0;}END{print "#include <glib.h>";print "#include <glib-object.h>";for(i in C) {print "extern",C[i];}print "static void __attribute__((constructor)) init_lib(void) {";print "  GType t;";print "  g_type_init();";for(i in C) {print "  t = "i" ();";};print "}";}' \
	> $(PRELINK)

.c.o:

#$(BUILDBASE)%.o: %.c
