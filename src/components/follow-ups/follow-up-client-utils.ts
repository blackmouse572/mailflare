import { authFetch } from "@/lib/auth/client";
import type { DueFollowUp, MessageFollowUp } from "@/lib/follow-ups/types";
import type { TranslationKey } from "@/lib/i18n/types";

/** Fired after a reminder changes so the inbox block and thread view reload. */
export const FOLLOW_UPS_CHANGED_EVENT = "mailflare:follow-ups-changed";

export function followUpOptionKey(days: number): TranslationKey {
	if (days === 1) return "followUp.in1Day";
	if (days === 7) return "followUp.in1Week";
	return "followUp.in3Days";
}

export async function fetchDueFollowUps(mailboxId?: string | null): Promise<DueFollowUp[]> {
	const query = mailboxId ? `?mailboxId=${encodeURIComponent(mailboxId)}` : "";
	const response = await authFetch(`/api/follow-ups${query}`);
	if (!response.ok) return [];
	return ((await response.json()) as { followUps: DueFollowUp[] }).followUps;
}

export async function fetchMessageFollowUp(messageId: string): Promise<MessageFollowUp | null> {
	const response = await authFetch(`/api/messages/${messageId}/follow-up`);
	if (!response.ok) return null;
	return ((await response.json()) as { followUp: MessageFollowUp | null }).followUp;
}

async function expectOk(response: Response): Promise<void> {
	if (!response.ok) throw new Error(`Follow-up request failed (${response.status})`);
	window.dispatchEvent(new Event(FOLLOW_UPS_CHANGED_EVENT));
}

export async function setMessageFollowUp(messageId: string, days: number): Promise<void> {
	await expectOk(await authFetch(`/api/messages/${messageId}/follow-up`, {
		method: "PUT",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({ days }),
	}));
}

export async function clearMessageFollowUp(messageId: string): Promise<void> {
	await expectOk(await authFetch(`/api/messages/${messageId}/follow-up`, { method: "DELETE" }));
}

export async function updateDueFollowUp(id: string, change: { action: "dismiss" } | { action: "snooze"; days: number }): Promise<void> {
	await expectOk(await authFetch(`/api/follow-ups/${id}`, {
		method: "PATCH",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify(change),
	}));
}
