#
# See https://github.com/ldx/dotfiles.git
#
# Run 'make' or 'make install' to copy all dotfiles to
# your ~.
#

CP = cp -rf
RM = rm -rf

EXCLUDE = . .. .git .gitmodules Makefile
ALL = $(wildcard .* *)
SRC = $(filter-out $(EXCLUDE), $(ALL))
DST = $(addprefix $(HOME)/, $(SRC))

$(HOME)/%: %
	@echo "$< -> $@"
	@$(RM) $@
	@$(CP) $< $@

install: $(DST)

clean:
	@$(foreach f, $(DST), echo "removing $(f)"; $(RM) $(f);)

.PHONY: clean
