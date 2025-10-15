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
    console.log(`export interface ${name} {`);
    console.log(lines.join("\\n"));
    console.log("}");
  ' "$name"
}

