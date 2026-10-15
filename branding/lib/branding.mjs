// Shared helpers for building per-company RustDesk client settings.

export const VARIANTS = {
  // End-user build: whoever runs it can only accept incoming sessions by clicking.
  client: { "approve-mode": "click" },
  // Technician build: normal RustDesk behaviour, sign-in with the agent account.
  agent: {},
};

export function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (!a.startsWith("--")) continue;
    const eq = a.indexOf("=");
    if (eq > 0) out[a.slice(2, eq)] = a.slice(eq + 1);
    else if (argv[i + 1] !== undefined && !argv[i + 1].startsWith("--")) out[a.slice(2)] = argv[++i];
    else out[a.slice(2)] = "true";
  }
  return out;
}

/** Resolves options from CLI flags, falling back to environment variables. */
export function resolveBrand(args, env = process.env) {
  const pick = (flag, envName) => args[flag] ?? env[envName] ?? "";
  const host = pick("host", "RD_HOST");
  const relay = pick("relay", "RD_RELAY") || (host ? `${host.split(":")[0]}:21117` : "");
  const key = pick("key", "RD_KEY");
  let api = pick("api", "RD_API");
  const apiBase = pick("api-base", "RD_API_BASE");
  const token = pick("token", "RD_ENROLL_TOKEN");
  if (!api && apiBase && token) api = `${apiBase.replace(/\/+$/, "")}/r/${token}`;
  const variant = pick("variant", "RD_VARIANT") || "client";
  const appName = pick("app-name", "RD_APP_NAME");
  const group = pick("group", "RD_DEVICE_GROUP");

  const missing = [["host", host], ["key", key], ["api (or api-base + token)", api]].filter(([, v]) => !v).map(([n]) => n);
  if (missing.length) throw new Error(`Missing required option(s): ${missing.join(", ")}`);
  if (!(variant in VARIANTS)) throw new Error(`--variant must be one of: ${Object.keys(VARIANTS).join(", ")}`);
  if (!/^https?:\/\//.test(api)) throw new Error("--api must be an absolute http(s) URL");
  return { host, relay, key, api, variant, appName, group };
}

/** Settings forced on every launch (users cannot change them in the UI). */
export function overwriteSettings(b) {
  return {
    "custom-rendezvous-server": b.host,
    "relay-server": b.relay,
    key: b.key,
    "api-server": b.api,
    ...VARIANTS[b.variant],
  };
}

export function builtinSettings(b) {
  return b.group ? { "preset-device-group-name": b.group } : {};
}

/** Same encoding as RustDesk "Export server config" / `rustdesk --config <string>`. */
export function configString(b) {
  const json = JSON.stringify({ host: b.host, relay: b.relay, api: b.api, key: b.key });
  return Buffer.from(json).toString("base64").replace(/=+$/, "").split("").reverse().join("");
}
