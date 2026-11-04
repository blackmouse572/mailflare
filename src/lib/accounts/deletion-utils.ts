export const ACCOUNT_RESTORE_DAYS = 20;

const DAY_MS = 24 * 60 * 60_000;

/** Last moment a deleted account can still be restored. */
export function getAccountPurgeDate(deletedAt: Date): Date {
	return new Date(deletedAt.getTime() + ACCOUNT_RESTORE_DAYS * DAY_MS);
}

/** Cutoff for the scheduled purge: accounts deleted at or before this are removed for good. */
export function getAccountPurgeCutoff(now: Date): Date {
	return new Date(now.getTime() - ACCOUNT_RESTORE_DAYS * DAY_MS);
}

export function getAccountStatus(account: { disabled: boolean; deletedAt?: Date | string | null }): "active" | "disabled" | "pendingDeletion" {
	if (account.deletedAt) return "pendingDeletion";
	return account.disabled ? "disabled" : "active";
}
