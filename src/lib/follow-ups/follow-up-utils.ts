/** Reminder delays offered by the composer, in days after delivery. */
export const FOLLOW_UP_DAY_OPTIONS = [1, 3, 7] as const;
export const MAX_FOLLOW_UP_DAYS = 30;

const DAY_MS = 24 * 60 * 60 * 1000;

/** Accepts a whole number of days from a form or JSON body; anything else means no reminder. */
export function parseFollowUpDays(value: unknown): number | null {
	const days = typeof value === "string" ? Number(value.trim()) : value;
	if (typeof days !== "number" || !Number.isInteger(days) || days < 1 || days > MAX_FOLLOW_UP_DAYS) return null;
	return days;
}

export function followUpDueAt(from: Date, days: number): Date {
	return new Date(from.getTime() + days * DAY_MS);
}

/**
 * Whether an inbound message answers the sent one: same mailbox and thread,
 * and received after the send. Replies are threaded by In-Reply-To/References,
 * so a reply to any message in the conversation counts.
 */
export function isReplyTo(
	sent: { mailboxId: string | null; threadId: string | null; createdAt: Date },
	candidate: { mailboxId: string | null; threadId: string | null; direction: string; createdAt: Date },
): boolean {
	return candidate.direction === "inbound" &&
		!!sent.threadId && candidate.threadId === sent.threadId &&
		candidate.mailboxId === sent.mailboxId &&
		candidate.createdAt.getTime() > sent.createdAt.getTime();
}
