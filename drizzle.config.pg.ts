import { defineConfig } from "drizzle-kit";

// Run with MAILFLARE_DB_DIALECT=postgres so the schema module builds pgTable definitions
// (the `db:generate:pg` script does this).
export default defineConfig({
	schema: "./src/db/schema/index.ts",
	out: "./drizzle/migrations-pg",
	dialect: "postgresql",
});
