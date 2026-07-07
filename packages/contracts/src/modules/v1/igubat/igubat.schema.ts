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
	category: z.enum([
		"news",
		"service_request",
		"issue_report",
		"emergency",
		"general",
		"discover_gubat",
		"transparency",
	]),
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
	discoverGubat: z.boolean(),
	transparency: z.boolean(),
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

// ============================================================================
// TRANSPARENCY & GOOD GOVERNANCE (Module 13)
// ============================================================================

export const TransparencyTypeSchema = z.enum([
	"program_project",
	"bid_procurement",
	"financial_report",
	"annual_budget",
	"legislative_ordinance",
	"executive_order",
])

export const TransparencyStatusSchema = z.enum(["draft", "scheduled", "published", "archived"])

/**
 * Per-type required fields stored in the item `metadata` JSON column. Modelled
 * as a discriminated union on `type` so the admin editor and the backend
 * validate exactly the fields the canonical spec requires for each type.
 */
export const TransparencyMetadataSchema = z.discriminatedUnion("type", [
	z.object({
		type: z.literal("program_project"),
		projectStatus: z.enum(["planned", "ongoing", "completed", "suspended"]),
		startDate: z.string(),
		endDate: z.string().optional(),
		costPhp: z.number().nonnegative(),
		implementingOffice: z.string().min(1),
		beneficiaries: z.string().optional(),
		locationAddress: z.string().optional(),
	}),
	z.object({
		type: z.literal("bid_procurement"),
		approvedBudgetForContractPhp: z.number().nonnegative(),
		procurementMode: z.enum(["public_bidding", "small_value", "shopping", "negotiated"]),
		closingDate: z.string(),
		awardedTo: z.string().optional(),
		awardedAmountPhp: z.number().nonnegative().optional(),
		bidStatus: z.enum(["posted", "pre_bid", "open", "awarded", "cancelled"]),
	}),
	z.object({
		type: z.literal("financial_report"),
		reportType: z.enum(["saob", "sre", "coa_annual", "quarterly_financial_statement", "other"]),
		fiscalPeriod: z.string(),
		preparedBy: z.string().optional(),
	}),
	z.object({
		type: z.literal("annual_budget"),
		budgetType: z.enum(["annual", "supplemental", "executive_budget"]),
		totalAmountPhp: z.number().nonnegative(),
		endorsedBy: z.string().optional(),
	}),
	z.object({
		type: z.literal("legislative_ordinance"),
		dateApproved: z.string(),
		principalAuthor: z.string(),
		sponsors: z.string().optional(),
		sbSessionDate: z.string().optional(),
	}),
	z.object({
		type: z.literal("executive_order"),
		dateIssued: z.string(),
		issuedBy: z.string(),
		revokes: z.string().optional(),
	}),
])

export const TransparencyAttachmentSchema = z.object({
	id: z.number(),
	fileName: z.string(),
	fileUrl: z.string(),
	mimeType: z.string(),
	sizeBytes: z.number(),
	sortOrder: z.number(),
})

export const TransparencyItemSummarySchema = z.object({
	id: z.number(),
	type: TransparencyTypeSchema,
	referenceNumber: z.string().nullable(),
	title: z.string(),
	slug: z.string().nullable(),
	summary: z.string().nullable(),
	fiscalYear: z.number().nullable(),
	effectiveDate: DateLikeSchema.nullable(),
	barangay: z.string().nullable(),
	status: TransparencyStatusSchema,
	coverImageUrl: z.string().nullable(),
	authorId: z.string().nullable(),
	scheduledAt: DateLikeSchema.nullable(),
	publishedAt: DateLikeSchema.nullable(),
	archivedAt: DateLikeSchema.nullable(),
	createdAt: DateLikeSchema,
	updatedAt: DateLikeSchema,
	authorName: z.string().nullable().optional(),
})

export const TransparencyItemDetailSchema = TransparencyItemSummarySchema.extend({
	body: z.string(),
	metadata: TransparencyMetadataSchema.nullable(),
	notifyOnPublish: z.boolean(),
	attachments: z.array(TransparencyAttachmentSchema),
})

const TransparencyAttachmentInputSchema = z.object({
	fileName: z.string().min(1),
	fileUrl: z.string().min(1),
	mimeType: z.enum(["application/pdf", "image/jpeg", "image/png"]),
	sizeBytes: z
		.number()
		.int()
		.nonnegative()
		.max(10 * 1024 * 1024, "Attachments must be <= 10 MB"),
	sortOrder: z.number().int().nonnegative().optional(),
})

const TransparencyItemInputSchema = z.object({
	type: TransparencyTypeSchema,
	referenceNumber: z.string().optional(),
	title: z.string().min(1),
	summary: z.string().optional(),
	body: z.string().optional(),
	fiscalYear: z.number().int().optional(),
	effectiveDate: z.string().optional(),
	barangay: z.string().optional(),
	coverImageUrl: z.string().optional(),
	metadata: TransparencyMetadataSchema,
	status: TransparencyStatusSchema.optional(),
	notifyOnPublish: z.boolean().optional(),
	scheduledAt: z.string().optional(),
	attachments: z.array(TransparencyAttachmentInputSchema).max(10).optional(),
})

function assertMatchingTransparencyMetadataType(
	input: {
		type?: z.infer<typeof TransparencyTypeSchema>
		metadata?: z.infer<typeof TransparencyMetadataSchema>
	},
	ctx: z.RefinementCtx
) {
	if (input.type && input.metadata && input.type !== input.metadata.type) {
		ctx.addIssue({
			code: "custom",
			path: ["metadata", "type"],
			message: "metadata.type must match type",
		})
	}
}

export const CreateTransparencyItemSchema = TransparencyItemInputSchema.superRefine(
	assertMatchingTransparencyMetadataType
)

export const UpdateTransparencyItemSchema = TransparencyItemInputSchema.partial()
	.extend({
		id: z.coerce.number().int().positive(),
	})
	.superRefine(assertMatchingTransparencyMetadataType)

export const TransparencyListQuerySchema = z
	.object({
		type: TransparencyTypeSchema.optional(),
		status: TransparencyStatusSchema.optional(),
		fiscalYear: z.coerce.number().int().optional(),
		barangay: z.string().optional(),
		search: z.string().optional(),
		limit: z.coerce.number().int().positive().max(100).optional(),
		cursor: z.coerce.number().int().nonnegative().optional(),
	})
	.optional()

export const PublishTransparencyItemSchema = IdParamSchema.extend({
	notifySubscribers: z.boolean(),
	publishAt: z.string().optional(),
})

const QueryBooleanSchema = z.preprocess(value => {
	if (typeof value === "boolean") return value
	if (typeof value !== "string") return value

	const normalized = value.trim().toLowerCase()
	if (["true", "1", "yes", "on"].includes(normalized)) return true
	if (["false", "0", "no", "off", ""].includes(normalized)) return false

	return value
}, z.boolean())

export const DeleteTransparencyItemSchema = IdParamSchema.extend({
	permanent: QueryBooleanSchema.optional(),
})

// ============================================================================
// DISCOVER GUBAT (Module 12)
// ============================================================================

export const DiscoverGubatTypeSchema = z.enum(["tourist_spot", "festival_culture", "local_product"])

export const DiscoverGubatStatusSchema = z.enum(["draft", "scheduled", "published", "archived"])

export const DiscoverGubatMetadataSchema = z.discriminatedUnion("type", [
	z.object({
		type: z.literal("tourist_spot"),
		mapLocation: z.string().min(1),
		latitude: z.number().optional(),
		longitude: z.number().optional(),
		bestFor: z.string().optional(),
		travelNote: z.string().optional(),
	}),
	z.object({
		type: z.literal("festival_culture"),
		cultureKind: z.enum(["festival", "heritage", "history", "tradition", "language"]).optional(),
		eventDate: z.string().optional(),
		culturalNote: z.string().optional(),
	}),
	z.object({
		type: z.literal("local_product"),
		productKind: z
			.enum(["delicacy", "pasalubong", "handicraft", "seafood", "pili_product"])
			.optional(),
		whereToBuy: z.string().min(1),
		pasalubongNote: z.string().optional(),
	}),
])

export const DiscoverGubatPhotoSchema = z.object({
	id: z.number(),
	imageUrl: z.string(),
	altText: z.string().nullable(),
	sortOrder: z.number(),
})

export const DiscoverGubatEntrySummarySchema = z.object({
	id: z.number(),
	type: DiscoverGubatTypeSchema,
	title: z.string(),
	slug: z.string().nullable(),
	summary: z.string().nullable(),
	category: z.string(),
	status: DiscoverGubatStatusSchema,
	coverImageUrl: z.string().nullable(),
	mapLocation: z.string().nullable(),
	whereToBuy: z.string().nullable(),
	eventDate: DateLikeSchema.nullable(),
	authorId: z.string().nullable(),
	scheduledAt: DateLikeSchema.nullable(),
	publishedAt: DateLikeSchema.nullable(),
	archivedAt: DateLikeSchema.nullable(),
	createdAt: DateLikeSchema,
	updatedAt: DateLikeSchema,
	authorName: z.string().nullable().optional(),
})

export const DiscoverGubatEntryDetailSchema = DiscoverGubatEntrySummarySchema.extend({
	body: z.string(),
	metadata: DiscoverGubatMetadataSchema.nullable(),
	notifyOnPublish: z.boolean(),
	photos: z.array(DiscoverGubatPhotoSchema),
})

const DiscoverGubatPhotoInputSchema = z.object({
	imageUrl: z.string().min(1),
	altText: z.string().optional(),
	sortOrder: z.number().int().nonnegative().optional(),
})

const DiscoverGubatEntryInputSchema = z.object({
	type: DiscoverGubatTypeSchema,
	title: z.string().min(1),
	summary: z.string().optional(),
	body: z.string().optional(),
	category: z.string().min(1),
	coverImageUrl: z.string().optional(),
	mapLocation: z.string().optional(),
	whereToBuy: z.string().optional(),
	eventDate: z.string().optional(),
	metadata: DiscoverGubatMetadataSchema,
	status: DiscoverGubatStatusSchema.optional(),
	notifyOnPublish: z.boolean().optional(),
	scheduledAt: z.string().optional(),
	photos: z.array(DiscoverGubatPhotoInputSchema).max(10).optional(),
})

function assertMatchingDiscoverGubatMetadataType(
	input: {
		type?: z.infer<typeof DiscoverGubatTypeSchema>
		metadata?: z.infer<typeof DiscoverGubatMetadataSchema>
	},
	ctx: z.RefinementCtx
) {
	if (input.type && input.metadata && input.type !== input.metadata.type) {
		ctx.addIssue({
			code: "custom",
			path: ["metadata", "type"],
			message: "metadata.type must match type",
		})
	}
}

export const CreateDiscoverGubatEntrySchema = DiscoverGubatEntryInputSchema.superRefine(
	assertMatchingDiscoverGubatMetadataType
)

export const UpdateDiscoverGubatEntrySchema = DiscoverGubatEntryInputSchema.partial()
	.extend({
		id: z.coerce.number().int().positive(),
	})
	.superRefine(assertMatchingDiscoverGubatMetadataType)

export const DiscoverGubatListQuerySchema = z
	.object({
		type: DiscoverGubatTypeSchema.optional(),
		status: DiscoverGubatStatusSchema.optional(),
		category: z.string().optional(),
		search: z.string().optional(),
		limit: z.coerce.number().int().positive().max(100).optional(),
		cursor: z.coerce.number().int().nonnegative().optional(),
	})
	.optional()

export const PublishDiscoverGubatEntrySchema = IdParamSchema.extend({
	notifySubscribers: z.boolean(),
	publishAt: z.string().optional(),
})

export const DeleteDiscoverGubatEntrySchema = IdParamSchema.extend({
	permanent: QueryBooleanSchema.optional(),
})
