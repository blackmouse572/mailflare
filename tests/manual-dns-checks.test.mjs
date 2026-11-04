import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import { build } from "esbuild";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const bundleDirectory = mkdtempSync(join(root, "node_modules", "mailflare-dns-bundle-"));
await build({
	stdin: {
		contents: `
			export { hasMx } from "./src/lib/domains/receiving-dns.ts";
			export { auditDomainDns } from "./src/lib/domains/dns-audit.ts";
		`,
		resolveDir: root,
		sourcefile: "dns-test-entry.ts",
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
const { hasMx, auditDomainDns } = await import(pathToFileURL(join(bundleDirectory, "entry.mjs")).href);
rmSync(bundleDirectory, { recursive: true, force: true });

const manualDomain = { hostname: "example.com", zoneId: "manual" };

function answerDns(answers) {
	const asked = [];
	globalThis.fetch = async (url) => {
		const parsed = new URL(url);
		const name = parsed.searchParams.get("name");
		asked.push(name);
		const data = answers[`${name}|${parsed.searchParams.get("type")}`];
		return Response.json(data === undefined ? { Status: 3 } : { Status: 0, Answer: data.map((value) => ({ name, type: 0, TTL: 60, data: value })) });
	};
	return asked;
}

test("a manual zone's MX is read from public DNS", async () => {
	answerDns({ "example.com|MX": ["10 inbound-smtp.ap-northeast-1.amazonaws.com."] });
	assert.equal(await hasMx({}, manualDomain, "inbound-smtp.ap-northeast-1.amazonaws.com"), true);
	assert.equal(await hasMx({}, manualDomain, "mail.example.net"), false);
});

test("a manual zone with no MX answers false, and a failed lookup stays unknown", async () => {
	answerDns({});
	assert.equal(await hasMx({}, manualDomain, "mail.example.net"), false);
	globalThis.fetch = async () => { throw new Error("offline"); };
	assert.equal(await hasMx({}, manualDomain, "mail.example.net"), null);
});

test("DKIM for a Resend domain is checked at Resend's selector when nothing else names one", async () => {
	const asked = answerDns({ "resend._domainkey.example.com|TXT": ["p=abc"] });
	const view = { routing: { records: [], missing: [] }, sending: [] };
	const resend = await auditDomainDns("example.com", view, "resend");
	assert.equal(resend.dkim.status, "ok");
	assert.ok(asked.includes("resend._domainkey.example.com"));
	const other = await auditDomainDns("example.com", view, "none");
	assert.equal(other.dkim.status, "unknown");
});
