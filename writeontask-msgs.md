% WRITEONTASK-MSGS(7)
%
% October 2026

# NAME

writeontask-msgs — messages accepted by the writeontask writing treadmill

# SYNOPSIS

`writeontask --msg MESSAGE`

`writeontask -m MESSAGE`

# DESCRIPTION

The `--msg` and `-m` options send directives to an already running `writeontask` session.

Messages are queued for processing by the main program, so the sending command can terminate before the requested action takes effect.

# SESSION CONTROL

## pause

Pause advancement of the writing target

    writeontask -m pause

- Current word count: continues to reflect monitored files
- Writing target: stops advancing
- Repeated pause: reports that the treadmill is already paused

## unpause

Resume advancement of the writing target

    writeontask -m unpause

- Target progression: resumes from the paused state
- Repeated unpause: reports that the treadmill was not paused

## stop

Request normal termination of the current session

    writeontask -m stop

- Main loop: terminates
- Final criogenum: written with clean-termination status
- Saved session: available for later restoration

## end

Alternative to `stop`, with identical behavior

    writeontask -m end

# WRITING RATE

## wpm:NUMBER

Change the target writing rate during an active session

    writeontask -m wpm:5

- Argument: new target rate in words per minute
- Effect: subsequent writing-target calculations use the new rate
- Session restart: unnecessary
- State: saved to the criogenum

Unlike the startup `--wpm` option, this message currently has no positive-number validation.

# MONITORED FILE DISPLAY

## list

Display the monitored files and their individual word counts

    writeontask -m list

- Output: one entry per monitored file
- Entry contents: current word count and pathname
- Ordering: current monitored-file ordering

## list:SECONDS

Display the monitored-file list and delay further processing by approximately the requested number of seconds

    writeontask -m list:10

For an immediate return to normal processing, use:

    writeontask -m list:0

# MONITORED FILE ORDERING

## sort

Sort monitored files alphabetically by complete pathname

    writeontask -m sort

- Comparison: Perl's case-sensitive lexical string comparison
- Compared text: complete pathname, including directory components
- Word counts and writing target: unchanged
- New ordering: saved to the criogenum

## nsort

Sort monitored files naturally by complete pathname

    writeontask -m nsort

- Comparison: consecutive ASCII digits compared as nonnegative integers
- Other characters: case-sensitive lexical comparison
- Large integers: compared without numeric conversion or integer overflow
- Equal numeric values: original pathname spelling used as final tie-breaker
- Word counts and writing target: unchanged
- New ordering: saved to the criogenum

Example ordering:

| `sort` | `nsort` |
|---|---|
| chapter1.md | chapter1.md |
| chapter10.md | chapter2.md |
| chapter2.md | chapter10.md |

# INVALID MESSAGES

Unrecognized message names cause an `Unknown message type` diagnostic in the running program.

# SEE ALSO

`writeontask(1)` — primary manual, including file addition and removal through `--addfile` and `--cutfile`

