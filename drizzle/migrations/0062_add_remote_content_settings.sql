ALTER TABLE `users` ADD `remote_content_mode` text DEFAULT 'allow' NOT NULL;--> statement-breakpoint
ALTER TABLE `contacts` ADD `remote_content_allowed` integer DEFAULT false NOT NULL;
