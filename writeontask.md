% WRITEONTASK(1)
%
% October 2026

# NAME

writeontask — a writing treadmill for maintaining a target writing pace

# SYNOPSIS

`writeontask [OPTIONS] [FILE ...]`

`writeontask-util MSGDIR SOUNDFILE [OPTIONS] [FILE ...]`

# DESCRIPTION

`writeontask` monitors the combined word count of selected files and compares writing progress against a target rate, expressed in words per minute.

As the writer falls behind the target, an audible alarm sounds, with its volume increasing according to the number of words behind.

The program displays the current word count, progress relative to the target, and elapsed session time.

## Word counting

- Input files: UTF-8 text
- Counting unit: whitespace-delimited token containing at least one Unicode letter or digit
- Punctuation-only tokens: excluded
- HTML-like tags: removed before counting
- Multiple files: counted together as a single writing session
- Files missing or unreadable during counting: contribute zero words

## Session timing

- Initial target: combined word count at session startup
- Target growth: configured words per minute after the head-start period
- Head start: 20 seconds by default
- Behind schedule: audible alarm with volume scaled to the deficit
- Ahead of schedule: progress display showing the estimated time advantage

# OPTIONS

`--help`, `-h`
: Display the built-in help text

`--wpm NUMBER`, `-w NUMBER`
: Target writing rate in words per minute; default `10`, requiring a positive number at startup

`--head SECONDS`, `-t SECONDS`
: Head-start duration in seconds; default `20`, requiring a nonnegative integer

`--max WORDS`
: Word deficit corresponding to maximum alarm volume; default `500`, requiring a positive integer

`--addfile FILENAME`, `-a FILENAME`
: Add a file to the monitored list of a running session

`--cutfile FILENAME`, `-x FILENAME`
: Remove a file from the monitored list of a running session

`--msg MESSAGE`, `-m MESSAGE`
: Send a message to a running session; see `writeontask-msgs(7)`

`--crio`, `-c`
: Restore a previously saved session from its criogenum

# MONITORED FILES

- Initial file list: positional filename arguments
- Additional files: `--addfile` or `-a`
- File removal: `--cutfile` or `-x`
- Duplicate detection: filesystem identity where available, otherwise resolved pathname
- Default ordering: order of addition
- Reordering: `sort` and `nsort` messages, documented in `writeontask-msgs(7)`

# SESSION CONTROL

## Sending messages

Message options communicate with an already running instance through its process-communications directory.

Multiple message options may be supplied in one invocation, with each message queued separately.

## Session recovery

The criogenum stores the monitored-file list, target rate, accumulated session timing, pause state, and other information needed to reconstruct the session.

- Storage: `criogen.json` within the process-communications directory
- Updates: periodically and after selected state changes
- Normal termination: criogenum retained
- Interrupted termination: recovery from the last successfully written criogenum
- Restoration: `writeontask --crio`

# EXAMPLES

Start a writing session with a target of five words per minute:

    writeontask --wpm 5 chapter01.md chapter02.md

Add another file to the running session:

    writeontask -a chapter03.md

Remove a file:

    writeontask -x chapter01.md

Pause the writing treadmill:

    writeontask -m pause

Resume it:

    writeontask -m unpause

Restore a previous session:

    writeontask --crio

# IMPLEMENTATION

## Executables

`writeontask`
: User-facing wrapper supplying installation-specific paths

`writeontask-util`
: Main Perl implementation

The wrapper passes the process-communications directory and alarm sound-file pathname as the first two positional arguments to `writeontask-util`, followed by the user's command-line arguments.

## Runtime requirements

- Perl
- Perl modules: `Time::HiRes`, `JSON::PP`, `Getopt::Long`, `Cwd`, `File::Spec`
- Current platform-specific utilities: `afplay`, `caffeinate`
- Additional Unix command-line utilities used internally

## Process-communications files

`current-process.dat`
: Registered process identifier

`criogen.json`
: Reconstructible session state

`mesg-*.txt`
: Queued messages awaiting processing

# SEE ALSO

`writeontask-msgs(7)` — message reference

