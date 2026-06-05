
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
[[ -f "$HOME/zsh/highlight.zsh" ]] && source "$HOME/zsh/highlight.zsh"

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

# fnm
FNM_PATH="/home/guilhermejcgois/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

# pnpm
export PNPM_HOME="/home/guilhermejcgois/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh"
