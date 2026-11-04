"use client";

import { useRef } from "react";
import type { HTMLAttributes, KeyboardEvent } from "react";
import { useDialogFocus } from "./use-dialog-focus";

type DialogFrameProps = Omit<HTMLAttributes<HTMLDivElement>, "role" | "onKeyDown"> & {
	label: string;
	onClose: () => void;
};

export function DialogFrame({ label, onClose, children, ...props }: DialogFrameProps) {
	const ref = useRef<HTMLDivElement>(null);
	useDialogFocus(ref);

	function onKeyDown(event: KeyboardEvent<HTMLDivElement>) {
		if (event.key !== "Escape" || event.defaultPrevented) return;
		event.stopPropagation();
		onClose();
	}

	return (
		<div ref={ref} role="dialog" aria-modal="true" aria-label={label} tabIndex={-1} onKeyDown={onKeyDown} {...props}>
			{children}
		</div>
	);
}
