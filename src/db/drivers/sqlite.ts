import type { OpenOptions, QueryResult, SqlExecutor } from "./types";
import { lazyExecutor, normalizeParam } from "./types";

const sqliteParam = (value: unknown) => {
	const normalized = normalizeParam(value);
	return typeof normalized === "boolean" ? (normalized ? 1 : 0) : normalized;
};

/** libSQL / Turso: remote (`libsql://`, `https://`) and local `file:` databases. */
export function openLibsql({ url, authToken }: OpenOptions): SqlExecutor {
	return lazyExecutor("sqlite", async () => {
		const { createClient } = await import("@libsql/client");
		const client = createClient({ url, authToken });
		type Executable = { execute(statement: { sql: string; args: unknown[] }): Promise<{ rows: Array<Record<string, unknown>>; columns: string[]; rowsAffected: number; lastInsertRowid?: bigint }> };
		const executorFor = (target: Executable, transaction?: SqlExecutor["transaction"]): SqlExecutor => ({
			dialect: "sqlite",
			async query(sql, values, mode): Promise<QueryResult> {
				const result = await target.execute({ sql, args: values.map(sqliteParam) });
				const rows = mode === "array" ? result.rows.map((row) => result.columns.map((_, i) => (row as unknown as unknown[])[i])) : result.rows.map((row) => ({ ...row }));
				return { rows, affectedRows: result.rowsAffected, insertId: result.lastInsertRowid === undefined ? undefined : Number(result.lastInsertRowid) };
			},
			transaction,
		});
		return {
			...executorFor(client as unknown as Executable, async (fn) => {
				const tx = await client.transaction("write");
				try {
					const result = await fn(executorFor(tx as unknown as Executable));
					await tx.commit();
					return result;
				} catch (error) {
					await tx.rollback().catch(() => undefined);
					throw error;
				} finally {
					tx.close();
				}
			}),
			close: async () => client.close(),
		};
	});
}

/** A local SQLite file through better-sqlite3 (Node only). */
export function openBetterSqlite3({ url }: OpenOptions): SqlExecutor {
	return lazyExecutor("sqlite", async () => {
		const name = "better-sqlite3";
		const Database = ((await import(/* @vite-ignore */ name)) as { default: new (path: string) => import("better-sqlite3").Database }).default;
		const path = url.replace(/^(file|sqlite):(\/\/)?/i, "") || ":memory:";
		const db = new Database(path);
		db.pragma("journal_mode = WAL");
		db.pragma("foreign_keys = ON");
		return syncSqliteExecutor((sql, values, mode) => {
			const statement = db.prepare(sql);
			if (statement.reader) {
				const rows = mode === "array" ? (statement.raw(true).all(...values) as unknown[]) : (statement.raw(false).all(...values) as unknown[]);
				return { rows, affectedRows: 0 };
			}
			const info = statement.run(...values);
			return { rows: [], affectedRows: info.changes, insertId: Number(info.lastInsertRowid) };
		}, async () => void db.close());
	});
}

/** A local SQLite file through bun:sqlite (Bun runtime only). */
export function openBunSqlite({ url }: OpenOptions): SqlExecutor {
	return lazyExecutor("sqlite", async () => {
		const name = "bun:sqlite";
		const { Database } = (await import(/* @vite-ignore */ name)) as { Database: new (path: string) => BunDatabase };
		const db = new Database(url.replace(/^(file|sqlite):(\/\/)?/i, "") || ":memory:");
		db.exec("PRAGMA journal_mode = WAL");
		db.exec("PRAGMA foreign_keys = ON");
		return syncSqliteExecutor((sql, values, mode) => {
			const statement = db.query(sql);
			if (statement.columnNames.length > 0) {
				return { rows: mode === "array" ? statement.values(...values) : statement.all(...values), affectedRows: 0 };
			}
			const info = statement.run(...values);
			return { rows: [], affectedRows: info.changes, insertId: Number(info.lastInsertRowid) };
		}, async () => db.close());
	});
}

interface BunStatement {
	columnNames: string[];
	values(...params: unknown[]): unknown[];
	all(...params: unknown[]): unknown[];
	run(...params: unknown[]): { changes: number; lastInsertRowid: number | bigint };
}
interface BunDatabase {
	query(sql: string): BunStatement;
	exec(sql: string): void;
	close(): void;
}

/** In-process drivers share one connection, so a transaction is BEGIN/COMMIT around awaited statements. */
function syncSqliteExecutor(run: (sql: string, values: unknown[], mode: "array" | "object") => QueryResult, close: () => Promise<void>): SqlExecutor {
	let chain: Promise<unknown> = Promise.resolve();
	const executor: SqlExecutor = {
		dialect: "sqlite",
		async query(sql, values, mode) {
			return run(sql, values.map(sqliteParam), mode);
		},
		// One connection means one transaction at a time; later callers wait for the earlier to finish.
		transaction(fn) {
			const result = chain.then(async () => {
				run("BEGIN", [], "array");
				try {
					const value = await fn(executor);
					run("COMMIT", [], "array");
					return value;
				} catch (error) {
					run("ROLLBACK", [], "array");
					throw error;
				}
			});
			chain = result.catch(() => undefined);
			return result;
		},
		close,
	};
	return executor;
}
