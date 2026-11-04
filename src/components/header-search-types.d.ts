import type { ReactNode } from "react";

export type HeaderSearchProps = {
	value: string;
	onChange: (value: string) => void;
	label: string;
	placeholder?: string;
	onSubmit?: () => void;
	trailing?: ReactNode;
	inputProps?: Record<string, string>;
	// On phones, park the collapsed search icon at the right end of the header.
	mobileEnd?: boolean;
};
