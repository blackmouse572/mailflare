import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test, { after } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import { build } from "esbuild";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");

const outDir = mkdtempSync(join(tmpdir(), "mailflare-inbound-key-"));
after(() => rmSync(outDir, { recursive: true, force: true }));

await build({
	stdin: {
		contents: `export { inboundMessageId, inboundStorageKey } from "./src/lib/email/inbound-id.ts";`,
		resolveDir: root,
		sourcefile: "inbound-key-test-entry.js",
	},
	outfile: join(outDir, "inbound-key.mjs"),
	bundle: true,
	platform: "node",
	format: "esm",
	target: "node22",
	tsconfig: join(root, "tsconfig.json"),
	logLevel: "silent",
});

const { inboundMessageId, inboundStorageKey } = await import(pathToFileURL(join(outDir, "inbound-key.mjs")).href);

function raw(headers, body = "Body.") {
	return new TextEncoder().encode(`${headers}\r\n\r\n${body}\r\n`).buffer;
}

test("inboundStorageKey is stable for identical bytes in the same mailbox", async () => {
	const a = await inboundStorageKey(raw("Message-ID: <x@y>"), "mb1");
	const b = await inboundStorageKey(raw("Message-ID: <x@y>"), "mb1");
	assert.equal(a, b);
	assert.match(a, /^inbound\/[0-9a-f]{64}\.eml$/);
});

test("inboundStorageKey differs per mailbox for identical bytes", async () => {
	const a = await inboundStorageKey(raw("Message-ID: <x@y>"), "mb1");
	const b = await inboundStorageKey(raw("Message-ID: <x@y>"), "mb2");
	assert.notEqual(a, b);
});

test("a forged message reusing a Message-ID cannot land on the original's key", async () => {
	const real = await inboundStorageKey(raw("Message-ID: <x@y>", "real"), "mb1");
	const forged = await inboundStorageKey(raw("Message-ID: <x@y>", "forged"), "mb1");
	assert.notEqual(real, forged);
});

test("inboundMessageId derives a stable id from the key", async () => {
	const key = await inboundStorageKey(raw("Message-ID: <x@y>"), "mb1");
	assert.equal(await inboundMessageId(key), await inboundMessageId(key));
});
