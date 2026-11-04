export type FollowUpStatus = "pending" | "due" | "replied" | "dismissed";

/** A reminder that has come due without a reply, as listed at the top of the inbox. */
export type DueFollowUp = {
	id: string;
	messageId: string;
	mailboxId: string | null;
	subject: string | null;
	toAddr: string;
	sentAt: string;
	dueAt: string;
};

/** The reminder on one sent message, for its reading view. */
export type MessageFollowUp = {
	id: string;
	status: FollowUpStatus;
	dueAt: string;
};
