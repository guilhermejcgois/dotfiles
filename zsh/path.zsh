# Adicione diretórios ao PATH aqui, mantendo ordem
typeset -U path PATH
path=("$HOME/bin" "$HOME/.local/bin" "/usr/local/bin" $path)
export PATH

