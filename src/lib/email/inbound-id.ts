export async function inboundMessageId(rawR2Key: string): Promise<string> {
	const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(rawR2Key));
	const hex = Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
	return `msg_${hex}`;
}

async function sha256Hex(parts: (string | Uint8Array)[]): Promise<string> {
	const encoder = new TextEncoder();
	const buffers = parts.map((part) => (typeof part === "string" ? encoder.encode(part) : part));
	const joined = new Uint8Array(buffers.reduce((total, buffer) => total + buffer.length, 0));
	let offset = 0;
	for (const buffer of buffers) {
		joined.set(buffer, offset);
		offset += buffer.length;
	}
	const digest = await crypto.subtle.digest("SHA-256", joined);
	return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

/**
 * Deterministic storage key for an inbound message, derived from the mailbox
 * and the raw bytes. A relay retry replays identical bytes, so it overwrites
 * the same object and the inbound queue consumer, which dedupes by
 * `(mailboxId, rawR2Key)`, skips it. Sender-controlled headers such as
 * `Message-ID` are deliberately not part of the key: a third party who knows
 * a message's `Message-ID` could otherwise overwrite its stored raw MIME or
 * make the real delivery look like a duplicate.
 */
export async function inboundStorageKey(raw: ArrayBuffer, mailboxId?: string): Promise<string> {
	return `inbound/${await sha256Hex([mailboxId ?? "", "\0", new Uint8Array(raw)])}.eml`;
}
