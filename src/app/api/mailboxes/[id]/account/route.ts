import { and, eq } from "drizzle-orm";
import { NextResponse } from "next/server";
import { z } from "zod";
import { getDb } from "@/db";
import { calendarEvents, folders, mailboxes, messages, routingRules, users } from "@/db/schema";
import { requireTeamAdmin } from "@/app/api/accounts/utils";
import { canManageUsers, isPrimaryAdmin } from "@/lib/auth/admin";
import { hashPassword } from "@/lib/auth/password";
import { ensureBookingUsername } from "@/lib/booking/username";
import { isUniqueConstraintError } from "@/lib/database-errors";
import { newId } from "@/lib/ids";
import { getAccountSeatError } from "@/lib/licenses/seats";
import { getMailboxAccountError } from "@/lib/mailboxes/account-from-mailbox-utils";
import type { MailboxRouteParams } from "../types";
import { selectMailboxById } from "../utils";

const schema = z.object({
	password: z.string().min(8).max(128),
	role: z.enum(["admin", "user"]).default("user"),
});

/** Turns a mailbox the admin owns into its own sign-in account, keeping its mail, folders and rules. */
export async function POST(request: Request, { params }: MailboxRouteParams) {
	const { id } = await params;
	const access = await requireTeamAdmin(request);
	if (access.error) return access.error;
	const { env } = access;
	const actor = access.user!;
	if (!canManageUsers(actor)) {
		return NextResponse.json({ error: "You do not have permission to manage users" }, { status: 403 });
	}
	const parsed = schema.safeParse(await request.json().catch(() => null));
	if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
	if (parsed.data.role === "admin" && !isPrimaryAdmin(actor)) {
		return NextResponse.json({ error: "Only the primary admin can create admin accounts" }, { status: 403 });
	}

	const db = getDb(env);
	const [mailbox] = await selectMailboxById(db, id);
	if (!mailbox) return NextResponse.json({ error: "Mailbox not found" }, { status: 404 });
	const blocker = getMailboxAccountError(mailbox, actor.id);
	if (blocker) return NextResponse.json({ error: blocker }, { status: 400 });
	const seatError = await getAccountSeatError(env);
	if (seatError) return NextResponse.json({ error: seatError }, { status: 403 });

	const email = `${mailbox.localPart}@${mailbox.hostname}`.toLowerCase();
	const userId = newId("usr");
	try {
		// One atomic batch: the account exists only if the mailbox and its data moved to it.
		await db.batch([
			db.insert(users).values({
				id: userId, email, passwordHash: hashPassword(parsed.data.password), name: mailbox.displayName || mailbox.localPart,
				role: parsed.data.role, createdByUserId: actor.id, remoteContentMode: "ask",
			}),
			db.update(mailboxes).set({ userId }).where(eq(mailboxes.id, id)),
			db.update(messages).set({ userId }).where(eq(messages.mailboxId, id)),
			db.update(folders).set({ userId }).where(eq(folders.mailboxId, id)),
			db.update(routingRules).set({ userId }).where(and(eq(routingRules.mailboxId, id), eq(routingRules.scope, "mailbox"))),
			db.update(calendarEvents).set({ userId }).where(eq(calendarEvents.mailboxId, id)),
		]);
	} catch (error) {
		if (isUniqueConstraintError(error)) {
			return NextResponse.json({ error: "An account with this email already exists" }, { status: 409 });
		}
		throw error;
	}
	await ensureBookingUsername(env, userId, email);
	return NextResponse.json({ account: { id: userId, email } }, { status: 201 });
}
