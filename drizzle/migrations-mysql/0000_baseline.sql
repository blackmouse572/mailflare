CREATE TABLE `agent_chat_messages` (
	`id` varchar(191) NOT NULL,
	`conversation_id` varchar(191) NOT NULL,
	`role` varchar(64) NOT NULL,
	`content` longtext NOT NULL,
	`tool_name` longtext,
	`created_at` bigint NOT NULL,
	CONSTRAINT `agent_chat_messages_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `agent_conversations` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`title` longtext NOT NULL DEFAULT ('New conversation'),
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `agent_conversations_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `agent_draft_metadata` (
	`draft_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`origin` varchar(64) NOT NULL,
	`source_message_id` varchar(191),
	`revision` bigint NOT NULL DEFAULT 1,
	`human_edited_at` bigint,
	`scheduled_at` bigint,
	`created_at` bigint NOT NULL,
	CONSTRAINT `agent_draft_metadata_draft_id` PRIMARY KEY(`draft_id`)
);
--> statement-breakpoint
CREATE TABLE `agent_jobs` (
	`id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`source_message_id` varchar(191) NOT NULL,
	`reviewer_user_id` varchar(191) NOT NULL,
	`status` varchar(64) NOT NULL DEFAULT 'pending',
	`attempts` bigint NOT NULL DEFAULT 0,
	`next_attempt_at` bigint NOT NULL,
	`lease_until` bigint,
	`draft_id` varchar(191),
	`reason` longtext,
	`created_at` bigint NOT NULL,
	CONSTRAINT `agent_jobs_id` PRIMARY KEY(`id`),
	CONSTRAINT `agent_jobs_source_idx` UNIQUE(`mailbox_id`,`source_message_id`)
);
--> statement-breakpoint
CREATE TABLE `agent_send_approvals` (
	`id` varchar(191) NOT NULL,
	`draft_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`request_key_id` varchar(191),
	`revision` bigint NOT NULL,
	`payload_hash` longtext NOT NULL,
	`status` varchar(64) NOT NULL DEFAULT 'pending',
	`claimed_at` bigint,
	`message_id` longtext,
	`expires_at` bigint NOT NULL,
	`created_at` bigint NOT NULL,
	CONSTRAINT `agent_send_approvals_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `ai_usage` (
	`id` varchar(191) NOT NULL,
	`created_at` bigint NOT NULL,
	`provider` longtext NOT NULL,
	`model` longtext NOT NULL,
	`source` longtext NOT NULL,
	`input_tokens` bigint,
	`output_tokens` bigint,
	`cost_usd_micros` bigint,
	CONSTRAINT `ai_usage_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `api_keys` (
	`id` varchar(191) NOT NULL,
	`kind` varchar(64) NOT NULL DEFAULT 'legacy',
	`user_id` varchar(191) NOT NULL,
	`name` longtext NOT NULL,
	`prefix` longtext NOT NULL,
	`key_hash` longtext NOT NULL,
	`scopes` longtext NOT NULL,
	`mailbox_scope_enabled` boolean NOT NULL DEFAULT false,
	`created_at` bigint NOT NULL,
	`last_used_at` bigint,
	CONSTRAINT `api_keys_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `app_settings` (
	`id` varchar(191) NOT NULL,
	`app_name` longtext NOT NULL DEFAULT ('Mailflare'),
	`outbound_attachment_max_mb` bigint NOT NULL DEFAULT 25,
	`drive_storage_limit_bytes` bigint,
	`resend_api_key` longtext,
	`aws_config` longtext,
	`ses_receiving` longtext,
	`resend_webhook_id` longtext,
	`resend_webhook_secret` longtext,
	`icon_key` longtext,
	`agent_enabled` boolean NOT NULL DEFAULT true,
	`agent_provider` varchar(64),
	`agent_preset` varchar(64),
	`agent_base_url` longtext,
	`agent_api_key` longtext,
	`agent_model` longtext,
	`agent_model_rates` longtext,
	`spamhaus_dqs_key` longtext,
	`abusech_auth_key` longtext,
	`spam_domain_age_check` boolean NOT NULL DEFAULT true,
	`spam_brands` longtext,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `app_settings_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `audit_logs` (
	`id` varchar(191) NOT NULL,
	`actor_user_id` varchar(191),
	`target_user_id` varchar(191),
	`mailbox_id` varchar(191),
	`message_id` varchar(191),
	`action` longtext NOT NULL,
	`metadata` longtext,
	`created_at` bigint NOT NULL,
	CONSTRAINT `audit_logs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `auto_reply_deliveries` (
	`id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`recipient` varchar(320) NOT NULL,
	`sent_at` bigint NOT NULL,
	CONSTRAINT `auto_reply_deliveries_id` PRIMARY KEY(`id`),
	CONSTRAINT `auto_reply_deliveries_mailbox_recipient_idx` UNIQUE(`mailbox_id`,`recipient`)
);
--> statement-breakpoint
CREATE TABLE `backup_settings` (
	`id` varchar(191) NOT NULL,
	`enabled` boolean NOT NULL DEFAULT true,
	`schedule_type` varchar(64) NOT NULL DEFAULT 'daily',
	`schedule_value` bigint,
	`retention_enabled` boolean NOT NULL DEFAULT false,
	`retention_days` bigint NOT NULL DEFAULT 30,
	`excluded_table_groups` longtext NOT NULL DEFAULT ('[]'),
	`updated_at` bigint NOT NULL,
	CONSTRAINT `backup_settings_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `backups` (
	`id` varchar(191) NOT NULL,
	`status` varchar(64) NOT NULL DEFAULT 'queued',
	`trigger` varchar(64) NOT NULL,
	`r2_key` longtext,
	`filename` longtext,
	`size` bigint,
	`error` longtext,
	`created_by_user_id` varchar(191),
	`created_at` bigint NOT NULL,
	`started_at` bigint,
	`completed_at` bigint,
	CONSTRAINT `backups_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `booking_events` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`name` longtext NOT NULL,
	`slug` varchar(191) NOT NULL DEFAULT '',
	`description` longtext NOT NULL DEFAULT (''),
	`color` longtext NOT NULL DEFAULT ('#2563eb'),
	`host_ids` longtext NOT NULL DEFAULT ('[]'),
	`duration_minutes` bigint NOT NULL,
	`location` longtext NOT NULL DEFAULT (''),
	`weekdays` longtext NOT NULL DEFAULT ('[1,2,3,4,5]'),
	`start_time` longtext NOT NULL DEFAULT ('09:00'),
	`end_time` longtext NOT NULL DEFAULT ('17:00'),
	`time_ranges` longtext NOT NULL DEFAULT ('[{"startTime":"09:00","endTime":"17:00"}]'),
	`time_zone` longtext NOT NULL DEFAULT ('UTC'),
	`enabled` boolean NOT NULL DEFAULT true,
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `booking_events_id` PRIMARY KEY(`id`),
	CONSTRAINT `booking_events_user_slug_idx` UNIQUE(`user_id`,`slug`)
);
--> statement-breakpoint
CREATE TABLE `calendar_events` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191),
	`title` longtext NOT NULL,
	`description` longtext NOT NULL DEFAULT (''),
	`location` longtext NOT NULL DEFAULT (''),
	`attendees` longtext NOT NULL DEFAULT ('[]'),
	`color` longtext NOT NULL DEFAULT ('blue'),
	`repeat` varchar(64) NOT NULL DEFAULT 'none',
	`repeat_days` longtext NOT NULL DEFAULT ('[]'),
	`repeat_anchor_day` bigint,
	`repeat_until` bigint,
	`excluded_occurrences` longtext NOT NULL DEFAULT ('[]'),
	`time_zone` longtext,
	`starts_at` bigint NOT NULL,
	`ends_at` bigint NOT NULL,
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `calendar_events_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `contacts` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`email` varchar(320) NOT NULL,
	`display_name` longtext,
	`avatar_key` longtext,
	`source` varchar(64) NOT NULL DEFAULT 'inbound',
	`blocked` boolean NOT NULL DEFAULT false,
	`remote_content_allowed` boolean NOT NULL DEFAULT false,
	`last_seen_at` bigint,
	`created_at` bigint NOT NULL,
	CONSTRAINT `contacts_id` PRIMARY KEY(`id`),
	CONSTRAINT `contacts_user_email_idx` UNIQUE(`user_id`,`email`)
);
--> statement-breakpoint
CREATE TABLE `domain_tracking_hosts` (
	`domain_id` varchar(191) NOT NULL,
	`hostname` varchar(255) NOT NULL,
	`created_at` bigint NOT NULL,
	CONSTRAINT `domain_tracking_hosts_domain_id` PRIMARY KEY(`domain_id`),
	CONSTRAINT `domain_tracking_hosts_hostname_idx` UNIQUE(`hostname`)
);
--> statement-breakpoint
CREATE TABLE `domains` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`hostname` varchar(255) NOT NULL,
	`zone_id` longtext NOT NULL,
	`status` varchar(64) NOT NULL DEFAULT 'pending',
	`routing_status` longtext,
	`sending_subdomain_tag` longtext,
	`sending_provider` varchar(64) NOT NULL DEFAULT 'none',
	`receiving_provider` varchar(64) NOT NULL DEFAULT 'cloudflare',
	`sending_requested` boolean NOT NULL DEFAULT false,
	`sending_enabled` boolean NOT NULL DEFAULT false,
	`routing_enabled` boolean NOT NULL DEFAULT false,
	`dns_skipped` boolean NOT NULL DEFAULT false,
	`created_at` bigint NOT NULL,
	CONSTRAINT `domains_id` PRIMARY KEY(`id`),
	CONSTRAINT `domains_hostname_idx` UNIQUE(`hostname`)
);
--> statement-breakpoint
CREATE TABLE `drive_items` (
	`id` varchar(191) NOT NULL,
	`owner_id` varchar(191) NOT NULL,
	`parent_id` varchar(191),
	`kind` varchar(64) NOT NULL,
	`name` longtext NOT NULL,
	`r2_key` longtext,
	`size` bigint NOT NULL DEFAULT 0,
	`content_type` longtext NOT NULL DEFAULT ('application/octet-stream'),
	`upload_id` longtext,
	`upload_part_size` bigint,
	`upload_fingerprint` longtext,
	`link_token` varchar(191),
	`trashed_at` bigint,
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `drive_items_id` PRIMARY KEY(`id`),
	CONSTRAINT `drive_items_link_token_idx` UNIQUE(`link_token`)
);
--> statement-breakpoint
CREATE TABLE `drive_shares` (
	`id` varchar(191) NOT NULL,
	`item_id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`role` varchar(64) NOT NULL DEFAULT 'view',
	`created_at` bigint NOT NULL,
	CONSTRAINT `drive_shares_id` PRIMARY KEY(`id`),
	CONSTRAINT `drive_shares_item_user_idx` UNIQUE(`item_id`,`user_id`)
);
--> statement-breakpoint
CREATE TABLE `drive_upload_parts` (
	`item_id` varchar(191) NOT NULL,
	`part_number` bigint NOT NULL,
	`etag` longtext NOT NULL,
	CONSTRAINT `drive_upload_parts_idx` UNIQUE(`item_id`,`part_number`)
);
--> statement-breakpoint
CREATE TABLE `email_templates` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`name` longtext NOT NULL,
	`subject` longtext NOT NULL DEFAULT (''),
	`text_body` longtext NOT NULL DEFAULT (''),
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `email_templates_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `folders` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`name` varchar(255) NOT NULL,
	`color` longtext NOT NULL DEFAULT ('#2563eb'),
	`created_at` bigint NOT NULL,
	CONSTRAINT `folders_id` PRIMARY KEY(`id`),
	CONSTRAINT `folders_mailbox_name_idx` UNIQUE(`mailbox_id`,`name`)
);
--> statement-breakpoint
CREATE TABLE `follow_ups` (
	`id` varchar(191) NOT NULL,
	`message_id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`due_at` bigint NOT NULL,
	`status` varchar(64) NOT NULL DEFAULT 'pending',
	`created_at` bigint NOT NULL,
	CONSTRAINT `follow_ups_id` PRIMARY KEY(`id`),
	CONSTRAINT `follow_ups_message_idx` UNIQUE(`message_id`)
);
--> statement-breakpoint
CREATE TABLE `import_jobs` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`kind` varchar(64) NOT NULL,
	`label` longtext NOT NULL,
	`status` varchar(64) NOT NULL DEFAULT 'queued',
	`total` bigint NOT NULL DEFAULT 0,
	`processed` bigint NOT NULL DEFAULT 0,
	`imported` bigint NOT NULL DEFAULT 0,
	`skipped` bigint NOT NULL DEFAULT 0,
	`spec` longtext NOT NULL,
	`cursor` longtext NOT NULL DEFAULT ('{}'),
	`errors` longtext NOT NULL DEFAULT ('[]'),
	`error_count` bigint NOT NULL DEFAULT 0,
	`error` longtext,
	`created_at` bigint NOT NULL,
	`started_at` bigint,
	`updated_at` bigint NOT NULL,
	`finished_at` bigint,
	CONSTRAINT `import_jobs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `jmap_change_floor` (
	`id` bigint NOT NULL,
	`seq` bigint NOT NULL DEFAULT 0,
	CONSTRAINT `jmap_change_floor_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `jmap_changes` (
	`seq` bigint AUTO_INCREMENT NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`object_type` varchar(64) NOT NULL,
	`object_id` longtext NOT NULL,
	`thread_id` longtext,
	`change` varchar(64) NOT NULL,
	`created_at` bigint NOT NULL DEFAULT (unix_timestamp()),
	CONSTRAINT `jmap_changes_seq` PRIMARY KEY(`seq`)
);
--> statement-breakpoint
CREATE TABLE `jmap_mailbox_revisions` (
	`mailbox_id` varchar(191) NOT NULL,
	`revision` bigint NOT NULL DEFAULT 0,
	CONSTRAINT `jmap_mailbox_revisions_mailbox_id` PRIMARY KEY(`mailbox_id`)
);
--> statement-breakpoint
CREATE TABLE `license_settings` (
	`id` varchar(191) NOT NULL,
	`instance_id` varchar(191) NOT NULL,
	`instance_url` longtext,
	`license_key_hash` longtext,
	`plan` varchar(64) NOT NULL DEFAULT 'community',
	`state` varchar(64) NOT NULL DEFAULT 'inactive',
	`features` longtext NOT NULL DEFAULT ('[]'),
	`seat_limit` bigint DEFAULT 1,
	`activated_at` bigint,
	`validated_at` bigint,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `license_settings_id` PRIMARY KEY(`id`),
	CONSTRAINT `license_settings_instance_id_unique` UNIQUE(`instance_id`)
);
--> statement-breakpoint
CREATE TABLE `login_challenges` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`token_hash` varchar(191) NOT NULL,
	`expires_at` bigint NOT NULL,
	`created_at` bigint NOT NULL,
	CONSTRAINT `login_challenges_id` PRIMARY KEY(`id`),
	CONSTRAINT `login_challenges_token_hash_unique` UNIQUE(`token_hash`)
);
--> statement-breakpoint
CREATE TABLE `mailbox_access` (
	`id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`permission` varchar(64) NOT NULL DEFAULT 'read_only',
	`created_by_user_id` varchar(191),
	`created_at` bigint NOT NULL,
	CONSTRAINT `mailbox_access_id` PRIMARY KEY(`id`),
	CONSTRAINT `mailbox_access_mailbox_user_idx` UNIQUE(`mailbox_id`,`user_id`)
);
--> statement-breakpoint
CREATE TABLE `mailbox_agent_settings` (
	`mailbox_id` varchar(191) NOT NULL,
	`enabled` boolean NOT NULL DEFAULT false,
	`model_id` longtext,
	`auto_draft_enabled` boolean NOT NULL DEFAULT false,
	`reviewer_user_id` varchar(191),
	`instructions` longtext NOT NULL DEFAULT (''),
	`daily_limit` bigint NOT NULL DEFAULT 25,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `mailbox_agent_settings_mailbox_id` PRIMARY KEY(`mailbox_id`)
);
--> statement-breakpoint
CREATE TABLE `mailbox_aliases` (
	`id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`domain_id` varchar(191) NOT NULL,
	`local_part` varchar(191) NOT NULL,
	`created_at` bigint NOT NULL,
	CONSTRAINT `mailbox_aliases_id` PRIMARY KEY(`id`),
	CONSTRAINT `mailbox_aliases_address_idx` UNIQUE(`domain_id`,`local_part`)
);
--> statement-breakpoint
CREATE TABLE `mailboxes` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`domain_id` varchar(191) NOT NULL,
	`local_part` varchar(191) NOT NULL,
	`display_name` longtext,
	`signature` longtext,
	`auto_reply_enabled` boolean NOT NULL DEFAULT false,
	`auto_reply_subject` longtext NOT NULL DEFAULT ('Out of office'),
	`auto_reply_body` longtext NOT NULL DEFAULT (''),
	`avatar_key` longtext,
	`type` varchar(64) NOT NULL DEFAULT 'personal',
	`use_all_domains` boolean NOT NULL DEFAULT true,
	`disabled` boolean NOT NULL DEFAULT false,
	`created_at` bigint NOT NULL,
	CONSTRAINT `mailboxes_id` PRIMARY KEY(`id`),
	CONSTRAINT `mailboxes_address_idx` UNIQUE(`domain_id`,`local_part`)
);
--> statement-breakpoint
CREATE TABLE `mcp_key_mailboxes` (
	`key_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	CONSTRAINT `mcp_key_mailbox_idx` UNIQUE(`key_id`,`mailbox_id`)
);
--> statement-breakpoint
CREATE TABLE `message_attachments` (
	`id` varchar(191) NOT NULL,
	`message_id` varchar(191) NOT NULL,
	`filename` longtext NOT NULL,
	`content_type` longtext NOT NULL,
	`size` bigint NOT NULL,
	`disposition` varchar(64) NOT NULL DEFAULT 'attachment',
	`content_id` longtext,
	`r2_key` varchar(512) NOT NULL,
	`trashed_at` bigint,
	`created_at` bigint NOT NULL,
	CONSTRAINT `message_attachments_id` PRIMARY KEY(`id`),
	CONSTRAINT `message_attachments_r2_key_unique` UNIQUE(`r2_key`)
);
--> statement-breakpoint
CREATE TABLE `message_opens` (
	`id` varchar(191) NOT NULL,
	`token` varchar(191) NOT NULL,
	`opened_at` bigint NOT NULL,
	`client` longtext,
	`device` longtext,
	`country` longtext,
	`city` longtext,
	`automated` boolean NOT NULL DEFAULT false,
	CONSTRAINT `message_opens_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `message_tracking` (
	`token` varchar(191) NOT NULL,
	`message_id` varchar(191) NOT NULL,
	`open_count` bigint NOT NULL DEFAULT 0,
	`first_opened_at` bigint,
	`last_opened_at` bigint,
	`created_at` bigint NOT NULL,
	CONSTRAINT `message_tracking_token` PRIMARY KEY(`token`),
	CONSTRAINT `message_tracking_message_idx` UNIQUE(`message_id`)
);
--> statement-breakpoint
CREATE TABLE `messages` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191),
	`direction` varchar(64) NOT NULL,
	`provider_message_id` varchar(512),
	`folder_id` varchar(191),
	`from_addr` longtext NOT NULL,
	`to_addr` longtext NOT NULL,
	`cc_addr` longtext,
	`bcc_addr` longtext,
	`reply_to` longtext,
	`subject` longtext,
	`snippet` longtext,
	`text_body` longtext,
	`html_body` longtext,
	`raw_r2_key` varchar(512),
	`status` varchar(191) NOT NULL DEFAULT 'received',
	`read` boolean NOT NULL DEFAULT false,
	`starred` boolean NOT NULL DEFAULT false,
	`snoozed_until` bigint,
	`thread_id` varchar(512),
	`in_reply_to` longtext,
	`references_header` longtext,
	`spam_score` bigint,
	`spam_verdict` varchar(64),
	`spam_signals` longtext,
	`spam_analyzed_at` bigint,
	`spam_analysis_error` longtext,
	`trashed_at` bigint,
	`created_at` bigint NOT NULL,
	CONSTRAINT `messages_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `mfa_recovery_codes` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`code_hash` varchar(191) NOT NULL,
	`used_at` bigint,
	`created_at` bigint NOT NULL,
	CONSTRAINT `mfa_recovery_codes_id` PRIMARY KEY(`id`),
	CONSTRAINT `mfa_recovery_codes_code_hash_unique` UNIQUE(`code_hash`)
);
--> statement-breakpoint
CREATE TABLE `outbound_jobs` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`message_id` varchar(191),
	`status` varchar(64) NOT NULL DEFAULT 'queued',
	`payload` longtext NOT NULL,
	`error` longtext,
	`scheduled_at` bigint,
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `outbound_jobs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `password_reset_tokens` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`token_hash` varchar(191) NOT NULL,
	`expires_at` bigint NOT NULL,
	`used_at` bigint,
	`created_at` bigint NOT NULL,
	CONSTRAINT `password_reset_tokens_id` PRIMARY KEY(`id`),
	CONSTRAINT `password_reset_tokens_token_hash_unique` UNIQUE(`token_hash`)
);
--> statement-breakpoint
CREATE TABLE `push_devices` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`api_key_id` varchar(191) NOT NULL,
	`platform` varchar(64) NOT NULL,
	`token` varchar(191) NOT NULL,
	`environment` varchar(64) NOT NULL DEFAULT 'production',
	`topic` longtext NOT NULL,
	`public_key` longtext,
	`previews` boolean NOT NULL DEFAULT true,
	`client_ref` longtext,
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `push_devices_id` PRIMARY KEY(`id`),
	CONSTRAINT `push_devices_platform_token_user_idx` UNIQUE(`platform`,`token`,`user_id`)
);
--> statement-breakpoint
CREATE TABLE `push_subscriptions` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`session_id` varchar(191) NOT NULL,
	`endpoint` varchar(512) NOT NULL,
	`p256dh` longtext NOT NULL,
	`auth` longtext NOT NULL,
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `push_subscriptions_id` PRIMARY KEY(`id`),
	CONSTRAINT `push_subscriptions_endpoint_idx` UNIQUE(`endpoint`)
);
--> statement-breakpoint
CREATE TABLE `routing_rules` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`domain_id` varchar(191) NOT NULL,
	`scope` varchar(64) NOT NULL DEFAULT 'mailbox',
	`name` longtext,
	`enabled` boolean NOT NULL DEFAULT true,
	`pattern` longtext NOT NULL,
	`match_field` varchar(64) NOT NULL DEFAULT 'email',
	`match_operator` varchar(64) NOT NULL DEFAULT 'contains',
	`match_value` longtext NOT NULL DEFAULT (''),
	`mailbox_id` varchar(191),
	`folder_id` varchar(191),
	`action` varchar(64) NOT NULL DEFAULT 'store',
	`forward_to` longtext,
	`keep_copy` boolean NOT NULL DEFAULT false,
	`reject_reason` longtext,
	`priority` bigint NOT NULL DEFAULT 0,
	`last_matched_at` bigint,
	`match_count` bigint NOT NULL DEFAULT 0,
	`created_at` bigint NOT NULL,
	CONSTRAINT `routing_rules_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `sessions` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`token_hash` varchar(191) NOT NULL,
	`expires_at` bigint NOT NULL,
	`created_at` bigint NOT NULL,
	CONSTRAINT `sessions_id` PRIMARY KEY(`id`),
	CONSTRAINT `sessions_token_hash_unique` UNIQUE(`token_hash`)
);
--> statement-breakpoint
CREATE TABLE `shared_attachment_links` (
	`id` varchar(191) NOT NULL,
	`attachment_id` varchar(191) NOT NULL,
	`expires_at` bigint NOT NULL,
	`created_at` bigint NOT NULL,
	CONSTRAINT `shared_attachment_links_id` PRIMARY KEY(`id`),
	CONSTRAINT `shared_attachment_links_attachment_id_unique` UNIQUE(`attachment_id`)
);
--> statement-breakpoint
CREATE TABLE `spam_feedback` (
	`message_id` varchar(191) NOT NULL,
	`mailbox_id` varchar(191) NOT NULL,
	`actor_user_id` varchar(191),
	`classification` varchar(64) NOT NULL,
	`training_tokens` longtext NOT NULL,
	`reputation_keys` longtext NOT NULL,
	`tokenizer_version` bigint NOT NULL DEFAULT 1,
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `spam_feedback_message_id` PRIMARY KEY(`message_id`)
);
--> statement-breakpoint
CREATE TABLE `spam_reputation` (
	`mailbox_id` varchar(191) NOT NULL,
	`type` varchar(64) NOT NULL,
	`key` varchar(191) NOT NULL,
	`messages_seen` bigint NOT NULL DEFAULT 0,
	`spam_count` bigint NOT NULL DEFAULT 0,
	`ham_count` bigint NOT NULL DEFAULT 0,
	`first_seen_at` bigint NOT NULL,
	`last_seen_at` bigint NOT NULL,
	CONSTRAINT `spam_reputation_mailbox_type_key_idx` UNIQUE(`mailbox_id`,`type`,`key`)
);
--> statement-breakpoint
CREATE TABLE `spam_token_stats` (
	`mailbox_id` varchar(191) NOT NULL,
	`token` varchar(191) NOT NULL,
	`spam_count` bigint NOT NULL DEFAULT 0,
	`ham_count` bigint NOT NULL DEFAULT 0,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `spam_token_stats_mailbox_token_idx` UNIQUE(`mailbox_id`,`token`)
);
--> statement-breakpoint
CREATE TABLE `user_compose_preferences` (
	`user_id` varchar(191) NOT NULL,
	`track_opens_default` boolean NOT NULL DEFAULT false,
	`undo_send_seconds` bigint NOT NULL DEFAULT 15,
	`updated_at` bigint NOT NULL,
	CONSTRAINT `user_compose_preferences_user_id` PRIMARY KEY(`user_id`)
);
--> statement-breakpoint
CREATE TABLE `users` (
	`id` varchar(191) NOT NULL,
	`email` varchar(320) NOT NULL,
	`reset_email` longtext,
	`forwarding_email` longtext,
	`password_hash` longtext NOT NULL,
	`name` longtext NOT NULL,
	`booking_username` varchar(191),
	`time_zone` longtext,
	`avatar_key` longtext,
	`role` varchar(64) NOT NULL DEFAULT 'user',
	`is_primary_admin` boolean NOT NULL DEFAULT false,
	`disabled` boolean NOT NULL DEFAULT false,
	`can_manage_mailboxes` boolean NOT NULL DEFAULT false,
	`can_manage_domains` boolean NOT NULL DEFAULT false,
	`can_manage_users` boolean NOT NULL DEFAULT false,
	`keyboard_shortcuts_enabled` boolean NOT NULL DEFAULT true,
	`spam_protection_enabled` boolean NOT NULL DEFAULT true,
	`trash_retention_days` bigint,
	`show_full_recipient_addresses` boolean NOT NULL DEFAULT false,
	`remote_content_mode` varchar(64) NOT NULL DEFAULT 'allow',
	`totp_secret` longtext,
	`totp_enabled` boolean NOT NULL DEFAULT false,
	`totp_confirmed_at` bigint,
	`last_sign_in_at` bigint,
	`deleted_at` bigint,
	`created_by_user_id` varchar(191),
	`created_at` bigint NOT NULL,
	CONSTRAINT `users_id` PRIMARY KEY(`id`),
	CONSTRAINT `users_email_unique` UNIQUE(`email`),
	CONSTRAINT `users_booking_username_idx` UNIQUE(`booking_username`)
);
--> statement-breakpoint
CREATE TABLE `webhook_deliveries` (
	`id` varchar(191) NOT NULL,
	`webhook_id` varchar(191) NOT NULL,
	`event_type` longtext NOT NULL,
	`payload` longtext NOT NULL,
	`status` varchar(191) NOT NULL DEFAULT 'pending',
	`attempts` bigint NOT NULL DEFAULT 0,
	`response_status` bigint,
	`error` longtext,
	`duration_ms` bigint,
	`last_attempt_at` bigint,
	`next_retry_at` bigint,
	`created_at` bigint NOT NULL,
	CONSTRAINT `webhook_deliveries_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `webhooks` (
	`id` varchar(191) NOT NULL,
	`user_id` varchar(191) NOT NULL,
	`description` longtext,
	`url` longtext NOT NULL,
	`secret` longtext NOT NULL,
	`events` longtext NOT NULL,
	`enabled` boolean NOT NULL DEFAULT true,
	`max_attempts` bigint NOT NULL DEFAULT 5,
	`created_at` bigint NOT NULL,
	CONSTRAINT `webhooks_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `agent_chat_messages` ADD CONSTRAINT `agent_chat_messages_conversation_id_agent_conversations_id_fk` FOREIGN KEY (`conversation_id`) REFERENCES `agent_conversations`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_conversations` ADD CONSTRAINT `agent_conversations_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_conversations` ADD CONSTRAINT `agent_conversations_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_draft_metadata` ADD CONSTRAINT `agent_draft_metadata_draft_id_messages_id_fk` FOREIGN KEY (`draft_id`) REFERENCES `messages`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_draft_metadata` ADD CONSTRAINT `agent_draft_metadata_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_draft_metadata` ADD CONSTRAINT `agent_draft_metadata_source_message_id_messages_id_fk` FOREIGN KEY (`source_message_id`) REFERENCES `messages`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_jobs` ADD CONSTRAINT `agent_jobs_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_jobs` ADD CONSTRAINT `agent_jobs_source_message_id_messages_id_fk` FOREIGN KEY (`source_message_id`) REFERENCES `messages`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_jobs` ADD CONSTRAINT `agent_jobs_reviewer_user_id_users_id_fk` FOREIGN KEY (`reviewer_user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_jobs` ADD CONSTRAINT `agent_jobs_draft_id_messages_id_fk` FOREIGN KEY (`draft_id`) REFERENCES `messages`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_send_approvals` ADD CONSTRAINT `agent_send_approvals_draft_id_messages_id_fk` FOREIGN KEY (`draft_id`) REFERENCES `messages`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_send_approvals` ADD CONSTRAINT `agent_send_approvals_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_send_approvals` ADD CONSTRAINT `agent_send_approvals_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `agent_send_approvals` ADD CONSTRAINT `agent_send_approvals_request_key_id_api_keys_id_fk` FOREIGN KEY (`request_key_id`) REFERENCES `api_keys`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `api_keys` ADD CONSTRAINT `api_keys_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `audit_logs` ADD CONSTRAINT `audit_logs_actor_user_id_users_id_fk` FOREIGN KEY (`actor_user_id`) REFERENCES `users`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `audit_logs` ADD CONSTRAINT `audit_logs_target_user_id_users_id_fk` FOREIGN KEY (`target_user_id`) REFERENCES `users`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `audit_logs` ADD CONSTRAINT `audit_logs_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `audit_logs` ADD CONSTRAINT `audit_logs_message_id_messages_id_fk` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `auto_reply_deliveries` ADD CONSTRAINT `auto_reply_deliveries_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `backups` ADD CONSTRAINT `backups_created_by_user_id_users_id_fk` FOREIGN KEY (`created_by_user_id`) REFERENCES `users`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `booking_events` ADD CONSTRAINT `booking_events_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `calendar_events` ADD CONSTRAINT `calendar_events_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `calendar_events` ADD CONSTRAINT `calendar_events_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `contacts` ADD CONSTRAINT `contacts_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `domain_tracking_hosts` ADD CONSTRAINT `domain_tracking_hosts_domain_id_domains_id_fk` FOREIGN KEY (`domain_id`) REFERENCES `domains`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `domains` ADD CONSTRAINT `domains_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `drive_items` ADD CONSTRAINT `drive_items_owner_id_users_id_fk` FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `drive_shares` ADD CONSTRAINT `drive_shares_item_id_drive_items_id_fk` FOREIGN KEY (`item_id`) REFERENCES `drive_items`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `drive_shares` ADD CONSTRAINT `drive_shares_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `drive_upload_parts` ADD CONSTRAINT `drive_upload_parts_item_id_drive_items_id_fk` FOREIGN KEY (`item_id`) REFERENCES `drive_items`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `email_templates` ADD CONSTRAINT `email_templates_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `folders` ADD CONSTRAINT `folders_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `folders` ADD CONSTRAINT `folders_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `follow_ups` ADD CONSTRAINT `follow_ups_message_id_messages_id_fk` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `follow_ups` ADD CONSTRAINT `follow_ups_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `import_jobs` ADD CONSTRAINT `import_jobs_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `import_jobs` ADD CONSTRAINT `import_jobs_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `login_challenges` ADD CONSTRAINT `login_challenges_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailbox_access` ADD CONSTRAINT `mailbox_access_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailbox_access` ADD CONSTRAINT `mailbox_access_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailbox_access` ADD CONSTRAINT `mailbox_access_created_by_user_id_users_id_fk` FOREIGN KEY (`created_by_user_id`) REFERENCES `users`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailbox_agent_settings` ADD CONSTRAINT `mailbox_agent_settings_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailbox_agent_settings` ADD CONSTRAINT `mailbox_agent_settings_reviewer_user_id_users_id_fk` FOREIGN KEY (`reviewer_user_id`) REFERENCES `users`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailbox_aliases` ADD CONSTRAINT `mailbox_aliases_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailbox_aliases` ADD CONSTRAINT `mailbox_aliases_domain_id_domains_id_fk` FOREIGN KEY (`domain_id`) REFERENCES `domains`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailboxes` ADD CONSTRAINT `mailboxes_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mailboxes` ADD CONSTRAINT `mailboxes_domain_id_domains_id_fk` FOREIGN KEY (`domain_id`) REFERENCES `domains`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mcp_key_mailboxes` ADD CONSTRAINT `mcp_key_mailboxes_key_id_api_keys_id_fk` FOREIGN KEY (`key_id`) REFERENCES `api_keys`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mcp_key_mailboxes` ADD CONSTRAINT `mcp_key_mailboxes_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `message_attachments` ADD CONSTRAINT `message_attachments_message_id_messages_id_fk` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `message_opens` ADD CONSTRAINT `message_opens_token_message_tracking_token_fk` FOREIGN KEY (`token`) REFERENCES `message_tracking`(`token`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `message_tracking` ADD CONSTRAINT `message_tracking_message_id_messages_id_fk` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `messages` ADD CONSTRAINT `messages_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `messages` ADD CONSTRAINT `messages_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `messages` ADD CONSTRAINT `messages_folder_id_folders_id_fk` FOREIGN KEY (`folder_id`) REFERENCES `folders`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `mfa_recovery_codes` ADD CONSTRAINT `mfa_recovery_codes_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `outbound_jobs` ADD CONSTRAINT `outbound_jobs_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `outbound_jobs` ADD CONSTRAINT `outbound_jobs_message_id_messages_id_fk` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `password_reset_tokens` ADD CONSTRAINT `password_reset_tokens_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `push_devices` ADD CONSTRAINT `push_devices_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `push_devices` ADD CONSTRAINT `push_devices_api_key_id_api_keys_id_fk` FOREIGN KEY (`api_key_id`) REFERENCES `api_keys`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `push_subscriptions` ADD CONSTRAINT `push_subscriptions_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `push_subscriptions` ADD CONSTRAINT `push_subscriptions_session_id_sessions_id_fk` FOREIGN KEY (`session_id`) REFERENCES `sessions`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `routing_rules` ADD CONSTRAINT `routing_rules_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `routing_rules` ADD CONSTRAINT `routing_rules_domain_id_domains_id_fk` FOREIGN KEY (`domain_id`) REFERENCES `domains`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `routing_rules` ADD CONSTRAINT `routing_rules_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `routing_rules` ADD CONSTRAINT `routing_rules_folder_id_folders_id_fk` FOREIGN KEY (`folder_id`) REFERENCES `folders`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `sessions` ADD CONSTRAINT `sessions_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `shared_attachment_links` ADD CONSTRAINT `shared_attachment_links_attachment_id_message_attachments_id_fk` FOREIGN KEY (`attachment_id`) REFERENCES `message_attachments`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `spam_feedback` ADD CONSTRAINT `spam_feedback_message_id_messages_id_fk` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `spam_feedback` ADD CONSTRAINT `spam_feedback_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `spam_feedback` ADD CONSTRAINT `spam_feedback_actor_user_id_users_id_fk` FOREIGN KEY (`actor_user_id`) REFERENCES `users`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `spam_reputation` ADD CONSTRAINT `spam_reputation_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `spam_token_stats` ADD CONSTRAINT `spam_token_stats_mailbox_id_mailboxes_id_fk` FOREIGN KEY (`mailbox_id`) REFERENCES `mailboxes`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_compose_preferences` ADD CONSTRAINT `user_compose_preferences_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `users` ADD CONSTRAINT `users_created_by_user_id_users_id_fk` FOREIGN KEY (`created_by_user_id`) REFERENCES `users`(`id`) ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `webhook_deliveries` ADD CONSTRAINT `webhook_deliveries_webhook_id_webhooks_id_fk` FOREIGN KEY (`webhook_id`) REFERENCES `webhooks`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `webhooks` ADD CONSTRAINT `webhooks_user_id_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `agent_chat_messages_conversation_idx` ON `agent_chat_messages` (`conversation_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `agent_conversations_owner_idx` ON `agent_conversations` (`user_id`,`mailbox_id`,`updated_at`);--> statement-breakpoint
CREATE INDEX `agent_conversations_mailbox_idx` ON `agent_conversations` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `agent_draft_meta_source_msg_idx` ON `agent_draft_metadata` (`source_message_id`);--> statement-breakpoint
CREATE INDEX `agent_draft_metadata_mailbox_idx` ON `agent_draft_metadata` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `agent_jobs_due_idx` ON `agent_jobs` (`status`,`next_attempt_at`);--> statement-breakpoint
CREATE INDEX `agent_jobs_source_message_idx` ON `agent_jobs` (`source_message_id`);--> statement-breakpoint
CREATE INDEX `agent_jobs_draft_idx` ON `agent_jobs` (`draft_id`);--> statement-breakpoint
CREATE INDEX `agent_jobs_reviewer_idx` ON `agent_jobs` (`reviewer_user_id`);--> statement-breakpoint
CREATE INDEX `agent_send_approvals_user_idx` ON `agent_send_approvals` (`user_id`,`status`);--> statement-breakpoint
CREATE INDEX `agent_send_approvals_delivery_idx` ON `agent_send_approvals` (`draft_id`);--> statement-breakpoint
CREATE INDEX `agent_send_approvals_request_key_idx` ON `agent_send_approvals` (`request_key_id`);--> statement-breakpoint
CREATE INDEX `agent_send_approvals_mailbox_idx` ON `agent_send_approvals` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `agent_send_approvals_draft_idx` ON `agent_send_approvals` (`draft_id`);--> statement-breakpoint
CREATE INDEX `ai_usage_created_idx` ON `ai_usage` (`created_at`);--> statement-breakpoint
CREATE INDEX `api_keys_user_idx` ON `api_keys` (`user_id`);--> statement-breakpoint
CREATE INDEX `audit_logs_actor_idx` ON `audit_logs` (`actor_user_id`);--> statement-breakpoint
CREATE INDEX `audit_logs_mailbox_idx` ON `audit_logs` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `audit_logs_created_idx` ON `audit_logs` (`created_at`);--> statement-breakpoint
CREATE INDEX `audit_logs_message_id_idx` ON `audit_logs` (`message_id`);--> statement-breakpoint
CREATE INDEX `audit_logs_target_user_idx` ON `audit_logs` (`target_user_id`);--> statement-breakpoint
CREATE INDEX `auto_reply_deliveries_sent_idx` ON `auto_reply_deliveries` (`sent_at`);--> statement-breakpoint
CREATE INDEX `backups_created_idx` ON `backups` (`created_at`);--> statement-breakpoint
CREATE INDEX `backups_status_idx` ON `backups` (`status`);--> statement-breakpoint
CREATE INDEX `backups_created_by_idx` ON `backups` (`created_by_user_id`);--> statement-breakpoint
CREATE INDEX `booking_events_user_idx` ON `booking_events` (`user_id`);--> statement-breakpoint
CREATE INDEX `calendar_events_user_starts_idx` ON `calendar_events` (`user_id`,`starts_at`);--> statement-breakpoint
CREATE INDEX `calendar_events_mailbox_idx` ON `calendar_events` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `contacts_user_idx` ON `contacts` (`user_id`);--> statement-breakpoint
CREATE INDEX `domains_user_idx` ON `domains` (`user_id`);--> statement-breakpoint
CREATE INDEX `drive_items_owner_parent_idx` ON `drive_items` (`owner_id`,`parent_id`);--> statement-breakpoint
CREATE INDEX `drive_shares_user_idx` ON `drive_shares` (`user_id`);--> statement-breakpoint
CREATE INDEX `email_templates_user_idx` ON `email_templates` (`user_id`);--> statement-breakpoint
CREATE INDEX `folders_user_idx` ON `folders` (`user_id`);--> statement-breakpoint
CREATE INDEX `folders_mailbox_idx` ON `folders` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `follow_ups_status_due_idx` ON `follow_ups` (`status`,`due_at`);--> statement-breakpoint
CREATE INDEX `follow_ups_user_status_idx` ON `follow_ups` (`user_id`,`status`);--> statement-breakpoint
CREATE INDEX `import_jobs_user_idx` ON `import_jobs` (`user_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `import_jobs_status_idx` ON `import_jobs` (`status`,`updated_at`);--> statement-breakpoint
CREATE INDEX `jmap_changes_mailbox_seq_idx` ON `jmap_changes` (`mailbox_id`,`seq`);--> statement-breakpoint
CREATE INDEX `login_challenges_user_idx` ON `login_challenges` (`user_id`);--> statement-breakpoint
CREATE INDEX `mailbox_access_user_idx` ON `mailbox_access` (`user_id`);--> statement-breakpoint
CREATE INDEX `mailbox_access_mailbox_idx` ON `mailbox_access` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `mailbox_access_created_by_idx` ON `mailbox_access` (`created_by_user_id`);--> statement-breakpoint
CREATE INDEX `mailbox_agent_settings_reviewer_idx` ON `mailbox_agent_settings` (`reviewer_user_id`);--> statement-breakpoint
CREATE INDEX `mailbox_aliases_mailbox_idx` ON `mailbox_aliases` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `mailboxes_user_idx` ON `mailboxes` (`user_id`);--> statement-breakpoint
CREATE INDEX `mcp_key_mailboxes_mailbox_idx` ON `mcp_key_mailboxes` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `message_attachments_message_idx` ON `message_attachments` (`message_id`);--> statement-breakpoint
CREATE INDEX `message_opens_token_idx` ON `message_opens` (`token`,`opened_at`);--> statement-breakpoint
CREATE INDEX `messages_user_created_idx` ON `messages` (`user_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `messages_mailbox_idx` ON `messages` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `messages_folder_idx` ON `messages` (`folder_id`);--> statement-breakpoint
CREATE INDEX `messages_thread_idx` ON `messages` (`mailbox_id`,`thread_id`);--> statement-breakpoint
CREATE INDEX `messages_provider_message_idx` ON `messages` (`mailbox_id`,`provider_message_id`);--> statement-breakpoint
CREATE INDEX `messages_raw_r2_key_idx` ON `messages` (`raw_r2_key`);--> statement-breakpoint
CREATE INDEX `messages_trashed_at_idx` ON `messages` (`trashed_at`);--> statement-breakpoint
CREATE INDEX `messages_inbox_page_idx` ON `messages` (`mailbox_id`,`status`,`folder_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `messages_thread_key_idx` ON `messages` (`mailbox_id`,`status`,`folder_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `messages_mailbox_thread_key_idx` ON `messages` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `messages_nav_cover_idx` ON `messages` (`mailbox_id`,`status`,`folder_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `messages_counts_cover_idx` ON `messages` (`mailbox_id`,`folder_id`,`direction`,`status`,`read`,`starred`,`snoozed_until`);--> statement-breakpoint
CREATE INDEX `messages_conv_cover_idx` ON `messages` (`mailbox_id`,`status`,`created_at`,`id`,`snoozed_until`);--> statement-breakpoint
CREATE INDEX `mfa_recovery_codes_user_idx` ON `mfa_recovery_codes` (`user_id`);--> statement-breakpoint
CREATE INDEX `outbound_jobs_user_idx` ON `outbound_jobs` (`user_id`);--> statement-breakpoint
CREATE INDEX `outbound_jobs_message_idx` ON `outbound_jobs` (`message_id`);--> statement-breakpoint
CREATE INDEX `password_reset_tokens_user_idx` ON `password_reset_tokens` (`user_id`);--> statement-breakpoint
CREATE INDEX `push_devices_user_idx` ON `push_devices` (`user_id`);--> statement-breakpoint
CREATE INDEX `push_devices_api_key_idx` ON `push_devices` (`api_key_id`);--> statement-breakpoint
CREATE INDEX `push_subscriptions_user_idx` ON `push_subscriptions` (`user_id`);--> statement-breakpoint
CREATE INDEX `push_subscriptions_session_idx` ON `push_subscriptions` (`session_id`);--> statement-breakpoint
CREATE INDEX `routing_rules_domain_scope_idx` ON `routing_rules` (`domain_id`,`scope`,`enabled`);--> statement-breakpoint
CREATE INDEX `routing_rules_mailbox_idx` ON `routing_rules` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `routing_rules_priority_idx` ON `routing_rules` (`priority`);--> statement-breakpoint
CREATE INDEX `routing_rules_user_idx` ON `routing_rules` (`user_id`);--> statement-breakpoint
CREATE INDEX `routing_rules_folder_idx` ON `routing_rules` (`folder_id`);--> statement-breakpoint
CREATE INDEX `sessions_user_idx` ON `sessions` (`user_id`);--> statement-breakpoint
CREATE INDEX `spam_feedback_mailbox_idx` ON `spam_feedback` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `spam_feedback_actor_user_idx` ON `spam_feedback` (`actor_user_id`);--> statement-breakpoint
CREATE INDEX `spam_reputation_mailbox_idx` ON `spam_reputation` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `spam_token_stats_mailbox_idx` ON `spam_token_stats` (`mailbox_id`);--> statement-breakpoint
CREATE INDEX `users_created_by_idx` ON `users` (`created_by_user_id`);--> statement-breakpoint
CREATE INDEX `webhook_deliveries_webhook_idx` ON `webhook_deliveries` (`webhook_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `webhook_deliveries_status_idx` ON `webhook_deliveries` (`status`);--> statement-breakpoint
CREATE INDEX `webhooks_user_idx` ON `webhooks` (`user_id`);