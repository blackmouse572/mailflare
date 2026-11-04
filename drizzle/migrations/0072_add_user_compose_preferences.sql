CREATE TABLE `user_compose_preferences` (
	`user_id` text PRIMARY KEY NOT NULL,
	`track_opens_default` integer DEFAULT false NOT NULL,
	`updated_at` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade
);
