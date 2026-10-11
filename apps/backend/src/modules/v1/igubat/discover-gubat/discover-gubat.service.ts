import {
	BadRequestException,
	ForbiddenException,
	Injectable,
	NotFoundException,
} from "@nestjs/common"
import { and, desc, eq, inArray, isNull, lte } from "drizzle-orm"

import {
	auditLogs,
	discoverGubatEntries,
	discoverGubatPhotos,
	notificationPreferences,
	notifications,
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

type ListQuery = NonNullable<V1Inputs["igubat"]["public"]["discoverGubat"]["list"]>
type CreateInput = V1Inputs["igubat"]["admin"]["discoverGubat"]["create"]
type UpdateInput = V1Inputs["igubat"]["admin"]["discoverGubat"]["update"]
type PublishInput = V1Inputs["igubat"]["admin"]["discoverGubat"]["publish"]
type DeleteInput = V1Inputs["igubat"]["admin"]["discoverGubat"]["delete"]
type NotificationFlagInput = {
	notifyOnPublish?: boolean
}

type DiscoverGubatRow = typeof discoverGubatEntries.$inferSelect
type DiscoverGubatSummary = V1Outputs["igubat"]["admin"]["discoverGubat"]["list"][number]
type DiscoverGubatDetail = V1Outputs["igubat"]["admin"]["discoverGubat"]["detail"]
type DiscoverGubatMetadata = DiscoverGubatDetail["metadata"]

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
	tourist_spot: "tourist spot",
	festival_culture: "festival and culture",
	local_product: "local product",
}

type MetadataObject = {
	type?: unknown
	mapLocation?: unknown
	whereToBuy?: unknown
	eventDate?: unknown
}

function slugify(value: string): string {
	return value
		.toLowerCase()
		.replace(/[^a-z0-9]+/g, "-")
		.replace(/^-|-$/g, "")
		.slice(0, 90)
}

function metadataObject(metadata: unknown): MetadataObject {
	return metadata && typeof metadata === "object" ? (metadata as MetadataObject) : {}
}

function optionalString(value: unknown): string | undefined {
	return typeof value === "string" && value.trim() ? value.trim() : undefined
}

@Injectable()
export class DiscoverGubatService {
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

	private toId(value: unknown): number {
		const id = Number(value)
		if (!Number.isInteger(id) || id < 1) {
			throw new BadRequestException("id must be a positive integer")
		}
		return id
	}

	private assertMetadataMatchesType(type: DiscoverGubatRow["type"], metadata: unknown) {
		const meta = metadataObject(metadata)
		if (meta.type && meta.type !== type) {
			throw new BadRequestException("metadata.type must match type")
		}
	}

	private assertRequiredTypeFields(
		type: DiscoverGubatRow["type"],
		metadata: unknown,
		fields: { mapLocation?: string | null; whereToBuy?: string | null }
	) {
		const meta = metadataObject(metadata)
		const mapLocation = fields.mapLocation ?? optionalString(meta.mapLocation)
		const whereToBuy = fields.whereToBuy ?? optionalString(meta.whereToBuy)

		if (type === "tourist_spot" && !mapLocation) {
			throw new BadRequestException("mapLocation is required for tourist spots")
		}
		if (type === "local_product" && !whereToBuy) {
			throw new BadRequestException("whereToBuy is required for local products")
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
			entityType: "discover_gubat_entry",
			entityId,
			details,
			ipAddress: "local-dev",
		})
	}

	private async authorName(authorId: string | null): Promise<string | null> {
		if (!authorId) return null
		const [author] = await db.select().from(users).where(eq(users.id, authorId))
		return author?.name ?? null
	}

	private toMetadata(metadata: DiscoverGubatRow["metadata"]): DiscoverGubatMetadata {
		return (metadata ?? null) as DiscoverGubatMetadata
	}

	private toSummary(row: DiscoverGubatRow, authorName: string | null = null): DiscoverGubatSummary {
		return {
			id: row.id,
			type: row.type,
			title: row.title,
			slug: row.slug,
			summary: row.summary,
			category: row.category,
			status: row.status,
			coverImageUrl: row.coverImageUrl,
			mapLocation: row.mapLocation,
			whereToBuy: row.whereToBuy,
			eventDate: row.eventDate,
			authorId: row.authorId,
			scheduledAt: row.scheduledAt,
			publishedAt: row.publishedAt,
			archivedAt: row.archivedAt,
			createdAt: row.createdAt,
			updatedAt: row.updatedAt,
			authorName,
		}
	}

	private auditSnapshot(row: DiscoverGubatRow) {
		return {
			id: row.id,
			type: row.type,
			title: row.title,
			slug: row.slug,
			category: row.category,
			status: row.status,
			notifyOnPublish: row.notifyOnPublish,
			scheduledAt: row.scheduledAt,
			publishedAt: row.publishedAt,
			archivedAt: row.archivedAt,
			deletedAt: row.deletedAt,
		}
	}

	private async toDetail(row: DiscoverGubatRow): Promise<DiscoverGubatDetail> {
		const [photos, authorName] = await Promise.all([
			db
				.select()
				.from(discoverGubatPhotos)
				.where(eq(discoverGubatPhotos.discoverGubatEntryId, row.id))
				.orderBy(discoverGubatPhotos.sortOrder),
			this.authorName(row.authorId),
		])
		return {
			...this.toSummary(row, authorName),
			body: row.body,
			metadata: this.toMetadata(row.metadata),
			notifyOnPublish: row.notifyOnPublish,
			photos: photos.map(photo => ({
				id: photo.id,
				imageUrl: photo.imageUrl,
				altText: photo.altText,
				sortOrder: photo.sortOrder,
			})),
		}
	}

	private applyQueryFilters(rows: DiscoverGubatRow[], query?: ListQuery) {
		if (!query) return rows
		const search = query.search?.trim().toLowerCase()
		const cursor = query.cursor ? this.toId(query.cursor) : undefined
		return rows.filter(row => {
			if (cursor && row.id >= cursor) return false
			if (query.type && row.type !== query.type) return false
			if (query.status && row.status !== query.status) return false
			if (query.category && row.category !== query.category) return false
			if (search) {
				const haystack = [row.title, row.category, row.summary, row.body]
					.filter(Boolean)
					.join(" ")
					.toLowerCase()
				if (!haystack.includes(search)) return false
			}
			return true
		})
	}

	private async rows(includeNonPublic: boolean): Promise<DiscoverGubatRow[]> {
		const where = includeNonPublic
			? isNull(discoverGubatEntries.deletedAt)
			: and(isNull(discoverGubatEntries.deletedAt), eq(discoverGubatEntries.status, "published"))
		return db
			.select()
			.from(discoverGubatEntries)
			.where(where)
			.orderBy(desc(discoverGubatEntries.publishedAt), desc(discoverGubatEntries.createdAt))
	}

	private async authorMap(rows: DiscoverGubatRow[]) {
		const ids = [...new Set(rows.map(row => row.authorId).filter(Boolean))] as string[]
		if (ids.length === 0) return new Map<string, string>()
		const authors = await db.select().from(users).where(inArray(users.id, ids))
		return new Map(authors.map(author => [author.id, author.name]))
	}

	async listPublic(query?: ListQuery) {
		const filtered = this.applyQueryFilters(await this.rows(false), query)
		const limited = query?.limit ? filtered.slice(0, Number(query.limit)) : filtered
		const authors = await this.authorMap(limited)
		return limited.map(row => this.toSummary(row, authors.get(row.authorId ?? "") ?? null))
	}

	async getPublicBySlug(slug: string) {
		const [row] = await db
			.select()
			.from(discoverGubatEntries)
			.where(and(eq(discoverGubatEntries.slug, slug), isNull(discoverGubatEntries.deletedAt)))
		if (!row || row.status !== "published") {
			throw new NotFoundException("Discover Gubat entry not found")
		}
		return this.toDetail(row)
	}

	async listAdmin(user: SessionUser, query?: ListQuery) {
		this.assertStaff(user)
		const filtered = this.applyQueryFilters(await this.rows(true), query)
		const limited = query?.limit ? filtered.slice(0, Number(query.limit)) : filtered
		const authors = await this.authorMap(limited)
		return limited.map(row => this.toSummary(row, authors.get(row.authorId ?? "") ?? null))
	}

	async getAdminById(user: SessionUser, id: unknown) {
		this.assertStaff(user)
		const row = await this.requireRow(this.toId(id))
		return this.toDetail(row)
	}

	private async requireRow(id: number): Promise<DiscoverGubatRow> {
		const [row] = await db
			.select()
			.from(discoverGubatEntries)
			.where(and(eq(discoverGubatEntries.id, id), isNull(discoverGubatEntries.deletedAt)))
		if (!row) throw new NotFoundException("Discover Gubat entry not found")
		return row
	}

	private async uniqueSlug(base: string, ignoreId?: number): Promise<string> {
		const root = slugify(base) || `discover-${Date.now()}`
		let candidate = root
		let suffix = 1
		while (true) {
			const [existing] = await db
				.select({ id: discoverGubatEntries.id })
				.from(discoverGubatEntries)
				.where(eq(discoverGubatEntries.slug, candidate))
			if (!existing || existing.id === ignoreId) return candidate
			suffix += 1
			candidate = `${root}-${suffix}`
		}
	}

	private async replacePhotos(entryId: number, photos: CreateInput["photos"]) {
		await db
			.delete(discoverGubatPhotos)
			.where(eq(discoverGubatPhotos.discoverGubatEntryId, entryId))
		if (!photos?.length) return
		await db.insert(discoverGubatPhotos).values(
			photos.slice(0, 10).map((photo, index) => ({
				discoverGubatEntryId: entryId,
				imageUrl: photo.imageUrl,
				altText: photo.altText,
				sortOrder: photo.sortOrder ?? index,
			}))
		)
	}

	private derivedMapLocation(input: { mapLocation?: string; metadata?: unknown }) {
		return input.mapLocation ?? optionalString(metadataObject(input.metadata).mapLocation) ?? null
	}

	private derivedWhereToBuy(input: { whereToBuy?: string; metadata?: unknown }) {
		return input.whereToBuy ?? optionalString(metadataObject(input.metadata).whereToBuy) ?? null
	}

	private derivedEventDate(input: { eventDate?: string; metadata?: unknown }) {
		return input.eventDate ?? optionalString(metadataObject(input.metadata).eventDate)
	}

	async create(user: SessionUser, input: CreateInput) {
		this.assertStaff(user)
		this.assertMetadataMatchesType(input.type, input.metadata)
		const mapLocation = this.derivedMapLocation(input)
		const whereToBuy = this.derivedWhereToBuy(input)
		this.assertRequiredTypeFields(input.type, input.metadata, { mapLocation, whereToBuy })
		const notifyOnPublish = (input as CreateInput & NotificationFlagInput).notifyOnPublish ?? false
		const status = input.status ?? "draft"
		const now = new Date()
		const eventDate = this.derivedEventDate(input)
		const slug = await this.uniqueSlug(input.title)
		const [created] = await db
			.insert(discoverGubatEntries)
			.values({
				type: input.type,
				title: input.title,
				slug,
				summary: input.summary,
				body: input.body ?? "",
				category: input.category,
				status,
				coverImageUrl: input.coverImageUrl,
				mapLocation,
				whereToBuy,
				eventDate: eventDate ? new Date(eventDate) : null,
				metadata: input.metadata,
				authorId: user.id,
				notifyOnPublish,
				scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : null,
				publishedAt: status === "published" ? now : null,
				archivedAt: status === "archived" ? now : null,
			})
			.returning()
		if (!created) throw new NotFoundException("Discover Gubat entry was not created")
		await this.replacePhotos(created.id, input.photos)
		await this.audit(user.id, "discover_gubat.create", String(created.id), {
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
		const mapLocation =
			input.mapLocation ??
			this.derivedMapLocation({ metadata: nextMetadata }) ??
			existing.mapLocation
		const whereToBuy =
			input.whereToBuy ?? this.derivedWhereToBuy({ metadata: nextMetadata }) ?? existing.whereToBuy
		this.assertMetadataMatchesType(nextType, nextMetadata)
		this.assertRequiredTypeFields(nextType, nextMetadata, { mapLocation, whereToBuy })
		const notifyOnPublish =
			(input as UpdateInput & NotificationFlagInput).notifyOnPublish ?? existing.notifyOnPublish
		const eventDate = this.derivedEventDate({ eventDate: input.eventDate, metadata: nextMetadata })
		const slug = input.title ? await this.uniqueSlug(input.title, existing.id) : existing.slug
		const [updated] = await db
			.update(discoverGubatEntries)
			.set({
				type: nextType,
				title: input.title ?? existing.title,
				slug,
				summary: input.summary ?? existing.summary,
				body: input.body ?? existing.body,
				category: input.category ?? existing.category,
				status: input.status ?? existing.status,
				coverImageUrl: input.coverImageUrl ?? existing.coverImageUrl,
				mapLocation,
				whereToBuy,
				eventDate: eventDate ? new Date(eventDate) : existing.eventDate,
				metadata: nextMetadata,
				notifyOnPublish,
				scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : existing.scheduledAt,
				updatedAt: new Date(),
			})
			.where(eq(discoverGubatEntries.id, id))
			.returning()
		if (!updated) throw new NotFoundException("Discover Gubat entry was not updated")
		if (input.photos) await this.replacePhotos(updated.id, input.photos)
		await this.audit(user.id, "discover_gubat.update", String(updated.id), {
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
			.update(discoverGubatEntries)
			.set({
				status: isFuture ? "scheduled" : "published",
				notifyOnPublish: notifySubscribers,
				scheduledAt: isFuture ? publishAt : null,
				publishedAt: isFuture ? null : publishAt,
				archivedAt: null,
				updatedAt: new Date(),
			})
			.where(eq(discoverGubatEntries.id, id))
			.returning()
		if (!updated) throw new NotFoundException("Discover Gubat entry was not published")
		if (!isFuture && notifySubscribers) {
			await this.notifySubscribers(updated)
		}
		await this.audit(
			user.id,
			isFuture ? "discover_gubat.schedule" : "discover_gubat.publish",
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
		const entryId = this.toId(id)
		const existing = await this.requireRow(entryId)
		const [updated] = await db
			.update(discoverGubatEntries)
			.set({ status: "archived", archivedAt: new Date(), updatedAt: new Date() })
			.where(eq(discoverGubatEntries.id, entryId))
			.returning()
		if (!updated) throw new NotFoundException("Discover Gubat entry was not archived")
		await this.audit(user.id, "discover_gubat.archive", String(updated.id), {
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
			await db.delete(discoverGubatEntries).where(eq(discoverGubatEntries.id, existing.id))
			await this.audit(user.id, "discover_gubat.permanent_delete", String(existing.id), {
				before: this.auditSnapshot(existing),
			})
			return { success: true, permanent: true }
		}
		await db
			.update(discoverGubatEntries)
			.set({ deletedAt: new Date(), updatedAt: new Date() })
			.where(eq(discoverGubatEntries.id, existing.id))
		await this.audit(user.id, "discover_gubat.delete", String(existing.id), {
			before: this.auditSnapshot(existing),
		})
		return { success: true, permanent: false }
	}

	private async notifySubscribers(entry: DiscoverGubatRow) {
		const subscribers = await db
			.select({
				userId: notificationPreferences.userId,
			})
			.from(notificationPreferences)
			.where(
				and(
					eq(notificationPreferences.discoverGubat, true),
					eq(notificationPreferences.pushEnabled, true)
				)
			)
		if (subscribers.length === 0) return
		const title = `New Discover Gubat ${TYPE_LABELS[entry.type] ?? "entry"}`
		const body = entry.summary ?? entry.title
		const metadata = {
			type: "discover_gubat",
			slug: entry.slug,
			entryId: entry.id,
			routeType: entry.type,
		}
		const rows = subscribers.flatMap(subscriber =>
			(["in_app", "push"] as const).map(channel => ({
				userId: subscriber.userId,
				title,
				body,
				type: channel,
				category: "discover_gubat" as const,
				metadata,
			}))
		)
		await db.insert(notifications).values(rows)
		await this.audit(entry.authorId, "discover_gubat.notify", String(entry.id), {
			recipients: subscribers.length,
		})
	}

	async promoteScheduled() {
		const now = new Date()
		const due = await db
			.select()
			.from(discoverGubatEntries)
			.where(
				and(
					eq(discoverGubatEntries.status, "scheduled"),
					isNull(discoverGubatEntries.deletedAt),
					lte(discoverGubatEntries.scheduledAt, now)
				)
			)
		for (const entry of due) {
			const [published] = await db
				.update(discoverGubatEntries)
				.set({ status: "published", publishedAt: now, updatedAt: now })
				.where(eq(discoverGubatEntries.id, entry.id))
				.returning()
			if (published?.notifyOnPublish) await this.notifySubscribers(published)
			await this.audit(entry.authorId, "discover_gubat.publish", String(entry.id), {
				before: this.auditSnapshot(entry),
				after: published ? this.auditSnapshot(published) : null,
				via: "scheduled_sweep",
			})
		}
		return { promoted: due.length }
	}
}
