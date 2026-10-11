-- Module 12 - Discover Gubat
-- Adds the tourism/culture/local-products content tables and notification
-- preference needed for opted-in publish alerts.

CREATE TABLE "discover_gubat_entries" (
	"id" serial PRIMARY KEY,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"slug" text UNIQUE,
	"summary" text,
	"body" text DEFAULT '' NOT NULL,
	"category" text NOT NULL,
	"status" text DEFAULT 'draft' NOT NULL,
	"cover_image_url" text,
	"map_location" text,
	"where_to_buy" text,
	"event_date" timestamp,
	"metadata" json,
	"author_id" text,
	"notify_on_publish" boolean DEFAULT false NOT NULL,
	"scheduled_at" timestamp,
	"published_at" timestamp,
	"archived_at" timestamp,
	"deleted_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "discover_gubat_photos" (
	"id" serial PRIMARY KEY,
	"discover_gubat_entry_id" integer NOT NULL,
	"image_url" text NOT NULL,
	"alt_text" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "notification_preferences" ADD COLUMN "discover_gubat" boolean DEFAULT true NOT NULL;
--> statement-breakpoint
CREATE INDEX "discover_gubat_entries_type_status_published_idx" ON "discover_gubat_entries" ("type","status","published_at");
--> statement-breakpoint
CREATE INDEX "discover_gubat_entries_category_idx" ON "discover_gubat_entries" ("category");
--> statement-breakpoint
ALTER TABLE "discover_gubat_entries" ADD CONSTRAINT "discover_gubat_entries_author_id_users_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE SET NULL;
--> statement-breakpoint
ALTER TABLE "discover_gubat_photos" ADD CONSTRAINT "discover_gubat_photos_discover_gubat_entry_id_fkey" FOREIGN KEY ("discover_gubat_entry_id") REFERENCES "discover_gubat_entries"("id") ON DELETE CASCADE;
