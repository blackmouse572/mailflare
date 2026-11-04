-- One device can be signed in to several accounts on the same server, so a
-- token belongs to a (token, user) pair instead of moving to whichever account
-- registered last. client_ref is the app's own id for the account, echoed in
-- pushes so a tap opens the right account.
DROP INDEX `push_devices_platform_token_idx`;--> statement-breakpoint
CREATE UNIQUE INDEX `push_devices_platform_token_user_idx` ON `push_devices` (`platform`,`token`,`user_id`);--> statement-breakpoint
ALTER TABLE `push_devices` ADD `client_ref` text;
