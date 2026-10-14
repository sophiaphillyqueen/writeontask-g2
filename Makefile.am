
# ============================================
# Public commands and core utility
# ============================================

nodist_bin_SCRIPTS = \
  build/writeontask \
  build/writeontask-bl2 \
  build/writeontask-g2-util


# ============================================
# Compatibility utilities
# ============================================

if BUILD_MACOS_AFPLAY
nodist_bin_SCRIPTS += build/writeontask-afplay
endif

if BUILD_NATIVE_CAFFEINATE
nodist_bin_SCRIPTS += build/writeontask-caffeinate
endif

if BUILD_ADAPTIVE_CAFFEINATE
nodist_bin_SCRIPTS += build/writeontask-caffeinate
endif


# ============================================
# Audio resources
# ============================================

dist_pkgdata_DATA = \
  audio-res/bell-sound-0001.wav \
  audio-res/bell-sound-0002.wav \
  audio-res/bell-sound-0003.wav \
  audio-res/bell-sound-0004.wav \
  audio-res/sound-credits.md


# ============================================
# Manual pages
# ============================================

dist_man1_MANS = build/writeontask.1
dist_man7_MANS = build/writeontask-msgs.7


# ============================================
# Source files for distribution
# ============================================

EXTRA_DIST = \
  writeontask.pl \
  writeontask.in \
  writeontask-bl2.in \
  d-writeontask-afplay/native-delegate \
  d-writeontask-caffeinate/native-delegate \
  d-writeontask-caffeinate/adaptive \
  writeontask.md \
  writeontask-msgs.md \
  BUILDING.md \
  LICENSE


# ============================================
# Generate the public Perl wrappers
# ============================================

# Embed actual installation paths, never DESTDIR paths.

build/writeontask: $(srcdir)/writeontask.in Makefile
	$(MKDIR_P) build
	sed \
	  -e 's|@PERL_PATH@|$(PERL)|g' \
	  -e 's|@DATADIR@|$(datadir)|g' \
	  $(srcdir)/writeontask.in > $@.tmp
	chmod +x $@.tmp
	mv $@.tmp $@

build/writeontask-bl2: $(srcdir)/writeontask-bl2.in Makefile
	$(MKDIR_P) build
	sed \
	  -e 's|@PERL_PATH@|$(PERL)|g' \
	  -e 's|@DATADIR@|$(datadir)|g' \
	  $(srcdir)/writeontask-bl2.in > $@.tmp
	chmod +x $@.tmp
	mv $@.tmp $@


# ============================================
# Generate the core utility
# ============================================

build/writeontask-g2-util: $(srcdir)/writeontask.pl
	$(MKDIR_P) build
	cp $(srcdir)/writeontask.pl $@
	chmod +x $@


# ============================================
# Audio playback compatibility
# ============================================

if BUILD_MACOS_AFPLAY

build/writeontask-afplay: $(srcdir)/d-writeontask-afplay/native-delegate
	$(MKDIR_P) build
	cp $(srcdir)/d-writeontask-afplay/native-delegate $@
	chmod +x $@

endif


# ============================================
# Display-sleep inhibition compatibility
# ============================================

if BUILD_NATIVE_CAFFEINATE

build/writeontask-caffeinate: $(srcdir)/d-writeontask-caffeinate/native-delegate
	$(MKDIR_P) build
	cp $(srcdir)/d-writeontask-caffeinate/native-delegate $@
	chmod +x $@

endif

if BUILD_ADAPTIVE_CAFFEINATE

build/writeontask-caffeinate: $(srcdir)/d-writeontask-caffeinate/adaptive
	$(MKDIR_P) build
	cp $(srcdir)/d-writeontask-caffeinate/adaptive $@
	chmod +x $@

endif


# ============================================
# Generate manual pages using Pandoc
# ============================================

if HAVE_PANDOC

build/writeontask.1: $(srcdir)/writeontask.md
	$(MKDIR_P) build
	$(PANDOC) --standalone --from=markdown --to=man \
	  --output=$@ $(srcdir)/writeontask.md

build/writeontask-msgs.7: $(srcdir)/writeontask-msgs.md
	$(MKDIR_P) build
	$(PANDOC) --standalone --from=markdown --to=man \
	  --output=$@ $(srcdir)/writeontask-msgs.md

endif


# ============================================
# Basic build verification
# ============================================

check-local:
	$(PERL) -c $(srcdir)/writeontask.pl
	$(PERL) -c build/writeontask
	$(PERL) -c build/writeontask-bl2
	test -s build/writeontask.1 || test -s $(srcdir)/build/writeontask.1
	test -s build/writeontask-msgs.7 || test -s $(srcdir)/build/writeontask-msgs.7


# ============================================
# macOS quarantine protection
# ============================================

# Include only executables actually selected for installation.
# Quote every pathname to support installation paths with spaces.
#
# DESTDIR is included for staged/package installations.

quarantine_executables = \
  "$(DESTDIR)$(bindir)/writeontask" \
  "$(DESTDIR)$(bindir)/writeontask-bl2" \
  "$(DESTDIR)$(bindir)/writeontask-g2-util"

if BUILD_MACOS_AFPLAY
quarantine_executables += "$(DESTDIR)$(bindir)/writeontask-afplay"
endif

if BUILD_NATIVE_CAFFEINATE
quarantine_executables += "$(DESTDIR)$(bindir)/writeontask-caffeinate"
endif

if BUILD_ADAPTIVE_CAFFEINATE
quarantine_executables += "$(DESTDIR)$(bindir)/writeontask-caffeinate"
endif


# Only macOS builds with quarantine protection enabled
# receive this installation hook.
#
# Inspect each installed executable, remove its quarantine
# attribute if present, and verify that it is absent afterward.
#
# An inspection or removal failure is an installation error.

if MACOS_QUARANTINE_CLEANUP

install-exec-hook:
	@set -e; \
	for lc_file in $(quarantine_executables); do \
	  if ! "$(XATTR)" -l "$$lc_file" >/dev/null 2>&1; then \
	    echo "Cannot inspect extended attributes: $$lc_file" >&2; \
	    exit 1; \
	  fi; \
	  if "$(XATTR)" -p com.apple.quarantine "$$lc_file" >/dev/null 2>&1; then \
	    if ! "$(XATTR)" -d com.apple.quarantine "$$lc_file"; then \
	      echo "Cannot remove quarantine: $$lc_file" >&2; \
	      exit 1; \
	    fi; \
	  fi; \
	  if "$(XATTR)" -p com.apple.quarantine "$$lc_file" >/dev/null 2>&1; then \
	    echo "Quarantine still present: $$lc_file" >&2; \
	    exit 1; \
	  fi; \
	done

endif


# ============================================
# Generated files removed by make clean
# ============================================

CLEANFILES = \
  build/writeontask \
  build/writeontask-bl2 \
  build/writeontask-g2-util \
  build/writeontask-afplay \
  build/writeontask-caffeinate

# Source distributions carry pre-generated manpages, which must
# survive make clean even when Pandoc is not installed.

if !HAVE_PREBUILT_MANPAGES
CLEANFILES += build/writeontask.1 build/writeontask-msgs.7
endif


# ============================================
# Timestamp development distributions
# ============================================

# UTC timestamp is generated when make runs, not at configure time.
# Pass the stamp to recursive make so distcheck uses the same name.

DIST_STAMP := $(shell lc_version='$(VERSION)'; if test "$${lc_version%-dev}" != "$$lc_version"; then date -u '+-%Y-%m-%d--%H-%M-%SZ'; fi)
AM_MAKEFLAGS = DIST_STAMP=$(DIST_STAMP)
distdir = $(PACKAGE)-$(VERSION)$(DIST_STAMP)

