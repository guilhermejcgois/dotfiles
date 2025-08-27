# Dotfiles

Minhas configurações pessoais de terminal com **Zsh**, **Powerlevel10k**, **Antidote** e outras ferramentas.  
Este repositório é gerenciado com [yadm](https://yadm.io/), que facilita versionar e aplicar dotfiles diretamente no `$HOME`.

## :sparkles: O que vem incluso
- [Zsh](https://www.zsh.org/) como shell padrão
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) para prompt rápido e customizável
- [Antidote](https://getantidote.github.io/) como gerenciador de plugins Zsh
- Plugins úteis:
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
  - `zsh-completions`
  - `zsh-autocomplete` (opcional)
  - `zoxide` ou `zsh-z` para navegação rápida
- Aliases, funções e variáveis de ambiente organizados em arquivos separados
- Arquivos de configuração do Git (`.gitconfig` e `.gitignore_global`)
- Script `bootstrap` para instalar pacotes básicos e configurar o ambiente automaticamente
- Listas de pacotes para `apt`, `dnf`, `pacman` e `brew`

## :package: Instala�ão

### 1. Instale o yadm
```bash
# Debian/Ubuntu
sudo apt-get update && sudo apt-get install -y yadm

# macOS (Homebrew)
brew install yadm

# Arch Linux
sudo pacman -S yadm

# Fedora
sudo dnf install -y yadm
```

### 2. Clone o repositório

```bash
yadm clone https://github.com/<seu-user>/dotfiles.git
```

O yadm vai aplicar automaticamente todos os arquivos no $HOME e rodar o script de bootstrap.

### 3. Reinicie o shell

```bash
exec zsh
```

Na primeira vez que abrir o terminal, o Powerlevel10k vai iniciar um assistente para configurar o prompt.

## :counterclockwise-arrows-button: Atualização de pluns

Quando editar a lista de plugins (.zsh_plugins.txt), rode:

```bash
zsh -ic 'antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh'
```

## :locked-with-key: Segredos

Para arquivos que não podem ir em texto puro (ex.: chaves de API), o`yadm` suporta criptografia:

```bash
yadm encrypt
yadm decrypt
```

## :open-file-folder: Estrutura

```lua
.
├── .zshenv
├── .zprofile
├── .zshrc
├── .p10k.zsh
├── .zsh_plugins.txt
├── zsh/
│   ├── path.zsh
│   ├── exports.zsh
│   ├── aliases.zsh
│   ├── functions.zsh
│   └── completions/
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── .config/
│   └── yadm/bootstrap
├── packages/
│   ├── apt.txt
│   ├── dnf.txt
│   ├── pacman.txt
│   └── brew.Brewfile
└── bin/
```

## :rocket: Em qualquer máquina nov

```bash
yadm clone https://github.com/guilhermejcgois/dotfiles.git
exec zsh
```
Pronto, o ambiente já estará configurado com todas as suas preferência:smiling-face-with-sunglasses:

