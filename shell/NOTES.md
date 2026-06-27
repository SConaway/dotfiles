# Shell debugging notes

## Ctrl-C sometimes hangs the terminal

### Root causes found (2026-06-24)

**bgnotify plugin** (now disabled) — two issues:
- `bgnotify_formatted` had `sleep 5; return` for gg/vim commands, causing a guaranteed 5s freeze after lazygit/nvim sessions
- `bgnotify_end` called `lsappinfo` (talks to WindowServer) synchronously in `precmd` after any command ≥5s; lsappinfo can stall intermittently on macOS

**Zellij completions** — `zellij setup --generate-completion zsh` was running inline on every shell start; now cached to `~/.cache/zellij_comp.zsh`

### Remaining suspected cause for "other commands"

**stty corruption** — TUI apps (nvim, lazygit, nnn, fzf) that exit via Ctrl-C instead of cleanly can leave the terminal in raw mode / echo-off. The prompt returns but the terminal is broken. Fix: save/restore stty around each command:

```zsh
_stty_settings=""
_stty_save()    { _stty_settings=$(stty -g 2>/dev/null); }
_stty_restore() { [[ -n "$_stty_settings" ]] && stty "$_stty_settings" 2>/dev/null; }
add-zsh-hook preexec _stty_save
add-zsh-hook precmd  _stty_restore
```

Also consider disabling `COMPLETION_WAITING_DOTS` — it disables line-wrap before running completion and if Ctrl-C interrupts it, line-wrap stays off.

### Things ruled out
- oh-my-zsh auto-update: noop (nix store isn't a git repo, exits early)
- atuin precmd: runs `atuin history end` async (`&`), not blocking
- git / gitfast plugins: no precmd hooks, just aliases
- zsh-syntax-highlighting: only `main` highlighter enabled, not expensive
