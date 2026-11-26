# Table Of Contents
- [Introduction](#introduction)
- [Requirements](#requirements)
- [Install](#install)
- [Usage](#usage)
- [See Also](#see-also)
- [License (MIT)](#license-mit)
- [Credits](#credits)

# Introduction

**locate_cc.sh** is a bash script to find the [iTerm2](https://iterm2.com/) tab running a
[Claude Code](https://claude.com/claude-code) session on a Mac.

I run [Claude Code](https://claude.com/claude-code) in many projects and use a lot of tabs, so it is hard to
find the right one. Now I type one command and iTerm2 jumps to it. Hope you
will find it useful as well.

# Requirements

* macOS with [iTerm2](https://iterm2.com/)
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

Run it without an argument to list all [Claude Code](https://claude.com/claude-code) sessions and pick one:

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

* [cc-statusline](https://github.com/muquit/cc-statusline) - a status line script for [Claude Code](https://claude.com/claude-code). It shows usage,
  context, model, git branch and how many other [Claude Code](https://claude.com/claude-code) sessions are
  running.

# License (MIT)

MIT. See the [LICENSE.txt](LICENSE.txt) file for details.

# Credits

Developed with [Claude Code](https://claude.com/claude-code) using Claude Sonnet 5.5.

---
<sub>TOC/glossary expansion by https://github.com/muquit/markdown-toc-go v1.0.6 on Nov-25-2026</sub>
