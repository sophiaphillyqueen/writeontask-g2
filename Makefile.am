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
# Verify and repair every installed file
# ============================================

# Automake installs scripts as mode 755 and data/manpages as mode 644.
# The verifier checks exact bytes, file type, and exact permission mode.
# On failure, it removes the destination, reinstalls it once, and checks
# again.  No temporary installation filenames are used.
#
# This shell function is shared by both installation hooks.

install_file_verifier = \
  check_installed_file () { \
    test -f "$$2" && test ! -L "$$2" && \
    cmp -s "$$1" "$$2" && \
    test -n "$$(find "$$2" -prune -type f -perm "0$$3" -print)"; \
  }; \
  verify_installed_file () { \
    if check_installed_file "$$1" "$$2" "$$3"; then return 0; fi; \
    printf 'Installation verification failed; removing and reinstalling: %s\n' "$$2" >&2; \
    lc_failure='Could not delete the defective destination'; \
    if rm -f "$$2"; then \
      lc_failure='Reinstallation command failed'; \
      if test "$$3" = 755; then \
        if $(INSTALL_SCRIPT) "$$1" "$$2"; then lc_failure=; fi; \
      else \
        if $(INSTALL_DATA) "$$1" "$$2"; then lc_failure=; fi; \
      fi; \
      if test -z "$$lc_failure"; then \
        if check_installed_file "$$1" "$$2" "$$3"; then \
          printf 'Reinstallation verified: %s\n' "$$2"; \
          return 0; \
        fi; \
        lc_failure='Reinstalled file still fails content or permission verification'; \
      fi; \
    fi; \
    printf '\n\nFATAL INSTALLATION ERROR: %s\nFile: %s\nSource: %s\n\n' \
      "$$lc_failure" "$$2" "$$1" >&2; \
    return 1; \
  }


# ============================================
# macOS quarantine protection
# ============================================

# Keep the original quarantine cleanup after executable verification.
# Only selected macOS builds require xattr.

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


# ============================================
# Check installed scripts after Automake installs them
# ============================================

install-exec-hook:
	@set -e; \
	$(install_file_verifier); \
	for lc_file in $(nodist_bin_SCRIPTS); do \
	  lc_source="$$lc_file"; \
	  if test ! -f "$$lc_source"; then lc_source='$(srcdir)/'"$$lc_file"; fi; \
	  lc_name=$${lc_file##*/}; \
	  lc_name=$$(printf '%s\n' "$$lc_name" | sed '$(transform)'); \
	  lc_dest='$(DESTDIR)$(bindir)/'"$$lc_name"; \
	  verify_installed_file "$$lc_source" "$$lc_dest" 755; \
	done


if MACOS_QUARANTINE_CLEANUP

# This recipe is added to the same install-exec-hook, after verification.
	@set -e; \
	for lc_file in $(quarantine_executables); do \
	  if ! "$(XATTR)" -l "$$lc_file" >/dev/null 2>&1; then \
	    printf '\n\nFATAL INSTALLATION ERROR: Cannot inspect extended attributes\nFile: %s\n\n' "$$lc_file" >&2; \
	    exit 1; \
	  fi; \
	  if "$(XATTR)" -p com.apple.quarantine "$$lc_file" >/dev/null 2>&1; then \
	    if ! "$(XATTR)" -d com.apple.quarantine "$$lc_file"; then \
	      printf '\n\nFATAL INSTALLATION ERROR: Cannot remove quarantine\nFile: %s\n\n' "$$lc_file" >&2; \
	      exit 1; \
	    fi; \
	  fi; \
	  if "$(XATTR)" -p com.apple.quarantine "$$lc_file" >/dev/null 2>&1; then \
	    printf '\n\nFATAL INSTALLATION ERROR: Quarantine still present\nFile: %s\n\n' "$$lc_file" >&2; \
	    exit 1; \
	  fi; \
	done

endif


# ============================================
# Check installed data and manual pages
# ============================================

install-data-hook:
	@set -e; \
	$(install_file_verifier); \
	for lc_file in $(dist_pkgdata_DATA); do \
	  lc_source="$$lc_file"; \
	  if test ! -f "$$lc_source"; then lc_source='$(srcdir)/'"$$lc_file"; fi; \
	  lc_dest='$(DESTDIR)$(pkgdatadir)/'"$${lc_file##*/}"; \
	  verify_installed_file "$$lc_source" "$$lc_dest" 644; \
	done; \
	for lc_file in $(dist_man1_MANS) $(dist_man7_MANS); do \
	  case "$$lc_file" in \
	    *.1) lc_dir='$(DESTDIR)$(man1dir)'; lc_ext=1 ;; \
	    *.7) lc_dir='$(DESTDIR)$(man7dir)'; lc_ext=7 ;; \
	  esac; \
	  lc_source="$$lc_file"; \
	  if test ! -f "$$lc_source"; then lc_source='$(srcdir)/'"$$lc_file"; fi; \
	  lc_stem=$${lc_file##*/}; \
	  lc_stem=$${lc_stem%.*}; \
	  lc_name=$$(printf '%s\n' "$$lc_stem" | sed '$(transform)'); \
	  lc_dest="$$lc_dir/$$lc_name.$$lc_ext"; \
	  verify_installed_file "$$lc_source" "$$lc_dest" 644; \
	done


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

