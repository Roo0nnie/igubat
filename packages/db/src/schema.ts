import { defineRelations } from "drizzle-orm"
import { index, primaryKey } from "drizzle-orm/pg-core"

import { createTable } from "./utils/table.js"

// ============================================================================
// BETTER AUTH TABLES
// ============================================================================

export const users = createTable("users", t => ({
	id: t.text("id").primaryKey(),
	name: t.text("name").notNull(),
	email: t.text("email").notNull().unique(),
	emailVerified: t.boolean("email_verified").default(false).notNull(),
	image: t.text("image"),
	role: t
		.text("role")
		.notNull()
		.default("registered_citizen")
		.$type<
			| "registered_citizen"
			| "frontline_officer"
			| "department_supervisor"
			| "content_editor"
			| "emergency_operator"
			| "ict_admin"
			| "super_admin"
		>(),
	status: t.text("status").notNull().default("active").$type<"active" | "locked" | "deactivated">(),
	departmentId: t.integer("department_id"),
	// Citizen profile captured at registration (mobile app). Persisted via
	// Better Auth `additionalFields` so the sign-up payload is stored rather
	// than dropped. Nullable because staff/seeded accounts do not supply them.
	mobileNumber: t.text("mobile_number"),
	barangay: t.text("barangay"),
	address: t.text("address"),
	// Explicit Data Privacy Act (RA 10173) consent given at registration.
	dpaConsent: t.boolean("dpa_consent").notNull().default(false),
	failedLoginAttempts: t.integer("failed_login_attempts").notNull().default(0),
	lockedUntil: t.timestamp("locked_until"),
	forcePasswordReset: t.boolean("force_password_reset").notNull().default(false),
	lastLoginAt: t.timestamp("last_login_at"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const sessions = createTable("sessions", t => ({
	id: t.text("id").primaryKey(),
	token: t.text("token").notNull().unique(),
	userId: t
		.text("user_id")
		.notNull()
		.references(() => users.id, { onDelete: "cascade" }),
	expiresAt: t.timestamp("expires_at").notNull(),
	ipAddress: t.text("ip_address"),
	userAgent: t.text("user_agent"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const accounts = createTable(
	"accounts",
	t => ({
		id: t.text("id"),
		accountId: t.text("account_id").notNull(),
		providerId: t.text("provider_id").notNull(),
		userId: t
			.text("user_id")
			.notNull()
			.references(() => users.id, { onDelete: "cascade" }),
		accessToken: t.text("access_token"),
		refreshToken: t.text("refresh_token"),
		idToken: t.text("id_token"),
		accessTokenExpiresAt: t.timestamp("access_token_expires_at"),
		refreshTokenExpiresAt: t.timestamp("refresh_token_expires_at"),
		scope: t.text("scope"),
		password: t.text("password"), // For email/password auth
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
		updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
	}),
	t => [
		// Composite primary key on provider and account
		primaryKey({ columns: [t.providerId, t.accountId] }),
		index("account_user_id_idx").on(t.userId),
	]
)

export const verifications = createTable(
	"verifications",
	t => ({
		id: t.text("id"),
		identifier: t.text("identifier").notNull(),
		value: t.text("value").notNull(),
		expiresAt: t.timestamp("expires_at").notNull(),
		createdAt: t.timestamp("created_at").defaultNow(),
		updatedAt: t.timestamp("updated_at").defaultNow(),
	}),
	t => [
		// Composite primary key on identifier and value
		primaryKey({ columns: [t.identifier, t.value] }),
	]
)

// ============================================================================
// TODOs
// ============================================================================

export const todos = createTable("todos", t => ({
	id: t.serial("id").primaryKey(),
	title: t.text("title").notNull(),
	completed: t.boolean("completed").notNull().default(false),
	authorId: t
		.text("author_id")
		.notNull()
		.references(() => users.id, { onDelete: "cascade" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// TICKETS
// ============================================================================

export const tickets = createTable("tickets", t => ({
	id: t.serial("id").primaryKey(),
	name: t.text("name").notNull(),
	email: t.text("email").notNull(),
	subject: t.text("subject").notNull(),
	priority: t
		.text("priority")
		.notNull()
		.default("medium")
		.$type<"low" | "medium" | "high" | "urgent">(),
	concern: t.text("concern").notNull(),
	status: t
		.text("status")
		.notNull()
		.default("received")
		.$type<"received" | "in_progress" | "resolved" | "closed">(),
	authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// NEWS ARTICLES
// ============================================================================

export const newsArticles = createTable("news_articles", t => ({
	id: t.serial("id").primaryKey(),
	title: t.text("title").notNull(),
	slug: t.text("slug").unique(),
	excerpt: t.text("excerpt"),
	body: t.text("body").notNull(),
	category: t.text("category").notNull(),
	status: t.text("status").notNull().default("draft").$type<"draft" | "published" | "archived">(),
	imageUrl: t.text("image_url"),
	isFeatured: t.boolean("is_featured").notNull().default(false),
	authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
	scheduledAt: t.timestamp("scheduled_at"),
	publishedAt: t.timestamp("published_at"),
	archivedAt: t.timestamp("archived_at"),
	deletedAt: t.timestamp("deleted_at"),
	metadata: t.json("metadata"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const contentPlacements = createTable("content_placements", t => ({
	id: t.serial("id").primaryKey(),
	type: t.text("type").notNull().$type<"carousel" | "banner">(),
	title: t.text("title").notNull(),
	imageUrl: t.text("image_url").notNull(),
	linkType: t
		.text("link_type")
		.notNull()
		.default("none")
		.$type<"none" | "article" | "service" | "event" | "external">(),
	linkTarget: t.text("link_target"),
	sortOrder: t.integer("sort_order").notNull().default(0),
	isActive: t.boolean("is_active").notNull().default(true),
	startsAt: t.timestamp("starts_at"),
	endsAt: t.timestamp("ends_at"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const events = createTable("events", t => ({
	id: t.serial("id").primaryKey(),
	title: t.text("title").notNull(),
	slug: t.text("slug").notNull().unique(),
	description: t.text("description").notNull(),
	category: t.text("category").notNull(),
	location: t.text("location").notNull(),
	imageUrl: t.text("image_url"),
	status: t
		.text("status")
		.notNull()
		.default("published")
		.$type<"draft" | "published" | "archived">(),
	startsAt: t.timestamp("starts_at").notNull(),
	endsAt: t.timestamp("ends_at"),
	publishedAt: t.timestamp("published_at"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// TRANSPARENCY & GOOD GOVERNANCE (Module 13)
// ============================================================================

/**
 * The six Full Disclosure Policy content types surfaced on the mobile
 * Transparency & Good Governance section. Stored as a text column with a
 * `$type` narrowing so the same enum is shared by the public list query,
 * the admin CMS, and the per-type `metadata` validators.
 */
export type TransparencyType =
	| "program_project"
	| "bid_procurement"
	| "financial_report"
	| "annual_budget"
	| "legislative_ordinance"
	| "executive_order"

export const transparencyItems = createTable(
	"transparency_items",
	t => ({
		id: t.serial("id").primaryKey(),
		type: t.text("type").notNull().$type<TransparencyType>(),
		referenceNumber: t.text("reference_number"),
		title: t.text("title").notNull(),
		slug: t.text("slug").unique(),
		summary: t.text("summary"),
		body: t.text("body").notNull().default(""),
		fiscalYear: t.integer("fiscal_year"),
		effectiveDate: t.timestamp("effective_date"),
		barangay: t.text("barangay"),
		status: t
			.text("status")
			.notNull()
			.default("draft")
			.$type<"draft" | "scheduled" | "published" | "archived">(),
		metadata: t.json("metadata"),
		coverImageUrl: t.text("cover_image_url"),
		authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
		// Snapshot of the "Notify subscribers" CMS checkbox at publish time.
		notifyOnPublish: t.boolean("notify_on_publish").notNull().default(false),
		scheduledAt: t.timestamp("scheduled_at"),
		publishedAt: t.timestamp("published_at"),
		archivedAt: t.timestamp("archived_at"),
		deletedAt: t.timestamp("deleted_at"),
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
		updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
	}),
	t => [
		// Drives the public/admin list query: filter by type + status, newest first.
		index("transparency_items_type_status_published_idx").on(t.type, t.status, t.publishedAt),
		index("transparency_items_fiscal_year_idx").on(t.fiscalYear),
	]
)

export const transparencyAttachments = createTable("transparency_attachments", t => ({
	id: t.serial("id").primaryKey(),
	transparencyItemId: t
		.integer("transparency_item_id")
		.notNull()
		.references(() => transparencyItems.id, { onDelete: "cascade" }),
	fileUrl: t.text("file_url").notNull(),
	fileName: t.text("file_name").notNull(),
	mimeType: t.text("mime_type").notNull().default("application/pdf"),
	sizeBytes: t.integer("size_bytes").notNull().default(0),
	sortOrder: t.integer("sort_order").notNull().default(0),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// DISCOVER GUBAT (Module 12)
// ============================================================================

export type DiscoverGubatType = "tourist_spot" | "festival_culture" | "local_product"

export const discoverGubatEntries = createTable(
	"discover_gubat_entries",
	t => ({
		id: t.serial("id").primaryKey(),
		type: t.text("type").notNull().$type<DiscoverGubatType>(),
		title: t.text("title").notNull(),
		slug: t.text("slug").unique(),
		summary: t.text("summary"),
		body: t.text("body").notNull().default(""),
		category: t.text("category").notNull(),
		status: t
			.text("status")
			.notNull()
			.default("draft")
			.$type<"draft" | "scheduled" | "published" | "archived">(),
		coverImageUrl: t.text("cover_image_url"),
		mapLocation: t.text("map_location"),
		whereToBuy: t.text("where_to_buy"),
		eventDate: t.timestamp("event_date"),
		metadata: t.json("metadata"),
		authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
		notifyOnPublish: t.boolean("notify_on_publish").notNull().default(false),
		scheduledAt: t.timestamp("scheduled_at"),
		publishedAt: t.timestamp("published_at"),
		archivedAt: t.timestamp("archived_at"),
		deletedAt: t.timestamp("deleted_at"),
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
		updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
	}),
	t => [
		index("discover_gubat_entries_type_status_published_idx").on(t.type, t.status, t.publishedAt),
		index("discover_gubat_entries_category_idx").on(t.category),
	]
)

export const discoverGubatPhotos = createTable("discover_gubat_photos", t => ({
	id: t.serial("id").primaryKey(),
	discoverGubatEntryId: t
		.integer("discover_gubat_entry_id")
		.notNull()
		.references(() => discoverGubatEntries.id, { onDelete: "cascade" }),
	imageUrl: t.text("image_url").notNull(),
	altText: t.text("alt_text"),
	sortOrder: t.integer("sort_order").notNull().default(0),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// CITIZEN REPORTS
// ============================================================================

export const citizenReports = createTable("citizen_reports", t => ({
	id: t.serial("id").primaryKey(),
	category: t.text("category").notNull(),
	description: t.text("description").notNull(),
	status: t
		.text("status")
		.notNull()
		.default("received")
		.$type<"received" | "in_progress" | "resolved" | "closed">(),
	barangay: t.text("barangay"),
	locationAddress: t.text("location_address"),
	latitude: t.numeric("latitude"),
	longitude: t.numeric("longitude"),
	publicRemarks: t.text("public_remarks"),
	internalNotes: t.text("internal_notes"),
	departmentId: t.integer("department_id"),
	assignedOfficerId: t
		.text("assigned_officer_id")
		.references(() => users.id, { onDelete: "set null" }),
	authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const citizenReportAttachments = createTable("citizen_report_attachments", t => ({
	id: t.serial("id").primaryKey(),
	citizenReportId: t
		.integer("citizen_report_id")
		.notNull()
		.references(() => citizenReports.id, { onDelete: "cascade" }),
	fileUrl: t.text("file_url").notNull(),
	fileName: t.text("file_name").notNull(),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

export const citizenReportStatusHistory = createTable("citizen_report_status_history", t => ({
	id: t.serial("id").primaryKey(),
	citizenReportId: t
		.integer("citizen_report_id")
		.notNull()
		.references(() => citizenReports.id, { onDelete: "cascade" }),
	status: t.text("status").notNull().$type<"received" | "in_progress" | "resolved" | "closed">(),
	remarks: t.text("remarks"),
	visibility: t.text("visibility").notNull().default("public").$type<"public" | "internal">(),
	changedById: t.text("changed_by_id").references(() => users.id, { onDelete: "set null" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// EMERGENCY DIRECTORY
// ============================================================================

export const emergencyDirectory = createTable("emergency_directory", t => ({
	id: t.serial("id").primaryKey(),
	name: t.text("name").notNull(),
	type: t.text("type").notNull().$type<"hospital" | "bfp" | "police" | "comcen">(),
	contactNumber: t.text("contact_number").notNull(),
	address: t.text("address"),
	hours: t.text("hours"),
	isActive: t.boolean("is_active").notNull().default(true),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const emergencyBroadcasts = createTable("emergency_broadcasts", t => ({
	id: t.serial("id").primaryKey(),
	title: t.text("title").notNull(),
	message: t.text("message").notNull(),
	severity: t
		.text("severity")
		.notNull()
		.default("warning")
		.$type<"info" | "warning" | "critical">(),
	status: t
		.text("status")
		.notNull()
		.default("draft")
		.$type<"draft" | "scheduled" | "sent" | "cancelled">(),
	scheduledAt: t.timestamp("scheduled_at"),
	sentAt: t.timestamp("sent_at"),
	senderId: t.text("sender_id").references(() => users.id, { onDelete: "set null" }),
	recipientCount: t.integer("recipient_count").notNull().default(0),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// DEPARTMENTS
// ============================================================================

export const departments = createTable("departments", t => ({
	id: t.serial("id").primaryKey(),
	name: t.text("name").notNull(),
	description: t.text("description"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// SERVICE REQUESTS
// ============================================================================

export const serviceRequests = createTable("service_requests", t => ({
	id: t.serial("id").primaryKey(),
	trackingNumber: t.text("tracking_number").notNull().unique(),
	serviceTypeId: t.integer("service_type_id"),
	serviceType: t.text("service_type").notNull(),
	description: t.text("description").notNull(),
	preferredDate: t.timestamp("preferred_date"),
	status: t
		.text("status")
		.notNull()
		.default("pending")
		.$type<"pending" | "in_review" | "approved" | "rejected" | "for_pickup" | "completed">(),
	departmentId: t
		.integer("department_id")
		.references(() => departments.id, { onDelete: "set null" }),
	assignedOfficerId: t
		.text("assigned_officer_id")
		.references(() => users.id, { onDelete: "set null" }),
	authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
	contactSnapshot: t.json("contact_snapshot"),
	publicRemarks: t.text("public_remarks"),
	internalNotes: t.text("internal_notes"),
	cancelledAt: t.timestamp("cancelled_at"),
	cancellationReason: t.text("cancellation_reason"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// SERVICE CATALOG
// ============================================================================

export const serviceCategories = createTable("service_categories", t => ({
	id: t.serial("id").primaryKey(),
	name: t.text("name").notNull(),
	slug: t.text("slug").notNull().unique(),
	description: t.text("description"),
	sortOrder: t.integer("sort_order").notNull().default(0),
	isActive: t.boolean("is_active").notNull().default(true),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const serviceTypes = createTable("service_types", t => ({
	id: t.serial("id").primaryKey(),
	categoryId: t
		.integer("category_id")
		.references(() => serviceCategories.id, { onDelete: "set null" }),
	name: t.text("name").notNull(),
	slug: t.text("slug").notNull().unique(),
	description: t.text("description").notNull(),
	requirements: t.json("requirements"),
	formFields: t.json("form_fields"),
	workflowSteps: t.json("workflow_steps"),
	processingDays: t.integer("processing_days").notNull().default(3),
	icon: t.text("icon").notNull().default("file-text"),
	imageUrl: t.text("image_url"),
	isPopular: t.boolean("is_popular").notNull().default(false),
	isActive: t.boolean("is_active").notNull().default(true),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const serviceRequestAttachments = createTable("service_request_attachments", t => ({
	id: t.serial("id").primaryKey(),
	serviceRequestId: t
		.integer("service_request_id")
		.notNull()
		.references(() => serviceRequests.id, { onDelete: "cascade" }),
	fileUrl: t.text("file_url").notNull(),
	fileName: t.text("file_name").notNull(),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

export const serviceRequestStatusHistory = createTable("service_request_status_history", t => ({
	id: t.serial("id").primaryKey(),
	serviceRequestId: t
		.integer("service_request_id")
		.notNull()
		.references(() => serviceRequests.id, { onDelete: "cascade" }),
	status: t
		.text("status")
		.notNull()
		.$type<"pending" | "in_review" | "approved" | "rejected" | "for_pickup" | "completed">(),
	remarks: t.text("remarks"),
	visibility: t.text("visibility").notNull().default("public").$type<"public" | "internal">(),
	changedById: t.text("changed_by_id").references(() => users.id, { onDelete: "set null" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// WORKFLOW TEMPLATES
// ============================================================================

export const workflowTemplates = createTable("workflow_templates", t => ({
	id: t.serial("id").primaryKey(),
	serviceType: t.text("service_type").notNull().unique(),
	departmentId: t
		.integer("department_id")
		.references(() => departments.id, { onDelete: "set null" }),
	steps: t.json("steps").notNull(),
	isActive: t.boolean("is_active").notNull().default(true),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// AUDIT LOGS
// ============================================================================

export const auditLogs = createTable("audit_logs", t => ({
	id: t.serial("id").primaryKey(),
	actorId: t.text("actor_id").references(() => users.id, { onDelete: "set null" }),
	actionType: t.text("action_type").notNull(),
	entityType: t.text("entity_type").notNull(),
	entityId: t.text("entity_id"),
	details: t.json("details"),
	ipAddress: t.text("ip_address"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// NOTIFICATIONS
// ============================================================================

export const notifications = createTable("notifications", t => ({
	id: t.serial("id").primaryKey(),
	userId: t.text("user_id").references(() => users.id, { onDelete: "cascade" }),
	title: t.text("title").notNull(),
	body: t.text("body").notNull(),
	type: t.text("type").notNull().default("in_app").$type<"in_app" | "push" | "email">(),
	category: t
		.text("category")
		.notNull()
		.default("general")
		.$type<
			| "news"
			| "service_request"
			| "issue_report"
			| "emergency"
			| "general"
			| "discover_gubat"
			| "transparency"
		>(),
	isRead: t.boolean("is_read").notNull().default(false),
	readAt: t.timestamp("read_at"),
	metadata: t.json("metadata"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

export const notificationPreferences = createTable("notification_preferences", t => ({
	id: t.serial("id").primaryKey(),
	userId: t
		.text("user_id")
		.notNull()
		.unique()
		.references(() => users.id, { onDelete: "cascade" }),
	news: t.boolean("news").notNull().default(true),
	serviceRequests: t.boolean("service_requests").notNull().default(true),
	issueReports: t.boolean("issue_reports").notNull().default(true),
	emergencyBroadcasts: t.boolean("emergency_broadcasts").notNull().default(true),
	discoverGubat: t.boolean("discover_gubat").notNull().default(true),
	transparency: t.boolean("transparency").notNull().default(true),
	pushEnabled: t.boolean("push_enabled").notNull().default(true),
	emailEnabled: t.boolean("email_enabled").notNull().default(true),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const notificationDeliveryLogs = createTable("notification_delivery_logs", t => ({
	id: t.serial("id").primaryKey(),
	notificationId: t
		.integer("notification_id")
		.references(() => notifications.id, { onDelete: "set null" }),
	userId: t.text("user_id").references(() => users.id, { onDelete: "set null" }),
	channel: t.text("channel").notNull().$type<"in_app" | "push" | "email" | "sms">(),
	status: t
		.text("status")
		.notNull()
		.default("queued")
		.$type<"queued" | "sent" | "failed" | "skipped">(),
	providerMessage: t.text("provider_message"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// SUPPORT, SETTINGS, MEDIA, AND ACTIVITY
// ============================================================================

export const mediaAssets = createTable("media_assets", t => ({
	id: t.serial("id").primaryKey(),
	fileName: t.text("file_name").notNull(),
	fileUrl: t.text("file_url").notNull(),
	mimeType: t.text("mime_type").notNull(),
	sizeBytes: t.integer("size_bytes").notNull().default(0),
	altText: t.text("alt_text"),
	folder: t.text("folder").notNull().default("general"),
	uploadedById: t.text("uploaded_by_id").references(() => users.id, { onDelete: "set null" }),
	deletedAt: t.timestamp("deleted_at"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const helpArticles = createTable("help_articles", t => ({
	id: t.serial("id").primaryKey(),
	slug: t.text("slug").notNull().unique(),
	title: t.text("title").notNull(),
	category: t.text("category").notNull(),
	content: t.text("content").notNull(),
	audience: t.text("audience").notNull().default("citizen").$type<"citizen" | "staff" | "all">(),
	sortOrder: t.integer("sort_order").notNull().default(0),
	isPublished: t.boolean("is_published").notNull().default(true),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const policyDocuments = createTable("policy_documents", t => ({
	id: t.serial("id").primaryKey(),
	slug: t.text("slug").notNull().unique(),
	title: t.text("title").notNull(),
	version: t.text("version").notNull().default("1.0"),
	content: t.text("content").notNull(),
	publishedAt: t.timestamp("published_at").notNull().defaultNow(),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const systemSettings = createTable("system_settings", t => ({
	id: t.serial("id").primaryKey(),
	key: t.text("key").notNull().unique(),
	category: t.text("category").notNull().default("application"),
	value: t.json("value").notNull(),
	isSecret: t.boolean("is_secret").notNull().default(false),
	updatedById: t.text("updated_by_id").references(() => users.id, { onDelete: "set null" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const userLoginActivity = createTable("user_login_activity", t => ({
	id: t.serial("id").primaryKey(),
	userId: t.text("user_id").references(() => users.id, { onDelete: "set null" }),
	identifier: t.text("identifier").notNull(),
	success: t.boolean("success").notNull().default(false),
	failureReason: t.text("failure_reason"),
	ipAddress: t.text("ip_address"),
	userAgent: t.text("user_agent"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// RELATIONS
// ============================================================================
export const relations = defineRelations(
	{
		users,
		sessions,
		accounts,
		todos,
		tickets,
		newsArticles,
		contentPlacements,
		events,
		transparencyItems,
		transparencyAttachments,
		discoverGubatEntries,
		discoverGubatPhotos,
		citizenReports,
		citizenReportAttachments,
		citizenReportStatusHistory,
		emergencyDirectory,
		emergencyBroadcasts,
		departments,
		serviceCategories,
		serviceTypes,
		serviceRequests,
		serviceRequestAttachments,
		serviceRequestStatusHistory,
		workflowTemplates,
		auditLogs,
		notifications,
		notificationPreferences,
		notificationDeliveryLogs,
		mediaAssets,
		helpArticles,
		policyDocuments,
		systemSettings,
		userLoginActivity,
	},
	r => ({
		users: {
			sessions: r.many.sessions(),
			accounts: r.many.accounts(),
			todos: r.many.todos(),
			tickets: r.many.tickets(),
			newsArticles: r.many.newsArticles(),
			citizenReports: r.many.citizenReports(),
			department: r.one.departments({
				from: r.users.departmentId,
				to: r.departments.id,
			}),
			serviceRequestsAuthored: r.many.serviceRequests({
				from: r.users.id,
				to: r.serviceRequests.authorId,
			}),
			serviceRequestsAssigned: r.many.serviceRequests({
				from: r.users.id,
				to: r.serviceRequests.assignedOfficerId,
			}),
			auditLogs: r.many.auditLogs(),
			notifications: r.many.notifications(),
		},
		departments: {
			users: r.many.users(),
			serviceRequests: r.many.serviceRequests(),
			workflowTemplates: r.many.workflowTemplates(),
		},
		serviceRequests: {
			author: r.one.users({
				from: r.serviceRequests.authorId,
				to: r.users.id,
			}),
			assignedOfficer: r.one.users({
				from: r.serviceRequests.assignedOfficerId,
				to: r.users.id,
			}),
			department: r.one.departments({
				from: r.serviceRequests.departmentId,
				to: r.departments.id,
			}),
			attachments: r.many.serviceRequestAttachments(),
		},
		serviceRequestAttachments: {
			serviceRequest: r.one.serviceRequests({
				from: r.serviceRequestAttachments.serviceRequestId,
				to: r.serviceRequests.id,
			}),
		},
		workflowTemplates: {
			department: r.one.departments({
				from: r.workflowTemplates.departmentId,
				to: r.departments.id,
			}),
		},
		auditLogs: {
			actor: r.one.users({
				from: r.auditLogs.actorId,
				to: r.users.id,
			}),
		},
		notifications: {
			user: r.one.users({
				from: r.notifications.userId,
				to: r.users.id,
			}),
		},
		sessions: {
			user: r.one.users({
				from: r.sessions.userId,
				to: r.users.id,
			}),
		},
		accounts: {
			user: r.one.users({
				from: r.accounts.userId,
				to: r.users.id,
			}),
		},
		todos: {
			author: r.one.users({
				from: r.todos.authorId,
				to: r.users.id,
			}),
		},
		tickets: {
			author: r.one.users({
				from: r.tickets.authorId,
				to: r.users.id,
			}),
		},
		newsArticles: {
			author: r.one.users({
				from: r.newsArticles.authorId,
				to: r.users.id,
			}),
		},
		transparencyItems: {
			author: r.one.users({
				from: r.transparencyItems.authorId,
				to: r.users.id,
			}),
			attachments: r.many.transparencyAttachments(),
		},
		transparencyAttachments: {
			transparencyItem: r.one.transparencyItems({
				from: r.transparencyAttachments.transparencyItemId,
				to: r.transparencyItems.id,
			}),
		},
		discoverGubatEntries: {
			author: r.one.users({
				from: r.discoverGubatEntries.authorId,
				to: r.users.id,
			}),
			photos: r.many.discoverGubatPhotos(),
		},
		discoverGubatPhotos: {
			discoverGubatEntry: r.one.discoverGubatEntries({
				from: r.discoverGubatPhotos.discoverGubatEntryId,
				to: r.discoverGubatEntries.id,
			}),
		},
		citizenReports: {
			author: r.one.users({
				from: r.citizenReports.authorId,
				to: r.users.id,
			}),
		},
	})
)

// ============================================================================
// SCHEMA
// ============================================================================
export const schema = Object.assign(
	{
		users,
		sessions,
		accounts,
		verifications,
		todos,
		tickets,
		newsArticles,
		contentPlacements,
		events,
		transparencyItems,
		transparencyAttachments,
		discoverGubatEntries,
		discoverGubatPhotos,
		citizenReports,
		citizenReportAttachments,
		citizenReportStatusHistory,
		emergencyDirectory,
		emergencyBroadcasts,
		departments,
		serviceCategories,
		serviceTypes,
		serviceRequests,
		serviceRequestAttachments,
		serviceRequestStatusHistory,
		workflowTemplates,
		auditLogs,
		notifications,
		notificationPreferences,
		notificationDeliveryLogs,
		mediaAssets,
		helpArticles,
		policyDocuments,
		systemSettings,
		userLoginActivity,
	},
	relations
)
