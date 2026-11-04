type MailboxForAccount = {
	userId: string;
	ownerEmail: string;
	localPart: string;
	hostname: string;
	type: "personal" | "shared";
};

/** Why this mailbox cannot become its own sign-in account, or null when it can. */
export function getMailboxAccountError(mailbox: MailboxForAccount, actorId: string): string | null {
	if (mailbox.userId !== actorId) return "Only mailboxes you own can become an account";
	if (mailbox.type === "shared") return "A shared inbox cannot become an account. Share it with accounts instead";
	if (`${mailbox.localPart}@${mailbox.hostname}`.toLowerCase() === mailbox.ownerEmail.trim().toLowerCase()) return "This is the primary mailbox of your own account";
	return null;
}
