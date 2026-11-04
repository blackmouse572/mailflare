/**
 * What the sign-in QR code encodes. The Mailflare mobile app scans it to fill in
 * its sign-in form: `mailflare://signin?server=…&email=…&key=…`.
 */
export function buildSignInQrPayload({ server, email, key }: { server: string; email: string; key: string }): string {
	const params = new URLSearchParams({ server });
	if (email) params.set("email", email);
	params.set("key", key);
	return `mailflare://signin?${params.toString()}`;
}
