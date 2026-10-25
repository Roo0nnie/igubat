import {
	BadRequestException,
	ForbiddenException,
	Injectable,
	NotFoundException,
} from "@nestjs/common"
import { randomBytes, scryptSync } from "node:crypto"
import { and, asc, count, desc, eq, gte, ilike, inArray, isNull, or } from "drizzle-orm"
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

type PublicListQuery = {
	search?: string
	status?: string
	category?: string
	barangay?: string
	serviceType?: string
	dateFrom?: string
	dateTo?: string
	page?: number
	limit?: number
}
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
type PublicNewsArticle = Pick<
	typeof newsArticles.$inferSelect,
	| "id"
	| "title"
	| "slug"
	| "excerpt"
	| "category"
	| "status"
	| "imageUrl"
	| "isFeatured"
	| "publishedAt"
	| "createdAt"
	| "updatedAt"
>
type AdminNewsArticle = PublicNewsArticle

type ListWindow = { limit: number; offset: number }

function listWindow(query?: { page?: number; limit?: number }): ListWindow | undefined {
	if (query?.page === undefined) return undefined
	const limit = Math.min(query.limit ?? 25, 100)
	return { limit, offset: (query.page - 1) * limit }
}

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

	private requestSelection() {
		return {
			id: serviceRequests.id,
			trackingNumber: serviceRequests.trackingNumber,
			serviceTypeId: serviceRequests.serviceTypeId,
			serviceType: serviceRequests.serviceType,
			description: serviceRequests.description,
			preferredDate: serviceRequests.preferredDate,
			status: serviceRequests.status,
			departmentId: serviceRequests.departmentId,
			assignedOfficerId: serviceRequests.assignedOfficerId,
			authorId: serviceRequests.authorId,
			publicRemarks: serviceRequests.publicRemarks,
			internalNotes: serviceRequests.internalNotes,
			createdAt: serviceRequests.createdAt,
			updatedAt: serviceRequests.updatedAt,
			citizenName: users.name,
			barangay: users.barangay,
		}
	}

	private async requestRows(options: { query?: PublicListQuery; authorId?: string } = {}) {
		const { query, authorId } = options
		const search = query?.search?.trim()
		const filters = [
			authorId ? eq(serviceRequests.authorId, authorId) : undefined,
			query?.status ? eq(serviceRequests.status, query.status as never) : undefined,
			query?.serviceType ? eq(serviceRequests.serviceType, query.serviceType) : undefined,
			query?.barangay ? eq(users.barangay, query.barangay) : undefined,
			search
				? or(
						ilike(serviceRequests.trackingNumber, `%${search}%`),
						ilike(serviceRequests.serviceType, `%${search}%`),
						ilike(users.name, `%${search}%`)
					)
				: undefined,
		]
		const window = listWindow(query)
		const request = db
			.select(this.requestSelection())
			.from(serviceRequests)
			.leftJoin(users, eq(serviceRequests.authorId, users.id))
			.where(and(...filters))
			.orderBy(desc(serviceRequests.createdAt), desc(serviceRequests.id))
		if (window) return request.limit(window.limit + 1).offset(window.offset)
		if (query?.limit) return request.limit(query.limit)
		return request
	}

	private reportSelection() {
		return {
			id: citizenReports.id,
			category: citizenReports.category,
			description: citizenReports.description,
			status: citizenReports.status,
			barangay: citizenReports.barangay,
			locationAddress: citizenReports.locationAddress,
			latitude: citizenReports.latitude,
			longitude: citizenReports.longitude,
			publicRemarks: citizenReports.publicRemarks,
			internalNotes: citizenReports.internalNotes,
			departmentId: citizenReports.departmentId,
			assignedOfficerId: citizenReports.assignedOfficerId,
			authorId: citizenReports.authorId,
			createdAt: citizenReports.createdAt,
			updatedAt: citizenReports.updatedAt,
			citizenName: users.name,
		}
	}

	private async reportRows(options: { query?: PublicListQuery; authorId?: string } = {}) {
		const { query, authorId } = options
		const search = query?.search?.trim()
		const filters = [
			authorId ? eq(citizenReports.authorId, authorId) : undefined,
			query?.status ? eq(citizenReports.status, query.status as never) : undefined,
			query?.category ? eq(citizenReports.category, query.category as never) : undefined,
			query?.barangay ? eq(citizenReports.barangay, query.barangay) : undefined,
			search
				? or(
						ilike(citizenReports.category, `%${search}%`),
						ilike(citizenReports.description, `%${search}%`),
						ilike(citizenReports.locationAddress, `%${search}%`),
						ilike(users.name, `%${search}%`)
					)
				: undefined,
		]
		const window = listWindow(query)
		const request = db
			.select(this.reportSelection())
			.from(citizenReports)
			.leftJoin(users, eq(citizenReports.authorId, users.id))
			.where(and(...filters))
			.orderBy(desc(citizenReports.createdAt), desc(citizenReports.id))
		if (window) return request.limit(window.limit + 1).offset(window.offset)
		if (query?.limit) return request.limit(query.limit)
		return request
	}

	async publicDashboard() {
		return this.dashboardSummary(false)
	}

	private async dashboardSummary(includeRecentActivity: boolean) {
		const [
			[userCount],
			requestCounts,
			reportCounts,
			[activeServices],
			[publishedAnnouncements],
			recentRequests,
			recentReports,
			upcomingEvents,
			[upcomingEventCount],
			statsConfig,
		] = await Promise.all([
			db.select({ value: count() }).from(users).where(eq(users.role, "registered_citizen")),
			db
				.select({ status: serviceRequests.status, value: count() })
				.from(serviceRequests)
				.groupBy(serviceRequests.status),
			db
				.select({ status: citizenReports.status, value: count() })
				.from(citizenReports)
				.groupBy(citizenReports.status),
			db.select({ value: count() }).from(serviceTypes).where(eq(serviceTypes.isActive, true)),
			db
				.select({ value: count() })
				.from(newsArticles)
				.where(and(eq(newsArticles.status, "published"), isNull(newsArticles.deletedAt))),
			includeRecentActivity
				? db
						.select(this.requestSelection())
						.from(serviceRequests)
						.leftJoin(users, eq(serviceRequests.authorId, users.id))
						.orderBy(desc(serviceRequests.createdAt), desc(serviceRequests.id))
						.limit(5)
				: Promise.resolve([]),
			includeRecentActivity
				? db
						.select(this.reportSelection())
						.from(citizenReports)
						.leftJoin(users, eq(citizenReports.authorId, users.id))
						.orderBy(desc(citizenReports.createdAt), desc(citizenReports.id))
						.limit(5)
				: Promise.resolve([]),
			includeRecentActivity ? this.listEvents(5) : Promise.resolve([]),
			db.select({ value: count() }).from(events).where(this.upcomingEventsCondition(new Date())),
			this.communityStatsConfig(),
		])

		const requestCountByStatus = new Map(requestCounts.map(row => [row.status, row.value]))
		const reportCountByStatus = new Map(reportCounts.map(row => [row.status, row.value]))
		const totals = {
			totalUsers: userCount?.value ?? 0,
			pendingRequests: requestCountByStatus.get("pending") ?? 0,
			activeServices: activeServices?.value ?? 0,
			newReports: reportCountByStatus.get("received") ?? 0,
			publishedAnnouncements: publishedAnnouncements?.value ?? 0,
		}
		const values: Record<CommunityStatKey, number> = {
			registered_citizens: totals.totalUsers,
			pending_requests: totals.pendingRequests,
			completed_requests: requestCountByStatus.get("completed") ?? 0,
			active_services: totals.activeServices,
			new_reports: totals.newReports,
			published_news: totals.publishedAnnouncements,
			upcoming_events: upcomingEventCount?.value ?? 0,
		}

		return {
			...totals,
			recentRequests,
			recentReports,
			upcomingEvents,
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

	async listNews(
		query: PublicListQuery | undefined,
		includeDrafts: true
	): Promise<AdminNewsArticle[]>
	async listNews(query?: PublicListQuery, includeDrafts?: false): Promise<PublicNewsArticle[]>
	async listNews(
		query?: PublicListQuery,
		includeDrafts = false
	): Promise<AdminNewsArticle[] | PublicNewsArticle[]> {
		const search = query?.search?.trim()
		const filters = [
			!includeDrafts ? eq(newsArticles.status, "published") : undefined,
			!includeDrafts ? isNull(newsArticles.deletedAt) : undefined,
			query?.status ? eq(newsArticles.status, query.status as never) : undefined,
			query?.category ? eq(newsArticles.category, query.category) : undefined,
			search
				? or(ilike(newsArticles.title, `%${search}%`), ilike(newsArticles.excerpt, `%${search}%`))
				: undefined,
		]
		const window = listWindow(query)
		const builder = includeDrafts
			? db
					.select({
						id: newsArticles.id,
						title: newsArticles.title,
						slug: newsArticles.slug,
						excerpt: newsArticles.excerpt,
						category: newsArticles.category,
						status: newsArticles.status,
						imageUrl: newsArticles.imageUrl,
						isFeatured: newsArticles.isFeatured,
						publishedAt: newsArticles.publishedAt,
						createdAt: newsArticles.createdAt,
						updatedAt: newsArticles.updatedAt,
					})
					.from(newsArticles)
					.where(and(...filters))
					.orderBy(
						desc(newsArticles.publishedAt),
						desc(newsArticles.createdAt),
						desc(newsArticles.id)
					)
			: db
					.select({
						id: newsArticles.id,
						title: newsArticles.title,
						slug: newsArticles.slug,
						excerpt: newsArticles.excerpt,
						category: newsArticles.category,
						status: newsArticles.status,
						imageUrl: newsArticles.imageUrl,
						isFeatured: newsArticles.isFeatured,
						publishedAt: newsArticles.publishedAt,
						createdAt: newsArticles.createdAt,
						updatedAt: newsArticles.updatedAt,
					})
					.from(newsArticles)
					.where(and(...filters))
					.orderBy(
						desc(newsArticles.publishedAt),
						desc(newsArticles.createdAt),
						desc(newsArticles.id)
					)
		if (window) return builder.limit(window.limit + 1).offset(window.offset)
		return builder.limit(query?.limit ?? 50)
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

	private upcomingEventsCondition(now: Date) {
		return and(
			eq(events.status, "published"),
			isNull(events.deletedAt),
			or(gte(events.endsAt, now), and(isNull(events.endsAt), gte(events.startsAt, now)))
		)
	}

	/** Published events that haven't ended yet, soonest first. */
	listEvents(limit?: number) {
		const query = db
			.select({
				id: events.id,
				title: events.title,
				slug: events.slug,
				category: events.category,
				location: events.location,
				imageUrl: events.imageUrl,
				status: events.status,
				startsAt: events.startsAt,
				endsAt: events.endsAt,
				publishedAt: events.publishedAt,
			})
			.from(events)
			.where(this.upcomingEventsCondition(new Date()))
			.orderBy(asc(events.startsAt))
		return query.limit(limit ?? 50)
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
		const search = query?.search?.trim()
		const filters = [
			isNull(events.deletedAt),
			query?.status ? eq(events.status, query.status as never) : undefined,
			query?.category ? eq(events.category, query.category) : undefined,
			search
				? or(
						ilike(events.title, `%${search}%`),
						ilike(events.location, `%${search}%`),
						ilike(events.category, `%${search}%`)
					)
				: undefined,
		]
		const builder = db
			.select({
				id: events.id,
				title: events.title,
				slug: events.slug,
				category: events.category,
				location: events.location,
				imageUrl: events.imageUrl,
				status: events.status,
				startsAt: events.startsAt,
				endsAt: events.endsAt,
				publishedAt: events.publishedAt,
			})
			.from(events)
			.where(and(...filters))
			.orderBy(desc(events.startsAt), desc(events.id))
		const window = listWindow(query)
		if (window) return builder.limit(window.limit + 1).offset(window.offset)
		const limit = Number(query?.limit ?? 100)
		return builder.limit(Number.isFinite(limit) ? Math.min(Math.max(limit, 1), 100) : 100)
	}

	async getAdminEvent(user: SessionUser, id: number) {
		this.assertStaff(user)
		const [event] = await db
			.select()
			.from(events)
			.where(and(eq(events.id, id), isNull(events.deletedAt)))
			.limit(1)
		return requireRow(event, "Event not found")
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
		const search = query?.search?.trim()
		const categoryId =
			query?.category && Number.isInteger(Number(query.category))
				? Number(query.category)
				: undefined
		const builder = db
			.select({
				id: serviceTypes.id,
				categoryId: serviceTypes.categoryId,
				name: serviceTypes.name,
				slug: serviceTypes.slug,
				description: serviceTypes.description,
				processingDays: serviceTypes.processingDays,
				icon: serviceTypes.icon,
				imageUrl: serviceTypes.imageUrl,
				isPopular: serviceTypes.isPopular,
				isActive: serviceTypes.isActive,
			})
			.from(serviceTypes)
			.where(
				and(
					eq(serviceTypes.isActive, true),
					categoryId !== undefined ? eq(serviceTypes.categoryId, categoryId) : undefined,
					search
						? or(
								ilike(serviceTypes.name, `%${search}%`),
								ilike(serviceTypes.description, `%${search}%`)
							)
						: undefined
				)
			)
			.orderBy(asc(serviceTypes.name))
		return builder.limit(query?.limit ?? 100)
	}

	async getService(slug: string) {
		const [service] = await db.select().from(serviceTypes).where(eq(serviceTypes.slug, slug))
		if (!service || !service.isActive) throw new NotFoundException("Service not found")
		return service
	}

	listEmergencyDirectory() {
		return db
			.select({
				id: emergencyDirectory.id,
				name: emergencyDirectory.name,
				type: emergencyDirectory.type,
				contactNumber: emergencyDirectory.contactNumber,
				address: emergencyDirectory.address,
				hours: emergencyDirectory.hours,
				isActive: emergencyDirectory.isActive,
			})
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
		const [profile] = await db
			.select({
				id: users.id,
				name: users.name,
				email: users.email,
				image: users.image,
				role: users.role,
				status: users.status,
				mobileNumber: users.mobileNumber,
				barangay: users.barangay,
				address: users.address,
				departmentId: users.departmentId,
				createdAt: users.createdAt,
				updatedAt: users.updatedAt,
				lastLoginAt: users.lastLoginAt,
				forcePasswordReset: users.forcePasswordReset,
			})
			.from(users)
			.where(eq(users.id, user.id))
		if (!profile) throw new NotFoundException("Profile not found")
		return profile
	}

	async updateProfile(user: SessionUser, input: V1Inputs["igubat"]["me"]["updateProfile"]) {
		const [profile] = await db
			.update(users)
			.set({ ...input, updatedAt: new Date() })
			.where(eq(users.id, user.id))
			.returning({
				id: users.id,
				name: users.name,
				email: users.email,
				image: users.image,
				role: users.role,
				status: users.status,
				mobileNumber: users.mobileNumber,
				barangay: users.barangay,
				address: users.address,
				departmentId: users.departmentId,
				createdAt: users.createdAt,
				updatedAt: users.updatedAt,
				lastLoginAt: users.lastLoginAt,
				forcePasswordReset: users.forcePasswordReset,
			})
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
		return this.requestRows({ authorId: user.id })
	}

	async getRequestDetail(id: number, user?: SessionUser, staff = false) {
		if (!staff && !user) throw new ForbiddenException("Cannot view a citizen request")
		const [request] = await db
			.select(this.requestSelection())
			.from(serviceRequests)
			.leftJoin(users, eq(serviceRequests.authorId, users.id))
			.where(
				and(
					eq(serviceRequests.id, id),
					!staff && user ? eq(serviceRequests.authorId, user.id) : undefined
				)
			)
			.limit(1)
		if (!request) throw new NotFoundException("Request not found")
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
		return this.reportRows({ authorId: user.id })
	}

	async getReportDetail(id: number, user?: SessionUser, staff = false) {
		if (!staff && !user) throw new ForbiddenException("Cannot view a citizen report")
		const [report] = await db
			.select(this.reportSelection())
			.from(citizenReports)
			.leftJoin(users, eq(citizenReports.authorId, users.id))
			.where(
				and(
					eq(citizenReports.id, id),
					!staff && user ? eq(citizenReports.authorId, user.id) : undefined
				)
			)
			.limit(1)
		if (!report) throw new NotFoundException("Report not found")
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
		return this.dashboardSummary(true)
	}

	async listAdminRequests(user: SessionUser, query?: PublicListQuery) {
		this.assertStaff(user)
		return this.requestRows({ query })
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
		return this.reportRows({ query })
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

	async getAdminArticle(user: SessionUser, id: number) {
		this.assertStaff(user)
		const [article] = await db.select().from(newsArticles).where(eq(newsArticles.id, id)).limit(1)
		return requireRow(article, "News article not found")
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

	listBroadcasts(user: SessionUser, query?: PublicListQuery) {
		this.assertStaff(user)
		const builder = db
			.select({
				id: emergencyBroadcasts.id,
				title: emergencyBroadcasts.title,
				message: emergencyBroadcasts.message,
				severity: emergencyBroadcasts.severity,
				status: emergencyBroadcasts.status,
				scheduledAt: emergencyBroadcasts.scheduledAt,
				sentAt: emergencyBroadcasts.sentAt,
				senderId: emergencyBroadcasts.senderId,
				recipientCount: emergencyBroadcasts.recipientCount,
				createdAt: emergencyBroadcasts.createdAt,
			})
			.from(emergencyBroadcasts)
			.orderBy(desc(emergencyBroadcasts.createdAt), desc(emergencyBroadcasts.id))
		const window = listWindow(query)
		if (window) return builder.limit(window.limit + 1).offset(window.offset)
		return builder.limit(query?.limit ?? 50)
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
					? ((
							await db
								.select({ value: count() })
								.from(users)
								.where(eq(users.role, "registered_citizen"))
						)[0]?.value ?? 0)
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

	async listCitizens(user: SessionUser, query?: PublicListQuery) {
		this.assertAdmin(user)
		const search = query?.search?.trim()
		const filters = [
			eq(users.role, "registered_citizen"),
			query?.status ? eq(users.status, query.status as never) : undefined,
			search
				? or(
						ilike(users.name, `%${search}%`),
						ilike(users.email, `%${search}%`),
						ilike(users.barangay, `%${search}%`)
					)
				: undefined,
		]
		const builder = db
			.select({
				id: users.id,
				name: users.name,
				email: users.email,
				image: users.image,
				role: users.role,
				status: users.status,
				mobileNumber: users.mobileNumber,
				barangay: users.barangay,
				address: users.address,
				departmentId: users.departmentId,
				createdAt: users.createdAt,
				lastLoginAt: users.lastLoginAt,
				forcePasswordReset: users.forcePasswordReset,
			})
			.from(users)
			.where(and(...filters))
			.orderBy(asc(users.name), asc(users.id))
		const window = listWindow(query)
		if (window) return builder.limit(window.limit + 1).offset(window.offset)
		if (query?.limit) return builder.limit(query.limit)
		return builder
	}

	async getCitizen(user: SessionUser, id: string) {
		this.assertAdmin(user)
		const [citizen] = await db
			.select({
				id: users.id,
				name: users.name,
				email: users.email,
				image: users.image,
				role: users.role,
				status: users.status,
				mobileNumber: users.mobileNumber,
				barangay: users.barangay,
				address: users.address,
				departmentId: users.departmentId,
				createdAt: users.createdAt,
				lastLoginAt: users.lastLoginAt,
				forcePasswordReset: users.forcePasswordReset,
			})
			.from(users)
			.where(and(eq(users.id, id), eq(users.role, "registered_citizen")))
		if (!citizen || citizen.role !== "registered_citizen")
			throw new NotFoundException("Citizen not found")
		return citizen
	}

	async listStaff(user: SessionUser, query?: PublicListQuery) {
		this.assertAdmin(user)
		const search = query?.search?.trim()
		const staffRoles = [...STAFF_ROLES] as (typeof users.$inferSelect)["role"][]
		const builder = db
			.select({
				id: users.id,
				name: users.name,
				email: users.email,
				image: users.image,
				role: users.role,
				status: users.status,
				mobileNumber: users.mobileNumber,
				barangay: users.barangay,
				address: users.address,
				departmentId: users.departmentId,
				createdAt: users.createdAt,
				lastLoginAt: users.lastLoginAt,
				forcePasswordReset: users.forcePasswordReset,
			})
			.from(users)
			.where(
				and(
					inArray(users.role, staffRoles),
					search
						? or(
								ilike(users.name, `%${search}%`),
								ilike(users.email, `%${search}%`),
								ilike(users.role, `%${search}%`)
							)
						: undefined
				)
			)
			.orderBy(asc(users.name), asc(users.id))
		const window = listWindow(query)
		if (window) return builder.limit(window.limit + 1).offset(window.offset)
		if (query?.limit) return builder.limit(query.limit)
		return builder
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
		const [[userCount], requestCounts, reportCounts, [articleCount], requestCountsByBarangay] =
			await Promise.all([
				db.select({ value: count() }).from(users).where(eq(users.role, "registered_citizen")),
				db
					.select({ status: serviceRequests.status, value: count() })
					.from(serviceRequests)
					.groupBy(serviceRequests.status),
				db
					.select({ status: citizenReports.status, value: count() })
					.from(citizenReports)
					.groupBy(citizenReports.status),
				db.select({ value: count() }).from(newsArticles),
				db
					.select({ barangay: users.barangay, value: count() })
					.from(serviceRequests)
					.leftJoin(users, eq(serviceRequests.authorId, users.id))
					.groupBy(users.barangay),
			])
		const byRequestStatus = Object.fromEntries(requestCounts.map(row => [row.status, row.value]))
		const byReportStatus = Object.fromEntries(reportCounts.map(row => [row.status, row.value]))
		const byBarangay: Record<string, number> = {}
		for (const row of requestCountsByBarangay) {
			const barangay = row.barangay ?? "Unknown"
			byBarangay[barangay] = (byBarangay[barangay] ?? 0) + row.value
		}
		const requestTotal = requestCounts.reduce((total, row) => total + row.value, 0)
		const reportTotal = reportCounts.reduce((total, row) => total + row.value, 0)
		return {
			users: userCount?.value ?? 0,
			requests: requestTotal,
			reports: reportTotal,
			articles: articleCount?.value ?? 0,
			byRequestStatus,
			byReportStatus,
			byBarangay,
		}
	}

	async listAuditLogs(user: SessionUser, query?: PublicListQuery) {
		this.assertAdmin(user)
		const search = query?.search?.trim()
		const builder = db
			.select({
				id: auditLogs.id,
				actorId: auditLogs.actorId,
				actionType: auditLogs.actionType,
				entityType: auditLogs.entityType,
				entityId: auditLogs.entityId,
				details: auditLogs.details,
				ipAddress: auditLogs.ipAddress,
				createdAt: auditLogs.createdAt,
				actorName: users.name,
				actorRole: users.role,
			})
			.from(auditLogs)
			.leftJoin(users, eq(auditLogs.actorId, users.id))
			.where(
				and(
					search
						? or(
								ilike(auditLogs.actionType, `%${search}%`),
								ilike(auditLogs.entityType, `%${search}%`),
								ilike(users.name, `%${search}%`)
							)
						: undefined
				)
			)
			.orderBy(desc(auditLogs.createdAt), desc(auditLogs.id))
		const window = listWindow(query)
		if (window) return builder.limit(window.limit + 1).offset(window.offset)
		if (query?.limit) return builder.limit(query.limit)
		return builder
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
