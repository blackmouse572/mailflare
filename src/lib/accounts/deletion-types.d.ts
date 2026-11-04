export type DeleteAccountsInput = {
	ids: string[];
	transferToId?: string | null;
};

export type DeleteAccountsResult =
	| { ok: true; deleted: number }
	| { ok: false; status: number; error: string };
