/** Seconds a send waits so it can still be cancelled; 0 sends at once. */
export const UNDO_SEND_OPTIONS = [0, 5, 10, 15, 30] as const;
export const DEFAULT_UNDO_SEND_SECONDS = 15;

export function parseUndoSendSeconds(value: unknown): number | null {
	const seconds = typeof value === "string" && value.trim() !== "" ? Number(value) : value;
	return typeof seconds === "number" && (UNDO_SEND_OPTIONS as readonly number[]).includes(seconds) ? seconds : null;
}
