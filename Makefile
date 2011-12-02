DEFAULT_CONFIG := advent-2011.ini

PATCH_LIB := PERL5LIB=./patch/lib/:$(PERL5LIB)

DEPEND_CPAN_MODULES := Text::MultiMarkdown \
		       WWW::AdventCalendar

ADVCAL := $(PATCH_LIB) advcal
ADVCAL_CONFIG  := advent.ini
ADVCAL_OUT     := 2011
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
	rm -rf $(ADVCAL_OUT) $(ADVCAL_OUT).tgz
	perl -E 'unlink "$(ADVCAL_CONFIG)" if readlink("$(ADVCAL_CONFIG)") eq "$(DEFAULT_CONFIG)";'

install-depends:
	cpan $(DEPEND_CPAN_MODULES)

upload: build
	tar cvzf $(ADVCAL_OUT).tgz $(ADVCAL_OUT)
	scp $(ADVCAL_OUT).tgz $(ADV_UPLOAD_USER)@$(ADV_UPLOAD_SERVER):/tmp/
	ssh -t $(ADV_UPLOAD_USER)@$(ADV_UPLOAD_SERVER) '$(ADV_UPLOAD_COMMAND)'
	ssh -t $(ADV_UPLOAD_USER)@$(ADV_UPLOAD_SERVER) rm -rf '/tmp/$(ADVCAL_OUT).tgz'

.PHONY: all build clean install-depends upload
