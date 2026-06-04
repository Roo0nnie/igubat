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
		.$type<"registered_citizen" | "frontline_officer" | "department_supervisor" | "content_editor" | "emergency_operator" | "ict_admin" | "super_admin">(),
	departmentId: t.integer("department_id"),
	// Citizen profile captured at registration (mobile app). Persisted via
	// Better Auth `additionalFields` so the sign-up payload is stored rather
	// than dropped. Nullable because staff/seeded accounts do not supply them.
	mobileNumber: t.text("mobile_number"),
	barangay: t.text("barangay"),
	address: t.text("address"),
	// Explicit Data Privacy Act (RA 10173) consent given at registration.
	dpaConsent: t.boolean("dpa_consent").notNull().default(false),
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
	body: t.text("body").notNull(),
	category: t.text("category").notNull(),
	status: t
		.text("status")
		.notNull()
		.default("draft")
		.$type<"draft" | "published" | "archived">(),
	imageUrl: t.text("image_url"),
	authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
	publishedAt: t.timestamp("published_at"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
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
	latitude: t.numeric("latitude"),
	longitude: t.numeric("longitude"),
	authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// EMERGENCY DIRECTORY
// ============================================================================

export const emergencyDirectory = createTable("emergency_directory", t => ({
	id: t.serial("id").primaryKey(),
	name: t.text("name").notNull(),
	type: t
		.text("type")
		.notNull()
		.$type<"hospital" | "bfp" | "police" | "comcen">(),
	contactNumber: t.text("contact_number").notNull(),
	address: t.text("address"),
	isActive: t.boolean("is_active").notNull().default(true),
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
	serviceType: t.text("service_type").notNull(),
	description: t.text("description").notNull(),
	preferredDate: t.timestamp("preferred_date"),
	status: t
		.text("status")
		.notNull()
		.default("pending")
		.$type<"pending" | "in_review" | "approved" | "rejected" | "for_pickup" | "completed">(),
	departmentId: t.integer("department_id").references(() => departments.id, { onDelete: "set null" }),
	assignedOfficerId: t.text("assigned_officer_id").references(() => users.id, { onDelete: "set null" }),
	authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const serviceRequestAttachments = createTable("service_request_attachments", t => ({
	id: t.serial("id").primaryKey(),
	serviceRequestId: t.integer("service_request_id").notNull().references(() => serviceRequests.id, { onDelete: "cascade" }),
	fileUrl: t.text("file_url").notNull(),
	fileName: t.text("file_name").notNull(),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// WORKFLOW TEMPLATES
// ============================================================================

export const workflowTemplates = createTable("workflow_templates", t => ({
	id: t.serial("id").primaryKey(),
	serviceType: t.text("service_type").notNull().unique(),
	departmentId: t.integer("department_id").references(() => departments.id, { onDelete: "set null" }),
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
	isRead: t.boolean("is_read").notNull().default(false),
	metadata: t.json("metadata"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
}))

// ============================================================================
// RELATIONS
// ============================================================================
export const relations = defineRelations({ users, sessions, accounts, todos, tickets, newsArticles, citizenReports, emergencyDirectory, departments, serviceRequests, serviceRequestAttachments, workflowTemplates, auditLogs, notifications }, r => ({
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
	citizenReports: {
		author: r.one.users({
			from: r.citizenReports.authorId,
			to: r.users.id,
		}),
	},
}))

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
		citizenReports,
		emergencyDirectory,
		departments,
		serviceRequests,
		serviceRequestAttachments,
		workflowTemplates,
		auditLogs,
		notifications,
	},
	relations
)
