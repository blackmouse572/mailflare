import { NextResponse } from "next/server";
import { z } from "zod";
import { getEnv } from "@/lib/cloudflare";
import { authenticateApiRequest, hasScope } from "@/lib/api/key-auth";
import { readJsonBody } from "@/lib/http/request";
import { canDeliverTo, registerPushDevice, unregisterPushDevice } from "@/lib/push/native";
import { isRelayHandle } from "@/lib/push/relay";
import { isValidDevicePublicKey } from "@/lib/push/native-crypto";

const registrationSchema = z.object({
	platform: z.literal("apns"),
	// An APNs token (hex) or a handle issued by a push relay.
	token: z.string().regex(/^(?:[0-9a-fA-F]{32,200}|mfr1\.[A-Za-z0-9_-]{20,1000})$/),
	environment: z.enum(["production", "sandbox"]).default("production"),
	topic: z.string().min(3).max(200),
	publicKey: z.string().max(200).nullable().default(null),
	previews: z.boolean().default(true),
	accountRef: z.string().min(1).max(100).optional(),
});

async function authenticate(env: CloudflareEnv, request: Request) {
	const auth = await authenticateApiRequest(env, request);
	if (!auth) return { auth: null, error: NextResponse.json({ error: "Unauthorized" }, { status: 401 }) } as const;
	if (!hasScope(auth.scopes, "jmap")) return { auth: null, error: NextResponse.json({ error: "This key does not have the jmap scope" }, { status: 403 }) } as const;
	return { auth, error: null } as const;
}

/**
 * The mobile app registers its APNs token here, authenticated with the same
 * device key it uses for JMAP. Revoking the key removes the registration.
 */
export async function PUT(request: Request) {
	const env = getEnv();
	const { auth, error } = await authenticate(env, request);
	if (error) return error;
	const parsed = registrationSchema.safeParse(await readJsonBody(request, 8 * 1024).catch(() => null));
	if (!parsed.success) return NextResponse.json({ error: "Invalid registration" }, { status: 400 });
	if (parsed.data.publicKey && !isValidDevicePublicKey(parsed.data.publicKey)) {
		return NextResponse.json({ error: "publicKey must be a raw uncompressed P-256 point" }, { status: 400 });
	}
	const { accountRef, ...registration } = parsed.data;
	await registerPushDevice(env, auth.userId, auth.keyId, { ...registration, token: isRelayHandle(registration.token) ? registration.token : registration.token.toLowerCase(), clientRef: accountRef ?? null });
	// Registrations are kept without APNs secrets, but nothing is sent; the app shows that instead of "On".
	return NextResponse.json({ ok: true, deliverable: canDeliverTo(env, registration.token) });
}

export async function DELETE(request: Request) {
	const env = getEnv();
	const { auth, error } = await authenticate(env, request);
	if (error) return error;
	await unregisterPushDevice(env, auth.keyId);
	return NextResponse.json({ ok: true });
}
