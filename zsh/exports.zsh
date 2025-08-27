export EDITOR="nvim"    # mude para "nvim" se preferir
export VISUAL="$EDITOR"
export PAGER="less -R"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || rg --files --hidden -g "!.git"'

