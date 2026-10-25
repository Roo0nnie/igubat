import {
	BadRequestException,
	ForbiddenException,
	Injectable,
	NotFoundException,
} from "@nestjs/common"
import { and, desc, eq, ilike, inArray, isNull, lt, lte, or } from "drizzle-orm"

import {
	auditLogs,
	notificationPreferences,
	notifications,
	transparencyAttachments,
	transparencyItems,
	users,
} from "@repo/db/schema"

import { db } from "@/common/database/database.client"
import type { V1Inputs, V1Outputs } from "@/config/contract-types"

type SessionUser = {
	id: string
	name?: string
	email?: string
	role?: string | null
}

type ListQuery = {
	type?: typeof transparencyItems.$inferSelect.type
	status?: typeof transparencyItems.$inferSelect.status
	fiscalYear?: number
	barangay?: string
	search?: string
	page?: number
	limit?: number
	cursor?: number
}
type CreateInput = V1Inputs["igubat"]["admin"]["transparency"]["create"]
type UpdateInput = V1Inputs["igubat"]["admin"]["transparency"]["update"]
type PublishInput = V1Inputs["igubat"]["admin"]["transparency"]["publish"]
type DeleteInput = V1Inputs["igubat"]["admin"]["transparency"]["delete"]
type NotificationFlagInput = {
	notifyOnPublish?: boolean
}

type TransparencyRow = typeof transparencyItems.$inferSelect
type TransparencyListRow = Pick<
	TransparencyRow,
	| "id"
	| "type"
	| "referenceNumber"
	| "title"
	| "slug"
	| "summary"
	| "fiscalYear"
	| "effectiveDate"
	| "barangay"
	| "status"
	| "coverImageUrl"
	| "authorId"
	| "scheduledAt"
	| "publishedAt"
	| "archivedAt"
	| "createdAt"
	| "updatedAt"
>
type TransparencySummary = V1Outputs["igubat"]["admin"]["transparency"]["list"][number]
type TransparencyDetail = V1Outputs["igubat"]["admin"]["transparency"]["detail"]
type TransparencyMetadata = TransparencyDetail["metadata"]

const ADMIN_ROLES = new Set(["ict_admin", "super_admin"])
const STAFF_ROLES = new Set([
	"frontline_officer",
	"department_supervisor",
	"content_editor",
	"emergency_operator",
	"ict_admin",
	"super_admin",
])

const TYPE_LABELS: Record<string, string> = {
	program_project: "Programs and Projects",
	bid_procurement: "Bids and Procurement",
	financial_report: "Financial Reports",
	annual_budget: "Annual Budget",
	legislative_ordinance: "Legislative Ordinances",
	executive_order: "Executive Orders",
}

function slugify(value: string): string {
	return value
		.toLowerCase()
		.replace(/[^a-z0-9]+/g, "-")
		.replace(/^-|-$/g, "")
		.slice(0, 90)
}

function csvCell(value: unknown): string {
	const text = value === null || value === undefined ? "" : String(value)
	if (/[",\n]/.test(text)) {
		return `"${text.replace(/"/g, '""')}"`
	}
	return text
}

@Injectable()
export class TransparencyService {
	private assertStaff(user: SessionUser) {
		if (!STAFF_ROLES.has(user.role ?? "")) {
			throw new ForbiddenException("Staff access required")
		}
	}

	private requireAdmin(user: SessionUser) {
		if (!ADMIN_ROLES.has(user.role ?? "")) {
			throw new ForbiddenException("Admin access required")
		}
	}

	// Contract input ids use `z.coerce.number()`, whose *input* type (what
	// `V1Inputs` infers) is `unknown`; coerce to a validated integer here.
	private toId(value: unknown): number {
		const id = Number(value)
		if (!Number.isInteger(id) || id < 1) {
			throw new BadRequestException("id must be a positive integer")
		}
		return id
	}

	private assertMetadataMatchesType(type: TransparencyRow["type"], metadata: unknown) {
		if (!metadata || typeof metadata !== "object" || !("type" in metadata)) return
		if ((metadata as { type?: unknown }).type !== type) {
			throw new BadRequestException("metadata.type must match type")
		}
	}

	private async audit(
		actorId: string | null,
		actionType: string,
		entityId?: string,
		details?: unknown
	) {
		await db.insert(auditLogs).values({
			actorId,
			actionType,
			entityType: "transparency_item",
			entityId,
			details,
			ipAddress: "local-dev",
		})
	}

	private async authorName(authorId: string | null): Promise<string | null> {
		if (!authorId) return null
		const [author] = await db.select({ name: users.name }).from(users).where(eq(users.id, authorId))
		return author?.name ?? null
	}

	private toMetadata(metadata: TransparencyRow["metadata"]): TransparencyMetadata {
		return (metadata ?? null) as TransparencyMetadata
	}

	private toSummary(
		row: TransparencyListRow,
		authorName: string | null = null
	): TransparencySummary {
		return {
			id: row.id,
			type: row.type,
			referenceNumber: row.referenceNumber,
			title: row.title,
			slug: row.slug,
			summary: row.summary,
			fiscalYear: row.fiscalYear,
			effectiveDate: row.effectiveDate,
			barangay: row.barangay,
			status: row.status,
			coverImageUrl: row.coverImageUrl,
			authorId: row.authorId,
			scheduledAt: row.scheduledAt,
			publishedAt: row.publishedAt,
			archivedAt: row.archivedAt,
			createdAt: row.createdAt,
			updatedAt: row.updatedAt,
			authorName,
		}
	}

	private auditSnapshot(row: TransparencyRow) {
		return {
			id: row.id,
			type: row.type,
			referenceNumber: row.referenceNumber,
			title: row.title,
			slug: row.slug,
			status: row.status,
			notifyOnPublish: row.notifyOnPublish,
			scheduledAt: row.scheduledAt,
			publishedAt: row.publishedAt,
			archivedAt: row.archivedAt,
			deletedAt: row.deletedAt,
		}
	}

	private async toDetail(row: TransparencyRow): Promise<TransparencyDetail> {
		const [attachments, authorName] = await Promise.all([
			db
				.select()
				.from(transparencyAttachments)
				.where(eq(transparencyAttachments.transparencyItemId, row.id))
				.orderBy(transparencyAttachments.sortOrder),
			this.authorName(row.authorId),
		])
		return {
			...this.toSummary(row, authorName),
			body: row.body,
			metadata: this.toMetadata(row.metadata),
			notifyOnPublish: row.notifyOnPublish,
			attachments: attachments.map(attachment => ({
				id: attachment.id,
				fileName: attachment.fileName,
				fileUrl: attachment.fileUrl,
				mimeType: attachment.mimeType,
				sizeBytes: attachment.sizeBytes,
				sortOrder: attachment.sortOrder,
			})),
		}
	}

	private async rows(
		includeNonPublic: boolean,
		query?: ListQuery,
		applyLimit = true
	): Promise<TransparencyListRow[]> {
		const search = query?.search?.trim()
		const cursor = query?.cursor ? this.toId(query.cursor) : undefined
		const where = and(
			isNull(transparencyItems.deletedAt),
			!includeNonPublic ? eq(transparencyItems.status, "published") : undefined,
			query?.type ? eq(transparencyItems.type, query.type) : undefined,
			query?.status ? eq(transparencyItems.status, query.status) : undefined,
			query?.fiscalYear ? eq(transparencyItems.fiscalYear, query.fiscalYear) : undefined,
			query?.barangay ? eq(transparencyItems.barangay, query.barangay) : undefined,
			cursor ? lt(transparencyItems.id, cursor) : undefined,
			search
				? or(
						ilike(transparencyItems.title, `%${search}%`),
						ilike(transparencyItems.referenceNumber, `%${search}%`),
						ilike(transparencyItems.summary, `%${search}%`)
					)
				: undefined
		)
		const builder = db
			.select({
				id: transparencyItems.id,
				type: transparencyItems.type,
				referenceNumber: transparencyItems.referenceNumber,
				title: transparencyItems.title,
				slug: transparencyItems.slug,
				summary: transparencyItems.summary,
				fiscalYear: transparencyItems.fiscalYear,
				effectiveDate: transparencyItems.effectiveDate,
				barangay: transparencyItems.barangay,
				status: transparencyItems.status,
				coverImageUrl: transparencyItems.coverImageUrl,
				authorId: transparencyItems.authorId,
				scheduledAt: transparencyItems.scheduledAt,
				publishedAt: transparencyItems.publishedAt,
				archivedAt: transparencyItems.archivedAt,
				createdAt: transparencyItems.createdAt,
				updatedAt: transparencyItems.updatedAt,
			})
			.from(transparencyItems)
			.where(where)
			.orderBy(
				desc(transparencyItems.publishedAt),
				desc(transparencyItems.createdAt),
				desc(transparencyItems.id)
			)
		if (!applyLimit) return builder
		if (query?.page !== undefined) {
			const limit = Math.min(query.limit ?? 25, 100)
			return builder.limit(limit + 1).offset((query.page - 1) * limit)
		}
		return query?.limit ? builder.limit(Number(query.limit)) : builder
	}

	// Public

	async listPublic(query?: ListQuery) {
		const rows = await this.rows(false, query)
		const authors = await this.authorMap(rows)
		return rows.map(row => this.toSummary(row, authors.get(row.authorId ?? "") ?? null))
	}

	async getPublicBySlug(slug: string) {
		const [row] = await db
			.select()
			.from(transparencyItems)
			.where(and(eq(transparencyItems.slug, slug), isNull(transparencyItems.deletedAt)))
		if (!row || row.status !== "published") {
			throw new NotFoundException("Transparency item not found")
		}
		return this.toDetail(row)
	}

	private async authorMap(rows: TransparencyListRow[]) {
		const ids = [...new Set(rows.map(row => row.authorId).filter(Boolean))] as string[]
		if (ids.length === 0) return new Map<string, string>()
		const authors = await db
			.select({ id: users.id, name: users.name })
			.from(users)
			.where(inArray(users.id, ids))
		return new Map(authors.map(author => [author.id, author.name]))
	}

	// Admin

	async listAdmin(user: SessionUser, query?: ListQuery) {
		this.assertStaff(user)
		const rows = await this.rows(true, query)
		const authors = await this.authorMap(rows)
		return rows.map(row => this.toSummary(row, authors.get(row.authorId ?? "") ?? null))
	}

	async getAdminById(user: SessionUser, id: unknown) {
		this.assertStaff(user)
		const row = await this.requireRow(this.toId(id))
		return this.toDetail(row)
	}

	private async requireRow(id: number): Promise<TransparencyRow> {
		const [row] = await db
			.select()
			.from(transparencyItems)
			.where(and(eq(transparencyItems.id, id), isNull(transparencyItems.deletedAt)))
		if (!row) throw new NotFoundException("Transparency item not found")
		return row
	}

	private async uniqueSlug(base: string, ignoreId?: number): Promise<string> {
		const root = slugify(base) || `item-${Date.now()}`
		let candidate = root
		let suffix = 1
		while (true) {
			const [existing] = await db
				.select({ id: transparencyItems.id })
				.from(transparencyItems)
				.where(eq(transparencyItems.slug, candidate))
			if (!existing || existing.id === ignoreId) return candidate
			suffix += 1
			candidate = `${root}-${suffix}`
		}
	}

	private async replaceAttachments(itemId: number, attachments: CreateInput["attachments"]) {
		await db
			.delete(transparencyAttachments)
			.where(eq(transparencyAttachments.transparencyItemId, itemId))
		if (!attachments?.length) return
		await db.insert(transparencyAttachments).values(
			attachments.slice(0, 10).map((file, index) => ({
				transparencyItemId: itemId,
				fileName: file.fileName,
				fileUrl: file.fileUrl,
				mimeType: file.mimeType,
				sizeBytes: file.sizeBytes,
				sortOrder: file.sortOrder ?? index,
			}))
		)
	}

	async create(user: SessionUser, input: CreateInput) {
		this.assertStaff(user)
		this.assertMetadataMatchesType(input.type, input.metadata)
		const notifyOnPublish = (input as CreateInput & NotificationFlagInput).notifyOnPublish ?? false
		const status = input.status ?? "draft"
		const now = new Date()
		const slug = await this.uniqueSlug(
			`${input.referenceNumber ?? ""} ${input.title}`.trim() || input.title
		)
		const [created] = await db
			.insert(transparencyItems)
			.values({
				type: input.type,
				referenceNumber: input.referenceNumber,
				title: input.title,
				slug,
				summary: input.summary,
				body: input.body ?? "",
				fiscalYear: input.fiscalYear,
				effectiveDate: input.effectiveDate ? new Date(input.effectiveDate) : null,
				barangay: input.barangay,
				coverImageUrl: input.coverImageUrl,
				metadata: input.metadata,
				status,
				authorId: user.id,
				notifyOnPublish,
				scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : null,
				publishedAt: status === "published" ? now : null,
				archivedAt: status === "archived" ? now : null,
			})
			.returning()
		if (!created) throw new NotFoundException("Transparency item was not created")
		await this.replaceAttachments(created.id, input.attachments)
		await this.audit(user.id, "transparency.create", String(created.id), {
			after: this.auditSnapshot(created),
		})
		if (created.status === "published" && created.notifyOnPublish) {
			await this.notifySubscribers(created)
		}
		return this.toDetail(created)
	}

	async update(user: SessionUser, input: UpdateInput) {
		this.assertStaff(user)
		const id = this.toId(input.id)
		const existing = await this.requireRow(id)
		if (input.type && input.type !== existing.type && !input.metadata) {
			throw new BadRequestException("metadata is required when changing type")
		}
		const nextType = input.type ?? existing.type
		const nextMetadata = input.metadata ?? existing.metadata
		const notifyOnPublish =
			(input as UpdateInput & NotificationFlagInput).notifyOnPublish ?? existing.notifyOnPublish
		this.assertMetadataMatchesType(nextType, nextMetadata)
		const slug =
			input.title || input.referenceNumber
				? await this.uniqueSlug(
						`${input.referenceNumber ?? existing.referenceNumber ?? ""} ${input.title ?? existing.title}`.trim(),
						existing.id
					)
				: existing.slug
		const [updated] = await db
			.update(transparencyItems)
			.set({
				type: nextType,
				referenceNumber: input.referenceNumber ?? existing.referenceNumber,
				title: input.title ?? existing.title,
				slug,
				summary: input.summary ?? existing.summary,
				body: input.body ?? existing.body,
				fiscalYear: input.fiscalYear ?? existing.fiscalYear,
				effectiveDate: input.effectiveDate ? new Date(input.effectiveDate) : existing.effectiveDate,
				barangay: input.barangay ?? existing.barangay,
				coverImageUrl: input.coverImageUrl ?? existing.coverImageUrl,
				metadata: nextMetadata,
				status: input.status ?? existing.status,
				notifyOnPublish,
				scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : existing.scheduledAt,
				updatedAt: new Date(),
			})
			.where(eq(transparencyItems.id, id))
			.returning()
		if (!updated) throw new NotFoundException("Transparency item was not updated")
		if (input.attachments) await this.replaceAttachments(updated.id, input.attachments)
		await this.audit(user.id, "transparency.update", String(updated.id), {
			before: this.auditSnapshot(existing),
			after: this.auditSnapshot(updated),
		})
		return this.toDetail(updated)
	}

	async publish(user: SessionUser, input: PublishInput) {
		this.assertStaff(user)
		const id = this.toId(input.id)
		const existing = await this.requireRow(id)
		const publishAt = input.publishAt ? new Date(input.publishAt) : new Date()
		const isFuture = publishAt.getTime() > Date.now()
		const notifySubscribers = input.notifySubscribers
		const [updated] = await db
			.update(transparencyItems)
			.set({
				status: isFuture ? "scheduled" : "published",
				notifyOnPublish: notifySubscribers,
				scheduledAt: isFuture ? publishAt : null,
				publishedAt: isFuture ? null : publishAt,
				archivedAt: null,
				updatedAt: new Date(),
			})
			.where(eq(transparencyItems.id, id))
			.returning()
		if (!updated) throw new NotFoundException("Transparency item was not published")
		if (!isFuture && notifySubscribers) {
			await this.notifySubscribers(updated)
		}
		await this.audit(
			user.id,
			isFuture ? "transparency.schedule" : "transparency.publish",
			String(updated.id),
			{
				before: this.auditSnapshot(existing),
				after: this.auditSnapshot(updated),
				notifySubscribers,
				publishAt: publishAt.toISOString(),
			}
		)
		return this.toDetail(updated)
	}

	async archive(user: SessionUser, id: unknown) {
		this.assertStaff(user)
		const itemId = this.toId(id)
		const existing = await this.requireRow(itemId)
		const [updated] = await db
			.update(transparencyItems)
			.set({ status: "archived", archivedAt: new Date(), updatedAt: new Date() })
			.where(eq(transparencyItems.id, itemId))
			.returning()
		if (!updated) throw new NotFoundException("Transparency item was not archived")
		await this.audit(user.id, "transparency.archive", String(updated.id), {
			before: this.auditSnapshot(existing),
			after: this.auditSnapshot(updated),
		})
		return this.toDetail(updated)
	}

	async remove(user: SessionUser, input: DeleteInput) {
		this.assertStaff(user)
		const existing = await this.requireRow(this.toId(input.id))
		if (input.permanent) {
			this.requireAdmin(user)
			await db.delete(transparencyItems).where(eq(transparencyItems.id, existing.id))
			await this.audit(user.id, "transparency.permanent_delete", String(existing.id), {
				before: this.auditSnapshot(existing),
			})
			return { success: true, permanent: true }
		}
		await db
			.update(transparencyItems)
			.set({ deletedAt: new Date(), updatedAt: new Date() })
			.where(eq(transparencyItems.id, existing.id))
		await this.audit(user.id, "transparency.delete", String(existing.id), {
			before: this.auditSnapshot(existing),
		})
		return { success: true, permanent: false }
	}

	async exportCsv(user: SessionUser, query?: ListQuery) {
		this.requireAdmin(user)
		const filtered = await this.rows(true, query, false)
		const header = ["id", "referenceNumber", "title", "type", "fiscalYear", "status", "publishedAt"]
		const lines = [header.join(",")]
		for (const row of filtered) {
			lines.push(
				[
					row.id,
					row.referenceNumber,
					row.title,
					TYPE_LABELS[row.type] ?? row.type,
					row.fiscalYear,
					row.status,
					row.publishedAt?.toISOString() ?? "",
				]
					.map(csvCell)
					.join(",")
			)
		}
		await this.audit(user.id, "transparency.export_csv", undefined, { count: filtered.length })
		return { fileName: "transparency-items.csv", content: lines.join("\n") }
	}

	// Notification fan-out

	private async notifySubscribers(item: TransparencyRow) {
		const subscribers = await db
			.select({
				userId: notificationPreferences.userId,
			})
			.from(notificationPreferences)
			.where(
				and(
					eq(notificationPreferences.transparency, true),
					eq(notificationPreferences.pushEnabled, true)
				)
			)
		if (subscribers.length === 0) return
		const title = `New ${TYPE_LABELS[item.type] ?? "transparency"} disclosure`
		const body = item.summary ?? item.title
		const metadata = {
			type: "transparency",
			slug: item.slug,
			itemId: item.id,
			routeType: item.type,
		}
		const rows = subscribers.flatMap(subscriber =>
			(["in_app", "push"] as const).map(channel => ({
				userId: subscriber.userId,
				title,
				body,
				type: channel,
				category: "transparency" as const,
				metadata,
			}))
		)
		await db.insert(notifications).values(rows)
		await this.audit(item.authorId, "transparency.notify", String(item.id), {
			recipients: subscribers.length,
		})
	}

	// Scheduled publish sweep

	async promoteScheduled() {
		const now = new Date()
		const due = await db
			.select()
			.from(transparencyItems)
			.where(
				and(
					eq(transparencyItems.status, "scheduled"),
					isNull(transparencyItems.deletedAt),
					lte(transparencyItems.scheduledAt, now)
				)
			)
		for (const item of due) {
			const [published] = await db
				.update(transparencyItems)
				.set({ status: "published", publishedAt: now, updatedAt: now })
				.where(eq(transparencyItems.id, item.id))
				.returning()
			if (published?.notifyOnPublish) await this.notifySubscribers(published)
			await this.audit(item.authorId, "transparency.publish", String(item.id), {
				before: this.auditSnapshot(item),
				after: published ? this.auditSnapshot(published) : null,
				via: "scheduled_sweep",
			})
		}
		return { promoted: due.length }
	}
}
