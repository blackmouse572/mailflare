import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import { build } from "esbuild";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const bundleDirectory = mkdtempSync(join(root, "node_modules", "mailflare-schedule-bundle-"));
await build({
	stdin: {
		contents: `
			export { isPastSchedule as isPastPick } from "./src/components/compose/schedule-send-utils.ts";
			export { isPastSchedule as isPastRequest } from "./src/app/api/send/utils.ts";
		`,
		resolveDir: root,
		sourcefile: "schedule-test-entry.ts",
	},
	outfile: join(bundleDirectory, "entry.mjs"),
	bundle: true,
	platform: "node",
	format: "esm",
	target: "node24",
	tsconfig: join(root, "tsconfig.json"),
	packages: "external",
	alias: { "cloudflare:workers": "./server/runtime/cloudflare-workers.ts" },
	logLevel: "silent",
});
const { isPastPick, isPastRequest } = await import(pathToFileURL(join(bundleDirectory, "entry.mjs")).href);
rmSync(bundleDirectory, { recursive: true, force: true });

const now = new Date("2026-10-13T14:05:42.000Z");

test("the picker allows the current minute and anything later", () => {
	assert.equal(isPastPick(new Date("2026-10-13T14:05:00.000Z"), now), false);
	assert.equal(isPastPick(new Date("2026-10-13T14:06:00.000Z"), now), false);
	assert.equal(isPastPick(new Date("2026-10-14T08:00:00.000Z"), now), false);
});

test("the picker rejects anything before the current minute", () => {
	assert.equal(isPastPick(new Date("2026-10-13T14:04:00.000Z"), now), true);
	assert.equal(isPastPick(new Date("2020-01-01T10:00:00.000Z"), now), true);
});

test("the send endpoint rejects a time more than a minute old or unreadable", () => {
	const at = now.getTime();
	assert.equal(isPastRequest(undefined, at), false);
	assert.equal(isPastRequest("2026-10-13T14:05:00.000Z", at), false);
	assert.equal(isPastRequest("2026-10-13T14:03:00.000Z", at), true);
	assert.equal(isPastRequest("2026-10-13T16:00:00.000Z", at), false);
	assert.equal(isPastRequest("not a date", at), true);
});
