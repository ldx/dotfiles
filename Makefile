#
# See https://github.com/ldx/dotfiles.git
#
# Run 'make' or 'make install' to copy all dotfiles to
# your ~.
#

CP = cp -a
RM = rm -rf
INSTALL = install -d -p

TOP_EXCLUDE = . .. .git .gitmodules Makefile
EXCLUDE= $(foreach x, .git .gitmodules .gitignore, -path "*/$(x)" -prune -o)
ALL = $(filter-out $(TOP_EXCLUDE), $(wildcard .* *))
SRC = $(foreach x, $(ALL), $(shell find $(x) $(EXCLUDE) -type f -print;))
DST = $(addprefix $(HOME)/, $(SRC))

$(HOME)/%: %
	@echo "$< -> $@"
	@$(INSTALL) $(shell dirname $@)
	@$(CP) $< $@

install: $(DST)

clean:
	@$(foreach f, $(DST), echo "removing $(f)"; $(RM) $(f);)

.PHONY: clean
