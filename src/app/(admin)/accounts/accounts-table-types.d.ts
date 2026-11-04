import type { Account } from "./types";

export type AccountsTableProps = {
	accounts: Account[];
	currentUserId?: string;
	isPrimaryAdmin: boolean;
	loading: boolean;
	selected: Set<string>;
	onSelectedChange: (selected: Set<string>) => void;
	onDeleteSelected: () => void;
	onRestore: (account: Account) => void;
	restoringId: string | null;
};

export type DeleteAccountsDialogProps = {
	open: boolean;
	onOpenChange: (open: boolean) => void;
	accounts: Account[];
	candidates: Account[];
	onDeleted: () => void;
};
