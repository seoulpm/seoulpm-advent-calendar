DEFAULT_CONFIG := advent-2011.ini

PATCH_LIB := PERL5LIB=./patch/lib/:$(PERL5LIB)

DEPEND_CPAN_MODULES := Text::MultiMarkdown \
		       WWW::AdventCalendar \
		       App::HTTPThis

ADVCAL := $(PATCH_LIB) advcal
ADVCAL_CONFIG  := advent.ini
ADVCAL_OUT     := 2011
ADVCAL_OUT_TGZ := 2011.tgz
ADVCAL_SHARE   := share
ADVCAL_ARTICLE := articles

ADVCAL_FLAGS  += --config $(ADVCAL_CONFIG)
ADVCAL_FLAGS  += --output-dir $(ADVCAL_OUT)
ADVCAL_FLAGS  += --article-dir $(ADVCAL_ARTICLE)
ADVCAL_FLAGS  += --share-dir $(ADVCAL_SHARE)

#
# Please set your environment variable for release
#
ADV_UPLOAD_USER    ?=
ADV_UPLOAD_SERVER  ?=
ADV_UPLOAD_COMMAND ?=

all: build

build:
	perl -E 'symlink "$(DEFAULT_CONFIG)", "$(ADVCAL_CONFIG)" unless -e "$(ADVCAL_CONFIG)"'
	$(ADVCAL) $(ADVCAL_FLAGS)

clean:
	rm -rf $(ADVCAL_OUT) $(ADVCAL_OUT_TGZ)
	perl -E 'unlink "$(ADVCAL_CONFIG)" if readlink("$(ADVCAL_CONFIG)") eq "$(DEFAULT_CONFIG)";'

install-depends:
	cpan $(DEPEND_CPAN_MODULES)

upload: build
	tar cvzf $(ADVCAL_OUT_TGZ) $(ADVCAL_OUT)
	scp $(ADVCAL_OUT_TGZ) $(ADV_UPLOAD_USER)@$(ADV_UPLOAD_SERVER):/tmp/
	ssh -t $(ADV_UPLOAD_USER)@$(ADV_UPLOAD_SERVER) '$(ADV_UPLOAD_COMMAND); rm -rf /tmp/$(ADVCAL_OUT_TGZ)' 
run: build
	ifconfig | perl -nlE 'do { say $$1 } if /inet addr:(\d{1,3}(?:\.\d{1,3}){3})/'
	http_this $(ADVCAL_OUT)

.PHONY: all build clean install-depends upload
