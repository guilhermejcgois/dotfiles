jtmin() {
  local name="${1:-Root}"
  node -e '
    const fs = require("fs");
    const name = process.argv[1] || "Root";
    const src = fs.readFileSync(0,"utf8");
    const j = JSON.parse(src);

    const isISODate = s => typeof s==="string" && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/.test(s);

    const t = v => {
      if (v === null) return "null";
      const k = Array.isArray(v) ? "array" : typeof v;
      switch (k) {
        case "string": return isISODate(v) ? "Date" : "string";
        case "number": return "number";
        case "boolean": return "boolean";
        case "array":
          if (!v.length) return "unknown[]";
          const inner = t(v[0]);
          return inner === "null" ? "unknown[]" : `${inner}[]`;
        case "object":
          return "{ " + Object.entries(v).map(([k2, v2]) => `${k2}: ${t(v2)}`).join("; ") + " }";
        default: return "unknown";
      }
    };

    if (typeof j !== "object" || Array.isArray(j) || j === null) {
      console.error("Esperava um objeto JSON na raiz.");
      process.exit(1);
    }
    const lines = Object.entries(j).map(([k,v]) => `    ${k}: ${t(v)};`);
    console.log(`export type ${name} = {`);
    console.log(lines.join("\n"));
    console.log("}");
  ' "$name"
}

# jta: append seguro de interface gerada pelo jtmin ao arquivo alvo.
# uso:
#   echo '{...json...}' | jta NomeInterface caminho/arquivo.ts
jta() {
  local name="$1" file="$2"
  if [[ -z "$name" || -z "$file" ]]; then
    echo "uso: echo '{json}' | jta NomeInterface caminho/arquivo.ts" >&2
    return 2
  fi

  # lê o JSON de STDIN para uma variável
  local json
  json="$(cat)"

  # cria o arquivo se não existir
  [[ -f "$file" ]] || touch "$file"

  # se já existe interface com esse nome, aborta
  if grep -qE "^[[:space:]]*export[[:space:]]+interface[[:space:]]+$name\\b" "$file"; then
    echo "Interface '$name' já existe em $file — nada feito." >&2
    return 1
  fi

  {
    printf '\n'
    printf '%s' "$json" | jtmin "$name"
    printf '\n'
  } >> "$file"

  echo "✓ Adicionada interface '$name' em $file"
}

# j2pg: JSON (stdin) -> CREATE TABLE (PostgreSQL)
# Uso:
#   echo '{...}' | j2pg nome_tabela [pk]
#   cat data.json | j2pg carteira_itens id
j2pg() {
  local table="${1:?uso: j2pg <tabela> [pk] }"
  local pk="${2:-}"
  node -e '
    const fs = require("fs");

    const toSnake = s =>
      String(s)
        .normalize("NFKD") // separa acento daletra
        .replace(/[\u0300-\u036f]/g, "") // remove marcas de acentos
        .replace(/([a-z0-9])([A-Z])/g, "$1_$2") // quebra camelCase: dataAplicacao -> data_Aplicacao
        .replace(/[^A-Za-z0-9]+/g, "_") // tudo que não é letra/número vira underscore
        .replace(/^_+|_+$/g, "") // trim underscore
        .replace(/_+/g, "_") // colapsa múltiplos _
        .toLowerCase()
        .replace(/^(\d)/, "_$1"); // prefixa _ se começar com número

    const isISODateTime = s =>
      typeof s === "string" &&
      /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/.test(s);

    const isISODate = s =>
      typeof s === "string" &&
      /^\d{4}-\d{2}-\d{2}$/.test(s);

    const isUUID = s =>
      typeof s === "string" &&
      /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$/.test(s);

    const infer = v => {
      if (v === null || v === undefined) return { sql: "TEXT", nullable: true };
      if (Array.isArray(v)) return { sql: "JSONB", nullable: true };
      switch (typeof v) {
        case "boolean": return { sql: "BOOLEAN", nullable: false };
        case "number":
          if (Number.isInteger(v)) return { sql: "INTEGER", nullable: false };
          return { sql: "DECIMAL", nullable: false };
        case "string":
          if (isUUID(v)) return { sql: "UUID", nullable: false };
          if (isISODateTime(v)) return { sql: "TIMESTAMPTZ", nullable: false };
          if (isISODate(v)) return { sql: "DATE", nullable: false };
          return { sql: "TEXT", nullable: false };
        case "object":
          return { sql: "JSONB", nullable: true };
        default:
          return { sql: "TEXT", nullable: true };
      }
    };

    // lê stdin
    const raw = fs.readFileSync(0, "utf8").trim();
    if (!raw) { console.error("stdin vazio"); process.exit(1); }
    let data = JSON.parse(raw);

    // se vier array, usa o primeiro elemento como amostra
    if (Array.isArray(data)) {
      if (!data.length) { console.error("array vazio"); process.exit(1); }
      data = data[0];
    }
    if (typeof data !== "object" || data === null || Array.isArray(data)) {
      console.error("esperava objeto na raiz");
      process.exit(1);
    }

    const table = toSnake(process.argv[1] || "tabela");
    const pk = (process.argv[2] || "").trim();

    const cols = Object.entries(data).map(([k,v]) => {
      const name = toSnake(k);
      const { sql, nullable } = infer(v);
      return { name, sql, nullable };
    });

    // se o pk foi passado e existe entre as colunas, marca NOT NULL e PRIMARY KEY
    const hasPK = pk && cols.some(c => c.name === toSnake(pk));
    if (hasPK) {
      cols.forEach(c => { if (c.name === toSnake(pk)) c.nullable = false; });
    }

    const lines = cols.map(c => `  ${c.name} ${c.sql}${c.nullable ? "" : " NOT NULL"}`).join(",\n");
    const pkLine = hasPK ? `,\n  PRIMARY KEY (${toSnake(pk)})` : "";
    const sql = `\nCREATE TABLE IF NOT EXISTS ${table} (\n${lines}${pkLine}\n);`;

    console.log(sql);
  ' "$table" "$pk"
}
# Caminho base dos pacotes
DOT_PKGS="$HOME/packages"

# --- APT ---
aptadd() {
  if [[ -z "$1" ]]; then
    echo "Uso: aptadd <pacote>"; return 1
  fi
  local pkg="$1"
  sudo apt install -y "$pkg" || return 1
  mkdir -p "$DOT_PKGS"
  grep -qx "$pkg" "$DOT_PKGS/apt.txt" 2>/dev/null || echo "$pkg" >> "$DOT_PKGS/apt.txt"
  sort -u -o "$DOT_PKGS/apt.txt" "$DOT_PKGS/apt.txt"
  echo "✅ Adicionado '$pkg' ao apt.txt"
}

aptremove() {
  if [[ -z "$1" ]]; then
    echo "Uso: aptremove <pacote>"; return 1
  fi
  local pkg="$1"
  sudo apt remove -y "$pkg"
  sed -i "/^$pkg$/d" "$DOT_PKGS/apt.txt"
  echo "❌ Removido '$pkg' do apt.txt"
}

# --- Homebrew ---
brewadd() {
  if [[ -z "$1" ]]; then
    echo "Uso: brewadd <pacote>"; return 1
  fi
  local pkg="$1"
  brew install "$pkg" || return 1
  mkdir -p "$DOT_PKGS"
  if ! grep -q "brew \"$pkg\"" "$DOT_PKGS/brew.Brewfile" 2>/dev/null; then
    echo "brew \"$pkg\"" >> "$DOT_PKGS/brew.Brewfile"
    sort -u -o "$DOT_PKGS/brew.Brewfile" "$DOT_PKGS/brew.Brewfile"
  fi
  echo "✅ Adicionado '$pkg' ao brew.Brewfile"
}

brewremove() {
  if [[ -z "$1" ]]; then
    echo "Uso: brewremove <pacote>"; return 1
  fi
  local pkg="$1"
  brew uninstall "$pkg"
  sed -i.bak "/brew \"$pkg\"/d" "$DOT_PKGS/brew.Brewfile" && rm -f "$DOT_PKGS/brew.Brewfile.bak"
  echo "❌ Removido '$pkg' do brew.Brewfile"
}

# Gera ou atualiza pacotes detectando os instalados atualmente
pkgsync() {
  mkdir -p "$DOT_PKGS"
  echo "🔄 Sincronizando pacotes..."
  if command -v apt >/dev/null 2>&1; then
    dpkg-query -f '${binary:Package}\n' -W | sort -u > "$DOT_PKGS/apt.txt"
    echo "📦 apt.txt atualizado ($(wc -l < "$DOT_PKGS/apt.txt") pacotes)"
  fi
  if command -v brew >/dev/null 2>&1; then
    brew bundle dump --file="$DOT_PKGS/brew.Brewfile" --force >/dev/null
    echo "🍺 brew.Brewfile atualizado"
  fi

  yadm add "$DOT_PKGS" && yadm commit -m "chore(pkgs): sync packages" && yadm push
}

