import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";
import Database from "better-sqlite3";

const { migrations } = JSON.parse(readFileSync(new URL("../src/lib/migrations/bundle.json", import.meta.url), "utf8"));

function database() {
	const db = new Database(":memory:");
	db.pragma("foreign_keys = OFF");
	for (const migration of migrations) for (const statement of migration.statements) db.exec(statement);
	return db;
}

const insert = (db, id, user, key, token) =>
	db
		.prepare(
			`INSERT INTO push_devices (id, user_id, api_key_id, platform, token, environment, topic, previews, client_ref, created_at, updated_at)
			 VALUES (?, ?, ?, 'apns', ?, 'production', 'app', 1, ?, 1, 1)
			 ON CONFLICT (platform, token, user_id) DO UPDATE SET api_key_id = excluded.api_key_id, client_ref = excluded.client_ref`,
		)
		.run(id, user, key, token, `ref-${user}`);

test("two accounts on one device each keep their push registration", () => {
	const db = database();
	insert(db, "a", "user1", "key1", "tok");
	insert(db, "b", "user2", "key2", "tok");
	const rows = db.prepare("SELECT user_id, client_ref FROM push_devices WHERE token = 'tok' ORDER BY user_id").all();
	assert.deepEqual(rows, [
		{ user_id: "user1", client_ref: "ref-user1" },
		{ user_id: "user2", client_ref: "ref-user2" },
	]);
});

test("registering the same account again replaces its key instead of duplicating", () => {
	const db = database();
	insert(db, "a", "user1", "key1", "tok");
	insert(db, "b", "user1", "key9", "tok");
	assert.deepEqual(db.prepare("SELECT api_key_id FROM push_devices").all(), [{ api_key_id: "key9" }]);
});
