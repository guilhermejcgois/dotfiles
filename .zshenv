# Minimal: só o essencial aqui
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Garante um diretório para binários locais
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

export VOLTA_HOME="$HOME/.volta"
if [[ -d "$VOLTA_HOME" ]]; then
    export PATH="$VOLTA_HOME:$PATH"
fi

export FNM_DIR="$HOME/.fnm"
if [[ -d "$FNM_DIR" ]]; then
    export PATH="$FNM_DIR:$PATH"
fi

