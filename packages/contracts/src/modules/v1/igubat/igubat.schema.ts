import { z } from "zod"

export const DateLikeSchema = z
	.union([z.date(), z.string()])
	.transform(value => (value instanceof Date ? value : new Date(value)))

export const IdParamSchema = z.object({
	id: z.coerce.number().int().positive(),
})

export const SlugParamSchema = z.object({
	slug: z.string().min(1),
})

export const ListQuerySchema = z
	.object({
		search: z.string().optional(),
		status: z.string().optional(),
		category: z.string().optional(),
		barangay: z.string().optional(),
		serviceType: z.string().optional(),
		dateFrom: z.string().optional(),
		dateTo: z.string().optional(),
		limit: z.coerce.number().int().positive().max(100).optional(),
	})
	.optional()

export const UserSummarySchema = z.object({
	id: z.string(),
	name: z.string(),
	email: z.string().email(),
	image: z.string().nullable().optional(),
	role: z.string(),
	status: z.string().optional(),
	mobileNumber: z.string().nullable().optional(),
	barangay: z.string().nullable().optional(),
	address: z.string().nullable().optional(),
	departmentId: z.number().nullable().optional(),
	createdAt: DateLikeSchema.optional(),
	lastLoginAt: DateLikeSchema.nullable().optional(),
	forcePasswordReset: z.boolean().optional(),
})

export const ServiceCategorySchema = z.object({
	id: z.number(),
	name: z.string(),
	slug: z.string(),
	description: z.string().nullable(),
	sortOrder: z.number(),
	isActive: z.boolean(),
})

export const ServiceTypeSchema = z.object({
	id: z.number(),
	categoryId: z.number().nullable(),
	name: z.string(),
	slug: z.string(),
	description: z.string(),
	requirements: z.unknown().nullable(),
	formFields: z.unknown().nullable(),
	workflowSteps: z.unknown().nullable(),
	processingDays: z.number(),
	icon: z.string(),
	imageUrl: z.string().nullable(),
	isPopular: z.boolean(),
	isActive: z.boolean(),
})

export const NewsArticleSchema = z.object({
	id: z.number(),
	title: z.string(),
	slug: z.string().nullable(),
	excerpt: z.string().nullable(),
	body: z.string(),
	category: z.string(),
	status: z.enum(["draft", "published", "archived"]),
	imageUrl: z.string().nullable(),
	isFeatured: z.boolean(),
	authorId: z.string().nullable(),
	scheduledAt: DateLikeSchema.nullable(),
	publishedAt: DateLikeSchema.nullable(),
	createdAt: DateLikeSchema,
	updatedAt: DateLikeSchema,
})

export const ContentPlacementSchema = z.object({
	id: z.number(),
	type: z.enum(["carousel", "banner"]),
	title: z.string(),
	imageUrl: z.string(),
	linkType: z.string(),
	linkTarget: z.string().nullable(),
	sortOrder: z.number(),
	isActive: z.boolean(),
})

export const EventSchema = z.object({
	id: z.number(),
	title: z.string(),
	slug: z.string(),
	description: z.string(),
	category: z.string(),
	location: z.string(),
	imageUrl: z.string().nullable(),
	status: z.enum(["draft", "published", "archived"]),
	startsAt: DateLikeSchema,
	endsAt: DateLikeSchema.nullable(),
})

export const EmergencyDirectorySchema = z.object({
	id: z.number(),
	name: z.string(),
	type: z.enum(["hospital", "bfp", "police", "comcen"]),
	contactNumber: z.string(),
	address: z.string().nullable(),
	hours: z.string().nullable(),
	isActive: z.boolean(),
})

export const EmergencyBroadcastSchema = z.object({
	id: z.number(),
	title: z.string(),
	message: z.string(),
	severity: z.enum(["info", "warning", "critical"]),
	status: z.enum(["draft", "scheduled", "sent", "cancelled"]),
	scheduledAt: DateLikeSchema.nullable(),
	sentAt: DateLikeSchema.nullable(),
	senderId: z.string().nullable(),
	recipientCount: z.number(),
	createdAt: DateLikeSchema,
})

export const ServiceRequestStatusSchema = z.enum([
	"pending",
	"in_review",
	"approved",
	"rejected",
	"for_pickup",
	"completed",
])

export const ServiceRequestSchema = z.object({
	id: z.number(),
	trackingNumber: z.string(),
	serviceTypeId: z.number().nullable(),
	serviceType: z.string(),
	description: z.string(),
	preferredDate: DateLikeSchema.nullable(),
	status: ServiceRequestStatusSchema,
	departmentId: z.number().nullable(),
	assignedOfficerId: z.string().nullable(),
	authorId: z.string().nullable(),
	publicRemarks: z.string().nullable(),
	internalNotes: z.string().nullable(),
	createdAt: DateLikeSchema,
	updatedAt: DateLikeSchema,
	citizenName: z.string().nullable().optional(),
	barangay: z.string().nullable().optional(),
})

export const RequestHistorySchema = z.object({
	id: z.number(),
	status: ServiceRequestStatusSchema,
	remarks: z.string().nullable(),
	visibility: z.enum(["public", "internal"]),
	changedById: z.string().nullable(),
	createdAt: DateLikeSchema,
})

export const ServiceRequestDetailSchema = ServiceRequestSchema.extend({
	attachments: z.array(
		z.object({
			id: z.number(),
			fileName: z.string(),
			fileUrl: z.string(),
		})
	),
	history: z.array(RequestHistorySchema),
})

export const CreateServiceRequestSchema = z.object({
	serviceTypeId: z.number().int().positive(),
	description: z.string().min(1),
	preferredDate: z.string().optional(),
	attachments: z
		.array(z.object({ fileName: z.string(), fileUrl: z.string() }))
		.max(3)
		.optional(),
})

export const UpdateRequestStatusSchema = IdParamSchema.extend({
	status: ServiceRequestStatusSchema,
	remarks: z.string().optional(),
	internalNotes: z.string().optional(),
})

export const CitizenReportStatusSchema = z.enum(["received", "in_progress", "resolved", "closed"])

export const CitizenReportSchema = z.object({
	id: z.number(),
	category: z.string(),
	description: z.string(),
	status: CitizenReportStatusSchema,
	barangay: z.string().nullable(),
	locationAddress: z.string().nullable(),
	latitude: z.string().nullable(),
	longitude: z.string().nullable(),
	publicRemarks: z.string().nullable(),
	internalNotes: z.string().nullable(),
	departmentId: z.number().nullable(),
	assignedOfficerId: z.string().nullable(),
	authorId: z.string().nullable(),
	createdAt: DateLikeSchema,
	updatedAt: DateLikeSchema,
	citizenName: z.string().nullable().optional(),
})

export const ReportHistorySchema = z.object({
	id: z.number(),
	status: CitizenReportStatusSchema,
	remarks: z.string().nullable(),
	visibility: z.enum(["public", "internal"]),
	changedById: z.string().nullable(),
	createdAt: DateLikeSchema,
})

export const CitizenReportDetailSchema = CitizenReportSchema.extend({
	attachments: z.array(z.object({ id: z.number(), fileName: z.string(), fileUrl: z.string() })),
	history: z.array(ReportHistorySchema),
})

export const CreateCitizenReportSchema = z.object({
	category: z.string().min(1),
	description: z.string().min(1),
	barangay: z.string().optional(),
	locationAddress: z.string().optional(),
	latitude: z.string().optional(),
	longitude: z.string().optional(),
	attachments: z
		.array(z.object({ fileName: z.string(), fileUrl: z.string() }))
		.max(3)
		.optional(),
})

export const UpdateReportStatusSchema = IdParamSchema.extend({
	status: CitizenReportStatusSchema,
	remarks: z.string().optional(),
	internalNotes: z.string().optional(),
})

export const NotificationSchema = z.object({
	id: z.number(),
	title: z.string(),
	body: z.string(),
	type: z.enum(["in_app", "push", "email"]),
	category: z.enum(["news", "service_request", "issue_report", "emergency", "general"]),
	isRead: z.boolean(),
	readAt: DateLikeSchema.nullable(),
	metadata: z.unknown().nullable(),
	createdAt: DateLikeSchema,
})

export const NotificationPreferenceSchema = z.object({
	news: z.boolean(),
	serviceRequests: z.boolean(),
	issueReports: z.boolean(),
	emergencyBroadcasts: z.boolean(),
	pushEnabled: z.boolean(),
	emailEnabled: z.boolean(),
})

export const HelpArticleSchema = z.object({
	id: z.number(),
	slug: z.string(),
	title: z.string(),
	category: z.string(),
	content: z.string(),
	audience: z.enum(["citizen", "staff", "all"]),
	sortOrder: z.number(),
})

export const PolicyDocumentSchema = z.object({
	id: z.number(),
	slug: z.string(),
	title: z.string(),
	version: z.string(),
	content: z.string(),
	publishedAt: DateLikeSchema,
})

export const AuditLogSchema = z.object({
	id: z.number(),
	actorId: z.string().nullable(),
	actionType: z.string(),
	entityType: z.string(),
	entityId: z.string().nullable(),
	details: z.unknown().nullable(),
	ipAddress: z.string().nullable(),
	createdAt: DateLikeSchema,
	actorName: z.string().nullable().optional(),
	actorRole: z.string().nullable().optional(),
})

export const SystemSettingSchema = z.object({
	id: z.number(),
	key: z.string(),
	category: z.string(),
	value: z.unknown(),
	isSecret: z.boolean(),
	updatedAt: DateLikeSchema,
})

export const DashboardSchema = z.object({
	totalUsers: z.number(),
	pendingRequests: z.number(),
	activeServices: z.number(),
	newReports: z.number(),
	publishedAnnouncements: z.number(),
	recentRequests: z.array(ServiceRequestSchema),
	recentReports: z.array(CitizenReportSchema),
	upcomingEvents: z.array(EventSchema),
})

export const AnalyticsSchema = z.object({
	users: z.number(),
	requests: z.number(),
	reports: z.number(),
	articles: z.number(),
	byRequestStatus: z.record(z.string(), z.number()),
	byReportStatus: z.record(z.string(), z.number()),
	byBarangay: z.record(z.string(), z.number()),
})

export const UpsertArticleSchema = z.object({
	id: z.number().int().positive().optional(),
	title: z.string().min(1),
	slug: z.string().min(1),
	excerpt: z.string().optional(),
	body: z.string().min(1),
	category: z.string().min(1),
	status: z.enum(["draft", "published", "archived"]),
	imageUrl: z.string().optional(),
	isFeatured: z.boolean().optional(),
	scheduledAt: z.string().optional(),
})

export const UpsertDirectoryEntrySchema = z.object({
	id: z.number().int().positive().optional(),
	name: z.string().min(1),
	type: z.enum(["hospital", "bfp", "police", "comcen"]),
	contactNumber: z.string().min(1),
	address: z.string().optional(),
	hours: z.string().optional(),
	isActive: z.boolean().optional(),
})

export const CreateBroadcastSchema = z.object({
	title: z.string().min(1),
	message: z.string().min(1).max(480),
	severity: z.enum(["info", "warning", "critical"]),
	scheduledAt: z.string().optional(),
	sendNow: z.boolean().optional(),
})

export const UpdateProfileSchema = z.object({
	name: z.string().min(1).optional(),
	mobileNumber: z.string().optional(),
	barangay: z.string().optional(),
	address: z.string().optional(),
	image: z.string().optional(),
})

export const UpsertSettingSchema = z.object({
	key: z.string().min(1),
	category: z.string().min(1),
	value: z.unknown(),
	isSecret: z.boolean().optional(),
})

export const CreateStaffSchema = z.object({
	name: z.string().min(1),
	email: z.string().email(),
	role: z.enum([
		"frontline_officer",
		"department_supervisor",
		"content_editor",
		"emergency_operator",
		"ict_admin",
	]),
	departmentId: z.number().int().positive().optional(),
})
