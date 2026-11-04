import bcrypt from "bcryptjs";
import { customAlphabet } from "nanoid";
import { newId } from "@/lib/ids";

const KEY_PREFIX = "ep_";

export function generateApiKey(): { fullKey: string; prefix: string; hash: string } {
	const secret = newId();
	const fullKey = `${KEY_PREFIX}${secret}`;
	const prefix = fullKey.slice(0, 12);
	const hash = bcrypt.hashSync(fullKey, 10);
	return { fullKey, prefix, hash };
}

const APP_PASSWORD_LENGTH = 16;
const APP_PASSWORD_PREFIX_LENGTH = 6;
const generateAppPasswordSecret = customAlphabet("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", APP_PASSWORD_LENGTH);

/** Stored lookup prefix for a presented key: short app passwords keep fewer plaintext characters. */
export function apiKeyLookupPrefix(key: string): string {
	return key.slice(0, key.length <= APP_PASSWORD_LENGTH ? APP_PASSWORD_PREFIX_LENGTH : 12);
}

/** 16-character password for mail apps. Older, longer `ep_` keys keep working. */
export function generateAppPassword(): { fullKey: string; prefix: string; hash: string } {
	const fullKey = generateAppPasswordSecret();
	return { fullKey, prefix: apiKeyLookupPrefix(fullKey), hash: bcrypt.hashSync(fullKey, 10) };
}

export function verifyApiKey(fullKey: string, hash: string): boolean {
	return bcrypt.compareSync(fullKey, hash);
}

export function parseScopes(scopesJson: string): string[] {
	try {
		const parsed = JSON.parse(scopesJson) as unknown;
		return Array.isArray(parsed) ? parsed.filter((s): s is string => typeof s === "string") : [];
	} catch {
		return [];
	}
}

export function scopesToJson(scopes: string[]): string {
	return JSON.stringify(scopes);
}
