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
- Configurações globais do [AWS Kiro](https://kiro.dev/) com steering files para desenvolvimento moderno

## :package: Instalação

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
├── .kiro/
│   ├── settings.json
│   └── steering/
│       ├── general.md
│       ├── docker-compose.md
│       ├── typescript.md
│       ├── frontend.md
│       ├── nx.md
│       ├── nestjs.md
│       ├── terraform.md
│       └── data.md
├── packages/
│   ├── apt.txt
│   ├── dnf.txt
│   ├── pacman.txt
│   └── brew.Brewfile
└── bin/
```

## :robot: AWS Kiro

As configurações do [AWS Kiro](https://kiro.dev/) ficam em `.kiro/` e são aplicadas globalmente pelo yadm no `$HOME`.

### settings.json

Configurações gerais do editor: formatação, TypeScript strict mode, variáveis de ambiente Docker BuildKit habilitadas.

### Steering Files

Arquivos Markdown que guiam o comportamento da IA do Kiro. Cada arquivo cobre um conjunto de tecnologias e é ativado automaticamente por padrão de arquivo (`fileMatch`) ou sempre (`always`):

| Arquivo | Ativação | Tecnologias |
|---|---|---|
| `general.md` | sempre | Convenções gerais, commits, testes, segurança |
| `docker-compose.md` | `docker-compose*.yml` | Docker, Docker Compose, Dockerfile multi-stage |
| `typescript.md` | `**/*.{ts,tsx}` | TypeScript, Zod, async/await |
| `frontend.md` | `angular.json`, `next.config.*`, `*.component.ts`, `*.page.tsx` | Angular (Signals), React (hooks), Next.js (App Router) |
| `nx.md` | `**/nx.json` | NX monorepo, module boundaries, cache, CI |
| `nestjs.md` | `*.module.ts`, `*.controller.ts`, `*.service.ts` | NestJS, DTOs, guards, Swagger, testes |
| `terraform.md` | `**/*.{tf,tfvars,tfvars.json}` | Terraform, AWS, módulos, state remoto, segurança |
| `data.md` | `dbt_project.yml`, `*.sql`, `schema.yml` | DBT, SQL, modelos incrementais, CTEs |

## :rocket: Em qualquer máquina nova

```bash
yadm clone https://github.com/guilhermejcgois/dotfiles.git
exec zsh
```
Pronto, o ambiente já estará configurado com todas as suas preferência:smiling-face-with-sunglasses:

