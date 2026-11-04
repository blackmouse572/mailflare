import { eq, sql } from "drizzle-orm";
import { getDb } from "@/db";
import { userComposePreferences } from "@/db/schema";
import { isMissingColumnError, isMissingTableError } from "@/lib/database-errors";
import { DEFAULT_UNDO_SEND_SECONDS, parseUndoSendSeconds } from "./compose-utils";
import type { ComposePreferences } from "./types";

const DEFAULTS: ComposePreferences = { trackOpensDefault: false, undoSendSeconds: DEFAULT_UNDO_SEND_SECONDS };

export class ComposePreferencesUnavailableError extends Error {
	constructor() {
		super("Apply pending database migrations first");
	}
}

/** The user's composer defaults; missing migrations (0072, 0073) fall back to the defaults. */
export async function getComposePreferences(env: CloudflareEnv, userId: string): Promise<ComposePreferences> {
	const db = getDb(env);
	try {
		const [row] = await db
			.select({ trackOpensDefault: userComposePreferences.trackOpensDefault, undoSendSeconds: userComposePreferences.undoSendSeconds })
			.from(userComposePreferences)
			.where(eq(userComposePreferences.userId, userId))
			.limit(1);
		if (!row) return DEFAULTS;
		return { trackOpensDefault: row.trackOpensDefault, undoSendSeconds: parseUndoSendSeconds(row.undoSendSeconds) ?? DEFAULT_UNDO_SEND_SECONDS };
	} catch (error) {
		if (isMissingTableError(error)) return DEFAULTS;
		if (!isMissingColumnError(error)) throw error;
	}
	const [row] = await db
		.select({ trackOpensDefault: userComposePreferences.trackOpensDefault })
		.from(userComposePreferences)
		.where(eq(userComposePreferences.userId, userId))
		.limit(1);
	return { ...DEFAULTS, trackOpensDefault: row?.trackOpensDefault ?? false };
}

export async function updateComposePreferences(env: CloudflareEnv, userId: string, patch: Partial<ComposePreferences>): Promise<ComposePreferences> {
	const next = { ...(await getComposePreferences(env, userId)), ...patch };
	const db = getDb(env);
	const updatedAt = new Date();
	try {
		await db
			.insert(userComposePreferences)
			.values({ userId, ...next, updatedAt })
			.onConflictDoUpdate({ target: userComposePreferences.userId, set: { ...next, updatedAt } });
		return next;
	} catch (error) {
		if (isMissingTableError(error)) throw new ComposePreferencesUnavailableError();
		if (!isMissingColumnError(error)) throw error;
	}
	// Before migration 0073 only the read-receipt default can be stored.
	if (next.undoSendSeconds !== DEFAULT_UNDO_SEND_SECONDS) throw new ComposePreferencesUnavailableError();
	await db.run(sql`
		INSERT INTO user_compose_preferences (user_id, track_opens_default, updated_at)
		VALUES (${userId}, ${next.trackOpensDefault ? 1 : 0}, ${Math.floor(updatedAt.getTime() / 1000)})
		ON CONFLICT (user_id) DO UPDATE SET track_opens_default = excluded.track_opens_default, updated_at = excluded.updated_at
	`);
	return next;
}
