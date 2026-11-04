import assert from "node:assert/strict";
import test from "node:test";
import { isRelayHandle, relayBaseUrl, sendViaRelay } from "../src/lib/push/relay.ts";

test("relay handles are told apart from APNs tokens", () => {
	assert.equal(isRelayHandle("mfr1.abc"), true);
	assert.equal(isRelayHandle("ab".repeat(32)), false);
});

test("the relay URL is an https origin without a trailing slash", () => {
	assert.equal(relayBaseUrl({ APNS_RELAY_URL: "https://ios-relay.mailflare.co" }), "https://ios-relay.mailflare.co");
	assert.equal(relayBaseUrl({ APNS_RELAY_URL: " https://ios-relay.mailflare.co/ " }), "https://ios-relay.mailflare.co");
	assert.equal(relayBaseUrl({ APNS_RELAY_URL: "http://localhost:3100" }), "http://localhost:3100");
	assert.equal(relayBaseUrl({ APNS_RELAY_URL: "http://relay.example.com" }), null);
	assert.equal(relayBaseUrl({ APNS_RELAY_URL: "not a url" }), null);
	assert.equal(relayBaseUrl({}), null);
});

test("a push is one POST to /api/v1/push with the handle", async () => {
	let seen;
	const fetchImpl = async (url, init) => {
		seen = { url, init };
		return new Response("{}", { status: 200 });
	};
	const payload = { aps: { alert: "x" } };
	assert.deepEqual(await sendViaRelay("https://r.example", "mfr1.h", payload, "c1", fetchImpl), { kind: "sent" });
	assert.equal(seen.url, "https://r.example/api/v1/push");
	assert.deepEqual(JSON.parse(seen.init.body), { handle: "mfr1.h", payload, collapseId: "c1" });
});

test("the relay's answers map to what the server should do", async () => {
	const reply = (status, body = {}) => async () => new Response(JSON.stringify(body), { status });
	const send = (fetchImpl) => sendViaRelay("https://r.example", "mfr1.h", {}, undefined, fetchImpl);
	assert.deepEqual(await send(reply(404)), { kind: "gone", status: 404 });
	assert.deepEqual(await send(reply(410)), { kind: "gone", status: 410 });
	assert.deepEqual(await send(reply(429)), { kind: "retry", status: 429 });
	assert.deepEqual(await send(reply(503)), { kind: "retry", status: 503 });
	assert.deepEqual(await send(reply(502, { error: "Apple rejected" })), { kind: "retry", status: 502 });
	assert.deepEqual(await send(reply(400, { error: "bad payload" })), { kind: "failed", status: 400, error: "bad payload" });
	assert.deepEqual(await send(async () => { throw new Error("offline"); }), { kind: "retry", status: 0 });
});
