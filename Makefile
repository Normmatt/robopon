PYTHON := python2.7
PYTHON3 := python3
MD5 := md5sum -c
POKETOOLS := extras/pokemontools

RZ       := $(PYTHON) rz.py compress
TM       := $(PYTHON) tm2bpp.py furl
EMOTE    := $(PYTHON) emote.py pack
2bpp     := $(PYTHON) gfx.py 2bpp
1bpp     := $(PYTHON) gfx.py 1bpp
includes := $(PYTHON) scan_includes.py

objs := \
	wram.o \
	sram.o \
	vram.o \
	gfx.o \
	audio.o \
	text.o \
	maps.o \
	home.o \
	main.o

sun_objs := $(objs:.o=_sun.o)
star_objs := $(objs:.o=_star.o)

$(foreach obj, $(objs:.o=), \
	$(eval $(obj)_dep := $(shell $(includes) $(obj).asm)) \
)

.SUFFIXES:
.SUFFIXES: .asm .o .gbc .png .2bpp .1bpp .pic .wav .pcm
.SECONDEXPANSION:
# Suppress annoying intermediate file deletion messages.
.PRECIOUS: %.2bpp %.png
.PHONY: all clean tidy roms sun star compare

sun  := robosun.gbc
star := robostar.gbc

all: roms

compare: roms
	$(MD5) roms.md5

roms: $(sun) $(star)

sun: $(sun)

star: $(star)

tidy:
	rm -f $(sun) $(star) $(sun_objs) $(star_objs) $(roms:.gbc=.sym) $(roms:.gbc=.map)

clean: tidy
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pic' -o -iname '*.pcm' -o -iname '*.rz' -o -iname '*.ctf' \) -exec rm {} +

%.ctf: %.asm
	$(PYTHON3) textcomp.py $<

%.asm: ;
%.tm: ;
%.png: ;

data/base_stats/%.bin: ;

%.2bpp: %.png
	$(2bpp) $<

%.1bpp: %.png
	$(1bpp) $<

%.tm2bpp: %.2bpp
	$(TM) $< $@

%.emote: %_*.2bpp
	$(EMOTE) $<

%.rz: %
	$(RZ) $< $@

$(sun_objs): %_sun.o: %.asm $$(%_dep)
	rgbasm -h -D SUN -o $@ $*.asm

$(star_objs): %_star.o: %.asm $$(%_dep)
	rgbasm -h -D STAR -o $@ $*.asm

opts = -csv -k 18 -l 0x33 -m 0xfe -p 0x00 -r 0x03

$(sun): $(sun_objs)
	rgblink -w -n $*.sym -o $@ $^
	rgbfix $(opts) -t "ROBOPON SUN" $@

$(star): $(star_objs)
	rgblink -w -n $*.sym -o $@ $^
	rgbfix $(opts) -t "ROBOPON STAR" $@
