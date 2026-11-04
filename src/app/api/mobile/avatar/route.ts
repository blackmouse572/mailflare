import { NextResponse } from "next/server";
import { getEnv } from "@/lib/cloudflare";
import { eq } from "drizzle-orm";
import { getDb } from "@/db";
import { domains, mailboxes, users } from "@/db/schema";
import { getMailboxAccessLevel } from "@/lib/mailboxes/access";
import { tracksAccountIdentity } from "@/lib/profile/identity-utils";
import { authenticateApiRequest, hasScope } from "@/lib/api/key-auth";
import { getAvatarImageResponse } from "@/lib/avatar-images";

/**
 * The signed-in user's profile picture for the mobile app. `GET /api/profile/avatar`
 * needs a session cookie, which a device key is not, so this takes the same
 * `jmap`-scoped key the app uses everywhere else. `?variant=preview` is the small one.
 * `?mailbox=<id>` returns that mailbox's picture instead (the account's own when it is
 * the primary mailbox), for the app's inbox switcher.
 */
export async function GET(request: Request) {
	const env = getEnv();
	const auth = await authenticateApiRequest(env, request);
	if (!auth) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
	if (!hasScope(auth.scopes, "jmap")) return NextResponse.json({ error: "This key does not have the jmap scope" }, { status: 403 });
	const mailboxId = new URL(request.url).searchParams.get("mailbox");
	if (mailboxId) {
		const db = getDb(env);
		const access = await getMailboxAccessLevel(db, auth.user, mailboxId);
		if (!access?.canRead) return new Response("Not found", { status: 404 });
		const [mailbox] = await db
			.select({
				avatarKey: mailboxes.avatarKey,
				type: mailboxes.type,
				localPart: mailboxes.localPart,
				hostname: domains.hostname,
				ownerEmail: users.email,
				ownerAvatarKey: users.avatarKey,
			})
			.from(mailboxes)
			.innerJoin(domains, eq(mailboxes.domainId, domains.id))
			.innerJoin(users, eq(mailboxes.userId, users.id))
			.where(eq(mailboxes.id, mailboxId))
			.limit(1);
		const key = mailbox && tracksAccountIdentity(mailbox, mailbox.ownerEmail) ? mailbox.ownerAvatarKey : mailbox?.avatarKey;
		if (!key) return new Response("Not found", { status: 404 });
		return getAvatarImageResponse(request, env.BUCKET, key);
	}
	if (!auth.user.avatarKey) return new Response("Not found", { status: 404 });
	return getAvatarImageResponse(request, env.BUCKET, auth.user.avatarKey);
}
