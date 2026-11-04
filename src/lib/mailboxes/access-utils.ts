import type { AppDatabase } from "@/db";

/** Self-hosted override: Team mailbox sharing is always on (see src/lib/licenses/service.ts). */
export async function isTeamMailboxSharingEnabled(_db: AppDatabase): Promise<boolean> {
	return true;
}
