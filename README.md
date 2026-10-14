# writeontask-g2

**A writing treadmill that tracks your word count and alerts you when behind schedule.**

`writeontask` monitors the combined word count of one or more text files and compares progress against a target writing rate. When you fall behind, an audible alarm alerts you, increasing in volume as the deficit grows.

Features include adjustable writing speed and head start, multiple monitored files, pause/resume, session restoration through a *criogenum*, and two alternative alarm recordings.

## Requirements

The program requires Perl. Building requires Pandoc and `make`; bootstrapping a Git checkout also requires GNU Autoconf and GNU Automake.

On macOS, the build prerequisites can be installed with Homebrew:

```sh
brew install autoconf automake pandoc
```

See [BUILDING.md](BUILDING.md) for GNU/Linux, Alpine Linux, FreeBSD, and other installation details.

## Install from a Git checkout

Run these commands **from the repository root**:

```sh
autoreconf -fi
./configure
make
make check
make install
```

The installed commands are `$HOME/local/bin/writeontask` and `$HOME/local/bin/writeontask-bl2`. Include `$HOME/local/bin` in your `PATH`.

This is an ordinary Autoconf/Automake installation. The Makefile automatically creates **one directory named `build/`** and places all generated program executables and manual pages there. You do not create or enter that directory yourself. Autotools configuration files and distribution archives remain in the repository root and are covered by `.gitignore`.

When building from a source-distribution tarball, omit `autoreconf -fi`; the generated `configure` script is already included.

## Basic usage

Start a writing session targeting five words per minute:

```sh
writeontask --wpm 5 chapter01.md
```

Monitor multiple files:

```sh
writeontask --wpm 5 chapter01.md chapter02.md
```

Use the alternative alarm sound:

```sh
writeontask-bl2 --wpm 5 chapter01.md
```

Send messages to a running session:

```sh
writeontask --msg pause
writeontask --msg unpause
writeontask --msg stop
```

Restore the most recently saved session:

```sh
writeontask --crio
```

For help:

```sh
writeontask --help
```

Both public commands use the same session-state directory, so either can restore a session.

## Documentation

- [writeontask.md](writeontask.md) — Main program reference.
- [writeontask-msgs.md](writeontask-msgs.md) — Messages accepted by a running session.
- [BUILDING.md](BUILDING.md) — Detailed build, installation, packaging, and cleanup instructions.

The build converts the command-reference documents to Unix manual pages:

```sh
man 1 writeontask
man 7 writeontask-msgs
```

## Maintenance

Run `make`, `make check`, `make install`, `make uninstall`, `make clean`, `make distclean`, `make dist`, and `make distcheck` from the repository root, after configuring.

If `configure.ac` or `Makefile.am` changes, regenerate with `autoreconf -fi` and rerun `./configure` with the intended options before building.

To preview removal of ignored build artifacts without deleting ordinary untracked source files:

```sh
git clean -ndX
```

If the preview contains only disposable files:

```sh
git clean -fdX
```

See [BUILDING.md](BUILDING.md) before using Git cleanup commands.

## Platform compatibility

Audio playback and display-sleep inhibition are optional, independently selected at configuration time. Native macOS installations use Apple's `afplay` and `caffeinate` utilities and **must** remove and verify the absence of `com.apple.quarantine` on installed executables. On GNU/Linux, sleep-inhibition support depends on a compatible `caffeinate` implementation being available.

## Source archives

Development versions ending in `-dev` automatically receive a UTC timestamp when `make dist` runs, for example:

```text
writeontask-g2-0.0.1-dev-2026-10-13--09-45-25Z.tar.gz
```

Release versions use ordinary untimestamped names, such as `writeontask-g2-0.0.1.tar.gz`.

## Licensing

- Software: GNU GPL version 3 or later (`GPL-3.0-or-later`).
- Documentation: GNU Free Documentation License version 1.3 or later (`GFDL-1.3-or-later`).
- Alarm recordings and modifications: CC0 1.0 Universal (`CC0-1.0`).

See [LICENSE](LICENSE) and [audio-res/sound-credits.md](audio-res/sound-credits.md). The full documentation-license materials are still to be added before public release.

