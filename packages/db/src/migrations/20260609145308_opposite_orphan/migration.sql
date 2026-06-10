-- Module 13 — Transparency & Good Governance
-- Adds two tables, the `transparency` notification-preference column, and the
-- supporting indexes / foreign keys. Incremental migration over the existing
-- schema (notifications.category gains "transparency" at the application layer
-- via the text column's $type narrowing — no DDL change required).

CREATE TABLE "transparency_items" (
	"id" serial PRIMARY KEY,
	"type" text NOT NULL,
	"reference_number" text,
	"title" text NOT NULL,
	"slug" text UNIQUE,
	"summary" text,
	"body" text DEFAULT '' NOT NULL,
	"fiscal_year" integer,
	"effective_date" timestamp,
	"barangay" text,
	"status" text DEFAULT 'draft' NOT NULL,
	"metadata" json,
	"cover_image_url" text,
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
CREATE TABLE "transparency_attachments" (
	"id" serial PRIMARY KEY,
	"transparency_item_id" integer NOT NULL,
	"file_url" text NOT NULL,
	"file_name" text NOT NULL,
	"mime_type" text DEFAULT 'application/pdf' NOT NULL,
	"size_bytes" integer DEFAULT 0 NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "notification_preferences" ADD COLUMN "transparency" boolean DEFAULT true NOT NULL;--> statement-breakpoint
CREATE INDEX "transparency_items_type_status_published_idx" ON "transparency_items" ("type","status","published_at");--> statement-breakpoint
CREATE INDEX "transparency_items_fiscal_year_idx" ON "transparency_items" ("fiscal_year");--> statement-breakpoint
ALTER TABLE "transparency_items" ADD CONSTRAINT "transparency_items_author_id_users_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE SET NULL;--> statement-breakpoint
ALTER TABLE "transparency_attachments" ADD CONSTRAINT "transparency_attachments_transparency_item_id_fkey" FOREIGN KEY ("transparency_item_id") REFERENCES "transparency_items"("id") ON DELETE CASCADE;
