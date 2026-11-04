import { defineConfig } from "drizzle-kit";

// Run with MAILFLARE_DB_DIALECT=mysql (the `db:generate:mysql` script does this). Also covers MariaDB and TiDB.
export default defineConfig({
	schema: "./src/db/schema/index.ts",
	out: "./drizzle/migrations-mysql",
	dialect: "mysql",
});
