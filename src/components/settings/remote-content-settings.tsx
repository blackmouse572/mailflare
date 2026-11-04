"use client";

import { useEffect, useState } from "react";
import { useLanguage } from "@/components/language-provider";
import {
	loadRemoteContentPolicy,
	updateRemoteContentMode,
	type RemoteContentMode,
} from "@/components/messages/use-remote-content-utils";

const OPTIONS = [
	{ mode: "ask", title: "settings.remoteContent.ask" },
	{ mode: "new_sender", title: "settings.remoteContent.newSender" },
	{ mode: "allow", title: "settings.remoteContent.allow" },
] as const;

export function RemoteContentSettings() {
	const { t } = useLanguage();
	const [mode, setMode] = useState<RemoteContentMode>("allow");
	const [loading, setLoading] = useState(true);
	const [saving, setSaving] = useState(false);
	const [error, setError] = useState<string | null>(null);

	useEffect(() => {
		let cancelled = false;
		loadRemoteContentPolicy()
			.then((policy) => { if (!cancelled) setMode(policy.mode); })
			.catch((loadError) => { if (!cancelled) setError(loadError instanceof Error ? loadError.message : t("settings.remoteContent.failed")); })
			.finally(() => { if (!cancelled) setLoading(false); });
		return () => { cancelled = true; };
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	const choose = (next: RemoteContentMode) => {
		const previous = mode;
		setMode(next);
		setSaving(true);
		setError(null);
		updateRemoteContentMode(next)
			.then(setMode)
			.catch((updateError) => {
				setMode(previous);
				setError(updateError instanceof Error ? updateError.message : t("settings.remoteContent.failed"));
			})
			.finally(() => setSaving(false));
	};

	return (
		<div>
			<div role="radiogroup" aria-label={t("settingsPage.inbox.remoteContent")} className="space-y-3">
				{OPTIONS.map((option) => (
					<label key={option.mode} className="flex cursor-pointer items-center gap-3 rounded-xl bg-neutral-50 p-4">
						<input
							type="radio"
							name="remote-content-mode"
														checked={mode === option.mode}
							disabled={loading || saving}
							onChange={() => choose(option.mode)}
						/>
						<span className="flex-1 text-sm font-medium text-neutral-900">{t(option.title)}</span>
					</label>
				))}
			</div>
			{error && <p role="alert" className="mt-2 px-4 text-sm text-red-600">{error}</p>}
		</div>
	);
}
