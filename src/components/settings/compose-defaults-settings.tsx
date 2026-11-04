"use client";

import { useEffect, useState } from "react";
import { loadComposePreferences, updateComposePreferences } from "@/components/compose/compose-preferences-utils";
import { useLanguage } from "@/components/language-provider";
import { Select } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { DEFAULT_UNDO_SEND_SECONDS, UNDO_SEND_OPTIONS, parseUndoSendSeconds } from "@/lib/compose/compose-utils";
import type { ComposePreferences } from "@/lib/compose/types";

/** Account-wide composer defaults; each message can still change the read receipt in the composer. */
export function ComposeDefaultsSettings() {
	const { t } = useLanguage();
	const [preferences, setPreferences] = useState<ComposePreferences>({ trackOpensDefault: false, undoSendSeconds: DEFAULT_UNDO_SEND_SECONDS });
	const [loading, setLoading] = useState(true);
	const [saving, setSaving] = useState(false);
	const [error, setError] = useState<string | null>(null);

	useEffect(() => {
		let active = true;
		void loadComposePreferences()
			.then((loaded) => {
				if (active) setPreferences(loaded);
			})
			.catch(() => {
				if (active) setError(t("settings.compose.failed"));
			})
			.finally(() => {
				if (active) setLoading(false);
			});
		return () => {
			active = false;
		};
	}, [t]);

	function change(patch: Partial<ComposePreferences>) {
		const previous = preferences;
		setPreferences({ ...preferences, ...patch });
		setSaving(true);
		setError(null);
		void updateComposePreferences(patch)
			.then(setPreferences)
			.catch((saveError) => {
				setPreferences(previous);
				setError(saveError instanceof Error && saveError.message === "MIGRATION_REQUIRED" ? t("settings.compose.migrationRequired") : t("settings.compose.failed"));
			})
			.finally(() => setSaving(false));
	}

	return (
		<div className="space-y-3">
			<label className="flex items-start gap-3 rounded-xl bg-neutral-50 p-4">
				<span className="flex-1">
					<span className="block text-sm font-medium text-neutral-900">{t("settings.compose.trackOpensTitle")}</span>
					<span className="mt-1 block text-sm text-neutral-500">{t("settings.compose.trackOpensDescription")}</span>
				</span>
				<Switch
					checked={preferences.trackOpensDefault}
					disabled={loading || saving}
					onCheckedChange={(trackOpensDefault) => change({ trackOpensDefault })}
					aria-label={t("settings.compose.trackOpensTitle")}
				/>
			</label>
			<div className="flex items-start gap-3 rounded-xl bg-neutral-50 p-4">
				<span className="flex-1">
					<label htmlFor="compose-undo-send" className="block text-sm font-medium text-neutral-900">{t("settings.compose.undoTitle")}</label>
					<span className="mt-1 block text-sm text-neutral-500">{t("settings.compose.undoDescription")}</span>
				</span>
				<Select
					id="compose-undo-send"
					value={String(preferences.undoSendSeconds)}
					disabled={loading || saving}
					className="py-1.5 text-sm text-neutral-900"
					onChange={(event) => {
						const undoSendSeconds = parseUndoSendSeconds(event.target.value);
						if (undoSendSeconds !== null) change({ undoSendSeconds });
					}}
				>
					{UNDO_SEND_OPTIONS.map((seconds) => (
						<option key={seconds} value={seconds}>
							{seconds === 0 ? t("settings.compose.undoOff") : t("settings.compose.undoSeconds", { seconds })}
						</option>
					))}
				</Select>
			</div>
			{error && <p role="alert" className="px-4 text-sm text-red-600">{error}</p>}
		</div>
	);
}
