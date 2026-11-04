import assert from "node:assert/strict";
import test from "node:test";

import { getMailboxAccountError } from "../src/lib/mailboxes/account-from-mailbox-utils.ts";

const ADMIN = { id: "usr_admin", email: "boss@example.com" };
const mailbox = { userId: ADMIN.id, ownerEmail: ADMIN.email, localPart: "lan", hostname: "example.com", type: "personal" };

test("an extra personal mailbox of the admin can become an account", () => {
	assert.equal(getMailboxAccountError(mailbox, ADMIN.id), null);
});

test("a mailbox owned by someone else cannot", () => {
	assert.match(getMailboxAccountError({ ...mailbox, userId: "usr_other" }, ADMIN.id), /own/);
});

test("a shared inbox cannot", () => {
	assert.match(getMailboxAccountError({ ...mailbox, type: "shared" }, ADMIN.id), /shared/i);
});

test("the admin's own primary mailbox cannot", () => {
	assert.match(getMailboxAccountError({ ...mailbox, localPart: "boss" }, ADMIN.id), /primary/i);
});
