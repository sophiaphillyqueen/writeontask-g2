# Building and Installing writeontask-g2

This document explains how to build, configure, test, install,
uninstall, and package `writeontask-g2`.

No previous experience with GNU Autoconf or Automake is required.

The project uses the standard GNU Autotools build procedure.
Its generated programs and manual pages are placed in a
directory named `build/`, which the build system creates
automatically. Source-distribution archives include pre-generated
manual pages in that same directory.

**You do not need to create or enter `build/` yourself.**

## 1. Understanding the build process

Building and installing are separate operations.

The usual sequence is:

1. **Bootstrap** — Generate the configuration infrastructure,
   if it is not already present.
2. **Configure** — Check the system and determine how the
   software should be built and installed.
3. **Build** — Generate the executable programs and manual pages.
4. **Test** — Run the project's automated checks.
5. **Install** — Copy the resulting files into their configured
   installation directories.

The commands used for these operations are:

| Operation | Command |
|---|---|
| Bootstrap | `autoreconf -fi` |
| Configure | `./configure` |
| Build | `make` |
| Test | `make check` |
| Install | `make install` |

All these commands are run from the top-level project directory.

The bootstrap step is necessary when building from a Git checkout,
but not when building from a generated source-distribution archive.

The build system does not install anything merely because you run
`./configure` or `make`.

Installation takes place only when you run `make install`.

## 2. Prerequisites

The software requires:

- Perl and its standard modules.
- Pandoc, when generated manual pages are not already supplied.
- A compatible `make` implementation.
- Standard Unix command-line utilities.

Building from a Git checkout additionally requires:

- GNU Autoconf.
- GNU Automake.

Source-distribution archives contain the generated configuration
infrastructure **and both pre-generated manual pages**. They can
be built without Autoconf, Automake, or Pandoc. If Pandoc is
available, the normal Makefile dependency rules can still use it
to refresh out-of-date manual pages.

### macOS

Install Apple's Command Line Tools if necessary:

```sh
xcode-select --install
```

If using Homebrew, install the additional prerequisites with:

```sh
brew install autoconf automake pandoc
```

### Debian and Ubuntu GNU/Linux

```sh
sudo apt update
sudo apt install autoconf automake make perl pandoc
```

### Fedora GNU/Linux

```sh
sudo dnf install autoconf automake make perl pandoc
```

### Arch GNU/Linux

```sh
sudo pacman -S autoconf automake make perl pandoc
```

### openSUSE GNU/Linux

```sh
sudo zypper install autoconf automake make perl pandoc
```

### Alpine Linux

For building from a source-distribution archive:

```sh
apk add make perl
```

For building directly from a Git checkout, Autoconf, Automake,
and Pandoc are also required; install them only where available.
In particular, Pandoc may be unavailable on iSH, so use a
source-distribution archive there.

### FreeBSD

```sh
sudo pkg install autoconf automake gmake perl5 pandoc
```

Use `gmake` in place of `make` for the build commands if the
system's default `make` is incompatible.

### Windows Subsystem for Linux

Use the instructions for the GNU/Linux distribution running
inside WSL.

Audio playback and display-sleep inhibition depend on the
available operating-system and desktop facilities.

Native Microsoft Windows builds are not covered by these
instructions.

## 3. Building from a Git checkout

After cloning the repository, enter its top-level directory.

### Step 1: Bootstrap

```sh
autoreconf -fi
```

This reads files such as `configure.ac` and `Makefile.am` and
generates the standard Autotools infrastructure.

Among the generated files are:

- `configure` — The configuration script.
- `Makefile.in` — A template used to generate the Makefile.
- Supporting Autotools scripts.

You normally need to bootstrap only once, unless the build-system
source files change.

### Step 2: Configure

```sh
./configure
```

This checks the system for required programs, determines the
operating-system-specific functionality available, and creates
the Makefile used by subsequent commands.

It **always checks for Pandoc**. If Pandoc is unavailable, both
pre-generated manual pages must already be present, or
configuration fails with an explanation. A fresh Git checkout
does not contain these pages, whereas a source tarball does.

Configuration also determines where files will be installed.

**You may supply configuration options according to your own
requirements.**

The command above does not prescribe any custom installation
directory or backend selection.

See Section 5 for an explanation of configuration options.

### Step 3: Build

```sh
make
```

This generates:

- `writeontask`
- `writeontask-bl2`
- `writeontask-g2-util`
- Any selected compatibility executables.
- The Unix manual pages, if absent or older than their Markdown
  sources and Pandoc is available.

These generated project files are placed inside `build/`.
When Pandoc is unavailable, the supplied manual pages are used
without running a converter.

The directory is created automatically.

Autotools configuration files, such as `Makefile` and
`config.status`, remain in the project root because they
are part of the conventional Autoconf configuration process.

### Step 4: Test

```sh
make check
```

The current automated checks verify:

- Perl syntax for the main implementation.
- Perl syntax for the generated public wrappers.
- Successful generation of the manual pages.

A successful result confirms that these checks passed.

It does not guarantee that audio playback, display-sleep
inhibition, or writing-session recovery will work in every
runtime environment.

Those features should also be tested where appropriate.

### Step 5: Install

```sh
make install
```

This copies the generated programs, resources, and manual pages
into the directories chosen during configuration.

**The build system does not assume that those directories are
writable by the current user.**

Depending on the configuration, installation may require
additional filesystem permissions.

Choose installation destinations and permissions appropriate
for your system.

Do not automatically use administrator privileges unless they
are necessary for the selected installation directories.

## 4. Building from a source-distribution archive

A source distribution generated by Automake contains the
configuration script and its supporting files.

After extracting the archive, enter its top-level directory
and run:

```sh
./configure
make
make check
make install
```

The `autoreconf -fi` step is unnecessary because the
configuration infrastructure is already included.

**Pandoc is also optional for source-distribution builds**,
because both generated manual pages are included in the archive.
Configuration still detects Pandoc if it is available; `make`
then uses normal file timestamps to decide whether a page
needs regeneration.

The same operating-system and installation options are
available as when building from a Git checkout.

## 5. Understanding configuration options

The `configure` script supports the conventional GNU Autoconf
installation and feature-selection options.

To see them:

```sh
./configure --help
```

This displays the available options without configuring
or building the project.

### Installation directories

The directory choices are made during configuration.

If no installation-directory options are supplied, Autoconf
uses its standard defaults.

For example, GNU Autoconf conventionally uses `/usr/local`
as the default installation prefix.

This is a default, **not a required installation location**.

You can select another prefix with:

```text
./configure --prefix=DIR
```

Replace `DIR` with the directory you actually want.

Other conventional options include:

| Option | Purpose |
|---|---|
| `--prefix=DIR` | General installation prefix |
| `--bindir=DIR` | Public executable directory |
| `--libexecdir=DIR` | Private executable directory |
| `--datadir=DIR` | Shared data directory |
| `--mandir=DIR` | Unix manual-page directory |

You do not have to specify every directory separately.

The installation-directory options can be combined with
the project's backend options in a single invocation of
`./configure`.

### Where the files go

The project installs the following categories of files:

| Category | Contents |
|---|---|
| Public executables | `writeontask`, `writeontask-bl2` |
| Private executables | `writeontask-g2-util` and selected compatibility utilities |
| Shared data | Alarm recordings and audio credits |
| Manual page, section 1 | Main command reference |
| Manual page, section 7 | Session-message reference |

The exact installed paths depend on the configuration
selected by the person performing the installation.

The program wrappers are generated using those configured
paths.

They do not assume any particular user's home directory.

### Reconfiguring

You can run `./configure` again to change the configuration.

When doing so, supply whichever options you want the new
configuration to use.

**Do not assume that omitting an option will preserve a
previously supplied custom value.**

If you want to retain your earlier choices, repeat those
options when reconfiguring.

Then run:

```sh
make
make check
make install
```

## 6. Platform-specific compatibility backends

The main program is written in Perl.

Optional compatibility executables provide:

- Audio playback through `writeontask-afplay`.
- Display-sleep inhibition through `writeontask-caffeinate`.

The two features are selected independently during
configuration.

### Audio playback

Supported audio-backend selections are:

| Selection | Behavior |
|---|---|
| `auto` | Choose the platform default |
| `macos` | Use Apple's native `afplay` |
| `none` | Do not install an audio compatibility executable |

On macOS, automatic selection uses the native backend.

On other operating systems, the current automatic selection
is `none`.

The relevant configuration option is:

```text
--with-audio-backend=BACKEND
```

To disable the backend explicitly:

```text
--without-audio-backend
```

An explicitly selected macOS backend requires a macOS target.

### Display-sleep inhibition

Supported sleep-backend selections are:

| Selection | Behavior |
|---|---|
| `auto` | Choose the platform default |
| `native` | Use Apple's native `caffeinate` |
| `adaptive` | Use the adaptive compatibility implementation |
| `none` | Do not install the compatibility executable |

On macOS, automatic selection uses the native backend.

On native Linux builds, automatic selection checks whether
an executable named `caffeinate` is available.

If one is found, the adaptive backend is selected.

Otherwise, display-sleep inhibition is omitted by default.

On other operating systems, the automatic selection is `none`.

The relevant configuration option is:

```text
--with-sleep-backend=BACKEND
```

To disable the backend explicitly:

```text
--without-sleep-backend
```

The adaptive implementation examines the command interface
of the installed `caffeinate` executable at runtime.

It recognizes supported interfaces, including macOS-style
and Debian-style implementations.

Unrecognized implementations are rejected rather than
assumed to be compatible.

Actual display-sleep inhibition also depends on the
capabilities of the operating system and desktop session.

### Cross-compilation

Configuration distinguishes between the system performing
the build and the system that will run the program.

A utility found on the build machine is not automatically
assumed to exist on a different target system.

Automatic backend selection is conservative during
cross-compilation.

Explicit backend selection remains available where supported.

## 7. macOS quarantine protection

macOS may attach an extended attribute named
`com.apple.quarantine` to executable files.

This attribute can interfere with running installed scripts.

For native macOS builds targeting macOS, the project
automatically enables mandatory quarantine cleanup.

The decision is made during `./configure`, not when the
source distribution is created.

### Configuration requirements

On a native macOS build, configuration requires:

```text
/usr/bin/xattr
```

If Apple's `xattr` utility is unavailable, configuration
fails rather than silently disabling quarantine protection.

### Installation behavior

During `make install`, the installation hook:

1. Inspects the installed project executables.
2. Removes `com.apple.quarantine` where present.
3. Verifies that the attribute is absent afterward.
4. Fails installation if inspection, removal, or verification
   fails.

This applies to:

- Both public command wrappers.
- The private Perl implementation.
- Every selected compatibility executable.

The hook respects configured installation directories and
package-staging paths.

On non-macOS systems, it is disabled.

It is also disabled when cross-building for macOS from
a non-macOS build system.

**The same source distribution therefore supports macOS
and other operating systems without needing separate
platform-specific archives.**

### Avoiding renewed quarantine

Editing installed executables with certain applications
may cause macOS to attach quarantine attributes again.

When possible, modify the source files and reinstall
rather than editing installed executables directly.

## 8. Rebuilding after source changes

If you modify the program source or other ordinary input
files, rebuild using:

```sh
make
make check
```

Install the new build when ready:

```sh
make install
```

If you modify `configure.ac` or `Makefile.am` in a Git
checkout, regenerate the Autotools infrastructure:

```sh
autoreconf -fi
```

Then run `./configure` with your intended configuration
options and rebuild:

```sh
make
make check
make install
```

Reconfiguration remains an explicit operation.

The build system does not silently choose installation
options on your behalf.

## 9. Cleaning generated files

There are several levels of cleanup.

All commands in this section are run from the project root.

### Remove generated project files

```sh
make clean
```

This removes generated executables while retaining the
configuration. In a Git checkout without pre-generated manual
pages, it also removes generated manual pages. In an extracted
source tarball, the distributed manual pages are preserved so
that a later build does not suddenly require Pandoc.

The `build/` directory may remain, but its contents are
ignored by Git in a checkout.

### Remove configuration results

```sh
make distclean
```

This performs the standard Automake distribution-cleanup
procedure, removing configuration results as well as
ordinary build products.

Afterward, rerun `./configure` before building again.

Autotools files generated by `autoreconf -fi` are not
necessarily removed by `make distclean`.

### Remove all ignored generated files

When working in a Git checkout, the project's `.gitignore`
covers:

- The entire `build/` directory.
- Generated Autotools infrastructure in the repository root.
- Distribution archives matching the configured ignore rules.
- Common macOS filesystem metadata.

First, preview the ignored files and directories that
would be removed:

```sh
git clean -ndX
```

Inspect this output carefully.

It is especially important to check for any valuable files
that you may have placed inside ignored directories.

If everything listed can safely be discarded, run:

```sh
git clean -fdX
```

The uppercase `-X` limits removal to ignored files.

Ordinary untracked files that are not ignored are preserved.

**Do not substitute lowercase `-x` casually.** That option
also permits deletion of ordinary untracked files.

Neither command reverts modifications to tracked files.

Cleaning the source tree does not uninstall the software
or remove personal writing-session data.

## 10. Uninstalling

To uninstall the package using the current configuration:

```sh
make uninstall
```

Run this while the configured Makefile still exists.

The same installation-directory configuration should be
used for uninstalling as was used for installing.

If installed resource filenames have changed between
versions, old installed resources may need separate cleanup,
because a newer Makefile does not necessarily know which
filenames an older version installed.

### Personal session data

Uninstalling the application does not remove personal
session-state files.

If `XDG_STATE_HOME` is set to an absolute path, the program
uses:

```text
$XDG_STATE_HOME/writeontask-g2/
```

Otherwise, it uses:

```text
$HOME/.local/state/writeontask-g2/
```

This directory stores process communications and recovery
information, including the criogenum.

The installation system does not own this user data.

## 11. Staged installation for package maintainers

Automake supports installation into a temporary staging
directory using `DESTDIR`.

The general syntax is:

```text
make DESTDIR=STAGING_DIRECTORY install
```

`STAGING_DIRECTORY` is the temporary directory selected
by the package maintainer.

The configured installation paths remain intact beneath
the staging directory.

The staging directory itself is not embedded into the
installed program wrappers.

The macOS quarantine-cleanup hook, when enabled, also
uses the staged executable paths.

## 12. Creating source distributions

After configuration, run:

```sh
make dist
```

Automake creates a source-distribution archive containing
the files required to build and install the project, including
**both generated manual pages**. From a fresh Git checkout,
Pandoc must be available to generate those pages before the
archive can be completed.

The distribution archive is written to the project root.

### Development snapshots

When the version identifier ends in `-dev`, the archive
name includes a UTC timestamp generated when the
distribution is created.

The timestamp format is:

```text
YYYY-MM-DD--HH-mm-ssZ
```

For example:

```text
writeontask-g2-0.0.1-dev-2026-10-13--09-45-25Z.tar.gz
```

The archive's internal top-level directory uses the
same timestamped distribution name.

The timestamp does not change the software's version
identifier.

### Release distributions

Versions without the `-dev` suffix use conventional
untimestamped names.

For example:

```text
writeontask-g2-0.0.1.tar.gz
```

### Validate a source distribution

Run:

```sh
make distcheck
```

This performs Automake's distribution validation,
including rebuilding and checking the generated archive
in a separate temporary environment.

It helps detect missing distribution files and build-system
problems.

It is not a substitute for testing platform-dependent
runtime functionality on the intended operating systems.

### Alternative archive formats

Automake provides additional distribution targets:

```sh
make dist-gzip
make dist-bzip2
make dist-xz
make dist-zip
```

The corresponding archive utilities must be available.

## 13. Troubleshooting

### `autoreconf` is not found

Install GNU Autoconf and Automake.

This step is needed when bootstrapping a Git checkout,
not when building an already-generated source distribution.

### `configure` is not found

If building from a Git checkout, run:

```sh
autoreconf -fi
```

Then run the generated `./configure` script.

### Pandoc is missing

When installing directly from a Git checkout, install Pandoc,
then rerun configuration; the manual pages need to be generated.
If Pandoc cannot be installed (for example, on iSH), use a
source tarball generated by `make dist` on another machine.
The tarball already includes both manual pages.

### `make` reports that no Makefile exists

Run `./configure` first.

If building from a Git checkout, make sure the Autotools
bootstrap step has also completed successfully.

### Installation reports a permissions error

Check the installation directories chosen during
configuration and whether the installing user has
permission to write to them.

Do not assume that every installation requires
administrator privileges.

### An executable runs as a shell script instead of Perl

A Perl script's interpreter line must be the very first
line of the executable file.

The wrapper templates use:

```text
#!@PERL_PATH@
```

During building, this placeholder is replaced with
the configured Perl interpreter pathname.

### An installed command appears outdated

Rebuild and reinstall:

```sh
make
make check
make install
```

Check which executable your shell is finding:

```sh
command -v writeontask
```

The result depends on the configured installation
directories and your shell's `PATH`.

### No audio is produced

Check the audio backend selected during configuration.

The current build does not provide an audio backend
automatically on every operating system.

### Display-sleep inhibition does not work

Check whether the selected `caffeinate` implementation
supports the required interface and whether the active
desktop environment honors its requests.

### macOS quarantine cleanup fails

Inspect the executable named in the installation error
and verify that `/usr/bin/xattr` can inspect and modify
its extended attributes.

Quarantine protection must not be bypassed silently.

### Git cleanup lists an unexpected file

Do not proceed with `git clean -fdX` until you have
determined whether the file is safe to delete.

## 14. Command reference

Unless otherwise specified, run these commands from
the project root.

| Task | Command |
|---|---|
| Bootstrap a Git checkout | `autoreconf -fi` |
| Display configuration options | `./configure --help` |
| Configure | `./configure` |
| Build | `make` |
| Test | `make check` |
| Install | `make install` |
| Uninstall | `make uninstall` |
| Remove build products | `make clean` |
| Remove configuration results | `make distclean` |
| Preview ignored files | `git clean -ndX` |
| Remove ignored files | `git clean -fdX` |
| Create a source archive | `make dist` |
| Validate a source archive | `make distcheck` |

The person configuring the software is responsible for
choosing any nondefault installation directories or
feature-selection options.

The build system automatically manages the `build/`
directory and requires no manual intervention to do so.

## Licensing

- Software: GNU GPL version 3 or later (`GPL-3.0-or-later`).
- Documentation: GNU Free Documentation License version 1.3
  or later (`GFDL-1.3-or-later`).
- Audio recordings and modifications: CC0 1.0 Universal
  (`CC0-1.0`).

See `LICENSE` and `audio-res/sound-credits.md` for the
software-license text and audio provenance.

