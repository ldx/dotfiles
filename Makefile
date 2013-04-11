#
# See https://github.com/ldx/dotfiles.git
#
# Run 'make' or 'make install' to copy all dotfiles to
# your ~.
#

CP = cp -a
RM = rm
INSTALL = install -d -p
CMP = cmp -s
RMDIR = rmdir -p --ignore-fail-on-non-empty

TOP_EXCLUDE = . .. .git .gitmodules terminfo Makefile
EXCLUDE= $(foreach x, .git .gitmodules .gitignore, -path "*/$(x)" -prune -o)
ALL = $(filter-out $(TOP_EXCLUDE), $(wildcard .* *))
SRC = $(foreach x, $(ALL), $(shell find $(x) $(EXCLUDE) -type f -print;))
DST = $(addprefix $(HOME)/, $(SRC))
TISRC = $(wildcard terminfo/*.terminfo)
TIDST = $(foreach x, $(TISRC), $(HOME)/.terminfo/$(shell basename $x|cut -c 1)/$(shell basename $x .terminfo))

$(HOME)/.terminfo/s/%: terminfo/%.terminfo
	@echo "$< => $@"
	@tic $<

$(HOME)/%: %
	@echo "$< -> $@"
	@$(INSTALL) $(shell dirname $@)
	@$(CP) $< $@

install: $(DST) $(TIDST)

clean:
	@$(foreach f, $(SRC), ($(CMP) $(f) $(HOME)/$(f) && \
		echo "removing $(f)" && $(RM) $(HOME)/$(f) && echo "removing $(shell dirname $(f))" && $(RMDIR) $(shell dirname $(HOME)/$(f))) || :;)

.PHONY: clean
