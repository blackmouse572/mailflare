import { authFetch } from "@/lib/auth/client";

export type RemoteContentMode = "ask" | "new_sender" | "allow";

export type RemoteContentPolicy = {
	mode: RemoteContentMode;
	/** Only reported for `new_sender`, and only when a sender was asked about. */
	senderAllowed?: boolean;
};

export const REMOTE_CONTENT_CHANGE_EVENT = "mailflare:remote-content-changed";

const ENDPOINT = "/api/settings/remote-content";

/** Spam never loads remote content on its own, whatever the setting. */
export function shouldAutoLoadRemote(policy: RemoteContentPolicy | null, spam: boolean): boolean {
	if (!policy || spam) return false;
	if (policy.mode === "allow") return true;
	return policy.mode === "new_sender" && policy.senderAllowed === true;
}

async function readPolicy(response: Response, fallback: string): Promise<RemoteContentPolicy> {
	const data = (await response.json()) as Partial<RemoteContentPolicy> & { error?: string };
	if (!response.ok || !data.mode) throw new Error(typeof data.error === "string" ? data.error : fallback);
	return { mode: data.mode, senderAllowed: data.senderAllowed };
}

export async function loadRemoteContentPolicy(sender?: string): Promise<RemoteContentPolicy> {
	const query = sender ? `?sender=${encodeURIComponent(sender)}` : "";
	return readPolicy(await authFetch(`${ENDPOINT}${query}`), "Failed to load remote content settings");
}

export async function updateRemoteContentMode(mode: RemoteContentMode): Promise<RemoteContentMode> {
	const response = await authFetch(ENDPOINT, {
		method: "PATCH",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({ mode }),
	});
	const updated = await readPolicy(response, "Failed to update remote content settings");
	window.dispatchEvent(new Event(REMOTE_CONTENT_CHANGE_EVENT));
	return updated.mode;
}

export async function allowRemoteContentFromSender(sender: string): Promise<void> {
	const response = await authFetch(ENDPOINT, {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({ sender }),
	});
	if (!response.ok) throw new Error("Failed to remember sender");
}
