import { sql } from "drizzle-orm";
import { getDb } from "@/db";
import { spamReputation } from "@/db/schema";
import type { ReputationKey } from "./types";

export async function recordReputationObservation(env: CloudflareEnv, mailboxId: string, keys: ReputationKey[]): Promise<void> {
	if (keys.length === 0) return;
	const db = getDb(env);
	const now = new Date();
	await db.batch(keys.map((item) => db
		.insert(spamReputation)
		.values({ mailboxId, type: item.type, key: item.key, messagesSeen: 1, spamCount: 0, hamCount: 0, firstSeenAt: now, lastSeenAt: now })
		.onConflictDoUpdate({
			target: [spamReputation.mailboxId, spamReputation.type, spamReputation.key],
			set: { messagesSeen: sql`${spamReputation.messagesSeen} + 1`, lastSeenAt: now },
		})) as never);
}
