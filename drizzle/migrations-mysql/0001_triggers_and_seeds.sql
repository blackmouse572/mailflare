-- Objects drizzle-kit does not generate: seed rows, and the triggers that keep
-- them (and messages.trashed_at) current whichever code path writes. The SQLite twins are migrations
-- 0009, 0012, 0042, 0053 and 0064. Message search uses LIKE (see src/lib/search/conditions.ts).
INSERT IGNORE INTO backup_settings (id, enabled, schedule_type, retention_enabled, retention_days, updated_at)
VALUES ('default', false, 'daily', false, 30, unix_timestamp());--> statement-breakpoint
INSERT IGNORE INTO app_settings (id, app_name, updated_at)
VALUES ('default', 'Mailflare', unix_timestamp());--> statement-breakpoint
INSERT IGNORE INTO jmap_change_floor (id, seq) VALUES (1, 0);--> statement-breakpoint
CREATE TRIGGER messages_trashed_at_bi BEFORE INSERT ON messages FOR EACH ROW
BEGIN
	IF NEW.status IN ('trash', 'spam') THEN
		SET NEW.trashed_at = unix_timestamp();
	END IF;
END;--> statement-breakpoint
CREATE TRIGGER messages_trashed_at_bu BEFORE UPDATE ON messages FOR EACH ROW
BEGIN
	IF (NEW.status IN ('trash', 'spam')) <> (OLD.status IN ('trash', 'spam')) THEN
		SET NEW.trashed_at = IF(NEW.status IN ('trash', 'spam'), unix_timestamp(), NULL);
	END IF;
END;--> statement-breakpoint
CREATE TRIGGER messages_jmap_ai AFTER INSERT ON messages FOR EACH ROW
BEGIN
	IF NEW.mailbox_id IS NOT NULL THEN
		INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (NEW.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
		INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, `change`)
		VALUES (NEW.mailbox_id, 'email', NEW.id, coalesce(NEW.thread_id, NEW.id), 'created');
	END IF;
END;--> statement-breakpoint
CREATE TRIGGER messages_jmap_au AFTER UPDATE ON messages FOR EACH ROW
BEGIN
	IF NEW.mailbox_id IS NOT NULL THEN
		INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (NEW.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
	END IF;
	IF OLD.mailbox_id IS NOT NULL AND NOT (OLD.mailbox_id <=> NEW.mailbox_id) THEN
		INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (OLD.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
	END IF;
	IF OLD.mailbox_id <=> NEW.mailbox_id THEN
		IF NEW.mailbox_id IS NOT NULL THEN
			INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, `change`)
			VALUES (NEW.mailbox_id, 'email', NEW.id, coalesce(NEW.thread_id, NEW.id), 'updated');
		END IF;
	ELSE
		IF OLD.mailbox_id IS NOT NULL THEN
			INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, `change`)
			VALUES (OLD.mailbox_id, 'email', OLD.id, coalesce(OLD.thread_id, OLD.id), 'destroyed');
		END IF;
		IF NEW.mailbox_id IS NOT NULL THEN
			INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, `change`)
			VALUES (NEW.mailbox_id, 'email', NEW.id, coalesce(NEW.thread_id, NEW.id), 'created');
		END IF;
	END IF;
END;--> statement-breakpoint
CREATE TRIGGER messages_jmap_ad AFTER DELETE ON messages FOR EACH ROW
BEGIN
	IF OLD.mailbox_id IS NOT NULL THEN
		INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (OLD.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
		INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, `change`)
		VALUES (OLD.mailbox_id, 'email', OLD.id, coalesce(OLD.thread_id, OLD.id), 'destroyed');
	END IF;
END;--> statement-breakpoint
CREATE TRIGGER folders_jmap_ai AFTER INSERT ON folders FOR EACH ROW
BEGIN
	INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (NEW.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
	INSERT INTO jmap_changes (mailbox_id, object_type, object_id, `change`) VALUES (NEW.mailbox_id, 'mailbox', NEW.id, 'created');
END;--> statement-breakpoint
CREATE TRIGGER folders_jmap_au AFTER UPDATE ON folders FOR EACH ROW
BEGIN
	INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (NEW.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
	IF NOT (OLD.mailbox_id <=> NEW.mailbox_id) THEN
		INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (OLD.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
		INSERT INTO jmap_changes (mailbox_id, object_type, object_id, `change`) VALUES (OLD.mailbox_id, 'mailbox', OLD.id, 'destroyed');
	END IF;
	INSERT INTO jmap_changes (mailbox_id, object_type, object_id, `change`)
	VALUES (NEW.mailbox_id, 'mailbox', NEW.id, IF(OLD.mailbox_id <=> NEW.mailbox_id, 'updated', 'created'));
END;--> statement-breakpoint
CREATE TRIGGER folders_jmap_ad AFTER DELETE ON folders FOR EACH ROW
BEGIN
	INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (OLD.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
	INSERT INTO jmap_changes (mailbox_id, object_type, object_id, `change`) VALUES (OLD.mailbox_id, 'mailbox', OLD.id, 'destroyed');
END;--> statement-breakpoint
CREATE TRIGGER mailboxes_jmap_au AFTER UPDATE ON mailboxes FOR EACH ROW
BEGIN
	INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (NEW.id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
	INSERT INTO jmap_changes (mailbox_id, object_type, object_id, `change`) VALUES (NEW.id, 'mailbox', NEW.id, 'updated');
END;--> statement-breakpoint
CREATE TRIGGER mailbox_aliases_jmap_ai AFTER INSERT ON mailbox_aliases FOR EACH ROW
BEGIN
	INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (NEW.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
END;--> statement-breakpoint
CREATE TRIGGER mailbox_aliases_jmap_au AFTER UPDATE ON mailbox_aliases FOR EACH ROW
BEGIN
	INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (NEW.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
	IF NOT (OLD.mailbox_id <=> NEW.mailbox_id) THEN
		INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (OLD.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
	END IF;
END;--> statement-breakpoint
CREATE TRIGGER mailbox_aliases_jmap_ad AFTER DELETE ON mailbox_aliases FOR EACH ROW
BEGIN
	INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (OLD.mailbox_id, 1) ON DUPLICATE KEY UPDATE revision = revision + 1;
END;
