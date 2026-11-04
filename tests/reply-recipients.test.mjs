import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import test, { after } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import { build } from "esbuild";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const directory = mkdtempSync(join(root, "node_modules", "mailflare-reply-recipients-"));
after(() => rmSync(directory, { recursive: true, force: true }));
await build({
	stdin: {
		contents: `
			export { createReplyDraft, getReplyRecipients, getReplyThreading, hasAdditionalRecipients } from "./src/components/message-actions/utils.ts";
			export { getOwnAddressForMessage } from "./src/app/(dashboard)/inbox/[messageId]/utils.ts";
			export { parseRawMime } from "./src/lib/email/parse.ts";
		`,
		resolveDir: root,
		sourcefile: "reply-recipients-entry.ts",
	},
	outfile: join(directory, "entry.mjs"),
	bundle: true,
	platform: "node",
	format: "esm",
	target: "node24",
	tsconfig: join(root, "tsconfig.json"),
	packages: "external",
	logLevel: "silent",
});
const { createReplyDraft, getReplyRecipients, getReplyThreading, hasAdditionalRecipients, getOwnAddressForMessage, parseRawMime } = await import(pathToFileURL(join(directory, "entry.mjs")).href);

const own = ["hello@example.com"];
const inbound = (fields) => ({
	direction: "inbound",
	fromAddr: "Website <no-reply@example.com>",
	toAddr: "hello@example.com",
	ccAddr: null,
	replyTo: null,
	providerMessageId: null,
	references: null,
	threadId: null,
	...fields,
});

test("a reply answers the sender when there is no Reply-To", () => {
	assert.deepEqual(getReplyRecipients(inbound({}), own, "reply"), { to: ["Website <no-reply@example.com>"], cc: [] });
});

test("a reply goes to every Reply-To address instead of the sender", () => {
	const message = inbound({ replyTo: "Visitor <visitor@example.net>, other@example.org" });
	assert.deepEqual(getReplyRecipients(message, own, "reply"), { to: ["Visitor <visitor@example.net>", "other@example.org"], cc: [] });
});

test("reply-all keeps the other recipients but not the From the Reply-To replaced", () => {
	const message = inbound({ replyTo: "visitor@example.net", toAddr: "hello@example.com, team@example.org", ccAddr: "boss@example.org" });
	assert.deepEqual(getReplyRecipients(message, own, "replyAll"), { to: ["visitor@example.net"], cc: ["team@example.org", "boss@example.org"] });
});

test("a Reply-To naming only the mailbox itself falls back to the sender", () => {
	const message = inbound({ replyTo: "hello@example.com" });
	assert.deepEqual(getReplyRecipients(message, own, "reply").to, ["Website <no-reply@example.com>"]);
});

test("the parser keeps the full Reply-To header", async () => {
	const raw = new TextEncoder().encode([
		"From: Website <no-reply@example.com>",
		"To: hello@example.com",
		"Reply-To: Visitor <visitor@example.net>, other@example.org",
		"Subject: Enquiry",
		"",
		"Hi",
	].join("\r\n")).buffer;
	assert.equal((await parseRawMime(raw)).replyTo, '"Visitor" <visitor@example.net>, other@example.org');
});

const ownAliases = ["hello@example.com", "hello@example.org"];
const aliasMessage = inbound({
	fromAddr: "Owner <hello@example.com>",
	toAddr: "hello@example.org",
	providerMessageId: "<original@example.com>",
	references: "<earlier@example.com>",
	threadId: "alias-thread",
});

test("a reply retains an incoming sender at the same own address or another own alias", () => {
	for (const toAddr of ownAliases) {
		const message = { ...aliasMessage, toAddr };
		assert.deepEqual(getReplyRecipients(message, ownAliases, "reply"), { to: [aliasMessage.fromAddr], cc: [] });
		assert.equal(hasAdditionalRecipients(message, ownAliases), false);
	}
});

test("reply-all retains the own-alias sender while excluding other own addresses and duplicates", () => {
	const message = { ...aliasMessage, toAddr: "hello@example.org, Friend <friend@example.net>", ccAddr: "HELLO@example.com, FRIEND@example.net, colleague@example.net" };
	assert.deepEqual(getReplyRecipients(message, ownAliases, "replyAll"), { to: [aliasMessage.fromAddr], cc: ["Friend <friend@example.net>", "colleague@example.net"] });
	assert.equal(hasAdditionalRecipients(message, ownAliases), true);
	const outgoing = { ...message, direction: "outbound", toAddr: "hello@example.org, friend@example.net" };
	assert.deepEqual(getReplyRecipients(outgoing, ownAliases, "replyAll"), { to: ["friend@example.net"], cc: ["colleague@example.net"] });
});

test("Reply-To precedence and own-address fallback work with an own-alias sender", () => {
	const message = { ...aliasMessage, replyTo: "Visitor <visitor@example.net>, other@example.net" };
	assert.deepEqual(getReplyRecipients(message, ownAliases, "replyAll"), { to: ["Visitor <visitor@example.net>", "other@example.net"], cc: [] });
	assert.deepEqual(getReplyRecipients({ ...aliasMessage, replyTo: "hello@example.org" }, ownAliases, "reply"), { to: [aliasMessage.fromAddr], cc: [] });
});

test("a cross-alias reply creates a draft from the receiving alias with the original threading", async (t) => {
	const requests = [];
	t.mock.method(globalThis, "fetch", async (url, options) => {
		assert.equal(url, "/api/drafts", "the test must not contact a real service");
		assert.equal(options.method, "POST");
		requests.push(JSON.parse(options.body));
		return Response.json({ draft: { id: "reply-draft" } });
	});
	const draftId = await createReplyDraft({
		mailboxId: "mailbox-1",
		senderAddress: aliasMessage.fromAddr,
		ownAddress: getOwnAddressForMessage(aliasMessage, ownAliases),
		subject: "Alias test",
		bodyText: "Original message",
		sentAt: "2026-10-14T12:00:00.000Z",
		recipients: getReplyRecipients(aliasMessage, ownAliases, "reply"),
		threading: getReplyThreading(aliasMessage),
	});
	assert.equal(draftId, "reply-draft");
	assert.equal(requests.length, 1);
	assert.equal(requests[0].mailboxId, "mailbox-1");
	assert.equal(requests[0].from, "hello@example.org");
	assert.equal(requests[0].to, aliasMessage.fromAddr);
	assert.equal(requests[0].cc, "");
	assert.equal(requests[0].subject, "Re: Alias test");
	assert.equal(requests[0].inReplyTo, "original@example.com");
	assert.equal(requests[0].references, "earlier@example.com original@example.com");
	assert.equal(requests[0].threadId, aliasMessage.threadId);
	assert.match(requests[0].html, /Original message/);
});

test("a missing incoming sender still cannot create a reply draft", async () => {
	const message = { ...aliasMessage, fromAddr: "" };
	const recipients = getReplyRecipients(message, ownAliases, "reply");
	assert.deepEqual(recipients, { to: [], cc: [] });
	await assert.rejects(createReplyDraft({ mailboxId: "mailbox-1", senderAddress: "", recipients }), /Sender address is required/);
});
