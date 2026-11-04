import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import test, { after } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import { build } from "esbuild";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const outDir = mkdtempSync(join(root, "tests", ".tmp-follow-ups-"));
after(() => rmSync(outDir, { recursive: true, force: true }));

await build({
	entryPoints: {
		utils: join(root, "src/lib/follow-ups/follow-up-utils.ts"),
		service: join(root, "src/lib/follow-ups/service.ts"),
		database: join(root, "server/runtime/sqlite-database.ts"),
		migrate: join(root, "server/runtime/migrate.ts"),
	},
	outdir: outDir,
	outExtension: { ".js": ".mjs" },
	bundle: true,
	platform: "node",
	format: "esm",
	target: "node22",
	tsconfig: join(root, "tsconfig.json"),
	external: ["better-sqlite3", "drizzle-orm", "drizzle-orm/*"],
	logLevel: "silent",
});

const load = (name) => import(pathToFileURL(join(outDir, `${name}.mjs`)).href);
const utils = await load("utils");
const service = await load("service");
const { SqliteDatabase } = await load("database");
const { applyMigrations } = await load("migrate");

const DAY = 24 * 60 * 60 * 1000;
const seconds = (date) => Math.floor(date.getTime() / 1000);

async function createFixture(t) {
	const database = new SqliteDatabase(join(outDir, `${crypto.randomUUID()}.sqlite`));
	t.after(() => database.db.close());
	await applyMigrations(database, join(root, "drizzle/migrations"));
	const now = seconds(new Date());
	database.db.prepare("INSERT INTO users (id, email, name, password_hash, created_at) VALUES ('u1', 'kevin@example.com', 'Kevin', 'x', ?)").run(now);
	database.db.prepare("INSERT INTO domains (id, user_id, hostname, zone_id, created_at) VALUES ('d1', 'u1', 'example.com', 'zone', ?)").run(now);
	database.db.prepare("INSERT INTO mailboxes (id, user_id, domain_id, local_part, created_at) VALUES ('mb1', 'u1', 'd1', 'kevin', ?)").run(now);
	const addMessage = (id, { direction = "outbound", threadId = "thread-1", mailboxId = "mb1", at = new Date() } = {}) => {
		database.db.prepare(
			"INSERT INTO messages (id, mailbox_id, user_id, direction, from_addr, to_addr, subject, status, thread_id, created_at) VALUES (?, ?, 'u1', ?, 'kevin@example.com', 'anna@example.org', 'Offer', ?, ?, ?)",
		).run(id, mailboxId, direction, direction === "outbound" ? "sent" : "received", threadId, seconds(at));
	};
	const status = (messageId) => database.db.prepare("SELECT status FROM follow_ups WHERE message_id = ?").get(messageId)?.status;
	return { env: { DB: database }, addMessage, status };
}

test("parseFollowUpDays accepts whole days from 1 to 30 only", () => {
	assert.equal(utils.parseFollowUpDays("3"), 3);
	assert.equal(utils.parseFollowUpDays(7), 7);
	for (const value of ["0", "31", "1.5", "", "soon", null, undefined, -1]) assert.equal(utils.parseFollowUpDays(value), null, String(value));
});

test("isReplyTo needs an inbound message in the same mailbox and thread, after the send", () => {
	const sent = { mailboxId: "mb1", threadId: "t", createdAt: new Date(1000) };
	const reply = { mailboxId: "mb1", threadId: "t", direction: "inbound", createdAt: new Date(2000) };
	assert.equal(utils.isReplyTo(sent, reply), true);
	assert.equal(utils.isReplyTo(sent, { ...reply, direction: "outbound" }), false);
	assert.equal(utils.isReplyTo(sent, { ...reply, threadId: "other" }), false);
	assert.equal(utils.isReplyTo(sent, { ...reply, mailboxId: "mb2" }), false);
	assert.equal(utils.isReplyTo(sent, { ...reply, createdAt: new Date(500) }), false);
	assert.equal(utils.isReplyTo({ ...sent, threadId: null }, { ...reply, threadId: null }), false);
});

test("a due reminder without a reply surfaces in the inbox list", async (t) => {
	const { env, addMessage, status } = await createFixture(t);
	const sentAt = new Date(Date.now() - 4 * DAY);
	addMessage("sent-1", { at: sentAt });
	addMessage("earlier-inbound", { direction: "inbound", at: new Date(sentAt.getTime() - DAY) });
	await service.setFollowUp(env, { messageId: "sent-1", userId: "u1", days: 3, from: sentAt });

	await service.runFollowUpReminders(env, new Date());
	assert.equal(status("sent-1"), "due");
	const due = await service.listDueFollowUps(env, "u1");
	assert.deepEqual(due.map((item) => item.messageId), ["sent-1"]);
	assert.equal(due[0].subject, "Offer");
	assert.deepEqual(await service.listDueFollowUps(env, "u1", "mb-other"), []);
});

test("a reply closes the reminder, both before and after it came due", async (t) => {
	const { env, addMessage, status } = await createFixture(t);
	const sentAt = new Date(Date.now() - 4 * DAY);
	addMessage("answered", { at: sentAt, threadId: "thread-a" });
	addMessage("reply-a", { direction: "inbound", threadId: "thread-a", at: new Date(sentAt.getTime() + DAY) });
	addMessage("late", { at: sentAt, threadId: "thread-b" });
	await service.setFollowUp(env, { messageId: "answered", userId: "u1", days: 3, from: sentAt });
	await service.setFollowUp(env, { messageId: "late", userId: "u1", days: 3, from: sentAt });

	await service.runFollowUpReminders(env, new Date());
	assert.equal(status("answered"), "replied");
	assert.equal(status("late"), "due");

	addMessage("reply-b", { direction: "inbound", threadId: "thread-b" });
	assert.deepEqual(await service.listDueFollowUps(env, "u1"), []);
	assert.equal(status("late"), "replied");
	assert.equal((await service.getMessageFollowUp(env, "u1", "late")).status, "replied");
});

test("reminders that are not yet due stay pending; snooze and dismiss belong to their owner", async (t) => {
	const { env, addMessage, status } = await createFixture(t);
	addMessage("fresh");
	const followUp = await service.setFollowUp(env, { messageId: "fresh", userId: "u1", days: 1 });
	await service.runFollowUpReminders(env, new Date());
	assert.equal(status("fresh"), "pending");

	assert.equal(await service.updateFollowUp(env, "someone-else", followUp.id, { action: "dismiss" }), false);
	assert.equal(await service.updateFollowUp(env, "u1", followUp.id, { action: "dismiss" }), true);
	assert.equal(status("fresh"), "dismissed");
	assert.equal(await service.updateFollowUp(env, "u1", followUp.id, { action: "snooze", days: 3 }), true);
	assert.equal(status("fresh"), "pending");
	const again = await service.getMessageFollowUp(env, "u1", "fresh");
	assert.ok(new Date(again.dueAt).getTime() > Date.now() + 2 * DAY);
});

test("without migration 0071 reminders are absent instead of failing", async (t) => {
	const database = new SqliteDatabase(join(outDir, `${crypto.randomUUID()}.sqlite`));
	t.after(() => database.db.close());
	const env = { DB: database };
	await service.runFollowUpReminders(env, new Date());
	assert.deepEqual(await service.listDueFollowUps(env, "u1"), []);
	assert.equal(await service.getMessageFollowUp(env, "u1", "m1"), null);
});
