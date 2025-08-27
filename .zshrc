# ---------- Basics ----------
setopt prompt_subst
setopt auto_cd
setopt hist_ignore_all_dups
setopt share_history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
bindkey -v

# Paths / ambiente
[[ -f "$HOME/zsh/path.zsh"      ]] && source "$HOME/zsh/path.zsh"
[[ -f "$HOME/zsh/exports.zsh"   ]] && source "$HOME/zsh/exports.zsh"
[[ -f "$HOME/zsh/aliases.zsh"   ]] && source "$HOME/zsh/aliases.zsh"
[[ -f "$HOME/zsh/functions.zsh" ]] && source "$HOME/zsh/functions.zsh"

# ---------- Antidote (plugins) ----------
# instala automaticamente se não existir
if [[ ! -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
fi
source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
antidote load < "${ZDOTDIR:-$HOME}/.zsh_plugins.txt"

# ---------- Tema (Powerlevel10k) ----------
# Se ainda não tiver o arquivo gerado, o Powerlevel10k abre um wizard na 1ª vez
[[ -r "${ZDOTDIR:-$HOME}/.p10k.zsh" ]] && source "${ZDOTDIR:-$HOME}/.p10k.zsh"

# ---------- fzf (se instalado) ----------
if command -v fzf >/dev/null 2>&1; then
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
fi

# ---------- zoxide (se instalado) ----------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

