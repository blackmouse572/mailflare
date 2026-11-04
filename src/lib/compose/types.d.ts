export type ComposePreferences = {
	/** New messages start with the read-receipt pixel on. */
	trackOpensDefault: boolean;
	/** One of UNDO_SEND_OPTIONS; 0 sends without an undo window. */
	undoSendSeconds: number;
};
