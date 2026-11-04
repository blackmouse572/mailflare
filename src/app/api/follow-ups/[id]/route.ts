import { NextResponse } from "next/server";
import { getCurrentUser } from "@/lib/auth/cookies";
import { getEnv } from "@/lib/cloudflare";
import { parseFollowUpDays } from "@/lib/follow-ups/follow-up-utils";
import { updateFollowUp } from "@/lib/follow-ups/service";

/** `{ action: "dismiss" }` closes a reminder; `{ action: "snooze", days }` brings it back later. */
export async function PATCH(request: Request, { params }: { params: Promise<{ id: string }> }) {
	const { id } = await params;
	const env = getEnv();
	const user = await getCurrentUser(env, request);
	if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
	const body = (await request.json().catch(() => null)) as { action?: unknown; days?: unknown } | null;
	let updated: boolean;
	if (body?.action === "dismiss") {
		updated = await updateFollowUp(env, user.id, id, { action: "dismiss" });
	} else if (body?.action === "snooze") {
		const days = parseFollowUpDays(body.days);
		if (!days) return NextResponse.json({ error: "Choose a reminder delay" }, { status: 400 });
		updated = await updateFollowUp(env, user.id, id, { action: "snooze", days });
	} else {
		return NextResponse.json({ error: "Unknown action" }, { status: 400 });
	}
	if (!updated) return NextResponse.json({ error: "Reminder not found" }, { status: 404 });
	return NextResponse.json({ ok: true });
}
