// Bundle a TypeScript script (resolving the `@/` alias) with esbuild and run it under Node.
// Usage: node scripts/run-ts.mjs scripts/db-smoke.ts [args...]
import { spawnSync } from "node:child_process";
import { mkdirSync } from "node:fs";
import { basename, resolve } from "node:path";
import { build } from "esbuild";

const [entry, ...args] = process.argv.slice(2);
if (!entry) throw new Error("usage: run-ts.mjs <script.ts> [args...]");
const root = resolve(import.meta.dirname, "..");
const outDir = resolve(root, "node_modules/.cache/run-ts");
mkdirSync(outDir, { recursive: true });
const outfile = resolve(outDir, `${basename(entry).replace(/\.ts$/, "")}.mjs`);

await build({
	entryPoints: [resolve(root, entry)],
	outfile,
	bundle: true,
	platform: "node",
	format: "esm",
	packages: "external",
	alias: { "@": resolve(root, "src") },
	logLevel: "error",
	define: { "import.meta.dirname": "undefined" },
});
const result = spawnSync(process.execPath, [outfile, ...args], { stdio: "inherit", cwd: root, env: process.env });
process.exit(result.status ?? 1);
