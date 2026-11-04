import type { DatabaseDialect } from "./dialect";
import { isExternalDatabase } from "./external";

/** Schema introspection for raw `env.DB` callers (backups, setup checks), per dialect. */
export function dialectOf(db: D1Database): DatabaseDialect {
	return isExternalDatabase(db) ? db.config.dialect : "sqlite";
}

/** Names of the tables in the current schema/database. */
export async function listTableNames(db: D1Database): Promise<Set<string>> {
	const dialect = dialectOf(db);
	const sql =
		dialect === "sqlite"
			? "SELECT name FROM sqlite_master WHERE type = 'table'"
			: dialect === "postgres"
				? "SELECT table_name AS name FROM information_schema.tables WHERE table_schema = current_schema() AND table_type = 'BASE TABLE'"
				: "SELECT table_name AS name FROM information_schema.tables WHERE table_schema = database() AND table_type = 'BASE TABLE'";
	const result = await db.prepare(sql).all<{ name?: string; NAME?: string }>();
	return new Set(result.results.map((row) => (row.name ?? row.NAME) as string));
}

/** Column names of a table, or an empty set when it does not exist. */
export async function listColumnNames(db: D1Database, table: string): Promise<Set<string>> {
	const dialect = dialectOf(db);
	if (dialect === "sqlite") {
		const result = await db.prepare(`PRAGMA table_info(${table})`).all<{ name: string }>();
		return new Set(result.results.map((column) => column.name));
	}
	const schema = dialect === "postgres" ? "current_schema()" : "database()";
	const result = await db
		.prepare(`SELECT column_name AS name FROM information_schema.columns WHERE table_schema = ${schema} AND table_name = ?`)
		.bind(table)
		.all<{ name?: string; NAME?: string }>();
	return new Set(result.results.map((row) => (row.name ?? row.NAME) as string));
}

export function quoteIdentifier(dialect: DatabaseDialect, name: string): string {
	return dialect === "mysql" ? `\`${name.replaceAll("`", "``")}\`` : `"${name.replaceAll('"', '""')}"`;
}
