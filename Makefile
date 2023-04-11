#*******************************************************************************************
# Makefile
#
# Created by: Erik van der Tier
# on: 2023-04-09
#*******************************************************************************************
NAME = 	F256Showcase
ADDR = 	0000
OUTDIR = build
BLD_NAME = $(OUTDIR)/$(NAME).bin

SRC = 	src/main.asm \
		src/init.asm \
		src/system.asm \
		src/showcase.asm \
		src/display.asm \
		src/audio.asm \
		src/defs/interrupt.asm \
		src/defs/tinyvicky.asm \
		src/defs/io.asm

BINS =  tile_data/tileset.bin \
  	    tile_data/tileset.pal.bin		

OPTS = 	--long-address -b -fc

$(BLD_NAME): $(SRC) $(BINS)
		64tass $(OPTS) $(SRC) -o $@ --list $(basename $@).lst --labels=$(basename $@).lbl

up: 	$(BLD_NAME)
		upload $(BLD_NAME) $(ADDR)

clean:
		rm $(OUTDIR)/*

.PHONY: up clean