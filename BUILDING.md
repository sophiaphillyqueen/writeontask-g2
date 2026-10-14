# Building and Installing writeontask-g2

This project uses **standard GNU Autoconf and Automake**. All commands below run in the **repository root**, not in a separate working directory.

The generated Makefile creates a single directory named `build/` automatically and writes generated program executables and manual pages there. It does not relocate Autoconf's own files (`configure`, `Makefile`, and associated files) or Automake's source-distribution archives, which are covered by `.gitignore`.

There is no custom Makefile dispatcher, configuration launcher, or manually created build directory.

## 1. Prerequisites

- Perl and its standard modules.
- Pandoc, for generating Unix manual pages.
- `make` and standard Unix utilities.
- GNU Autoconf and GNU Automake **when bootstrapping a Git checkout**. They are not required simply to configure a generated source distribution.

### macOS

Install Apple's Command Line Tools if necessary:

```sh
xcode-select --install
```

Install the remaining prerequisites:

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

```sh
apk add autoconf automake make perl pandoc
```

Package availability may vary by Alpine release and architecture, including in iSH.

### FreeBSD

```sh
sudo pkg install autoconf automake gmake perl5 pandoc
```

Use `gmake` in place of `make` if the system's default `make` is incompatible with the generated Makefile.

### Windows Subsystem for Linux

Use your GNU/Linux distribution's instructions; audio and display-sleep behavior depend on the environment. Native Windows builds are not covered here.

## 2. Build from a Git checkout

From the repository root:

```sh
autoreconf -fi
./configure
make
make check
make install
```

`autoreconf -fi` generates the standard Autotools support files. `./configure` chooses the installation paths and backends and creates `Makefile`. The `make` rules then **automatically create `build/`** and put generated executable copies and manual pages inside it.

**Do not manually create or enter `build/`.** It is simply the destination for disposable generated project files, not a separate configuration directory.

For the example personal prefix, the installed public commands are `$HOME/local/bin/writeontask` and `$HOME/local/bin/writeontask-bl2`; administrator privileges should not be required.

Verify the installation:

```sh
"$HOME/local/bin/writeontask" --help
"$HOME/local/bin/writeontask-bl2" --help
```

`make check` verifies Perl syntax and generated manual pages; it is not a complete test of audio output or writing-session recovery.

## 3. Build from a source tarball

Extract the archive, enter its top-level directory, and run:

```sh
./configure --prefix="$HOME/local"
make
make check
make install
```

Generated source distributions contain `configure` and the supporting Autotools files, so `autoreconf -fi` is unnecessary.

## 4. Installation directories

The conventional Autoconf installation-directory options are supported:

```sh
./configure --prefix="$HOME/local"
```

| Destination | Contents |
|---|---|
| `$HOME/local/bin/` | `writeontask`, `writeontask-bl2` |
| `$HOME/local/libexec/` | `writeontask-g2-util` and selected compatibility executables |
| `$HOME/local/share/writeontask-g2/` | Alarm recordings and credits |
| `$HOME/local/share/man/man1/` | Main manual page |
| `$HOME/local/share/man/man7/` | Message manual page |

Override individual installation paths with `--bindir=DIR`, `--libexecdir=DIR`, `--datadir=DIR`, or `--mandir=DIR`.

Run `./configure --help` for the full list of options.

The installed wrappers contain the configured paths, **not** `DESTDIR` staging paths.

## 5. Compatibility backends

The project installs optional compatibility executables through independent configuration choices.

### Audio playback

- On macOS, `auto` selects a delegate to `/usr/bin/afplay`.
- On other systems, `auto` selects `none`.
- Valid `--with-audio-backend=` values: `auto`, `macos`, `none`.
- `--without-audio-backend` selects `none`.

An explicitly selected macOS backend requires a macOS target.

### Display-sleep inhibition

- On macOS, `auto` selects a delegate to `/usr/bin/caffeinate`.
- On native Linux, `auto` selects the adaptive backend if `caffeinate` is found in `PATH`, otherwise `none`.
- On other targets, `auto` selects `none`.
- Valid `--with-sleep-backend=` values: `auto`, `native`, `adaptive`, `none`.
- `--without-sleep-backend` selects `none`.

The adaptive implementation resolves `caffeinate` at runtime, identifies recognized interfaces (including macOS-style and Debian-style command forms), and rejects unknown implementations. Functional support also depends on the active desktop environment.

To disable both optional backends:

```sh
./configure --prefix="$HOME/local" \
  --without-audio-backend \
  --without-sleep-backend
```

Cross-compilation does not use an executable found on the build machine as evidence that it exists on the target. Explicit backend selection remains available where compatible.

## 6. macOS quarantine protection

On a native macOS build targeting macOS, `configure` **requires `/usr/bin/xattr`** and enables a mandatory installation hook.

During `make install`, the hook:

1. Inspects every installed `writeontask-g2` executable.
2. Removes `com.apple.quarantine` if it is present.
3. Verifies that it is absent afterward.
4. Fails installation if inspection or cleanup fails.

The hook respects installation-directory configuration and `DESTDIR` staging. It is omitted on non-macOS systems, including builds targeting macOS from a non-macOS build machine.

Do not edit installed executable files with an editor that might reapply quarantine. Modify source files, then rebuild and reinstall.

## 7. Rebuilding and reconfiguring

For normal source changes:

```sh
make
make check
make install
```

After modifying `configure.ac` or `Makefile.am`, regenerate Autotools and reconfigure, repeating your original options:

```sh
autoreconf -fi
./configure --prefix="$HOME/local"
make
make check
make install
```

The configuration step is explicit. No `make` target silently chooses a new prefix or overwrites configuration options.

## 8. Cleaning generated files

To remove generated project executables and manual pages but retain configuration:

```sh
make clean
```

To remove configuration results as well:

```sh
make distclean
```

After `make distclean`, run `./configure` again before building. Autotools bootstrap files generated by `autoreconf` remain at the repository root.

### Pristine Git working tree

`.gitignore` covers the entire `/build/` directory, known Autotools-generated root files, macOS metadata, and archives ending in `.tar`, `.gz`, or `.tgz`. The contents of `build/` never need individual ignore rules.

Preview **ignored** artifacts:

```sh
git clean -ndX
```

After checking that no important data is stored among those ignored files, remove them:

```sh
git clean -fdX
```

Uppercase `-X` preserves ordinary untracked files, unlike lowercase `-x`. Neither command reverts edits to tracked files. **Do not run cleanup on files you want to keep**, including ignored archives or manually stored files inside `build/`.

Cleaning the checkout does not uninstall the program or remove personal session data.

## 9. Uninstalling

While the same configured Makefile still exists:

```sh
make uninstall
```

Uninstallation removes installed package files but leaves user session data untouched.

The runtime state directory is `$XDG_STATE_HOME/writeontask-g2/` when `XDG_STATE_HOME` is absolute, otherwise `$HOME/.local/state/writeontask-g2/`.

## 10. Staged installations

For packaging, use the standard `DESTDIR` variable:

```sh
make DESTDIR=/tmp/writeontask-stage install
```

The configured installation prefix is preserved beneath the staging root. For a configuration made with `--prefix=/usr`, files appear beneath `/tmp/writeontask-stage/usr/`; the temporary staging prefix is not embedded in the wrappers.

## 11. Source distributions

After configuration, create a source archive:

```sh
make dist
```

For version identifiers ending in `-dev`, the distribution name receives a UTC timestamp **when the archive is created**, for example:

```text
writeontask-g2-0.0.1-dev-2026-10-13--09-45-25Z.tar.gz
```

The format is `YYYY-MM-DD--HH-mm-ssZ`, and the archive's internal top-level directory uses the same name. Release versions omit the timestamp, for example `writeontask-g2-0.0.1.tar.gz`.

Validate source archives with:

```sh
make distcheck
```

Automake also offers `make dist-gzip`, `make dist-bzip2`, `make dist-xz`, and `make dist-zip` when the relevant archive programs are available. Distribution archives are created in the repository root and are ignored by Git as requested for `.tar`, `.gz`, and `.tgz` extensions.

## 12. Troubleshooting

- **`autoreconf: command not found`:** Install GNU Autoconf and Automake before bootstrapping a Git checkout.
- **Pandoc not found:** Install Pandoc and rerun `./configure`.
- **`make` has no Makefile:** Run `autoreconf -fi` (for a Git checkout) and `./configure` first.
- **Perl script interpreted by the shell:** Its `#!` interpreter line must be the very first line of the file.
- **Installed executable is outdated:** Run `make`, `make check`, and `make install`; inspect `command -v writeontask`.
- **No alarm sound:** Check the selected audio backend and platform availability.
- **Display still sleeps:** Check the installed `caffeinate` implementation and the desktop session.
- **macOS quarantine cleanup fails:** Inspect the executable identified in the error; the installer must not silently skip cleanup.
- **Unexpected files appear in `git clean -ndX`:** Stop and preserve them before running `git clean -fdX`.

## Licensing

- Software: GNU GPL version 3 or later.
- Documentation: GNU Free Documentation License version 1.3 or later.
- Audio resources: CC0 1.0 Universal.

See `LICENSE` and `audio-res/sound-credits.md`.

