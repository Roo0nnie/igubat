import { BadRequestException, ForbiddenException } from "@nestjs/common"

import { DiscoverGubatService } from "./discover-gubat.service"

jest.mock("@repo/db/schema", () => ({
	auditLogs: { actorId: "actorId" },
	discoverGubatEntries: {
		id: "id",
		type: "type",
		category: "category",
		status: "status",
		slug: "slug",
		authorId: "authorId",
		deletedAt: "deletedAt",
		scheduledAt: "scheduledAt",
		publishedAt: "publishedAt",
		createdAt: "createdAt",
	},
	discoverGubatPhotos: {
		discoverGubatEntryId: "discoverGubatEntryId",
		sortOrder: "sortOrder",
	},
	notificationPreferences: {
		userId: "userId",
		discoverGubat: "discoverGubat",
		pushEnabled: "pushEnabled",
	},
	notifications: { id: "id" },
	users: { id: "id" },
}))

jest.mock("@/common/database/database.client", () => ({
	db: {
		select: jest.fn(),
		insert: jest.fn(),
		update: jest.fn(),
		delete: jest.fn(),
	},
}))

type MockDb = {
	select: jest.Mock
	insert: jest.Mock
	update: jest.Mock
	delete: jest.Mock
}

const baseEntry = {
	id: 7,
	type: "tourist_spot" as const,
	title: "Buenavista Beach",
	slug: "buenavista-beach",
	summary: "Beginner-friendly surf and beach destination.",
	body: "Buenavista Beach is one of Gubat's coastal destinations.",
	category: "Beach",
	status: "draft" as const,
	coverImageUrl: null,
	mapLocation: "Buenavista, Gubat, Sorsogon",
	whereToBuy: null,
	eventDate: null,
	metadata: {
		type: "tourist_spot" as const,
		mapLocation: "Buenavista, Gubat, Sorsogon",
		latitude: 12.9201,
		longitude: 124.1234,
	},
	authorId: "staff-user",
	notifyOnPublish: false,
	scheduledAt: null,
	publishedAt: null,
	archivedAt: null,
	deletedAt: null,
	createdAt: new Date("2026-01-01T00:00:00Z"),
	updatedAt: new Date("2026-01-01T00:00:00Z"),
}

function selectWhere(result: unknown[]) {
	return {
		from: jest.fn(() => ({
			where: jest.fn(async () => result),
		})),
	}
}

function selectOrderBy(result: unknown[]) {
	let limit = Number.POSITIVE_INFINITY
	let offset = 0
	const query: {
		limit: jest.Mock
		offset: jest.Mock
		then: (
			resolve: (value: unknown[]) => unknown,
			reject?: (reason: unknown) => unknown
		) => Promise<unknown>
	} = {
		limit: jest.fn((value: number) => {
			limit = value
			return query
		}),
		offset: jest.fn((value: number) => {
			offset = value
			return query
		}),
		then: (resolve, reject) =>
			Promise.resolve(result.slice(offset, offset + limit)).then(resolve, reject),
	}
	return {
		from: jest.fn(() => ({
			where: jest.fn(() => ({
				orderBy: jest.fn(() => query),
			})),
		})),
	}
}

function updateReturning(result: unknown) {
	return {
		set: jest.fn(() => ({
			where: jest.fn(() => ({
				returning: jest.fn(async () => [result]),
			})),
		})),
	}
}

function updateSetWhere() {
	return {
		set: jest.fn(() => ({
			where: jest.fn(async () => undefined),
		})),
	}
}

function deleteWhere() {
	return {
		where: jest.fn(async () => undefined),
	}
}

describe("DiscoverGubatService", () => {
	let service: DiscoverGubatService
	let mockDb: MockDb
	let insertedValues: unknown[]

	beforeEach(() => {
		jest.clearAllMocks()
		insertedValues = []
		mockDb = require("@/common/database/database.client").db
		mockDb.insert.mockImplementation(() => ({
			values: jest.fn(async (value: unknown) => {
				insertedValues.push(value)
				return undefined
			}),
		}))
		service = new DiscoverGubatService()
	})

	it("filters public list results by type, category, search, and limit", async () => {
		const rows = [
			{ ...baseEntry, authorId: null, status: "published" as const },
			{
				...baseEntry,
				id: 6,
				type: "local_product" as const,
				title: "Timitim",
				category: "Delicacy",
				summary: "Cassava and pili cake.",
				metadata: {
					type: "local_product" as const,
					productKind: "delicacy",
					whereToBuy: "Public Market",
				},
				authorId: null,
				status: "published" as const,
			},
		]
		mockDb.select.mockReturnValueOnce(selectOrderBy(rows))

		const result = await service.listPublic({
			type: "tourist_spot",
			category: "Beach",
			search: "surf",
			limit: 1,
		})

		expect(result).toHaveLength(1)
		expect(result[0]).toEqual(
			expect.objectContaining({
				id: 7,
				type: "tourist_spot",
				title: "Buenavista Beach",
			})
		)
	})

	it("publishes immediately and fans out in-app plus push notifications to Discover Gubat subscribers", async () => {
		const publishedEntry = {
			...baseEntry,
			status: "published" as const,
			notifyOnPublish: true,
			publishedAt: new Date("2026-06-10T08:00:00Z"),
		}
		mockDb.select
			.mockReturnValueOnce(selectWhere([baseEntry]))
			.mockReturnValueOnce(selectWhere([{ userId: "citizen-with-push", pushEnabled: true }]))
			.mockReturnValueOnce(selectOrderBy([]))
			.mockReturnValueOnce(selectWhere([]))
		mockDb.update.mockReturnValueOnce(updateReturning(publishedEntry))

		const result = await service.publish(
			{ id: "staff-user", role: "content_editor" },
			{ id: 7, notifySubscribers: true }
		)

		const notificationRows = insertedValues.find(
			value => Array.isArray(value) && value.some(row => row.category === "discover_gubat")
		) as Array<{ type: string; userId: string }>

		expect(result.status).toBe("published")
		expect(notificationRows).toEqual([
			expect.objectContaining({
				userId: "citizen-with-push",
				type: "in_app",
				category: "discover_gubat",
				metadata: expect.objectContaining({
					type: "discover_gubat",
					slug: "buenavista-beach",
					entryId: 7,
					routeType: "tourist_spot",
				}),
			}),
			expect.objectContaining({ userId: "citizen-with-push", type: "push" }),
		])
		expect(notificationRows.map(row => row.type)).not.toContain("email")
	})

	it("rejects creating a tourist spot without a map location", async () => {
		await expect(
			service.create(
				{ id: "staff-user", role: "content_editor" },
				{
					type: "tourist_spot",
					title: "Hidden Beach",
					category: "Beach",
					metadata: {
						type: "tourist_spot",
					} as never,
				}
			)
		).rejects.toBeInstanceOf(BadRequestException)
		expect(mockDb.insert).not.toHaveBeenCalled()
	})

	it("promotes due scheduled entries and notifies subscribed users", async () => {
		const dueEntry = {
			...baseEntry,
			status: "scheduled" as const,
			notifyOnPublish: true,
			scheduledAt: new Date("2026-06-10T08:00:00Z"),
		}
		const publishedEntry = {
			...dueEntry,
			status: "published" as const,
			publishedAt: new Date("2026-06-10T08:01:00Z"),
		}
		mockDb.select
			.mockReturnValueOnce(selectWhere([dueEntry]))
			.mockReturnValueOnce(selectWhere([{ userId: "citizen-user", pushEnabled: true }]))
		mockDb.update.mockReturnValueOnce(updateReturning(publishedEntry))

		const result = await service.promoteScheduled()

		const notificationRows = insertedValues.find(
			value => Array.isArray(value) && value.some(row => row.category === "discover_gubat")
		) as Array<{ type: string; userId: string }>

		expect(result).toEqual({ promoted: 1 })
		expect(notificationRows).toEqual([
			expect.objectContaining({ userId: "citizen-user", type: "in_app" }),
			expect.objectContaining({ userId: "citizen-user", type: "push" }),
		])
	})

	it("soft-deletes entries when permanent is false", async () => {
		mockDb.select.mockReturnValueOnce(selectWhere([baseEntry]))
		mockDb.update.mockReturnValueOnce(updateSetWhere())

		const result = await service.remove(
			{ id: "staff-user", role: "content_editor" },
			{ id: 7, permanent: false }
		)

		expect(result).toEqual({ success: true, permanent: false })
		expect(mockDb.update).toHaveBeenCalledTimes(1)
		expect(mockDb.delete).not.toHaveBeenCalled()
	})

	it("allows permanent delete for admin users only", async () => {
		mockDb.select.mockReturnValueOnce(selectWhere([baseEntry]))
		mockDb.delete.mockReturnValueOnce(deleteWhere())

		const result = await service.remove(
			{ id: "admin-user", role: "ict_admin" },
			{ id: 7, permanent: true }
		)

		expect(result).toEqual({ success: true, permanent: true })
		expect(mockDb.delete).toHaveBeenCalledTimes(1)
	})

	it("rejects permanent delete for non-admin staff", async () => {
		mockDb.select.mockReturnValueOnce(selectWhere([baseEntry]))

		await expect(
			service.remove({ id: "staff-user", role: "content_editor" }, { id: 7, permanent: true })
		).rejects.toBeInstanceOf(ForbiddenException)
		expect(mockDb.delete).not.toHaveBeenCalled()
	})
})
