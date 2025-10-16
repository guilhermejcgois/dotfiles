# Git
alias gs='git status -sb'
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull --rebase --autostash'
alias gco='git checkout'
alias gb='git branch -v'

# Navegação
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'

# Segurança
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Miscelânea
alias e='${EDITOR:-code}'
alias apt='sudo apt'
alias apti='aptadd'
alias brewi='brewadd'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --color=always --icons=auto'
  alias ll='eza -lh    --group-directories-first --color=always --icons=auto'
  alias la='eza -lha   --group-directories-first --color=always --icons=auto'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
  alias lt2='eza --tree --level=2 --group-directories-first --icons=auto --ignore-glob="node_modules|.git|dist|build"'
  alias lsg='eza -lh --git --group-directories-first --icons=auto'
  alias lsm='eza -lh --sort=modified --group-directories-first --icons=auto'
elif command -v lsd >/dev/null 2>&1; then
  alias ls='lsd --group-dirs=first --icon=auto'
  alias ll='lsd -lh      --group-dirs=first --icon=auto'
  alias la='lsd -lha     --group-dirs=first --icon=auto'
  alias lt='lsd --tree --depth=2 --group-dirs=first --icon=auto'
  alias lsg='lsd -lh --group-dirs=first --icon=auto'  # (lsd não tem --git)
fi

