EXE=rrdtool

LIBDIR=$(PWD)/lib
INCDIR=$(PWD)/include
VAPIDIR=$(PWD)/vapi

PKG_USED=gee-0.8 glib-2.0 cairo
LIBS=-lrrd2_core -lrrd2_command -L$(LIBDIR) -Wl,-rpath -Wl,$(LIBDIR)

include Makefile.common

VALAFLAGS=$(VALAFLAGSBASE)
CFLAGS=$(CFLAGSBASE) -I$(INCDIR) $(PKG_CFLAGS)
LDFLAGS=-g $(LIBS) $(PKG_LIBS) -lrt -pthread -lm

VALASRC=$(wildcard *.vala)
VALACSRC=$(addprefix $(BUILDBASE)/,$(VALASRC:.vala=.c))
VALAOBJ=$(VALACSRC:.c=.o)

VALAFLAGS=$(VALAFLAGSBASE) --pkg gee-0.8 --vapidir=$(VAPIDIR) --pkg rrd2_core --pkg rrd2_command --pkg cairo

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
	rm -rf vapi lib include $(BUILDBASE)

core::
	$(MAKE) -C core PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)
clean_core::
	$(MAKE) -C core clean PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

command::
	$(MAKE) -C command PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)
clean_command::
	$(MAKE) -C command clean PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

#$(EXE): $(BASEDIRS) core command $(VALASRC)
#	$(VALAC) $(VALAFLAGS) $(VALASRC)

$(EXE): $(BASEDIRS) core command $(BUILDBASE) $(VALAOBJ)
	$(CC) -o $@ $(VALAOBJ) $(LDFLAGS) $(LIBS) $(PKG_LIBS)

$(VALACSRC):
	$(VALAC) -C $(VALAFLAGS) $(VALASHAREDFLAGS) --directory $(BUILDBASE) $(VALASRC)

.c.o:

$(BUILDBASE):
	mkdir -p $(BUILDBASE)


test:: test1 test2

test1:: $(EXE)
	@rm -f core.*
	./$(EXE) --verbose --debug graph --width 600 --height 300 \
		--imagefile /tmp/test.png \
		dEf:test=/tmp/test.rrd:field1:AVG \
		'comment:abc\\:cde'
test2:: $(EXE)
	./$(EXE) graph --width 600 --height 300 \
	--imagefile /tmp/test.png \
	dEf:test=/tmp/test.rrd:field1:AVG \
	tsgraph:id=xxx:title=test:yonleft=false
