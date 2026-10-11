import { oc } from "@orpc/contract"
import { z } from "zod"

import {
	AnalyticsSchema,
	AuditLogSchema,
	CitizenReportDetailSchema,
	CitizenReportSchema,
	CommunityStatConfigSchema,
	ContentPlacementSchema,
	CreateBroadcastSchema,
	CreateCitizenReportSchema,
	CreateDiscoverGubatEntrySchema,
	CreateServiceRequestSchema,
	CreateStaffSchema,
	CreateTransparencyItemSchema,
	DashboardSchema,
	DeleteDiscoverGubatEntrySchema,
	DeleteTransparencyItemSchema,
	DiscoverGubatEntryDetailSchema,
	DiscoverGubatEntrySummarySchema,
	DiscoverGubatListQuerySchema,
	EmergencyBroadcastSchema,
	EmergencyDirectorySchema,
	EventSchema,
	HelpArticleSchema,
	IdParamSchema,
	ListQuerySchema,
	NewsArticleSchema,
	NotificationPreferenceSchema,
	NotificationSchema,
	PolicyDocumentSchema,
	PublishDiscoverGubatEntrySchema,
	PublishTransparencyItemSchema,
	ServiceCategorySchema,
	ServiceRequestDetailSchema,
	ServiceRequestSchema,
	ServiceTypeSchema,
	SlugParamSchema,
	SystemSettingSchema,
	TransparencyItemDetailSchema,
	TransparencyItemSummarySchema,
	TransparencyListQuerySchema,
	UpdateCommunityStatsSchema,
	UpdateDiscoverGubatEntrySchema,
	UpdateProfileSchema,
	UpdateReportStatusSchema,
	UpdateRequestStatusSchema,
	UpdateTransparencyItemSchema,
	UpsertArticleSchema,
	UpsertDirectoryEntrySchema,
	UpsertEventSchema,
	UpsertSettingSchema,
	UserSummarySchema,
} from "./igubat.schema.js"

export const igubatContract = oc.prefix("/igubat").router(
	oc.router({
		public: oc.prefix("/public").router(
			oc.router({
				dashboard: oc
					.route({
						method: "GET",
						path: "/dashboard",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.output(DashboardSchema),
				news: oc
					.route({
						method: "GET",
						path: "/news",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.input(ListQuerySchema)
					.output(z.array(NewsArticleSchema)),
				article: oc
					.route({
						method: "GET",
						path: "/news/{slug}",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.input(SlugParamSchema)
					.output(NewsArticleSchema),
				placements: oc
					.route({
						method: "GET",
						path: "/placements",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.output(z.array(ContentPlacementSchema)),
				events: oc
					.route({
						method: "GET",
						path: "/events",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.output(z.array(EventSchema)),
				event: oc
					.route({
						method: "GET",
						path: "/events/{slug}",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.input(SlugParamSchema)
					.output(EventSchema),
				serviceCategories: oc
					.route({
						method: "GET",
						path: "/service-categories",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.output(z.array(ServiceCategorySchema)),
				services: oc
					.route({
						method: "GET",
						path: "/services",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.input(ListQuerySchema)
					.output(z.array(ServiceTypeSchema)),
				service: oc
					.route({
						method: "GET",
						path: "/services/{slug}",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.input(SlugParamSchema)
					.output(ServiceTypeSchema),
				emergencyDirectory: oc
					.route({
						method: "GET",
						path: "/emergency-directory",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.output(z.array(EmergencyDirectorySchema)),
				help: oc
					.route({
						method: "GET",
						path: "/help",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.output(z.array(HelpArticleSchema)),
				policy: oc
					.route({
						method: "GET",
						path: "/policies/{slug}",
						tags: ["iGubat Public"],
						spec: spec => ({ ...spec, security: [] }),
					})
					.input(SlugParamSchema)
					.output(PolicyDocumentSchema),
				transparency: oc.router({
					list: oc
						.route({
							method: "GET",
							path: "/transparency",
							tags: ["iGubat Transparency"],
							spec: spec => ({ ...spec, security: [] }),
						})
						.input(TransparencyListQuerySchema)
						.output(z.array(TransparencyItemSummarySchema)),
					detail: oc
						.route({
							method: "GET",
							path: "/transparency/{slug}",
							tags: ["iGubat Transparency"],
							spec: spec => ({ ...spec, security: [] }),
						})
						.input(SlugParamSchema)
						.output(TransparencyItemDetailSchema),
				}),
				discoverGubat: oc.router({
					list: oc
						.route({
							method: "GET",
							path: "/discover-gubat",
							tags: ["iGubat Discover Gubat"],
							spec: spec => ({ ...spec, security: [] }),
						})
						.input(DiscoverGubatListQuerySchema)
						.output(z.array(DiscoverGubatEntrySummarySchema)),
					detail: oc
						.route({
							method: "GET",
							path: "/discover-gubat/{slug}",
							tags: ["iGubat Discover Gubat"],
							spec: spec => ({ ...spec, security: [] }),
						})
						.input(SlugParamSchema)
						.output(DiscoverGubatEntryDetailSchema),
				}),
			})
		),
		me: oc.prefix("/me").router(
			oc.router({
				profile: oc
					.route({ method: "GET", path: "/profile", tags: ["iGubat Citizen"] })
					.output(UserSummarySchema),
				updateProfile: oc
					.route({ method: "PATCH", path: "/profile", tags: ["iGubat Citizen"] })
					.input(UpdateProfileSchema)
					.output(UserSummarySchema),
				notificationPreferences: oc
					.route({ method: "GET", path: "/notification-preferences", tags: ["iGubat Citizen"] })
					.output(NotificationPreferenceSchema),
				updateNotificationPreferences: oc
					.route({ method: "PATCH", path: "/notification-preferences", tags: ["iGubat Citizen"] })
					.input(NotificationPreferenceSchema.partial())
					.output(NotificationPreferenceSchema),
				requests: oc
					.route({ method: "GET", path: "/requests", tags: ["iGubat Citizen"] })
					.output(z.array(ServiceRequestSchema)),
				request: oc
					.route({ method: "GET", path: "/requests/{id}", tags: ["iGubat Citizen"] })
					.input(IdParamSchema)
					.output(ServiceRequestDetailSchema),
				createRequest: oc
					.route({ method: "POST", path: "/requests", tags: ["iGubat Citizen"] })
					.input(CreateServiceRequestSchema)
					.output(ServiceRequestDetailSchema),
				cancelRequest: oc
					.route({ method: "POST", path: "/requests/{id}/cancel", tags: ["iGubat Citizen"] })
					.input(IdParamSchema)
					.output(ServiceRequestDetailSchema),
				reports: oc
					.route({ method: "GET", path: "/reports", tags: ["iGubat Citizen"] })
					.output(z.array(CitizenReportSchema)),
				report: oc
					.route({ method: "GET", path: "/reports/{id}", tags: ["iGubat Citizen"] })
					.input(IdParamSchema)
					.output(CitizenReportDetailSchema),
				createReport: oc
					.route({ method: "POST", path: "/reports", tags: ["iGubat Citizen"] })
					.input(CreateCitizenReportSchema)
					.output(CitizenReportDetailSchema),
				notifications: oc
					.route({ method: "GET", path: "/notifications", tags: ["iGubat Citizen"] })
					.output(z.array(NotificationSchema)),
				markNotificationRead: oc
					.route({ method: "POST", path: "/notifications/{id}/read", tags: ["iGubat Citizen"] })
					.input(IdParamSchema)
					.output(NotificationSchema),
				markAllNotificationsRead: oc
					.route({ method: "POST", path: "/notifications/read-all", tags: ["iGubat Citizen"] })
					.output(z.object({ success: z.boolean() })),
			})
		),
		admin: oc.prefix("/admin").router(
			oc.router({
				dashboard: oc
					.route({ method: "GET", path: "/dashboard", tags: ["iGubat Admin"] })
					.output(DashboardSchema),
				requests: oc
					.route({ method: "GET", path: "/requests", tags: ["iGubat Admin"] })
					.input(ListQuerySchema)
					.output(z.array(ServiceRequestSchema)),
				request: oc
					.route({ method: "GET", path: "/requests/{id}", tags: ["iGubat Admin"] })
					.input(IdParamSchema)
					.output(ServiceRequestDetailSchema),
				updateRequestStatus: oc
					.route({ method: "PATCH", path: "/requests/{id}/status", tags: ["iGubat Admin"] })
					.input(UpdateRequestStatusSchema)
					.output(ServiceRequestDetailSchema),
				reports: oc
					.route({ method: "GET", path: "/reports", tags: ["iGubat Admin"] })
					.input(ListQuerySchema)
					.output(z.array(CitizenReportSchema)),
				report: oc
					.route({ method: "GET", path: "/reports/{id}", tags: ["iGubat Admin"] })
					.input(IdParamSchema)
					.output(CitizenReportDetailSchema),
				updateReportStatus: oc
					.route({ method: "PATCH", path: "/reports/{id}/status", tags: ["iGubat Admin"] })
					.input(UpdateReportStatusSchema)
					.output(CitizenReportDetailSchema),
				articles: oc
					.route({ method: "GET", path: "/articles", tags: ["iGubat Admin"] })
					.input(ListQuerySchema)
					.output(z.array(NewsArticleSchema)),
				upsertArticle: oc
					.route({ method: "POST", path: "/articles", tags: ["iGubat Admin"] })
					.input(UpsertArticleSchema)
					.output(NewsArticleSchema),
				events: oc
					.route({ method: "GET", path: "/events", tags: ["iGubat Admin"] })
					.input(ListQuerySchema)
					.output(z.array(EventSchema)),
				upsertEvent: oc
					.route({ method: "POST", path: "/events", tags: ["iGubat Admin"] })
					.input(UpsertEventSchema)
					.output(EventSchema),
				deleteEvent: oc
					.route({ method: "DELETE", path: "/events/{id}", tags: ["iGubat Admin"] })
					.input(IdParamSchema)
					.output(z.object({ success: z.boolean() })),
				communityStats: oc
					.route({ method: "GET", path: "/community-stats", tags: ["iGubat Admin"] })
					.output(z.array(CommunityStatConfigSchema)),
				updateCommunityStats: oc
					.route({ method: "PUT", path: "/community-stats", tags: ["iGubat Admin"] })
					.input(UpdateCommunityStatsSchema)
					.output(z.array(CommunityStatConfigSchema)),
				emergencyDirectory: oc
					.route({ method: "GET", path: "/emergency-directory", tags: ["iGubat Admin"] })
					.output(z.array(EmergencyDirectorySchema)),
				upsertDirectoryEntry: oc
					.route({ method: "POST", path: "/emergency-directory", tags: ["iGubat Admin"] })
					.input(UpsertDirectoryEntrySchema)
					.output(EmergencyDirectorySchema),
				broadcasts: oc
					.route({ method: "GET", path: "/broadcasts", tags: ["iGubat Admin"] })
					.output(z.array(EmergencyBroadcastSchema)),
				createBroadcast: oc
					.route({ method: "POST", path: "/broadcasts", tags: ["iGubat Admin"] })
					.input(CreateBroadcastSchema)
					.output(EmergencyBroadcastSchema),
				citizens: oc
					.route({ method: "GET", path: "/citizens", tags: ["iGubat Admin"] })
					.input(ListQuerySchema)
					.output(z.array(UserSummarySchema)),
				citizen: oc
					.route({ method: "GET", path: "/citizens/{id}", tags: ["iGubat Admin"] })
					.input(z.object({ id: z.string().min(1) }))
					.output(UserSummarySchema),
				staff: oc
					.route({ method: "GET", path: "/staff", tags: ["iGubat Admin"] })
					.output(z.array(UserSummarySchema)),
				createStaff: oc
					.route({ method: "POST", path: "/staff", tags: ["iGubat Admin"] })
					.input(CreateStaffSchema)
					.output(UserSummarySchema),
				analytics: oc
					.route({ method: "GET", path: "/analytics", tags: ["iGubat Admin"] })
					.input(ListQuerySchema)
					.output(AnalyticsSchema),
				auditLogs: oc
					.route({ method: "GET", path: "/audit-logs", tags: ["iGubat Admin"] })
					.input(ListQuerySchema)
					.output(z.array(AuditLogSchema)),
				settings: oc
					.route({ method: "GET", path: "/settings", tags: ["iGubat Admin"] })
					.output(z.array(SystemSettingSchema)),
				upsertSetting: oc
					.route({ method: "POST", path: "/settings", tags: ["iGubat Admin"] })
					.input(UpsertSettingSchema)
					.output(SystemSettingSchema),
				transparency: oc.router({
					exportCsv: oc
						.route({
							method: "GET",
							path: "/transparency/export",
							tags: ["iGubat Transparency"],
						})
						.input(TransparencyListQuerySchema)
						.output(z.object({ fileName: z.string(), content: z.string() })),
					list: oc
						.route({ method: "GET", path: "/transparency", tags: ["iGubat Transparency"] })
						.input(TransparencyListQuerySchema)
						.output(z.array(TransparencyItemSummarySchema)),
					detail: oc
						.route({
							method: "GET",
							path: "/transparency/{id}",
							tags: ["iGubat Transparency"],
						})
						.input(IdParamSchema)
						.output(TransparencyItemDetailSchema),
					create: oc
						.route({ method: "POST", path: "/transparency", tags: ["iGubat Transparency"] })
						.input(CreateTransparencyItemSchema)
						.output(TransparencyItemDetailSchema),
					update: oc
						.route({
							method: "PATCH",
							path: "/transparency/{id}",
							tags: ["iGubat Transparency"],
						})
						.input(UpdateTransparencyItemSchema)
						.output(TransparencyItemDetailSchema),
					publish: oc
						.route({
							method: "POST",
							path: "/transparency/{id}/publish",
							tags: ["iGubat Transparency"],
						})
						.input(PublishTransparencyItemSchema)
						.output(TransparencyItemDetailSchema),
					archive: oc
						.route({
							method: "POST",
							path: "/transparency/{id}/archive",
							tags: ["iGubat Transparency"],
						})
						.input(IdParamSchema)
						.output(TransparencyItemDetailSchema),
					delete: oc
						.route({
							method: "DELETE",
							path: "/transparency/{id}",
							tags: ["iGubat Transparency"],
						})
						.input(DeleteTransparencyItemSchema)
						.output(z.object({ success: z.boolean(), permanent: z.boolean() })),
				}),
				discoverGubat: oc.router({
					list: oc
						.route({ method: "GET", path: "/discover-gubat", tags: ["iGubat Discover Gubat"] })
						.input(DiscoverGubatListQuerySchema)
						.output(z.array(DiscoverGubatEntrySummarySchema)),
					detail: oc
						.route({
							method: "GET",
							path: "/discover-gubat/{id}",
							tags: ["iGubat Discover Gubat"],
						})
						.input(IdParamSchema)
						.output(DiscoverGubatEntryDetailSchema),
					create: oc
						.route({ method: "POST", path: "/discover-gubat", tags: ["iGubat Discover Gubat"] })
						.input(CreateDiscoverGubatEntrySchema)
						.output(DiscoverGubatEntryDetailSchema),
					update: oc
						.route({
							method: "PATCH",
							path: "/discover-gubat/{id}",
							tags: ["iGubat Discover Gubat"],
						})
						.input(UpdateDiscoverGubatEntrySchema)
						.output(DiscoverGubatEntryDetailSchema),
					publish: oc
						.route({
							method: "POST",
							path: "/discover-gubat/{id}/publish",
							tags: ["iGubat Discover Gubat"],
						})
						.input(PublishDiscoverGubatEntrySchema)
						.output(DiscoverGubatEntryDetailSchema),
					archive: oc
						.route({
							method: "POST",
							path: "/discover-gubat/{id}/archive",
							tags: ["iGubat Discover Gubat"],
						})
						.input(IdParamSchema)
						.output(DiscoverGubatEntryDetailSchema),
					delete: oc
						.route({
							method: "DELETE",
							path: "/discover-gubat/{id}",
							tags: ["iGubat Discover Gubat"],
						})
						.input(DeleteDiscoverGubatEntrySchema)
						.output(z.object({ success: z.boolean(), permanent: z.boolean() })),
				}),
			})
		),
	})
)
