# Globals and files to compile.
EXE := tdc

SOURCEDIR := source
SOURCE := $(shell find $(SOURCEDIR) -type f -name '*.d')
OBJ := $(SOURCE:.d=.o)

# User options.
PREFIX  = /usr/local
DESTDIR =

DC = dmd

DFLAGS = -O -dw
DHARDFLAGS := $(DFLAGS)    \
	-I=$(SOURCEDIR)        \
	-I=$(SOURCEDIR)/dmd    \
	-J=$(SOURCEDIR)/dmdres \
	-version=NoBackend     \
	-version=NoMain

.PHONY: all clean install uninstall

all: $(OBJ)
	$(DC) $(DHARDFLAGS) -of=$(EXE) $(OBJ)

%.o: %.d
	$(DC) $(DHARDFLAGS) -of=$@ -c $<

clean:
	rm -f $(OBJ) $(EXE)

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -s $(EXE) $(DESTDIR)$(PREFIX)/bin

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(EXE)
