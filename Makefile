# QMD_FILES := $(wildcard *.qmd)
QMD_FILES = $(shell find content/ -type f -name '*.qmd')
QMD_OUT_FILES := $(QMD_FILES:.qmd=.quarto.md)
# QMD_OUT_FILES = $(patsubst %.œmd, %.quarto.md, $(QMD_FILES))


export PATH := /tmp/quarto/bin:$(PATH)

netlify: all

all: quartos

quartos: $(QMD_OUT_FILES)

%.quarto.md: %.qmd Makefile
	quarto render $< --to hugo
	mv $*.md $*.quarto.md
	static_name=$(shell basename $*)_files; \
	static_path=static/$$static_name; \
	rm -rf $$static_path; \
	cp -rf $*_files $$static_path; \
	if [ "$(shell uname)" = "Darwin" ]; then \
		sed -i "" -e "s/$$static_name/\/$$static_name/g" $@; \
		sed -i "" -e 's/\\\[/\[/g' $@; \
		sed -i "" -e 's/\\\]/\]/g' $@; \
	else \
		sed -i -e "s/$$static_name/\/$$static_name/g" $@; \
		sed -i -e 's/\\\[/\[/g' $@; \
		sed -i -e 's/\\\]/\]/g' $@; \
	fi

clean:
	rm -f $(QMD_OUT_FILES)

# Interval between checks (in seconds)
INTERVAL := 0.1
TARGET := all

watch:
	@while true; do \
		make $(TARGET) -s all; \
		sleep $(INTERVAL); \
	done

# watch:
# 	while true; do \
# 		inotifywait -e modify,create,delete,move $(QMD_FILES); \
# 		make quarto; \
# 	done

.PHONY: quartos clean all netlify