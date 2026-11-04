import { useEffect, useState } from "react";
import { getCachedComposePreferences, loadComposePreferences } from "./compose-preferences-utils";

/**
 * Whether this message carries a read-receipt pixel. Starts from the account
 * default (Settings → Inbox → Compose); toggling it only affects this message.
 */
export function useTrackOpens(): [boolean, (next: boolean) => void] {
	const [choice, setChoice] = useState<boolean | null>(null);
	const [accountDefault, setAccountDefault] = useState(() => getCachedComposePreferences()?.trackOpensDefault ?? false);

	useEffect(() => {
		let active = true;
		void loadComposePreferences()
			.then((preferences) => {
				if (active) setAccountDefault(preferences.trackOpensDefault);
			})
			.catch(() => undefined);
		return () => {
			active = false;
		};
	}, []);

	return [choice ?? accountDefault, setChoice];
}
