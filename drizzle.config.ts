import { defineConfig } from "drizzle-kit";

// SQLite (D1, libSQL, better-sqlite3). PostgreSQL and MySQL have their own configs:
// drizzle.config.pg.ts and drizzle.config.mysql.ts.
export default defineConfig({
	schema: "./src/db/schema/index.ts",
	out: "./drizzle/migrations",
	dialect: "sqlite",
});
