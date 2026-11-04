import type { DatabaseDialect } from "./dialect";
import { normalizeParam, numberPlaceholders, type SqlExecutor } from "./drivers/types";

/**
 * A `D1Database` over any SqlExecutor, for the raw `env.DB.prepare(...)` call sites. SQL is written
 * with `?` placeholders as D1 expects; PostgreSQL gets them numbered here.
 */
type Row = Record<string, unknown>;

function meta(affectedRows: number, insertId?: number) {
	return { duration: 0, size_after: 0, rows_read: 0, rows_written: affectedRows, last_row_id: insertId ?? 0, changed_db: affectedRows > 0, changes: affectedRows };
}

export class CompatStatement {
	constructor(
		readonly db: CompatDatabase,
		readonly sql: string,
		readonly params: unknown[] = [],
	) {}

	bind(...values: unknown[]) {
		return new CompatStatement(this.db, this.sql, values.map(normalizeParam));
	}

	/** Statements without parameters (migrations) are sent untouched, so a `?` inside a function body survives. */
	private text() {
		return this.db.dialect === "postgres" && this.params.length > 0 ? numberPlaceholders(this.sql) : this.sql;
	}

	/** @internal */
	async execute(executor: SqlExecutor) {
		return executor.query(this.text(), this.params, "object");
	}

	async run<T = Row>() {
		const result = await this.execute(this.db.executor());
		return { results: result.rows as T[], success: true as const, meta: meta(result.affectedRows, result.insertId) };
	}

	async all<T = Row>() {
		return this.run<T>();
	}

	async first<T = Row>(column?: string): Promise<T | null> {
		const result = await this.execute(this.db.executor());
		const row = result.rows[0] as Row | undefined;
		if (!row) return null;
		return (column ? row[column] : row) as T;
	}

	async raw<T = unknown[]>(): Promise<T[]> {
		return (await this.db.executor().query(this.text(), this.params, "array")).rows as T[];
	}
}

export class CompatDatabase {
	constructor(
		readonly dialect: DatabaseDialect,
		private readonly base: SqlExecutor,
		private readonly active: () => SqlExecutor | null = () => null,
	) {}

	executor() {
		return this.active() ?? this.base;
	}

	prepare(sql: string) {
		return new CompatStatement(this, sql);
	}

	async batch<T = Row>(statements: CompatStatement[]) {
		const run = async (executor: SqlExecutor) => {
			const results: Array<{ results: T[]; success: true; meta: ReturnType<typeof meta> }> = [];
			for (const statement of statements) {
				const result = await statement.execute(executor);
				results.push({ results: result.rows as T[], success: true as const, meta: meta(result.affectedRows, result.insertId) });
			}
			return results;
		};
		return this.base.transaction ? this.base.transaction(run) : run(this.base);
	}

	async exec(sql: string) {
		const result = await this.base.query(sql, [], "object");
		return { count: 1, duration: 0, rows: result.rows };
	}

	async dump(): Promise<ArrayBuffer> {
		throw new Error("dump() is not available on external databases.");
	}
}
