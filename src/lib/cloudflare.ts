import { env } from "cloudflare:workers";
import { getNodeEnv } from "@/lib/runtime";
import { withDatabase } from "@/db/with-database";
import { withStorage } from "@/lib/storage";

export function getEnv(): CloudflareEnv {
	return withDatabase(withStorage(getNodeEnv() ?? (env as CloudflareEnv)));
}

export async function getEnvAsync(): Promise<CloudflareEnv> {
	return getEnv();
}
