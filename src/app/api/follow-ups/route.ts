import { NextResponse } from "next/server";
import { getDb } from "@/db";
import { getCurrentUser } from "@/lib/auth/cookies";
import { getEnv } from "@/lib/cloudflare";
import { listDueFollowUps } from "@/lib/follow-ups/service";
import { getMailboxAccessLevel } from "@/lib/mailboxes/access";

/** Reminders of the signed-in user that came due without a reply. */
export async function GET(request: Request) {
	const env = getEnv();
	const user = await getCurrentUser(env, request);
	if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
	const mailboxId = new URL(request.url).searchParams.get("mailboxId");
	if (mailboxId) {
		const access = await getMailboxAccessLevel(getDb(env), user, mailboxId);
		if (!access?.canRead) return NextResponse.json({ error: "Mailbox not found" }, { status: 404 });
	}
	return NextResponse.json({ followUps: await listDueFollowUps(env, user.id, mailboxId) });
}
