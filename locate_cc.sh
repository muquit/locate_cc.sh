#!/bin/bash
# locate_cc.sh - jump to the iTerm2 tab that is running Claude Code for a repo.
#
# Usage:  locate_cc.sh [-n] [repo_name]
#   no repo_name  list all Claude Code sessions and pick one
#   -n            only list, do not switch to iTerm2
#
# How it works:
#   1. find running `claude` processes (pgrep)
#   2. get each one's working directory (lsof) and terminal (ps)
#   3. keep those whose repo root or directory name contains repo_name
#   4. ask iTerm2 (AppleScript) which window/tab owns that terminal, select it
#
# Not for tmux: inside tmux the terminal is tmux's, not iTerm2's.

DRY=0
if [ "${1:-}" = "-n" ]; then
  DRY=1
  shift
fi

if [ $# -gt 1 ]; then
  echo "Usage: ${0##*/} [-n] [repo_name]" >&2
  exit 2
fi

# case-insensitive substring match; empty matches every session
WANT=$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')

PIDS=$(pgrep -x claude)
if [ -z "$PIDS" ]; then
  echo "No Claude Code processes found." >&2
  exit 1
fi

# parallel arrays (bash 3.2 on macOS has no associative arrays)
M_PID=()
M_TTY=()
M_DIR=()
M_UP=()

for pid in $PIDS; do
  cwd=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')
  [ -z "$cwd" ] && continue
  tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
  case "$tty" in
    ""|"??") continue ;;
  esac
  up=$(ps -o etime= -p "$pid" 2>/dev/null | tr -d ' ')
  root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  [ -z "$root" ] && root=$cwd
  hay=$(printf '%s\n%s' "${root##*/}" "${cwd##*/}" | tr '[:upper:]' '[:lower:]')
  case "$hay" in
    *"$WANT"*)
      M_PID+=("$pid")
      M_TTY+=("$tty")
      M_DIR+=("$cwd")
      M_UP+=("$up")
      ;;
  esac
done

N=${#M_PID[@]}
if [ "$N" -eq 0 ]; then
  if [ -z "$WANT" ]; then
    echo "No Claude Code sessions found." >&2
  else
    echo "No Claude Code session found for '$1'." >&2
  fi
  exit 1
fi

pick=0
if [ "$N" -gt 1 ] || [ -z "$WANT" ]; then
  i=0
  while [ "$i" -lt "$N" ]; do
    printf '%d) pid %s  %s  up %s  %s\n' "$((i + 1))" "${M_PID[$i]}" "${M_TTY[$i]}" "${M_UP[$i]}" "${M_DIR[$i]}"
    i=$((i + 1))
  done
  if [ "$DRY" -eq 1 ]; then
    exit 0
  fi
  printf 'Which one? [1-%d, Enter to quit] ' "$N"
  read -r ans </dev/tty
  [ -z "$ans" ] && exit 0
  case "$ans" in
    *[!0-9]*) echo "Not a number." >&2; exit 2 ;;
  esac
  if [ "$ans" -lt 1 ] || [ "$ans" -gt "$N" ]; then
    echo "Out of range." >&2
    exit 2
  fi
  pick=$((ans - 1))
else
  printf 'pid %s  %s  up %s  %s\n' "${M_PID[0]}" "${M_TTY[0]}" "${M_UP[0]}" "${M_DIR[0]}"
fi

if [ "$DRY" -eq 1 ]; then
  exit 0
fi

if [ "$(osascript -e 'application "iTerm2" is running' 2>/dev/null)" != "true" ]; then
  echo "iTerm2 is not running." >&2
  exit 1
fi

# iTerm2 reports the terminal as /dev/ttysNNN
RESULT=$(osascript - "/dev/${M_TTY[$pick]}" <<'EOF'
on run argv
  set wantTTY to item 1 of argv
  tell application "iTerm2"
    repeat with w in windows
      repeat with t in tabs of w
        repeat with s in sessions of t
          if (tty of s) is wantTTY then
            tell w to select
            tell t to select
            tell s to select
            activate
            return "found"
          end if
        end repeat
      end repeat
    end repeat
  end tell
  return "notfound"
end run
EOF
)

if [ "$RESULT" = "found" ]; then
  exit 0
fi
echo "Found the process (${M_TTY[$pick]}) but no iTerm2 tab owns that terminal." >&2
echo "Is it running inside tmux, or in a different terminal app?" >&2
exit 1
