import { resolveDatabaseConfig, type DatabaseConfig } from "./dialect";
import { openExternalDatabase, type ExternalDatabase } from "./external";

const wrapped = new WeakMap<object, CloudflareEnv>();
const proxies = new WeakSet<object>();
const opened = new Map<string, ExternalDatabase>();

type DatabaseEnv = Partial<Pick<CloudflareEnv, "DATABASE_URL" | "DATABASE_DRIVER" | "DATABASE_AUTH_TOKEN" | "HYPERDRIVE" | "MAILFLARE_RUNTIME">>;

/** Resolve the configured database: env vars first, then process.env (self-hosted), then a Hyperdrive binding. */
export function getDatabaseConfig(env: DatabaseEnv): DatabaseConfig {
	const processEnv = (globalThis as { process?: { env?: Record<string, string | undefined> } }).process?.env ?? {};
	const pick = (key: "DATABASE_URL" | "DATABASE_DRIVER" | "DATABASE_AUTH_TOKEN") => (typeof env[key] === "string" && env[key]!.trim() ? env[key] : processEnv[key]);
	return resolveDatabaseConfig(
		{ DATABASE_URL: pick("DATABASE_URL"), DATABASE_DRIVER: pick("DATABASE_DRIVER"), DATABASE_AUTH_TOKEN: pick("DATABASE_AUTH_TOKEN") },
		env.HYPERDRIVE?.connectionString,
	);
}

/**
 * Returns env with `DB` served by the database `DATABASE_URL` names, or env unchanged when it is unset
 * (the D1 binding on Workers, the SQLite file when self-hosted). Like `withStorage`, this is the one place
 * that decides where data lives; every caller keeps reading `env.DB`.
 */
export function withDatabase(env: CloudflareEnv): CloudflareEnv {
	if (proxies.has(env)) return env;
	const cached = wrapped.get(env);
	if (cached) return cached;
	const config = getDatabaseConfig(env);
	if (config.driver === "d1") return env;
	const key = `${config.driver}|${config.url}`;
	let database = opened.get(key);
	if (!database) {
		database = openExternalDatabase(config, env.MAILFLARE_RUNTIME === "node");
		opened.set(key, database);
	}
	const proxy = new Proxy(env, { get: (target, property) => (property === "DB" ? database : Reflect.get(target, property)) });
	wrapped.set(env, proxy);
	proxies.add(proxy);
	return proxy;
}
