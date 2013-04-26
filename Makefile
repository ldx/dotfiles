#
# See https://github.com/ldx/dotfiles.git
#
# Run 'make' or 'make install' to copy all dotfiles to
# your ~.
#

CP = cp -a
RM = rm
INSTALL = install -p
CMP = cmp -s
RMDIR = rmdir -p --ignore-fail-on-non-empty

TOP_EXCLUDE = . .. .git .gitmodules terminfo Makefile
EXCLUDE= $(foreach x, .git .gitmodules .gitignore, -path "*/$(x)" -prune -o)
ALL = $(filter-out $(TOP_EXCLUDE), $(wildcard .* *))
SRC = $(foreach x, $(ALL), $(shell find $(x) $(EXCLUDE) -type f -print;))
DST = $(addprefix $(HOME)/, $(SRC))
TISRC = $(wildcard terminfo/*.terminfo)
TIDST = $(foreach x, $(TISRC), $(HOME)/.terminfo/$(shell basename $x|cut -c 1)/$(shell basename $x .terminfo))

$(HOME)/.local/share/applications/%: .local/share/applications/%
	@echo "$< -> $@"
	@$(INSTALL) -m $(shell stat -c %a $<) $< $@
ifneq ($(shell which gsettings > /dev/null),)
	@gsettings set com.canonical.Unity.Launcher favorites $(shell echo "import os.path\nlauncher='application://' + os.path.basename('$<')\nli=`gsettings get com.canonical.Unity.Launcher favorites`\nif launcher not in li:\n  li.insert(1, launcher)\nprint '%s%s%s' % (chr(34), li, chr(34))"|python)
endif

$(HOME)/%: %
	@echo "$< -> $@"
	@$(INSTALL) -m $(shell stat -c %a $<) $< $@

install: $(DST) $(TIDST)

clean:
	@$(foreach f, $(SRC), ($(CMP) $(f) $(HOME)/$(f) && \
		echo "removing $(f)" && $(RM) $(HOME)/$(f) && echo "removing $(shell dirname $(f))" && $(RMDIR) $(shell dirname $(HOME)/$(f))) || :;)

.PHONY: clean

.SECONDEXPANSION:
${HOME}/.terminfo/%: terminfo/$$(notdir $$*).terminfo
	@echo "$< => $@"
	@tic $<
