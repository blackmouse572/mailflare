import { dialectOf } from "@/db/introspect";

/**
 * Maintenance for the full-text index. On SQLite (D1) triggers keep the FTS5 table current, so a rebuild is
 * only needed after a restore from a backup that predates the index, or if the counts below ever disagree.
 * PostgreSQL and MySQL search the message columns directly (see conditions.ts), so there is no index to
 * rebuild and the status always reports every message as searchable.
 */
export async function rebuildSearchIndex(env: CloudflareEnv): Promise<void> {
	if (dialectOf(env.DB) !== "sqlite") return;
	await env.DB.prepare("INSERT INTO messages_fts(messages_fts) VALUES ('rebuild')").run();
}

export async function getSearchIndexStatus(env: CloudflareEnv): Promise<{ indexed: number; messages: number }> {
	if (dialectOf(env.DB) !== "sqlite") {
		const total = await env.DB.prepare("SELECT count(*) AS n FROM messages").first<{ n: number }>();
		const messages = Number(total?.n ?? 0);
		return { indexed: messages, messages };
	}
	const [indexed, total] = await env.DB.batch<{ n: number }>([
		env.DB.prepare("SELECT count(*) AS n FROM messages_fts"),
		env.DB.prepare("SELECT count(*) AS n FROM messages"),
	]);
	return { indexed: indexed.results[0]?.n ?? 0, messages: total.results[0]?.n ?? 0 };
}
