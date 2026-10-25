CREATE INDEX IF NOT EXISTS "service_requests_created_idx"
	ON "service_requests" ("created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "users_role_name_idx"
	ON "users" ("role", "name", "id");
--> statement-breakpoint
DROP INDEX IF EXISTS "users_role_idx";
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "news_articles_list_order_idx"
	ON "news_articles" ("published_at", "created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "events_starts_at_idx"
	ON "events" ("starts_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "service_requests_author_created_idx"
	ON "service_requests" ("author_id", "created_at", "id");
--> statement-breakpoint
DROP INDEX IF EXISTS "service_requests_author_idx";
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "citizen_reports_created_idx"
	ON "citizen_reports" ("created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "citizen_reports_author_created_idx"
	ON "citizen_reports" ("author_id", "created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "citizen_reports_status_created_idx"
	ON "citizen_reports" ("status", "created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "transparency_items_list_order_idx"
	ON "transparency_items" ("published_at", "created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "discover_gubat_entries_list_order_idx"
	ON "discover_gubat_entries" ("published_at", "created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "emergency_broadcasts_created_idx"
	ON "emergency_broadcasts" ("created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "audit_logs_created_idx"
	ON "audit_logs" ("created_at", "id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "notifications_user_created_idx"
	ON "notifications" ("user_id", "created_at", "id");
