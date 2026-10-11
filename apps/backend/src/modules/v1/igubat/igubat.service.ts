import {
	BadRequestException,
	ForbiddenException,
	Injectable,
	NotFoundException,
} from "@nestjs/common"
import { randomBytes, scryptSync } from "node:crypto"
import { and, asc, desc, eq, gte, isNull, or } from "drizzle-orm"
import { z } from "zod"

import {
	COMMUNITY_STATS_SETTING_KEY,
	CommunityStatConfigSchema,
	DEFAULT_COMMUNITY_STATS,
} from "@repo/contracts"
import {
	accounts,
	auditLogs,
	citizenReportAttachments,
	citizenReports,
	citizenReportStatusHistory,
	contentPlacements,
	emergencyBroadcasts,
	emergencyDirectory,
	events,
	helpArticles,
	newsArticles,
	notificationPreferences,
	notifications,
	policyDocuments,
	serviceCategories,
	serviceRequestAttachments,
	serviceRequests,
	serviceRequestStatusHistory,
	serviceTypes,
	systemSettings,
	users,
} from "@repo/db/schema"

import { db } from "@/common/database/database.client"
import type { V1Inputs } from "@/config/contract-types"

type SessionUser = {
	id: string
	name?: string
	email?: string
	role?: string | null
}

type PublicListQuery = NonNullable<V1Inputs["igubat"]["public"]["news"]>
type CreateRequestInput = V1Inputs["igubat"]["me"]["createRequest"]
type CreateReportInput = V1Inputs["igubat"]["me"]["createReport"]
type UpdateRequestStatusInput = V1Inputs["igubat"]["admin"]["updateRequestStatus"]
type UpdateReportStatusInput = V1Inputs["igubat"]["admin"]["updateReportStatus"]
type CreateBroadcastInput = V1Inputs["igubat"]["admin"]["createBroadcast"]
type CreateStaffInput = V1Inputs["igubat"]["admin"]["createStaff"]
type UpsertEventInput = V1Inputs["igubat"]["admin"]["upsertEvent"]
type UpdateCommunityStatsInput = V1Inputs["igubat"]["admin"]["updateCommunityStats"]
type CommunityStatConfig = z.infer<typeof CommunityStatConfigSchema>
type CommunityStatKey = CommunityStatConfig["key"]

const ADMIN_ROLES = new Set(["ict_admin", "super_admin"])
const STAFF_ROLES = new Set([
	"frontline_officer",
	"department_supervisor",
	"content_editor",
	"emergency_operator",
	"ict_admin",
	"super_admin",
])
const DEFAULT_STAFF_PASSWORD = "password123"

function hashPassword(password: string): string {
	const saltHex = randomBytes(16).toString("hex")
	const key = scryptSync(password.normalize("NFKC"), saltHex, 64, {
		N: 16384,
		r: 16,
		p: 1,
		maxmem: 128 * 16384 * 16 * 2,
	})
	return `${saltHex}:${key.toString("hex")}`
}

function trackingPrefix(serviceName: string): string {
	const words = serviceName
		.replace(/[^a-zA-Z\s]/g, " ")
		.split(/\s+/)
		.filter(Boolean)
	return (words.map(word => word[0]).join("") || "SR").slice(0, 3).toUpperCase()
}

function requireRow<T>(row: T | undefined, message: string): T {
	if (!row) throw new NotFoundException(message)
	return row
}

function positiveId(value: unknown, label = "id"): number {
	const id = Number(value)
	if (!Number.isInteger(id) || id < 1) {
		throw new BadRequestException(`${label} must be a positive integer`)
	}
	return id
}

@Injectable()
export class IgubatService {
	private assertStaff(user: SessionUser) {
		if (!STAFF_ROLES.has(user.role ?? "")) {
			throw new ForbiddenException("Staff access required")
		}
	}

	private assertAdmin(user: SessionUser) {
		if (!ADMIN_ROLES.has(user.role ?? "")) {
			throw new ForbiddenException("Admin access required")
		}
	}

	private async audit(
		actorId: string | null,
		actionType: string,
		entityType: string,
		entityId?: string,
		details?: unknown
	) {
		await db.insert(auditLogs).values({
			actorId,
			actionType,
			entityType,
			entityId,
			details,
			ipAddress: "local-dev",
		})
	}

	private async usersById() {
		const allUsers = await db.select().from(users)
		return new Map(allUsers.map(user => [user.id, user]))
	}

	private async requestRows() {
		const [rows, userMap] = await Promise.all([
			db.select().from(serviceRequests).orderBy(desc(serviceRequests.createdAt)),
			this.usersById(),
		])
		return rows.map(row => {
			const citizen = row.authorId ? userMap.get(row.authorId) : undefined
			return {
				...row,
				citizenName: citizen?.name ?? null,
				barangay: citizen?.barangay ?? null,
			}
		})
	}

	private async reportRows() {
		const [rows, userMap] = await Promise.all([
			db.select().from(citizenReports).orderBy(desc(citizenReports.createdAt)),
			this.usersById(),
		])
		return rows.map(row => {
			const citizen = row.authorId ? userMap.get(row.authorId) : undefined
			return {
				...row,
				citizenName: citizen?.name ?? null,
			}
		})
	}

	private filterRows<
		T extends {
			status?: string
			category?: string
			serviceType?: string
			barangay?: string | null
		},
	>(rows: T[], query?: PublicListQuery) {
		if (!query) return rows
		return rows.filter(row => {
			if (query.status && row.status !== query.status) return false
			if (query.category && row.category !== query.category) return false
			if (query.serviceType && row.serviceType !== query.serviceType) return false
			if (query.barangay && row.barangay !== query.barangay) return false
			return true
		})
	}

	async publicDashboard() {
		const [allUsers, requests, reports, articles, services, upcomingEvents, statsConfig] =
			await Promise.all([
				db.select().from(users),
				this.requestRows(),
				this.reportRows(),
				db
					.select()
					.from(newsArticles)
					.where(and(eq(newsArticles.status, "published"), isNull(newsArticles.deletedAt))),
				db.select().from(serviceTypes).where(eq(serviceTypes.isActive, true)),
				this.listEvents(),
				this.communityStatsConfig(),
			])

		const totals = {
			totalUsers: allUsers.filter(user => user.role === "registered_citizen").length,
			pendingRequests: requests.filter(request => request.status === "pending").length,
			activeServices: services.length,
			newReports: reports.filter(report => report.status === "received").length,
			publishedAnnouncements: articles.length,
		}
		const values: Record<CommunityStatKey, number> = {
			registered_citizens: totals.totalUsers,
			pending_requests: totals.pendingRequests,
			completed_requests: requests.filter(request => request.status === "completed").length,
			active_services: totals.activeServices,
			new_reports: totals.newReports,
			published_news: totals.publishedAnnouncements,
			upcoming_events: upcomingEvents.length,
		}

		return {
			...totals,
			recentRequests: requests.slice(0, 5),
			recentReports: reports.slice(0, 5),
			upcomingEvents: upcomingEvents.slice(0, 5),
			communityStats: statsConfig
				.filter(stat => stat.enabled)
				.map(stat => ({ key: stat.key, label: stat.label, value: values[stat.key] })),
		}
	}

	/**
	 * Admin-configured Community Stats (order, labels, visibility). Falls back to
	 * defaults when unset/invalid; stats added later are appended disabled.
	 */
	private async communityStatsConfig(): Promise<CommunityStatConfig[]> {
		const [setting] = await db
			.select()
			.from(systemSettings)
			.where(eq(systemSettings.key, COMMUNITY_STATS_SETTING_KEY))
		const parsed = z.array(CommunityStatConfigSchema).safeParse(setting?.value)
		if (!parsed.success) return DEFAULT_COMMUNITY_STATS
		const seen = new Set(parsed.data.map(stat => stat.key))
		return [
			...parsed.data,
			...DEFAULT_COMMUNITY_STATS.filter(stat => !seen.has(stat.key)).map(stat => ({
				...stat,
				enabled: false,
			})),
		]
	}

	async getAdminCommunityStats(user: SessionUser) {
		this.assertStaff(user)
		return this.communityStatsConfig()
	}

	async updateCommunityStats(user: SessionUser, input: UpdateCommunityStatsInput) {
		this.assertStaff(user)
		await this.upsertSettingValue(user.id, COMMUNITY_STATS_SETTING_KEY, "home", input.stats)
		await this.audit(user.id, "update", "system_setting", COMMUNITY_STATS_SETTING_KEY)
		return this.communityStatsConfig()
	}

	private async upsertSettingValue(actorId: string, key: string, category: string, value: unknown) {
		const payload = { key, category, value, updatedById: actorId, updatedAt: new Date() }
		await db
			.insert(systemSettings)
			.values(payload)
			.onConflictDoUpdate({ target: systemSettings.key, set: payload })
	}

	async listNews(query?: PublicListQuery, includeDrafts = false) {
		const rows = await db
			.select()
			.from(newsArticles)
			.orderBy(desc(newsArticles.publishedAt), desc(newsArticles.createdAt))
		const visible = includeDrafts
			? rows
			: rows.filter(row => row.status === "published" && row.deletedAt === null)
		return this.filterRows(visible, query)
	}

	async getArticle(slug: string, includeDrafts = false) {
		const [article] = await db.select().from(newsArticles).where(eq(newsArticles.slug, slug))
		if (!article || (!includeDrafts && article.status !== "published")) {
			throw new NotFoundException("Article not found")
		}
		return article
	}

	listPlacements() {
		return db
			.select()
			.from(contentPlacements)
			.where(eq(contentPlacements.isActive, true))
			.orderBy(asc(contentPlacements.sortOrder))
	}

	/** Published events that haven't ended yet, soonest first. */
	listEvents() {
		const now = new Date()
		return db
			.select()
			.from(events)
			.where(
				and(
					eq(events.status, "published"),
					isNull(events.deletedAt),
					or(gte(events.endsAt, now), and(isNull(events.endsAt), gte(events.startsAt, now)))
				)
			)
			.orderBy(asc(events.startsAt))
	}

	async getEvent(slug: string) {
		const [event] = await db.select().from(events).where(eq(events.slug, slug))
		if (!event || event.status !== "published" || event.deletedAt) {
			throw new NotFoundException("Event not found")
		}
		return event
	}

	async listAdminEvents(user: SessionUser, query?: PublicListQuery) {
		this.assertStaff(user)
		const rows = await db
			.select()
			.from(events)
			.where(isNull(events.deletedAt))
			.orderBy(desc(events.startsAt))
		const search = query?.search?.trim().toLowerCase()
		return this.filterRows(rows, query).filter(
			row =>
				!search || `${row.title} ${row.location} ${row.category}`.toLowerCase().includes(search)
		)
	}

	async upsertEvent(user: SessionUser, input: UpsertEventInput) {
		this.assertStaff(user)
		const startsAt = new Date(input.startsAt)
		const endsAt = input.endsAt ? new Date(input.endsAt) : null
		if (Number.isNaN(startsAt.getTime()) || (endsAt && Number.isNaN(endsAt.getTime()))) {
			throw new BadRequestException("Invalid event date")
		}
		if (endsAt && endsAt < startsAt) {
			throw new BadRequestException("End date must be after the start date")
		}

		const [slugOwner] = await db.select().from(events).where(eq(events.slug, input.slug))
		if (slugOwner && slugOwner.id !== input.id && !slugOwner.deletedAt) {
			throw new BadRequestException("Another event already uses this slug")
		}

		const existing = input.id
			? requireRow(
					(await db.select().from(events).where(eq(events.id, input.id)))[0],
					"Event not found"
				)
			: undefined
		const now = new Date()
		const payload = {
			title: input.title,
			slug: input.slug,
			description: input.description,
			category: input.category,
			location: input.location,
			imageUrl: input.imageUrl || null,
			status: input.status,
			startsAt,
			endsAt,
			publishedAt:
				input.status === "published" ? (existing?.publishedAt ?? now) : existing?.publishedAt,
			archivedAt: input.status === "archived" ? (existing?.archivedAt ?? now) : null,
			updatedAt: now,
		}
		const [event] = existing
			? await db.update(events).set(payload).where(eq(events.id, existing.id)).returning()
			: slugOwner?.deletedAt
				? // Re-use a soft-deleted row so the unique slug can be taken again.
					await db
						.update(events)
						.set({ ...payload, deletedAt: null, authorId: user.id, createdAt: now })
						.where(eq(events.id, slugOwner.id))
						.returning()
				: await db
						.insert(events)
						.values({ ...payload, authorId: user.id })
						.returning()
		const savedEvent = requireRow(event, "Event was not saved")
		await this.audit(user.id, existing ? "update" : "create", "event", String(savedEvent.id), {
			status: input.status,
		})
		return savedEvent
	}

	async deleteEvent(user: SessionUser, id: number) {
		this.assertStaff(user)
		const [event] = await db
			.update(events)
			.set({ deletedAt: new Date(), updatedAt: new Date() })
			.where(and(eq(events.id, id), isNull(events.deletedAt)))
			.returning({ id: events.id })
		requireRow(event, "Event not found")
		await this.audit(user.id, "delete", "event", String(id))
		return { success: true }
	}

	listServiceCategories() {
		return db
			.select()
			.from(serviceCategories)
			.where(eq(serviceCategories.isActive, true))
			.orderBy(asc(serviceCategories.sortOrder))
	}

	async listServices(query?: PublicListQuery) {
		const rows = await db
			.select()
			.from(serviceTypes)
			.where(eq(serviceTypes.isActive, true))
			.orderBy(asc(serviceTypes.name))
		return this.filterRows(
			rows.map(row => ({ ...row, category: row.categoryId?.toString() })),
			query
		)
	}

	async getService(slug: string) {
		const [service] = await db.select().from(serviceTypes).where(eq(serviceTypes.slug, slug))
		if (!service || !service.isActive) throw new NotFoundException("Service not found")
		return service
	}

	listEmergencyDirectory() {
		return db
			.select()
			.from(emergencyDirectory)
			.where(eq(emergencyDirectory.isActive, true))
			.orderBy(asc(emergencyDirectory.type), asc(emergencyDirectory.name))
	}

	listHelp() {
		return db
			.select()
			.from(helpArticles)
			.where(eq(helpArticles.isPublished, true))
			.orderBy(asc(helpArticles.sortOrder), asc(helpArticles.title))
	}

	async getPolicy(slug: string) {
		const [policy] = await db.select().from(policyDocuments).where(eq(policyDocuments.slug, slug))
		if (!policy) throw new NotFoundException("Policy not found")
		return policy
	}

	async getProfile(user: SessionUser) {
		const [profile] = await db.select().from(users).where(eq(users.id, user.id))
		if (!profile) throw new NotFoundException("Profile not found")
		return profile
	}

	async updateProfile(user: SessionUser, input: V1Inputs["igubat"]["me"]["updateProfile"]) {
		const [profile] = await db
			.update(users)
			.set({ ...input, updatedAt: new Date() })
			.where(eq(users.id, user.id))
			.returning()
		if (!profile) throw new NotFoundException("Profile not found")
		await this.audit(user.id, "profile_update", "user", user.id, input)
		return profile
	}

	async getNotificationPreferences(user: SessionUser) {
		const [existing] = await db
			.select()
			.from(notificationPreferences)
			.where(eq(notificationPreferences.userId, user.id))
		if (existing) return existing
		const [createdRow] = await db
			.insert(notificationPreferences)
			.values({ userId: user.id })
			.returning()
		const created = requireRow(createdRow, "Notification preferences were not created")
		return created
	}

	async updateNotificationPreferences(
		user: SessionUser,
		input: V1Inputs["igubat"]["me"]["updateNotificationPreferences"]
	) {
		await this.getNotificationPreferences(user)
		const { emergencyOptOutConfirmedAt, ...preferences } = input
		const [updated] = await db
			.update(notificationPreferences)
			.set({
				...preferences,
				...(emergencyOptOutConfirmedAt !== undefined
					? {
							emergencyOptOutConfirmedAt: emergencyOptOutConfirmedAt
								? new Date(emergencyOptOutConfirmedAt)
								: null,
						}
					: {}),
				updatedAt: new Date(),
			})
			.where(eq(notificationPreferences.userId, user.id))
			.returning()
		return requireRow(updated, "Notification preferences were not updated")
	}

	async listMyRequests(user: SessionUser) {
		return (await this.requestRows()).filter(request => request.authorId === user.id)
	}

	async getRequestDetail(id: number, user?: SessionUser, staff = false) {
		const [request] = await this.requestRows().then(rows => rows.filter(row => row.id === id))
		if (!request) throw new NotFoundException("Request not found")
		if (!staff && user && request.authorId !== user.id)
			throw new ForbiddenException("Cannot view another citizen request")
		const [attachments, history] = await Promise.all([
			db
				.select()
				.from(serviceRequestAttachments)
				.where(eq(serviceRequestAttachments.serviceRequestId, id)),
			db
				.select()
				.from(serviceRequestStatusHistory)
				.where(eq(serviceRequestStatusHistory.serviceRequestId, id))
				.orderBy(asc(serviceRequestStatusHistory.createdAt)),
		])
		return {
			...request,
			attachments,
			history: staff ? history : history.filter(item => item.visibility === "public"),
		}
	}

	async createRequest(user: SessionUser, input: CreateRequestInput) {
		const [service] = await db
			.select()
			.from(serviceTypes)
			.where(eq(serviceTypes.id, input.serviceTypeId))
		if (!service) throw new NotFoundException("Service type not found")
		const profile = await this.getProfile(user)
		const now = new Date()
		const trackingNumber = `${trackingPrefix(service.name)}-${now.getFullYear()}-${String(Date.now()).slice(-5)}`
		const [createdRequest] = await db
			.insert(serviceRequests)
			.values({
				trackingNumber,
				serviceTypeId: service.id,
				serviceType: service.name,
				description: input.description,
				preferredDate: input.preferredDate ? new Date(input.preferredDate) : null,
				status: "pending",
				departmentId: service.categoryId,
				authorId: user.id,
				contactSnapshot: {
					name: profile.name,
					email: profile.email,
					mobileNumber: profile.mobileNumber,
					barangay: profile.barangay,
					address: profile.address,
				},
			})
			.returning()
		const request = requireRow(createdRequest, "Service request was not created")
		await db.insert(serviceRequestStatusHistory).values({
			serviceRequestId: request.id,
			status: "pending",
			remarks: "Request submitted through iGubat.",
			visibility: "public",
			changedById: user.id,
		})
		if (input.attachments?.length) {
			await db.insert(serviceRequestAttachments).values(
				input.attachments.map(file => ({
					serviceRequestId: request.id,
					fileName: file.fileName,
					fileUrl: file.fileUrl,
				}))
			)
		}
		await this.audit(user.id, "create", "service_request", trackingNumber, {
			serviceType: service.name,
		})
		return this.getRequestDetail(request.id, user)
	}

	async cancelRequest(user: SessionUser, id: number) {
		const detail = await this.getRequestDetail(id, user)
		if (detail.status !== "pending")
			throw new ForbiddenException("Only pending requests can be cancelled")
		await db
			.update(serviceRequests)
			.set({
				status: "rejected",
				cancelledAt: new Date(),
				cancellationReason: "Cancelled by citizen",
				updatedAt: new Date(),
			})
			.where(eq(serviceRequests.id, id))
		await db.insert(serviceRequestStatusHistory).values({
			serviceRequestId: id,
			status: "rejected",
			remarks: "Cancelled by citizen.",
			visibility: "public",
			changedById: user.id,
		})
		await this.audit(user.id, "cancel", "service_request", detail.trackingNumber)
		return this.getRequestDetail(id, user)
	}

	async listMyReports(user: SessionUser) {
		return (await this.reportRows()).filter(report => report.authorId === user.id)
	}

	async getReportDetail(id: number, user?: SessionUser, staff = false) {
		const [report] = await this.reportRows().then(rows => rows.filter(row => row.id === id))
		if (!report) throw new NotFoundException("Report not found")
		if (!staff && user && report.authorId !== user.id)
			throw new ForbiddenException("Cannot view another citizen report")
		const [attachments, history] = await Promise.all([
			db
				.select()
				.from(citizenReportAttachments)
				.where(eq(citizenReportAttachments.citizenReportId, id)),
			db
				.select()
				.from(citizenReportStatusHistory)
				.where(eq(citizenReportStatusHistory.citizenReportId, id))
				.orderBy(asc(citizenReportStatusHistory.createdAt)),
		])
		return {
			...report,
			attachments,
			history: staff ? history : history.filter(item => item.visibility === "public"),
		}
	}

	async createReport(user: SessionUser, input: CreateReportInput) {
		const [createdReport] = await db
			.insert(citizenReports)
			.values({
				category: input.category,
				description: input.description,
				barangay: input.barangay,
				locationAddress: input.locationAddress,
				latitude: input.latitude,
				longitude: input.longitude,
				status: "received",
				authorId: user.id,
			})
			.returning()
		const report = requireRow(createdReport, "Citizen report was not created")
		await db.insert(citizenReportStatusHistory).values({
			citizenReportId: report.id,
			status: "received",
			remarks: "Report received by the LGU.",
			visibility: "public",
			changedById: user.id,
		})
		if (input.attachments?.length) {
			await db.insert(citizenReportAttachments).values(
				input.attachments.map(file => ({
					citizenReportId: report.id,
					fileName: file.fileName,
					fileUrl: file.fileUrl,
				}))
			)
		}
		await this.audit(user.id, "create", "citizen_report", String(report.id), {
			category: input.category,
		})
		return this.getReportDetail(report.id, user)
	}

	async listNotifications(user: SessionUser) {
		return db
			.select()
			.from(notifications)
			.where(eq(notifications.userId, user.id))
			.orderBy(desc(notifications.createdAt))
	}

	async markNotificationRead(user: SessionUser, id: number) {
		const [notification] = await db.select().from(notifications).where(eq(notifications.id, id))
		if (!notification || notification.userId !== user.id)
			throw new NotFoundException("Notification not found")
		const [updated] = await db
			.update(notifications)
			.set({ isRead: true, readAt: new Date() })
			.where(eq(notifications.id, id))
			.returning()
		return requireRow(updated, "Notification was not updated")
	}

	async markAllNotificationsRead(user: SessionUser) {
		await db
			.update(notifications)
			.set({ isRead: true, readAt: new Date() })
			.where(eq(notifications.userId, user.id))
		return { success: true }
	}

	async adminDashboard(user: SessionUser) {
		this.assertStaff(user)
		return this.publicDashboard()
	}

	async listAdminRequests(user: SessionUser, query?: PublicListQuery) {
		this.assertStaff(user)
		return this.filterRows(await this.requestRows(), query)
	}

	async updateRequestStatus(user: SessionUser, input: UpdateRequestStatusInput) {
		this.assertStaff(user)
		const id = positiveId(input.id)
		const detail = await this.getRequestDetail(id, user, true)
		const [updated] = await db
			.update(serviceRequests)
			.set({
				status: input.status,
				publicRemarks: input.remarks ?? detail.publicRemarks,
				internalNotes: input.internalNotes ?? detail.internalNotes,
				updatedAt: new Date(),
			})
			.where(eq(serviceRequests.id, id))
			.returning()
		const updatedRequest = requireRow(updated, "Service request was not updated")
		await db.insert(serviceRequestStatusHistory).values({
			serviceRequestId: id,
			status: input.status,
			remarks: input.remarks,
			visibility: "public",
			changedById: user.id,
		})
		if (updatedRequest.authorId) {
			await db.insert(notifications).values({
				userId: updatedRequest.authorId,
				title: `${updatedRequest.serviceType} ${input.status.replace(/_/g, " ")}`,
				body:
					input.remarks ?? `Your request ${updatedRequest.trackingNumber} is now ${input.status}.`,
				type: "in_app",
				category: "service_request",
				metadata: { entityType: "service_request", entityId: updatedRequest.trackingNumber },
			})
		}
		await this.audit(user.id, "status_change", "service_request", updatedRequest.trackingNumber, {
			to: input.status,
		})
		return this.getRequestDetail(id, user, true)
	}

	async listAdminReports(user: SessionUser, query?: PublicListQuery) {
		this.assertStaff(user)
		return this.filterRows(await this.reportRows(), query)
	}

	async updateReportStatus(user: SessionUser, input: UpdateReportStatusInput) {
		this.assertStaff(user)
		const id = positiveId(input.id)
		const detail = await this.getReportDetail(id, user, true)
		const [updated] = await db
			.update(citizenReports)
			.set({
				status: input.status,
				publicRemarks: input.remarks ?? detail.publicRemarks,
				internalNotes: input.internalNotes ?? detail.internalNotes,
				updatedAt: new Date(),
			})
			.where(eq(citizenReports.id, id))
			.returning()
		const updatedReport = requireRow(updated, "Citizen report was not updated")
		await db.insert(citizenReportStatusHistory).values({
			citizenReportId: id,
			status: input.status,
			remarks: input.remarks,
			visibility: "public",
			changedById: user.id,
		})
		if (updatedReport.authorId) {
			await db.insert(notifications).values({
				userId: updatedReport.authorId,
				title: `Report ${input.status.replace(/_/g, " ")}`,
				body: input.remarks ?? `Your ${updatedReport.category} report is now ${input.status}.`,
				type: "in_app",
				category: "issue_report",
				metadata: { entityType: "citizen_report", entityId: String(updatedReport.id) },
			})
		}
		await this.audit(user.id, "status_change", "citizen_report", String(updatedReport.id), {
			to: input.status,
		})
		return this.getReportDetail(id, user, true)
	}

	async upsertArticle(user: SessionUser, input: V1Inputs["igubat"]["admin"]["upsertArticle"]) {
		this.assertStaff(user)
		const payload = {
			title: input.title,
			slug: input.slug,
			excerpt: input.excerpt,
			body: input.body,
			category: input.category,
			status: input.status,
			imageUrl: input.imageUrl,
			isFeatured: input.isFeatured ?? false,
			scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : null,
			publishedAt: input.status === "published" ? new Date() : null,
			authorId: user.id,
			updatedAt: new Date(),
		}
		const [article] = input.id
			? await db.update(newsArticles).set(payload).where(eq(newsArticles.id, input.id)).returning()
			: await db.insert(newsArticles).values(payload).returning()
		const savedArticle = requireRow(article, "News article was not saved")
		await this.audit(
			user.id,
			input.id ? "update" : "create",
			"news_article",
			String(savedArticle.id),
			{ status: input.status }
		)
		return savedArticle
	}

	async listAdminArticles(user: SessionUser, query?: PublicListQuery) {
		this.assertStaff(user)
		return this.listNews(query, true)
	}

	async listAdminEmergencyDirectory(user: SessionUser) {
		this.assertStaff(user)
		return this.listEmergencyDirectory()
	}

	async upsertDirectoryEntry(
		user: SessionUser,
		input: V1Inputs["igubat"]["admin"]["upsertDirectoryEntry"]
	) {
		this.assertStaff(user)
		const payload = {
			name: input.name,
			type: input.type,
			contactNumber: input.contactNumber,
			address: input.address,
			hours: input.hours,
			isActive: input.isActive ?? true,
			updatedAt: new Date(),
		}
		const [entry] = input.id
			? await db
					.update(emergencyDirectory)
					.set(payload)
					.where(eq(emergencyDirectory.id, input.id))
					.returning()
			: await db.insert(emergencyDirectory).values(payload).returning()
		const savedEntry = requireRow(entry, "Emergency directory entry was not saved")
		await this.audit(
			user.id,
			input.id ? "update" : "create",
			"emergency_directory",
			String(savedEntry.id)
		)
		return savedEntry
	}

	listBroadcasts(user: SessionUser) {
		this.assertStaff(user)
		return db.select().from(emergencyBroadcasts).orderBy(desc(emergencyBroadcasts.createdAt))
	}

	async createBroadcast(user: SessionUser, input: CreateBroadcastInput) {
		this.assertStaff(user)
		const sendNow = input.sendNow ?? !input.scheduledAt
		const [createdBroadcast] = await db
			.insert(emergencyBroadcasts)
			.values({
				title: input.title,
				message: input.message,
				severity: input.severity,
				status: sendNow ? "sent" : "scheduled",
				scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : null,
				sentAt: sendNow ? new Date() : null,
				senderId: user.id,
				recipientCount: sendNow
					? (await db.select().from(users)).filter(row => row.role === "registered_citizen").length
					: 0,
			})
			.returning()
		const broadcast = requireRow(createdBroadcast, "Emergency broadcast was not created")
		await this.audit(
			user.id,
			sendNow ? "send" : "schedule",
			"emergency_broadcast",
			String(broadcast.id),
			{ severity: input.severity }
		)
		return broadcast
	}

	async listCitizens(user: SessionUser) {
		this.assertAdmin(user)
		return db
			.select()
			.from(users)
			.where(eq(users.role, "registered_citizen"))
			.orderBy(asc(users.name))
	}

	async getCitizen(user: SessionUser, id: string) {
		this.assertAdmin(user)
		const [citizen] = await db.select().from(users).where(eq(users.id, id))
		if (!citizen || citizen.role !== "registered_citizen")
			throw new NotFoundException("Citizen not found")
		return citizen
	}

	async listStaff(user: SessionUser) {
		this.assertAdmin(user)
		const rows = await db.select().from(users).orderBy(asc(users.name))
		return rows.filter(row => STAFF_ROLES.has(row.role))
	}

	async createStaff(user: SessionUser, input: CreateStaffInput) {
		this.assertAdmin(user)
		const id = `staff-${Date.now()}`
		const now = new Date()
		const [createdStaff] = await db
			.insert(users)
			.values({
				id,
				name: input.name,
				email: input.email,
				emailVerified: true,
				role: input.role,
				status: "active",
				departmentId: input.departmentId,
				forcePasswordReset: true,
				dpaConsent: false,
				createdAt: now,
				updatedAt: now,
			})
			.returning()
		const staff = requireRow(createdStaff, "Staff user was not created")
		await db.insert(accounts).values({
			providerId: "credential",
			accountId: id,
			userId: id,
			password: hashPassword(DEFAULT_STAFF_PASSWORD),
			createdAt: now,
			updatedAt: now,
		})
		await this.audit(user.id, "create", "staff_user", id, { role: input.role })
		return staff
	}

	async analytics(user: SessionUser) {
		this.assertAdmin(user)
		const [allUsers, requests, reports, articles] = await Promise.all([
			db.select().from(users),
			this.requestRows(),
			this.reportRows(),
			db.select().from(newsArticles),
		])
		const byRequestStatus = Object.fromEntries(
			["pending", "in_review", "approved", "rejected", "for_pickup", "completed"].map(status => [
				status,
				requests.filter(row => row.status === status).length,
			])
		)
		const byReportStatus = Object.fromEntries(
			["received", "in_progress", "resolved", "closed"].map(status => [
				status,
				reports.filter(row => row.status === status).length,
			])
		)
		const byBarangay: Record<string, number> = {}
		for (const row of requests) {
			const barangay = row.barangay ?? "Unknown"
			byBarangay[barangay] = (byBarangay[barangay] ?? 0) + 1
		}
		return {
			users: allUsers.filter(row => row.role === "registered_citizen").length,
			requests: requests.length,
			reports: reports.length,
			articles: articles.length,
			byRequestStatus,
			byReportStatus,
			byBarangay,
		}
	}

	async listAuditLogs(user: SessionUser) {
		this.assertAdmin(user)
		const [logs, userMap] = await Promise.all([
			db.select().from(auditLogs).orderBy(desc(auditLogs.createdAt)),
			this.usersById(),
		])
		return logs.map(log => {
			const actor = log.actorId ? userMap.get(log.actorId) : undefined
			return { ...log, actorName: actor?.name ?? null, actorRole: actor?.role ?? null }
		})
	}

	listSettings(user: SessionUser) {
		this.assertAdmin(user)
		return db
			.select()
			.from(systemSettings)
			.orderBy(asc(systemSettings.category), asc(systemSettings.key))
	}

	async upsertSetting(user: SessionUser, input: V1Inputs["igubat"]["admin"]["upsertSetting"]) {
		this.assertAdmin(user)
		const [existing] = await db
			.select()
			.from(systemSettings)
			.where(eq(systemSettings.key, input.key))
		const payload = {
			key: input.key,
			category: input.category,
			value: input.value,
			isSecret: input.isSecret ?? false,
			updatedById: user.id,
			updatedAt: new Date(),
		}
		const [setting] = existing
			? await db
					.update(systemSettings)
					.set(payload)
					.where(eq(systemSettings.key, input.key))
					.returning()
			: await db.insert(systemSettings).values(payload).returning()
		const savedSetting = requireRow(setting, "System setting was not saved")
		await this.audit(user.id, "upsert", "system_setting", input.key)
		return savedSetting
	}
}
