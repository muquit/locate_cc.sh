# Introduction

**locate_cc.sh** is a bash script to find the @ITERM2@ tab running a
@CLAUDE_CODE@ session on a Mac.

I run @CLAUDE_CODE@ in many projects and use a lot of tabs, so it is hard to
find the right one. Now I type one command and iTerm2 jumps to it. Hope you
will find it useful as well.

# Requirements

* macOS with @ITERM2@
* bash, and `pgrep`, `lsof`, `ps` and `osascript` (all come with macOS)
* git (optional, used to find the repo name)

I did not test it on Linux. On Linux there is no iTerm2 and no `osascript`, so
it will not work.

# Install

Copy the script somewhere in your PATH, for example:

```bash
cp locate_cc.sh ~/bin/
chmod +x ~/bin/locate_cc.sh
```

# Usage

Run it without an argument to list all @CLAUDE_CODE@ sessions and pick one:

```
$ locate_cc.sh
1) pid 44726  ttys005  up 23:00:30  /Users/muquit/gitdev/cc-statusline
2) pid 78099  ttys003  up 20:34:12  /Users/muquit/gitdev/mailsend
Which one? [1-2, Enter to quit]
```

Type a number and iTerm2 selects that tab and comes to the front. Press Enter
to quit.

Give a repo name to go straight there:

```
locate_cc.sh mailsend
```

The name is matched against the repo (or directory) name, ignoring case. A
part of the name is enough. If more than one session matches, you get the list
to pick from.

To only list the sessions and not switch, use `-n`:

```
locate_cc.sh -n
locate_cc.sh -n mailsend
```

The first time, macOS asks if the script may control iTerm2. Allow it.

The script finds the `claude` processes, looks up the terminal of each one
and asks iTerm2 which tab owns that terminal. It changes nothing except
which tab is selected.

If you run tmux inside iTerm2 it should not find the tab, because the terminal
is tmux's, not iTerm2's. I did not test it.

# See Also

* @CC_STATUSLINE@ - a status line script for @CLAUDE_CODE@. It shows usage,
  context, model, git branch and how many other @CLAUDE_CODE@ sessions are
  running.

# License (MIT)

MIT. See the @LICENSE_FILE@ file for details.

# Credits

Developed with @CLAUDE_CODE@ using Claude Sonnet 5.5.
