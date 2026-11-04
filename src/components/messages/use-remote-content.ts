"use client";

import { useCallback, useEffect, useState } from "react";
import {
	REMOTE_CONTENT_CHANGE_EVENT,
	allowRemoteContentFromSender,
	loadRemoteContentPolicy,
	shouldAutoLoadRemote,
	type RemoteContentPolicy,
} from "./use-remote-content-utils";

/**
 * Whether a message's remote content loads without a click, per the user's
 * setting. `allowSender` remembers a sender once the user allows their content.
 * Nothing loads until the setting has been read.
 */
export function useRemoteContent(sender: string | undefined, spam: boolean) {
	const [policy, setPolicy] = useState<RemoteContentPolicy | null>(null);
	const address = sender?.trim().toLowerCase();

	useEffect(() => {
		let cancelled = false;
		const load = () => {
			loadRemoteContentPolicy(address)
				.then((loaded) => { if (!cancelled) setPolicy(loaded); })
				.catch(() => { if (!cancelled) setPolicy(null); });
		};
		load();
		window.addEventListener(REMOTE_CONTENT_CHANGE_EVENT, load);
		return () => {
			cancelled = true;
			window.removeEventListener(REMOTE_CONTENT_CHANGE_EVENT, load);
		};
	}, [address]);

	const allowSender = useCallback(() => {
		if (!address || spam || policy?.mode !== "new_sender") return;
		void allowRemoteContentFromSender(address).catch(() => undefined);
	}, [address, spam, policy?.mode]);

	return { autoAllow: shouldAutoLoadRemote(policy, spam), allowSender };
}
