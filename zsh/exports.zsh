export EDITOR="nvim"    # mude para "nvim" se preferir
export VISUAL="$EDITOR"
export PAGER="less -R"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || rg --files --hidden -g "!.git"'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
  --color=fg:#c0caf5,bg:#1a1b26,hl:#7dcfff
  --color=fg+:#c0caf5,bg+:#283457,hl+:#7aa2f7
  --color=info:#7aa2f7,prompt:#9ece6a,spinner:#bb9af7,pointer:#f7768e,marker:#e0af68,header:#565f89
"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export GPG_TTY="$(tty)"

