-- Objects drizzle-kit does not generate: seed rows, and the triggers that keep
-- them (and messages.trashed_at) current whichever code path writes. The SQLite twins are migrations
-- 0009, 0012, 0042, 0053 and 0064. Full-text search has no table here: PostgreSQL searches with ILIKE,
-- optionally accelerated by the pg_trgm indexes at the end.
INSERT INTO backup_settings (id, enabled, schedule_type, retention_enabled, retention_days, updated_at)
VALUES ('default', false, 'daily', false, 30, extract(epoch from now())::bigint)
ON CONFLICT DO NOTHING;--> statement-breakpoint
INSERT INTO app_settings (id, app_name, updated_at)
VALUES ('default', 'Mailflare', extract(epoch from now())::bigint)
ON CONFLICT DO NOTHING;--> statement-breakpoint
INSERT INTO jmap_change_floor (id, seq) VALUES (1, 0) ON CONFLICT DO NOTHING;--> statement-breakpoint
CREATE FUNCTION mailflare_bump_revision(target text) RETURNS void AS $$
BEGIN
	INSERT INTO jmap_mailbox_revisions (mailbox_id, revision) VALUES (target, 1)
	ON CONFLICT (mailbox_id) DO UPDATE SET revision = jmap_mailbox_revisions.revision + 1;
END;
$$ LANGUAGE plpgsql;--> statement-breakpoint
CREATE FUNCTION mailflare_messages_trashed_at() RETURNS trigger AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		IF NEW.status IN ('trash', 'spam') THEN
			NEW.trashed_at := extract(epoch from now())::bigint;
		END IF;
	ELSIF (NEW.status IN ('trash', 'spam')) <> (OLD.status IN ('trash', 'spam')) THEN
		NEW.trashed_at := CASE WHEN NEW.status IN ('trash', 'spam') THEN extract(epoch from now())::bigint ELSE NULL END;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;--> statement-breakpoint
CREATE TRIGGER messages_trashed_at_bi BEFORE INSERT OR UPDATE OF status ON messages
FOR EACH ROW EXECUTE FUNCTION mailflare_messages_trashed_at();--> statement-breakpoint
CREATE FUNCTION mailflare_messages_changed() RETURNS trigger AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		IF NEW.mailbox_id IS NOT NULL THEN
			PERFORM mailflare_bump_revision(NEW.mailbox_id);
			INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, change)
			VALUES (NEW.mailbox_id, 'email', NEW.id, coalesce(NEW.thread_id, NEW.id), 'created');
		END IF;
	ELSIF TG_OP = 'UPDATE' THEN
		IF NEW.mailbox_id IS NOT NULL THEN
			PERFORM mailflare_bump_revision(NEW.mailbox_id);
		END IF;
		IF OLD.mailbox_id IS NOT NULL AND OLD.mailbox_id IS DISTINCT FROM NEW.mailbox_id THEN
			PERFORM mailflare_bump_revision(OLD.mailbox_id);
		END IF;
		IF OLD.mailbox_id IS NOT DISTINCT FROM NEW.mailbox_id THEN
			IF NEW.mailbox_id IS NOT NULL THEN
				INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, change)
				VALUES (NEW.mailbox_id, 'email', NEW.id, coalesce(NEW.thread_id, NEW.id), 'updated');
			END IF;
		ELSE
			IF OLD.mailbox_id IS NOT NULL THEN
				INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, change)
				VALUES (OLD.mailbox_id, 'email', OLD.id, coalesce(OLD.thread_id, OLD.id), 'destroyed');
			END IF;
			IF NEW.mailbox_id IS NOT NULL THEN
				INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, change)
				VALUES (NEW.mailbox_id, 'email', NEW.id, coalesce(NEW.thread_id, NEW.id), 'created');
			END IF;
		END IF;
	ELSE
		IF OLD.mailbox_id IS NOT NULL THEN
			PERFORM mailflare_bump_revision(OLD.mailbox_id);
			INSERT INTO jmap_changes (mailbox_id, object_type, object_id, thread_id, change)
			VALUES (OLD.mailbox_id, 'email', OLD.id, coalesce(OLD.thread_id, OLD.id), 'destroyed');
		END IF;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;--> statement-breakpoint
CREATE TRIGGER messages_jmap_changed AFTER INSERT OR UPDATE OR DELETE ON messages
FOR EACH ROW EXECUTE FUNCTION mailflare_messages_changed();--> statement-breakpoint
CREATE FUNCTION mailflare_folders_changed() RETURNS trigger AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		PERFORM mailflare_bump_revision(NEW.mailbox_id);
		INSERT INTO jmap_changes (mailbox_id, object_type, object_id, change) VALUES (NEW.mailbox_id, 'mailbox', NEW.id, 'created');
	ELSIF TG_OP = 'UPDATE' THEN
		PERFORM mailflare_bump_revision(NEW.mailbox_id);
		IF OLD.mailbox_id IS DISTINCT FROM NEW.mailbox_id THEN
			PERFORM mailflare_bump_revision(OLD.mailbox_id);
			INSERT INTO jmap_changes (mailbox_id, object_type, object_id, change) VALUES (OLD.mailbox_id, 'mailbox', OLD.id, 'destroyed');
		END IF;
		INSERT INTO jmap_changes (mailbox_id, object_type, object_id, change)
		VALUES (NEW.mailbox_id, 'mailbox', NEW.id, CASE WHEN OLD.mailbox_id IS NOT DISTINCT FROM NEW.mailbox_id THEN 'updated' ELSE 'created' END);
	ELSE
		PERFORM mailflare_bump_revision(OLD.mailbox_id);
		INSERT INTO jmap_changes (mailbox_id, object_type, object_id, change) VALUES (OLD.mailbox_id, 'mailbox', OLD.id, 'destroyed');
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;--> statement-breakpoint
CREATE TRIGGER folders_jmap_changed AFTER INSERT OR UPDATE OR DELETE ON folders
FOR EACH ROW EXECUTE FUNCTION mailflare_folders_changed();--> statement-breakpoint
CREATE FUNCTION mailflare_mailboxes_changed() RETURNS trigger AS $$
BEGIN
	PERFORM mailflare_bump_revision(NEW.id);
	INSERT INTO jmap_changes (mailbox_id, object_type, object_id, change) VALUES (NEW.id, 'mailbox', NEW.id, 'updated');
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;--> statement-breakpoint
CREATE TRIGGER mailboxes_jmap_changed AFTER UPDATE ON mailboxes
FOR EACH ROW EXECUTE FUNCTION mailflare_mailboxes_changed();--> statement-breakpoint
CREATE FUNCTION mailflare_aliases_changed() RETURNS trigger AS $$
BEGIN
	IF TG_OP IN ('INSERT', 'UPDATE') THEN
		PERFORM mailflare_bump_revision(NEW.mailbox_id);
	END IF;
	IF TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND OLD.mailbox_id IS DISTINCT FROM NEW.mailbox_id) THEN
		PERFORM mailflare_bump_revision(OLD.mailbox_id);
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;--> statement-breakpoint
CREATE TRIGGER mailbox_aliases_jmap_changed AFTER INSERT OR UPDATE OR DELETE ON mailbox_aliases
FOR EACH ROW EXECUTE FUNCTION mailflare_aliases_changed();--> statement-breakpoint
DO $$
BEGIN
	CREATE EXTENSION IF NOT EXISTS pg_trgm;
	CREATE INDEX messages_subject_trgm_idx ON messages USING gin (lower(subject) gin_trgm_ops);
	CREATE INDEX messages_text_body_trgm_idx ON messages USING gin (lower(text_body) gin_trgm_ops);
EXCEPTION WHEN OTHERS THEN
	RAISE NOTICE 'pg_trgm is unavailable; message search will scan with ILIKE instead (%).', SQLERRM;
END;
$$;
