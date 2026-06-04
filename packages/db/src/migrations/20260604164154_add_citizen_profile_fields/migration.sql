ALTER TABLE "users" ADD COLUMN "mobile_number" text;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "barangay" text;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "address" text;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "dpa_consent" boolean DEFAULT false NOT NULL;