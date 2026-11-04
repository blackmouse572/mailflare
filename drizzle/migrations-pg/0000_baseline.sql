CREATE TABLE "agent_chat_messages" (
	"id" text PRIMARY KEY NOT NULL,
	"conversation_id" text NOT NULL,
	"role" text NOT NULL,
	"content" text NOT NULL,
	"tool_name" text,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_conversations" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"mailbox_id" text NOT NULL,
	"title" text DEFAULT 'New conversation' NOT NULL,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_draft_metadata" (
	"draft_id" text PRIMARY KEY NOT NULL,
	"mailbox_id" text NOT NULL,
	"origin" text NOT NULL,
	"source_message_id" text,
	"revision" bigint DEFAULT 1 NOT NULL,
	"human_edited_at" bigint,
	"scheduled_at" bigint,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_jobs" (
	"id" text PRIMARY KEY NOT NULL,
	"mailbox_id" text NOT NULL,
	"source_message_id" text NOT NULL,
	"reviewer_user_id" text NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"attempts" bigint DEFAULT 0 NOT NULL,
	"next_attempt_at" bigint NOT NULL,
	"lease_until" bigint,
	"draft_id" text,
	"reason" text,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_send_approvals" (
	"id" text PRIMARY KEY NOT NULL,
	"draft_id" text NOT NULL,
	"mailbox_id" text NOT NULL,
	"user_id" text NOT NULL,
	"request_key_id" text,
	"revision" bigint NOT NULL,
	"payload_hash" text NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"claimed_at" bigint,
	"message_id" text,
	"expires_at" bigint NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ai_usage" (
	"id" text PRIMARY KEY NOT NULL,
	"created_at" bigint NOT NULL,
	"provider" text NOT NULL,
	"model" text NOT NULL,
	"source" text NOT NULL,
	"input_tokens" bigint,
	"output_tokens" bigint,
	"cost_usd_micros" bigint
);
--> statement-breakpoint
CREATE TABLE "api_keys" (
	"id" text PRIMARY KEY NOT NULL,
	"kind" text DEFAULT 'legacy' NOT NULL,
	"user_id" text NOT NULL,
	"name" text NOT NULL,
	"prefix" text NOT NULL,
	"key_hash" text NOT NULL,
	"scopes" text NOT NULL,
	"mailbox_scope_enabled" boolean DEFAULT false NOT NULL,
	"created_at" bigint NOT NULL,
	"last_used_at" bigint
);
--> statement-breakpoint
CREATE TABLE "app_settings" (
	"id" text PRIMARY KEY NOT NULL,
	"app_name" text DEFAULT 'Mailflare' NOT NULL,
	"outbound_attachment_max_mb" bigint DEFAULT 25 NOT NULL,
	"drive_storage_limit_bytes" bigint,
	"resend_api_key" text,
	"aws_config" text,
	"ses_receiving" text,
	"resend_webhook_id" text,
	"resend_webhook_secret" text,
	"icon_key" text,
	"agent_enabled" boolean DEFAULT true NOT NULL,
	"agent_provider" text,
	"agent_preset" text,
	"agent_base_url" text,
	"agent_api_key" text,
	"agent_model" text,
	"agent_model_rates" text,
	"spamhaus_dqs_key" text,
	"abusech_auth_key" text,
	"spam_domain_age_check" boolean DEFAULT true NOT NULL,
	"spam_brands" text,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "audit_logs" (
	"id" text PRIMARY KEY NOT NULL,
	"actor_user_id" text,
	"target_user_id" text,
	"mailbox_id" text,
	"message_id" text,
	"action" text NOT NULL,
	"metadata" text,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "auto_reply_deliveries" (
	"id" text PRIMARY KEY NOT NULL,
	"mailbox_id" text NOT NULL,
	"recipient" text NOT NULL,
	"sent_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "backup_settings" (
	"id" text PRIMARY KEY NOT NULL,
	"enabled" boolean DEFAULT true NOT NULL,
	"schedule_type" text DEFAULT 'daily' NOT NULL,
	"schedule_value" bigint,
	"retention_enabled" boolean DEFAULT false NOT NULL,
	"retention_days" bigint DEFAULT 30 NOT NULL,
	"excluded_table_groups" text DEFAULT '[]' NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "backups" (
	"id" text PRIMARY KEY NOT NULL,
	"status" text DEFAULT 'queued' NOT NULL,
	"trigger" text NOT NULL,
	"r2_key" text,
	"filename" text,
	"size" bigint,
	"error" text,
	"created_by_user_id" text,
	"created_at" bigint NOT NULL,
	"started_at" bigint,
	"completed_at" bigint
);
--> statement-breakpoint
CREATE TABLE "booking_events" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"name" text NOT NULL,
	"slug" text DEFAULT '' NOT NULL,
	"description" text DEFAULT '' NOT NULL,
	"color" text DEFAULT '#2563eb' NOT NULL,
	"host_ids" text DEFAULT '[]' NOT NULL,
	"duration_minutes" bigint NOT NULL,
	"location" text DEFAULT '' NOT NULL,
	"weekdays" text DEFAULT '[1,2,3,4,5]' NOT NULL,
	"start_time" text DEFAULT '09:00' NOT NULL,
	"end_time" text DEFAULT '17:00' NOT NULL,
	"time_ranges" text DEFAULT '[{"startTime":"09:00","endTime":"17:00"}]' NOT NULL,
	"time_zone" text DEFAULT 'UTC' NOT NULL,
	"enabled" boolean DEFAULT true NOT NULL,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "calendar_events" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"mailbox_id" text,
	"title" text NOT NULL,
	"description" text DEFAULT '' NOT NULL,
	"location" text DEFAULT '' NOT NULL,
	"attendees" text DEFAULT '[]' NOT NULL,
	"color" text DEFAULT 'blue' NOT NULL,
	"repeat" text DEFAULT 'none' NOT NULL,
	"repeat_days" text DEFAULT '[]' NOT NULL,
	"repeat_anchor_day" bigint,
	"repeat_until" bigint,
	"excluded_occurrences" text DEFAULT '[]' NOT NULL,
	"time_zone" text,
	"starts_at" bigint NOT NULL,
	"ends_at" bigint NOT NULL,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "contacts" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"email" text NOT NULL,
	"display_name" text,
	"avatar_key" text,
	"source" text DEFAULT 'inbound' NOT NULL,
	"blocked" boolean DEFAULT false NOT NULL,
	"remote_content_allowed" boolean DEFAULT false NOT NULL,
	"last_seen_at" bigint,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "domain_tracking_hosts" (
	"domain_id" text PRIMARY KEY NOT NULL,
	"hostname" text NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "domains" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"hostname" text NOT NULL,
	"zone_id" text NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"routing_status" text,
	"sending_subdomain_tag" text,
	"sending_provider" text DEFAULT 'none' NOT NULL,
	"receiving_provider" text DEFAULT 'cloudflare' NOT NULL,
	"sending_requested" boolean DEFAULT false NOT NULL,
	"sending_enabled" boolean DEFAULT false NOT NULL,
	"routing_enabled" boolean DEFAULT false NOT NULL,
	"dns_skipped" boolean DEFAULT false NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "drive_items" (
	"id" text PRIMARY KEY NOT NULL,
	"owner_id" text NOT NULL,
	"parent_id" text,
	"kind" text NOT NULL,
	"name" text NOT NULL,
	"r2_key" text,
	"size" bigint DEFAULT 0 NOT NULL,
	"content_type" text DEFAULT 'application/octet-stream' NOT NULL,
	"upload_id" text,
	"upload_part_size" bigint,
	"upload_fingerprint" text,
	"link_token" text,
	"trashed_at" bigint,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "drive_shares" (
	"id" text PRIMARY KEY NOT NULL,
	"item_id" text NOT NULL,
	"user_id" text NOT NULL,
	"role" text DEFAULT 'view' NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "drive_upload_parts" (
	"item_id" text NOT NULL,
	"part_number" bigint NOT NULL,
	"etag" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "email_templates" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"name" text NOT NULL,
	"subject" text DEFAULT '' NOT NULL,
	"text_body" text DEFAULT '' NOT NULL,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "folders" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"mailbox_id" text NOT NULL,
	"name" text NOT NULL,
	"color" text DEFAULT '#2563eb' NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "follow_ups" (
	"id" text PRIMARY KEY NOT NULL,
	"message_id" text NOT NULL,
	"user_id" text NOT NULL,
	"due_at" bigint NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "import_jobs" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"mailbox_id" text NOT NULL,
	"kind" text NOT NULL,
	"label" text NOT NULL,
	"status" text DEFAULT 'queued' NOT NULL,
	"total" bigint DEFAULT 0 NOT NULL,
	"processed" bigint DEFAULT 0 NOT NULL,
	"imported" bigint DEFAULT 0 NOT NULL,
	"skipped" bigint DEFAULT 0 NOT NULL,
	"spec" text NOT NULL,
	"cursor" text DEFAULT '{}' NOT NULL,
	"errors" text DEFAULT '[]' NOT NULL,
	"error_count" bigint DEFAULT 0 NOT NULL,
	"error" text,
	"created_at" bigint NOT NULL,
	"started_at" bigint,
	"updated_at" bigint NOT NULL,
	"finished_at" bigint
);
--> statement-breakpoint
CREATE TABLE "jmap_change_floor" (
	"id" bigint PRIMARY KEY NOT NULL,
	"seq" bigint DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "jmap_changes" (
	"seq" bigserial PRIMARY KEY NOT NULL,
	"mailbox_id" text NOT NULL,
	"object_type" text NOT NULL,
	"object_id" text NOT NULL,
	"thread_id" text,
	"change" text NOT NULL,
	"created_at" bigint DEFAULT (extract(epoch from now())::bigint) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "jmap_mailbox_revisions" (
	"mailbox_id" text PRIMARY KEY NOT NULL,
	"revision" bigint DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "license_settings" (
	"id" text PRIMARY KEY NOT NULL,
	"instance_id" text NOT NULL,
	"instance_url" text,
	"license_key_hash" text,
	"plan" text DEFAULT 'community' NOT NULL,
	"state" text DEFAULT 'inactive' NOT NULL,
	"features" text DEFAULT '[]' NOT NULL,
	"seat_limit" bigint DEFAULT 1,
	"activated_at" bigint,
	"validated_at" bigint,
	"updated_at" bigint NOT NULL,
	CONSTRAINT "license_settings_instance_id_unique" UNIQUE("instance_id")
);
--> statement-breakpoint
CREATE TABLE "login_challenges" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"token_hash" text NOT NULL,
	"expires_at" bigint NOT NULL,
	"created_at" bigint NOT NULL,
	CONSTRAINT "login_challenges_token_hash_unique" UNIQUE("token_hash")
);
--> statement-breakpoint
CREATE TABLE "mailbox_access" (
	"id" text PRIMARY KEY NOT NULL,
	"mailbox_id" text NOT NULL,
	"user_id" text NOT NULL,
	"permission" text DEFAULT 'read_only' NOT NULL,
	"created_by_user_id" text,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "mailbox_agent_settings" (
	"mailbox_id" text PRIMARY KEY NOT NULL,
	"enabled" boolean DEFAULT false NOT NULL,
	"model_id" text,
	"auto_draft_enabled" boolean DEFAULT false NOT NULL,
	"reviewer_user_id" text,
	"instructions" text DEFAULT '' NOT NULL,
	"daily_limit" bigint DEFAULT 25 NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "mailbox_aliases" (
	"id" text PRIMARY KEY NOT NULL,
	"mailbox_id" text NOT NULL,
	"domain_id" text NOT NULL,
	"local_part" text NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "mailboxes" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"domain_id" text NOT NULL,
	"local_part" text NOT NULL,
	"display_name" text,
	"signature" text,
	"auto_reply_enabled" boolean DEFAULT false NOT NULL,
	"auto_reply_subject" text DEFAULT 'Out of office' NOT NULL,
	"auto_reply_body" text DEFAULT '' NOT NULL,
	"avatar_key" text,
	"type" text DEFAULT 'personal' NOT NULL,
	"use_all_domains" boolean DEFAULT true NOT NULL,
	"disabled" boolean DEFAULT false NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "mcp_key_mailboxes" (
	"key_id" text NOT NULL,
	"mailbox_id" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "message_attachments" (
	"id" text PRIMARY KEY NOT NULL,
	"message_id" text NOT NULL,
	"filename" text NOT NULL,
	"content_type" text NOT NULL,
	"size" bigint NOT NULL,
	"disposition" text DEFAULT 'attachment' NOT NULL,
	"content_id" text,
	"r2_key" text NOT NULL,
	"trashed_at" bigint,
	"created_at" bigint NOT NULL,
	CONSTRAINT "message_attachments_r2_key_unique" UNIQUE("r2_key")
);
--> statement-breakpoint
CREATE TABLE "message_opens" (
	"id" text PRIMARY KEY NOT NULL,
	"token" text NOT NULL,
	"opened_at" bigint NOT NULL,
	"client" text,
	"device" text,
	"country" text,
	"city" text,
	"automated" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "message_tracking" (
	"token" text PRIMARY KEY NOT NULL,
	"message_id" text NOT NULL,
	"open_count" bigint DEFAULT 0 NOT NULL,
	"first_opened_at" bigint,
	"last_opened_at" bigint,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "messages" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"mailbox_id" text,
	"direction" text NOT NULL,
	"provider_message_id" text,
	"folder_id" text,
	"from_addr" text NOT NULL,
	"to_addr" text NOT NULL,
	"cc_addr" text,
	"bcc_addr" text,
	"reply_to" text,
	"subject" text,
	"snippet" text,
	"text_body" text,
	"html_body" text,
	"raw_r2_key" text,
	"status" text DEFAULT 'received' NOT NULL,
	"read" boolean DEFAULT false NOT NULL,
	"starred" boolean DEFAULT false NOT NULL,
	"snoozed_until" bigint,
	"thread_id" text,
	"in_reply_to" text,
	"references_header" text,
	"spam_score" bigint,
	"spam_verdict" text,
	"spam_signals" text,
	"spam_analyzed_at" bigint,
	"spam_analysis_error" text,
	"trashed_at" bigint,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "mfa_recovery_codes" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"code_hash" text NOT NULL,
	"used_at" bigint,
	"created_at" bigint NOT NULL,
	CONSTRAINT "mfa_recovery_codes_code_hash_unique" UNIQUE("code_hash")
);
--> statement-breakpoint
CREATE TABLE "outbound_jobs" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"message_id" text,
	"status" text DEFAULT 'queued' NOT NULL,
	"payload" text NOT NULL,
	"error" text,
	"scheduled_at" bigint,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "password_reset_tokens" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"token_hash" text NOT NULL,
	"expires_at" bigint NOT NULL,
	"used_at" bigint,
	"created_at" bigint NOT NULL,
	CONSTRAINT "password_reset_tokens_token_hash_unique" UNIQUE("token_hash")
);
--> statement-breakpoint
CREATE TABLE "push_devices" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"api_key_id" text NOT NULL,
	"platform" text NOT NULL,
	"token" text NOT NULL,
	"environment" text DEFAULT 'production' NOT NULL,
	"topic" text NOT NULL,
	"public_key" text,
	"previews" boolean DEFAULT true NOT NULL,
	"client_ref" text,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "push_subscriptions" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"session_id" text NOT NULL,
	"endpoint" text NOT NULL,
	"p256dh" text NOT NULL,
	"auth" text NOT NULL,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "routing_rules" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"domain_id" text NOT NULL,
	"scope" text DEFAULT 'mailbox' NOT NULL,
	"name" text,
	"enabled" boolean DEFAULT true NOT NULL,
	"pattern" text NOT NULL,
	"match_field" text DEFAULT 'email' NOT NULL,
	"match_operator" text DEFAULT 'contains' NOT NULL,
	"match_value" text DEFAULT '' NOT NULL,
	"mailbox_id" text,
	"folder_id" text,
	"action" text DEFAULT 'store' NOT NULL,
	"forward_to" text,
	"keep_copy" boolean DEFAULT false NOT NULL,
	"reject_reason" text,
	"priority" bigint DEFAULT 0 NOT NULL,
	"last_matched_at" bigint,
	"match_count" bigint DEFAULT 0 NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"token_hash" text NOT NULL,
	"expires_at" bigint NOT NULL,
	"created_at" bigint NOT NULL,
	CONSTRAINT "sessions_token_hash_unique" UNIQUE("token_hash")
);
--> statement-breakpoint
CREATE TABLE "shared_attachment_links" (
	"id" text PRIMARY KEY NOT NULL,
	"attachment_id" text NOT NULL,
	"expires_at" bigint NOT NULL,
	"created_at" bigint NOT NULL,
	CONSTRAINT "shared_attachment_links_attachment_id_unique" UNIQUE("attachment_id")
);
--> statement-breakpoint
CREATE TABLE "spam_feedback" (
	"message_id" text PRIMARY KEY NOT NULL,
	"mailbox_id" text NOT NULL,
	"actor_user_id" text,
	"classification" text NOT NULL,
	"training_tokens" text NOT NULL,
	"reputation_keys" text NOT NULL,
	"tokenizer_version" bigint DEFAULT 1 NOT NULL,
	"created_at" bigint NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "spam_reputation" (
	"mailbox_id" text NOT NULL,
	"type" text NOT NULL,
	"key" text NOT NULL,
	"messages_seen" bigint DEFAULT 0 NOT NULL,
	"spam_count" bigint DEFAULT 0 NOT NULL,
	"ham_count" bigint DEFAULT 0 NOT NULL,
	"first_seen_at" bigint NOT NULL,
	"last_seen_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "spam_token_stats" (
	"mailbox_id" text NOT NULL,
	"token" text NOT NULL,
	"spam_count" bigint DEFAULT 0 NOT NULL,
	"ham_count" bigint DEFAULT 0 NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user_compose_preferences" (
	"user_id" text PRIMARY KEY NOT NULL,
	"track_opens_default" boolean DEFAULT false NOT NULL,
	"undo_send_seconds" bigint DEFAULT 15 NOT NULL,
	"updated_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" text PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"reset_email" text,
	"forwarding_email" text,
	"password_hash" text NOT NULL,
	"name" text NOT NULL,
	"booking_username" text,
	"time_zone" text,
	"avatar_key" text,
	"role" text DEFAULT 'user' NOT NULL,
	"is_primary_admin" boolean DEFAULT false NOT NULL,
	"disabled" boolean DEFAULT false NOT NULL,
	"can_manage_mailboxes" boolean DEFAULT false NOT NULL,
	"can_manage_domains" boolean DEFAULT false NOT NULL,
	"can_manage_users" boolean DEFAULT false NOT NULL,
	"keyboard_shortcuts_enabled" boolean DEFAULT true NOT NULL,
	"spam_protection_enabled" boolean DEFAULT true NOT NULL,
	"trash_retention_days" bigint,
	"show_full_recipient_addresses" boolean DEFAULT false NOT NULL,
	"remote_content_mode" text DEFAULT 'allow' NOT NULL,
	"totp_secret" text,
	"totp_enabled" boolean DEFAULT false NOT NULL,
	"totp_confirmed_at" bigint,
	"last_sign_in_at" bigint,
	"deleted_at" bigint,
	"created_by_user_id" text,
	"created_at" bigint NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "webhook_deliveries" (
	"id" text PRIMARY KEY NOT NULL,
	"webhook_id" text NOT NULL,
	"event_type" text NOT NULL,
	"payload" text NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"attempts" bigint DEFAULT 0 NOT NULL,
	"response_status" bigint,
	"error" text,
	"duration_ms" bigint,
	"last_attempt_at" bigint,
	"next_retry_at" bigint,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "webhooks" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"description" text,
	"url" text NOT NULL,
	"secret" text NOT NULL,
	"events" text NOT NULL,
	"enabled" boolean DEFAULT true NOT NULL,
	"max_attempts" bigint DEFAULT 5 NOT NULL,
	"created_at" bigint NOT NULL
);
--> statement-breakpoint
ALTER TABLE "agent_chat_messages" ADD CONSTRAINT "agent_chat_messages_conversation_id_agent_conversations_id_fk" FOREIGN KEY ("conversation_id") REFERENCES "public"."agent_conversations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_conversations" ADD CONSTRAINT "agent_conversations_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_conversations" ADD CONSTRAINT "agent_conversations_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_draft_metadata" ADD CONSTRAINT "agent_draft_metadata_draft_id_messages_id_fk" FOREIGN KEY ("draft_id") REFERENCES "public"."messages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_draft_metadata" ADD CONSTRAINT "agent_draft_metadata_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_draft_metadata" ADD CONSTRAINT "agent_draft_metadata_source_message_id_messages_id_fk" FOREIGN KEY ("source_message_id") REFERENCES "public"."messages"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_jobs" ADD CONSTRAINT "agent_jobs_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_jobs" ADD CONSTRAINT "agent_jobs_source_message_id_messages_id_fk" FOREIGN KEY ("source_message_id") REFERENCES "public"."messages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_jobs" ADD CONSTRAINT "agent_jobs_reviewer_user_id_users_id_fk" FOREIGN KEY ("reviewer_user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_jobs" ADD CONSTRAINT "agent_jobs_draft_id_messages_id_fk" FOREIGN KEY ("draft_id") REFERENCES "public"."messages"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_send_approvals" ADD CONSTRAINT "agent_send_approvals_draft_id_messages_id_fk" FOREIGN KEY ("draft_id") REFERENCES "public"."messages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_send_approvals" ADD CONSTRAINT "agent_send_approvals_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_send_approvals" ADD CONSTRAINT "agent_send_approvals_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_send_approvals" ADD CONSTRAINT "agent_send_approvals_request_key_id_api_keys_id_fk" FOREIGN KEY ("request_key_id") REFERENCES "public"."api_keys"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_actor_user_id_users_id_fk" FOREIGN KEY ("actor_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_target_user_id_users_id_fk" FOREIGN KEY ("target_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_message_id_messages_id_fk" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "auto_reply_deliveries" ADD CONSTRAINT "auto_reply_deliveries_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "backups" ADD CONSTRAINT "backups_created_by_user_id_users_id_fk" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "booking_events" ADD CONSTRAINT "booking_events_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "calendar_events" ADD CONSTRAINT "calendar_events_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "calendar_events" ADD CONSTRAINT "calendar_events_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "contacts" ADD CONSTRAINT "contacts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "domain_tracking_hosts" ADD CONSTRAINT "domain_tracking_hosts_domain_id_domains_id_fk" FOREIGN KEY ("domain_id") REFERENCES "public"."domains"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "domains" ADD CONSTRAINT "domains_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "drive_items" ADD CONSTRAINT "drive_items_owner_id_users_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "drive_shares" ADD CONSTRAINT "drive_shares_item_id_drive_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."drive_items"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "drive_shares" ADD CONSTRAINT "drive_shares_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "drive_upload_parts" ADD CONSTRAINT "drive_upload_parts_item_id_drive_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."drive_items"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "email_templates" ADD CONSTRAINT "email_templates_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "folders" ADD CONSTRAINT "folders_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "folders" ADD CONSTRAINT "folders_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "follow_ups" ADD CONSTRAINT "follow_ups_message_id_messages_id_fk" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "follow_ups" ADD CONSTRAINT "follow_ups_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "import_jobs" ADD CONSTRAINT "import_jobs_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "import_jobs" ADD CONSTRAINT "import_jobs_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "login_challenges" ADD CONSTRAINT "login_challenges_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailbox_access" ADD CONSTRAINT "mailbox_access_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailbox_access" ADD CONSTRAINT "mailbox_access_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailbox_access" ADD CONSTRAINT "mailbox_access_created_by_user_id_users_id_fk" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailbox_agent_settings" ADD CONSTRAINT "mailbox_agent_settings_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailbox_agent_settings" ADD CONSTRAINT "mailbox_agent_settings_reviewer_user_id_users_id_fk" FOREIGN KEY ("reviewer_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailbox_aliases" ADD CONSTRAINT "mailbox_aliases_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailbox_aliases" ADD CONSTRAINT "mailbox_aliases_domain_id_domains_id_fk" FOREIGN KEY ("domain_id") REFERENCES "public"."domains"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailboxes" ADD CONSTRAINT "mailboxes_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mailboxes" ADD CONSTRAINT "mailboxes_domain_id_domains_id_fk" FOREIGN KEY ("domain_id") REFERENCES "public"."domains"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mcp_key_mailboxes" ADD CONSTRAINT "mcp_key_mailboxes_key_id_api_keys_id_fk" FOREIGN KEY ("key_id") REFERENCES "public"."api_keys"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mcp_key_mailboxes" ADD CONSTRAINT "mcp_key_mailboxes_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "message_attachments" ADD CONSTRAINT "message_attachments_message_id_messages_id_fk" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "message_opens" ADD CONSTRAINT "message_opens_token_message_tracking_token_fk" FOREIGN KEY ("token") REFERENCES "public"."message_tracking"("token") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "message_tracking" ADD CONSTRAINT "message_tracking_message_id_messages_id_fk" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_folder_id_folders_id_fk" FOREIGN KEY ("folder_id") REFERENCES "public"."folders"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mfa_recovery_codes" ADD CONSTRAINT "mfa_recovery_codes_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "outbound_jobs" ADD CONSTRAINT "outbound_jobs_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "outbound_jobs" ADD CONSTRAINT "outbound_jobs_message_id_messages_id_fk" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "password_reset_tokens" ADD CONSTRAINT "password_reset_tokens_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "push_devices" ADD CONSTRAINT "push_devices_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "push_devices" ADD CONSTRAINT "push_devices_api_key_id_api_keys_id_fk" FOREIGN KEY ("api_key_id") REFERENCES "public"."api_keys"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "push_subscriptions" ADD CONSTRAINT "push_subscriptions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "push_subscriptions" ADD CONSTRAINT "push_subscriptions_session_id_sessions_id_fk" FOREIGN KEY ("session_id") REFERENCES "public"."sessions"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "routing_rules" ADD CONSTRAINT "routing_rules_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "routing_rules" ADD CONSTRAINT "routing_rules_domain_id_domains_id_fk" FOREIGN KEY ("domain_id") REFERENCES "public"."domains"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "routing_rules" ADD CONSTRAINT "routing_rules_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "routing_rules" ADD CONSTRAINT "routing_rules_folder_id_folders_id_fk" FOREIGN KEY ("folder_id") REFERENCES "public"."folders"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "shared_attachment_links" ADD CONSTRAINT "shared_attachment_links_attachment_id_message_attachments_id_fk" FOREIGN KEY ("attachment_id") REFERENCES "public"."message_attachments"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "spam_feedback" ADD CONSTRAINT "spam_feedback_message_id_messages_id_fk" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "spam_feedback" ADD CONSTRAINT "spam_feedback_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "spam_feedback" ADD CONSTRAINT "spam_feedback_actor_user_id_users_id_fk" FOREIGN KEY ("actor_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "spam_reputation" ADD CONSTRAINT "spam_reputation_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "spam_token_stats" ADD CONSTRAINT "spam_token_stats_mailbox_id_mailboxes_id_fk" FOREIGN KEY ("mailbox_id") REFERENCES "public"."mailboxes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_compose_preferences" ADD CONSTRAINT "user_compose_preferences_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_created_by_user_id_users_id_fk" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "webhook_deliveries" ADD CONSTRAINT "webhook_deliveries_webhook_id_webhooks_id_fk" FOREIGN KEY ("webhook_id") REFERENCES "public"."webhooks"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "webhooks" ADD CONSTRAINT "webhooks_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "agent_chat_messages_conversation_idx" ON "agent_chat_messages" USING btree ("conversation_id","created_at");--> statement-breakpoint
CREATE INDEX "agent_conversations_owner_idx" ON "agent_conversations" USING btree ("user_id","mailbox_id","updated_at");--> statement-breakpoint
CREATE INDEX "agent_conversations_mailbox_idx" ON "agent_conversations" USING btree ("mailbox_id");--> statement-breakpoint
CREATE INDEX "agent_draft_meta_source_msg_idx" ON "agent_draft_metadata" USING btree ("source_message_id");--> statement-breakpoint
CREATE INDEX "agent_draft_metadata_mailbox_idx" ON "agent_draft_metadata" USING btree ("mailbox_id");--> statement-breakpoint
CREATE UNIQUE INDEX "agent_jobs_source_idx" ON "agent_jobs" USING btree ("mailbox_id","source_message_id");--> statement-breakpoint
CREATE INDEX "agent_jobs_due_idx" ON "agent_jobs" USING btree ("status","next_attempt_at");--> statement-breakpoint
CREATE INDEX "agent_jobs_source_message_idx" ON "agent_jobs" USING btree ("source_message_id");--> statement-breakpoint
CREATE INDEX "agent_jobs_draft_idx" ON "agent_jobs" USING btree ("draft_id");--> statement-breakpoint
CREATE INDEX "agent_jobs_reviewer_idx" ON "agent_jobs" USING btree ("reviewer_user_id");--> statement-breakpoint
CREATE INDEX "agent_send_approvals_user_idx" ON "agent_send_approvals" USING btree ("user_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "agent_send_approvals_delivery_idx" ON "agent_send_approvals" USING btree ("draft_id") WHERE status IN ('claimed', 'sent', 'unknown');--> statement-breakpoint
CREATE INDEX "agent_send_approvals_request_key_idx" ON "agent_send_approvals" USING btree ("request_key_id");--> statement-breakpoint
CREATE INDEX "agent_send_approvals_mailbox_idx" ON "agent_send_approvals" USING btree ("mailbox_id");--> statement-breakpoint
CREATE INDEX "agent_send_approvals_draft_idx" ON "agent_send_approvals" USING btree ("draft_id");--> statement-breakpoint
CREATE INDEX "ai_usage_created_idx" ON "ai_usage" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "api_keys_user_idx" ON "api_keys" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "audit_logs_actor_idx" ON "audit_logs" USING btree ("actor_user_id");--> statement-breakpoint
CREATE INDEX "audit_logs_mailbox_idx" ON "audit_logs" USING btree ("mailbox_id");--> statement-breakpoint
CREATE INDEX "audit_logs_created_idx" ON "audit_logs" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "audit_logs_message_id_idx" ON "audit_logs" USING btree ("message_id");--> statement-breakpoint
CREATE INDEX "audit_logs_target_user_idx" ON "audit_logs" USING btree ("target_user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "auto_reply_deliveries_mailbox_recipient_idx" ON "auto_reply_deliveries" USING btree ("mailbox_id","recipient");--> statement-breakpoint
CREATE INDEX "auto_reply_deliveries_sent_idx" ON "auto_reply_deliveries" USING btree ("sent_at");--> statement-breakpoint
CREATE INDEX "backups_created_idx" ON "backups" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "backups_status_idx" ON "backups" USING btree ("status");--> statement-breakpoint
CREATE INDEX "backups_created_by_idx" ON "backups" USING btree ("created_by_user_id");--> statement-breakpoint
CREATE INDEX "booking_events_user_idx" ON "booking_events" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "booking_events_user_slug_idx" ON "booking_events" USING btree ("user_id","slug");--> statement-breakpoint
CREATE INDEX "calendar_events_user_starts_idx" ON "calendar_events" USING btree ("user_id","starts_at");--> statement-breakpoint
CREATE INDEX "calendar_events_mailbox_idx" ON "calendar_events" USING btree ("mailbox_id");--> statement-breakpoint
CREATE UNIQUE INDEX "contacts_user_email_idx" ON "contacts" USING btree ("user_id","email");--> statement-breakpoint
CREATE INDEX "contacts_user_idx" ON "contacts" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "domain_tracking_hosts_hostname_idx" ON "domain_tracking_hosts" USING btree ("hostname");--> statement-breakpoint
CREATE UNIQUE INDEX "domains_hostname_idx" ON "domains" USING btree ("hostname");--> statement-breakpoint
CREATE INDEX "domains_user_idx" ON "domains" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "drive_items_owner_parent_idx" ON "drive_items" USING btree ("owner_id","parent_id");--> statement-breakpoint
CREATE UNIQUE INDEX "drive_items_link_token_idx" ON "drive_items" USING btree ("link_token");--> statement-breakpoint
CREATE UNIQUE INDEX "drive_shares_item_user_idx" ON "drive_shares" USING btree ("item_id","user_id");--> statement-breakpoint
CREATE INDEX "drive_shares_user_idx" ON "drive_shares" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "drive_upload_parts_idx" ON "drive_upload_parts" USING btree ("item_id","part_number");--> statement-breakpoint
CREATE INDEX "email_templates_user_idx" ON "email_templates" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "folders_mailbox_name_idx" ON "folders" USING btree ("mailbox_id","name");--> statement-breakpoint
CREATE INDEX "folders_user_idx" ON "folders" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "folders_mailbox_idx" ON "folders" USING btree ("mailbox_id");--> statement-breakpoint
CREATE UNIQUE INDEX "follow_ups_message_idx" ON "follow_ups" USING btree ("message_id");--> statement-breakpoint
CREATE INDEX "follow_ups_status_due_idx" ON "follow_ups" USING btree ("status","due_at");--> statement-breakpoint
CREATE INDEX "follow_ups_user_status_idx" ON "follow_ups" USING btree ("user_id","status");--> statement-breakpoint
CREATE INDEX "import_jobs_user_idx" ON "import_jobs" USING btree ("user_id","created_at");--> statement-breakpoint
CREATE INDEX "import_jobs_status_idx" ON "import_jobs" USING btree ("status","updated_at");--> statement-breakpoint
CREATE INDEX "jmap_changes_mailbox_seq_idx" ON "jmap_changes" USING btree ("mailbox_id","seq");--> statement-breakpoint
CREATE INDEX "login_challenges_user_idx" ON "login_challenges" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "mailbox_access_mailbox_user_idx" ON "mailbox_access" USING btree ("mailbox_id","user_id");--> statement-breakpoint
CREATE INDEX "mailbox_access_user_idx" ON "mailbox_access" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "mailbox_access_mailbox_idx" ON "mailbox_access" USING btree ("mailbox_id");--> statement-breakpoint
CREATE INDEX "mailbox_access_created_by_idx" ON "mailbox_access" USING btree ("created_by_user_id");--> statement-breakpoint
CREATE INDEX "mailbox_agent_settings_reviewer_idx" ON "mailbox_agent_settings" USING btree ("reviewer_user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "mailbox_aliases_address_idx" ON "mailbox_aliases" USING btree ("domain_id","local_part");--> statement-breakpoint
CREATE INDEX "mailbox_aliases_mailbox_idx" ON "mailbox_aliases" USING btree ("mailbox_id");--> statement-breakpoint
CREATE UNIQUE INDEX "mailboxes_address_idx" ON "mailboxes" USING btree ("domain_id","local_part");--> statement-breakpoint
CREATE INDEX "mailboxes_user_idx" ON "mailboxes" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "mcp_key_mailbox_idx" ON "mcp_key_mailboxes" USING btree ("key_id","mailbox_id");--> statement-breakpoint
CREATE INDEX "mcp_key_mailboxes_mailbox_idx" ON "mcp_key_mailboxes" USING btree ("mailbox_id");--> statement-breakpoint
CREATE INDEX "message_attachments_message_idx" ON "message_attachments" USING btree ("message_id");--> statement-breakpoint
CREATE INDEX "message_opens_token_idx" ON "message_opens" USING btree ("token","opened_at");--> statement-breakpoint
CREATE UNIQUE INDEX "message_tracking_message_idx" ON "message_tracking" USING btree ("message_id");--> statement-breakpoint
CREATE INDEX "messages_user_created_idx" ON "messages" USING btree ("user_id","created_at");--> statement-breakpoint
CREATE INDEX "messages_mailbox_idx" ON "messages" USING btree ("mailbox_id");--> statement-breakpoint
CREATE INDEX "messages_folder_idx" ON "messages" USING btree ("folder_id");--> statement-breakpoint
CREATE INDEX "messages_thread_idx" ON "messages" USING btree ("mailbox_id","thread_id");--> statement-breakpoint
CREATE INDEX "messages_provider_message_idx" ON "messages" USING btree ("mailbox_id","provider_message_id");--> statement-breakpoint
CREATE INDEX "messages_raw_r2_key_idx" ON "messages" USING btree ("raw_r2_key");--> statement-breakpoint
CREATE INDEX "messages_trashed_at_idx" ON "messages" USING btree ("trashed_at");--> statement-breakpoint
CREATE INDEX "messages_inbox_page_idx" ON "messages" USING btree ("mailbox_id","status","folder_id","created_at" desc,"id" desc);--> statement-breakpoint
CREATE INDEX "messages_thread_key_idx" ON "messages" USING btree ("mailbox_id","status","folder_id",coalesce("thread_id", "id"),"created_at");--> statement-breakpoint
CREATE INDEX "messages_mailbox_thread_key_idx" ON "messages" USING btree ("mailbox_id",coalesce("thread_id", "id"));--> statement-breakpoint
CREATE INDEX "messages_nav_cover_idx" ON "messages" USING btree ("mailbox_id","status","folder_id","created_at" desc,"id" desc,"direction","read","thread_id","snoozed_until");--> statement-breakpoint
CREATE INDEX "messages_counts_cover_idx" ON "messages" USING btree ("mailbox_id","folder_id","direction","status","read","starred","snoozed_until");--> statement-breakpoint
CREATE INDEX "messages_conv_cover_idx" ON "messages" USING btree ("mailbox_id","status",coalesce("thread_id", "id"),"created_at","id","snoozed_until");--> statement-breakpoint
CREATE INDEX "mfa_recovery_codes_user_idx" ON "mfa_recovery_codes" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "outbound_jobs_user_idx" ON "outbound_jobs" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "outbound_jobs_message_idx" ON "outbound_jobs" USING btree ("message_id");--> statement-breakpoint
CREATE INDEX "password_reset_tokens_user_idx" ON "password_reset_tokens" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "push_devices_platform_token_user_idx" ON "push_devices" USING btree ("platform","token","user_id");--> statement-breakpoint
CREATE INDEX "push_devices_user_idx" ON "push_devices" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "push_devices_api_key_idx" ON "push_devices" USING btree ("api_key_id");--> statement-breakpoint
CREATE UNIQUE INDEX "push_subscriptions_endpoint_idx" ON "push_subscriptions" USING btree ("endpoint");--> statement-breakpoint
CREATE INDEX "push_subscriptions_user_idx" ON "push_subscriptions" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "push_subscriptions_session_idx" ON "push_subscriptions" USING btree ("session_id");--> statement-breakpoint
CREATE INDEX "routing_rules_domain_scope_idx" ON "routing_rules" USING btree ("domain_id","scope","enabled");--> statement-breakpoint
CREATE INDEX "routing_rules_mailbox_idx" ON "routing_rules" USING btree ("mailbox_id");--> statement-breakpoint
CREATE INDEX "routing_rules_priority_idx" ON "routing_rules" USING btree ("priority");--> statement-breakpoint
CREATE INDEX "routing_rules_user_idx" ON "routing_rules" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "routing_rules_folder_idx" ON "routing_rules" USING btree ("folder_id");--> statement-breakpoint
CREATE INDEX "sessions_user_idx" ON "sessions" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "spam_feedback_mailbox_idx" ON "spam_feedback" USING btree ("mailbox_id");--> statement-breakpoint
CREATE INDEX "spam_feedback_actor_user_idx" ON "spam_feedback" USING btree ("actor_user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "spam_reputation_mailbox_type_key_idx" ON "spam_reputation" USING btree ("mailbox_id","type","key");--> statement-breakpoint
CREATE INDEX "spam_reputation_mailbox_idx" ON "spam_reputation" USING btree ("mailbox_id");--> statement-breakpoint
CREATE UNIQUE INDEX "spam_token_stats_mailbox_token_idx" ON "spam_token_stats" USING btree ("mailbox_id","token");--> statement-breakpoint
CREATE INDEX "spam_token_stats_mailbox_idx" ON "spam_token_stats" USING btree ("mailbox_id");--> statement-breakpoint
CREATE UNIQUE INDEX "users_booking_username_idx" ON "users" USING btree ("booking_username");--> statement-breakpoint
CREATE INDEX "users_created_by_idx" ON "users" USING btree ("created_by_user_id");--> statement-breakpoint
CREATE INDEX "webhook_deliveries_webhook_idx" ON "webhook_deliveries" USING btree ("webhook_id","created_at");--> statement-breakpoint
CREATE INDEX "webhook_deliveries_status_idx" ON "webhook_deliveries" USING btree ("status");--> statement-breakpoint
CREATE INDEX "webhooks_user_idx" ON "webhooks" USING btree ("user_id");