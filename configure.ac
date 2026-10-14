AC_INIT([writeontask-g2], [0.0.1-dev])
AC_CONFIG_SRCDIR([writeontask.pl])
AM_INIT_AUTOMAKE([foreign])

AC_CANONICAL_HOST
AC_PROG_INSTALL

# Required programs.

AC_PATH_PROG([PERL], [perl])
AS_IF([test -z "$PERL"],
  [AC_MSG_ERROR([Perl is required to run writeontask-g2])])

# Detect Pandoc whether or not pre-generated manual pages are available.
# A source tarball contains both pages; a fresh Git checkout does not.
AC_PATH_PROG([PANDOC], [pandoc])

prebuilt_manpages=no
AS_IF([test -s "$srcdir/build/writeontask.1" &&
       test -s "$srcdir/build/writeontask-msgs.7"],
  [prebuilt_manpages=yes])

AS_IF([test -z "$PANDOC" && test "x$prebuilt_manpages" != xyes],
  [AC_MSG_ERROR([Pandoc is required unless both pre-generated manual pages are supplied])])

AM_CONDITIONAL([HAVE_PANDOC], [test -n "$PANDOC"])
AM_CONDITIONAL([HAVE_PREBUILT_MANPAGES], [test "x$prebuilt_manpages" = xyes])


# Audio playback backend.
#
# macos:
#   Delegate to Apple's native afplay.
#
# none:
#   Do not install writeontask-afplay.

AS_CASE([$host_os],
  [darwin*], [default_audio_backend=macos],
  [*],       [default_audio_backend=none])

AC_ARG_WITH([audio-backend],
  [AS_HELP_STRING([--with-audio-backend=BACKEND],
    [audio backend: auto, macos, none (default: auto)])],
  [with_audio_backend=$withval],
  [with_audio_backend=auto])

AS_CASE([$with_audio_backend],
  [auto|yes], [audio_backend=$default_audio_backend],
  [none|no],  [audio_backend=none],
  [macos],    [audio_backend=macos],
  [*],        [AC_MSG_ERROR([Invalid audio backend: $with_audio_backend])])

AS_IF([test "x$audio_backend" = xmacos], [
  AS_CASE([$host_os],
    [darwin*], [:],
    [*], [AC_MSG_ERROR([The macos audio backend requires a macOS target])])
])


# Display-sleep inhibition backend.
#
# native:
#   Delegate directly to Apple's caffeinate.
#
# adaptive:
#   Resolve caffeinate at runtime, identify its interface,
#   and invoke that same executable appropriately.
#
# none:
#   Do not install writeontask-caffeinate.

AS_CASE([$host_os],
  [darwin*], [default_sleep_backend=native],
  [linux*],  [default_sleep_backend=adaptive],
  [*],       [default_sleep_backend=none])

AC_ARG_WITH([sleep-backend],
  [AS_HELP_STRING([--with-sleep-backend=BACKEND],
    [sleep backend: auto, native, adaptive, none (default: auto)])],
  [with_sleep_backend=$withval],
  [with_sleep_backend=auto])

AS_CASE([$with_sleep_backend],
  [auto|yes], [sleep_backend=$default_sleep_backend],
  [none|no],  [sleep_backend=none],
  [native],   [sleep_backend=native],
  [adaptive], [sleep_backend=adaptive],
  [*],        [AC_MSG_ERROR([Invalid sleep backend: $with_sleep_backend])])


# Validate backend compatibility with the target platform.

AS_IF([test "x$sleep_backend" = xnative], [
  AS_CASE([$host_os],
    [darwin*], [:],
    [*], [AC_MSG_ERROR([The native sleep backend requires a macOS target])])
])

AS_IF([test "x$sleep_backend" = xadaptive], [
  AS_CASE([$host_os],
    [linux*], [:],
    [*], [AC_MSG_ERROR([The adaptive sleep backend requires a Linux target])])
])


# For native Linux builds, check whether caffeinate exists.
#
# Its implementation will be identified at runtime.
# Never use a build-machine executable as evidence that
# the command is available on a cross-compilation target.

AS_IF([test "x$sleep_backend" = xadaptive], [
  AS_IF([test "x$build" = "x$host"], [
    AC_PATH_PROG([CAFFEINATE_PATH], [caffeinate])

    AS_IF([test -z "$CAFFEINATE_PATH"], [
      AS_CASE([$with_sleep_backend],
        [auto|yes], [sleep_backend=none],
        [*], [AC_MSG_ERROR([The adaptive sleep backend requires caffeinate in PATH])])
    ])
  ], [
    AS_IF([test "x$with_sleep_backend" = xauto || test "x$with_sleep_backend" = xyes],
      [sleep_backend=none],
      [AC_MSG_NOTICE([Cross-build: the explicitly selected adaptive sleep backend is not checked])])
  ])
])


# macOS quarantine protection.
#
# Select this feature at configure time.
#
# It applies when both the target system and the build
# system are macOS.
#
# A non-macOS system cross-building for macOS must not
# be required to provide or execute Apple's xattr.
#
# Native macOS builds require Apple's own xattr command.

macos_quarantine_cleanup=no
XATTR=

AS_CASE([$host_os],
  [darwin*], [
    AS_CASE([$build_os],
      [darwin*], [
        AS_IF([test ! -x /usr/bin/xattr],
          [AC_MSG_ERROR([macOS installation requires /usr/bin/xattr for quarantine protection])])

        XATTR=/usr/bin/xattr
        macos_quarantine_cleanup=yes
      ],
      [*], [
        AC_MSG_NOTICE([macOS quarantine cleanup skipped when building on a non-macOS system])
      ])
  ])

AC_SUBST([XATTR])

AM_CONDITIONAL([MACOS_QUARANTINE_CLEANUP],
  [test "x$macos_quarantine_cleanup" = xyes])


# Automake conditionals.

AM_CONDITIONAL([BUILD_MACOS_AFPLAY],
  [test "x$audio_backend" = xmacos])

AM_CONDITIONAL([BUILD_NATIVE_CAFFEINATE],
  [test "x$sleep_backend" = xnative])

AM_CONDITIONAL([BUILD_ADAPTIVE_CAFFEINATE],
  [test "x$sleep_backend" = xadaptive])


# Export backend selections.

AC_SUBST([AUDIO_BACKEND], [$audio_backend])
AC_SUBST([SLEEP_BACKEND], [$sleep_backend])

AC_MSG_NOTICE([Audio backend: $audio_backend])
AC_MSG_NOTICE([Display-sleep backend: $sleep_backend])
AC_MSG_NOTICE([macOS quarantine cleanup: $macos_quarantine_cleanup])


# Generate the Makefile.

AC_CONFIG_FILES([Makefile])
AC_OUTPUT


