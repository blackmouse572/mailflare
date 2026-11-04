import type { Translator } from "@/lib/i18n/utils";

export function escapeHtml(value: string): string {
	return value.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

export function buildPasswordResetEmail(
	t: Translator,
	{ email, appName, link, minutes }: { email: string; appName: string; link: string; minutes: number },
): { subject: string; text: string; html: string } {
	const ignore = t("auth.resetMail.ignore");
	return {
		subject: t("auth.resetMail.subject", { appName }),
		text: [
			t("auth.resetMail.intro", { email, appName }),
			"",
			t("auth.resetMail.instructions", { minutes }),
			link,
			"",
			ignore,
		].join("\n"),
		html: `<p>${t("auth.resetMail.intro", { email: `<b>${escapeHtml(email)}</b>`, appName: escapeHtml(appName) })}</p><p>${escapeHtml(t("auth.resetMail.instructions", { minutes }))}</p><p><a href="${escapeHtml(link)}">${escapeHtml(link)}</a></p><p>${escapeHtml(ignore)}</p>`,
	};
}
