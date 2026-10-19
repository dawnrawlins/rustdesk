// Shared helpers for building per-company RustDesk client settings.
import fs from "node:fs";

export const VARIANTS = {
  // End-user build: whoever runs it can only accept incoming sessions by clicking.
  client: { "approve-mode": "click" },
  // Technician build: normal RustDesk behaviour, sign-in with the agent account.
  agent: {},
};

/**
 * Compile-time switches that cannot be changed by the user or by settings.
 * The end-user build is a small status window: ID, access mode, install banner and
 * connection status. No "connect to" box, address book, account or settings.
 */
export const HARD_VARIANTS = {
  client: {
    "conn-type": "incoming",
    "disable-settings": "Y",
    "disable-ab": "Y",
    "disable-account": "Y",
  },
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

/**
 * Resolves options from CLI flags, falling back to environment variables, then to `--brand-file`
 * (the branding/brand.json written by a previous run; used by the build workflow).
 */
export function resolveBrand(args, env = process.env) {
  const base = args["brand-file"] ? JSON.parse(fs.readFileSync(args["brand-file"], "utf8")) : {};
  const pick = (flag, envName, baseKey = flag) => args[flag] ?? env[envName] ?? base[baseKey] ?? "";
  const host = pick("host", "RD_HOST");
  const relay = pick("relay", "RD_RELAY") || (host ? `${host.split(":")[0]}:21117` : "");
  const key = pick("key", "RD_KEY");
  let api = pick("api", "RD_API");
  const apiBase = pick("api-base", "RD_API_BASE");
  const token = pick("token", "RD_ENROLL_TOKEN");
  if (!api && apiBase && token) api = `${apiBase.replace(/\/+$/, "")}/r/${token}`;
  const variant = pick("variant", "RD_VARIANT") || "client";
  const appName = pick("app-name", "RD_APP_NAME", "appName");
  const group = pick("group", "RD_DEVICE_GROUP");

  const missing = [["host", host], ["key", key], ["api (or api-base + token)", api]].filter(([, v]) => !v).map(([n]) => n);
  if (missing.length) throw new Error(`Missing required option(s): ${missing.join(", ")}`);
  if (!(variant in VARIANTS)) throw new Error(`--variant must be one of: ${Object.keys(VARIANTS).join(", ")}`);
  if (!/^https?:\/\//.test(api)) throw new Error("--api must be an absolute http(s) URL");
  // Public website: replaces every rustdesk.com / GitHub link in the app (docs, privacy, download, update checks).
  const site = (pick("site", "RD_SITE") || new URL(api).origin).replace(/\/+$/, "");
  if (!/^https?:\/\//.test(site)) throw new Error("--site must be an absolute http(s) URL");
  return { host, relay, key, api, variant, appName, group, site };
}

/** Settings forced on every launch (users cannot change them in the UI). */
export function overwriteSettings(b) {
  return {
    "custom-rendezvous-server": b.host,
    "relay-server": b.relay,
    key: b.key,
    "api-server": b.api,
    "allow-auto-update": "N",
    ...VARIANTS[b.variant],
  };
}

/** Local (per-machine) settings forced on every launch: no update checks, no WebRTC/STUN. */
export function overwriteLocalSettings() {
  return { "enable-check-update": "N", "enable-webrtc": "N" };
}

/** Compile-time defaults. `auto-install` makes the downloaded file install itself on first run (see src/core_main.rs). */
export function builtinSettings(b) {
  return { "auto-install": "Y", ...(b.group ? { "preset-device-group-name": b.group } : {}) };
}

export function hardSettings(b) {
  return { ...HARD_VARIANTS[b.variant] };
}

/** Same encoding as RustDesk "Export server config" / `rustdesk --config <string>`. */
export function configString(b) {
  const json = JSON.stringify({ host: b.host, relay: b.relay, api: b.api, key: b.key });
  return Buffer.from(json).toString("base64").replace(/=+$/, "").split("").reverse().join("");
}
