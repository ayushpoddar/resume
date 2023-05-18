OUT_DIR=output
IN_DIR=markdown
STYLES_DIR=styles
STYLE=style

all: html docx rtf
pdf: html weasyprint
open: open_pdf
view: open_html

# pdf: init
# 	for f in $(IN_DIR)/*.md; do \
# 		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
# 		echo $$FILE_NAME.pdf; \
# 		pandoc --standalone --template $(STYLES_DIR)/$(STYLE).tex \
# 			--from markdown --to context \
# 			--variable papersize=A4 \
# 			--output $(OUT_DIR)/$$FILE_NAME.tex $$f > /dev/null; \
# 		mtxrun --path=$(OUT_DIR) --result=$$FILE_NAME.pdf --script context $$FILE_NAME.tex > $(OUT_DIR)/context_$$FILE_NAME.log 2>&1; \
# 	done

open_pdf: init
	@FILE_NAME=`ls -1r $(OUT_DIR)/*.pdf | head -n 1`; \
	open $$FILE_NAME

open_html: init
	for f in $(OUT_DIR)/*.html; do \
		FILE_NAME=`basename $$f | sed 's/.html//g'`; \
		echo $$FILE_NAME.html; \
		open $$f; \
	done

weasyprint: init
	for f in $(OUT_DIR)/*.html; do \
		FILE_NAME=`basename $$f | sed 's/.html//g'`; \
		FILE_NAME=`echo ayush_$${FILE_NAME}_$$(date +%d%m_%H%M)_$$(git branch --show-current)`; \
		echo $$FILE_NAME.pdf; \
		weasyprint -q $$f $(OUT_DIR)/$$FILE_NAME.pdf; \
	done

html: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.html; \
		pandoc --standalone --include-in-header $(STYLES_DIR)/$(STYLE).css \
			--lua-filter=pdc-links-target-blank.lua \
			--from markdown --to html \
			--output $(OUT_DIR)/$$FILE_NAME.html $$f \
			--metadata pagetitle=$$FILE_NAME;\
	done

docx: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.docx; \
		pandoc --standalone $$SMART $$f --output $(OUT_DIR)/$$FILE_NAME.docx; \
	done

rtf: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.rtf; \
		pandoc --standalone $$SMART $$f --output $(OUT_DIR)/$$FILE_NAME.rtf; \
	done

init: dir version

dir:
	mkdir -p $(OUT_DIR)

version:
	PANDOC_VERSION=`pandoc --version | head -1 | cut -d' ' -f2 | cut -d'.' -f1`; \
	if [ "$$PANDOC_VERSION" -eq "2" ]; then \
		SMART=-smart; \
	else \
		SMART=--smart; \
	fi \

clean:
	rm -f $(OUT_DIR)/*
