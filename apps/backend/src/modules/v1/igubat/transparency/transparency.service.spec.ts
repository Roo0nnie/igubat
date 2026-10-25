import { BadRequestException, ForbiddenException } from "@nestjs/common"

import { TransparencyService } from "./transparency.service"

jest.mock("@repo/db/schema", () => ({
	auditLogs: { actorId: "actorId" },
	notificationPreferences: {
		userId: "userId",
		transparency: "transparency",
		pushEnabled: "pushEnabled",
	},
	notifications: { id: "id" },
	transparencyAttachments: {
		transparencyItemId: "transparencyItemId",
		sortOrder: "sortOrder",
	},
	transparencyItems: {
		id: "id",
		type: "type",
		status: "status",
		slug: "slug",
		authorId: "authorId",
		deletedAt: "deletedAt",
		scheduledAt: "scheduledAt",
		publishedAt: "publishedAt",
		createdAt: "createdAt",
	},
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

const baseItem = {
	id: 42,
	type: "program_project" as const,
	referenceNumber: "PRJ-2026-014",
	title: "Buenavista Beach Mangrove Rehabilitation",
	slug: "prj-2026-014-buenavista-beach-mangrove-rehabilitation",
	summary: "Rehabilitates the Buenavista mangrove coastline.",
	body: "Full project details.",
	fiscalYear: 2026,
	effectiveDate: null,
	barangay: "Buenavista",
	status: "draft" as const,
	metadata: {
		type: "program_project" as const,
		projectStatus: "ongoing" as const,
		startDate: "2026-02-01",
		costPhp: 1850000,
		implementingOffice: "MENRO",
	},
	coverImageUrl: null,
	authorId: "seed-user-editor",
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

function updateSetWhere() {
	return {
		set: jest.fn(() => ({
			where: jest.fn(async () => undefined),
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

function deleteWhere() {
	return {
		where: jest.fn(async () => undefined),
	}
}

describe("TransparencyService", () => {
	let service: TransparencyService
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
		service = new TransparencyService()
	})

	it("filters list results by type, fiscal year, search, and limit", async () => {
		const rows = [
			{ ...baseItem, authorId: null, status: "published" as const },
			{
				...baseItem,
				id: 41,
				type: "bid_procurement" as const,
				referenceNumber: "IB-2026-007",
				title: "Invitation to Bid for Road Works",
				summary: "Road concreting procurement.",
				authorId: null,
				status: "published" as const,
			},
			{
				...baseItem,
				id: 40,
				title: "Mangrove Rehabilitation Phase 2",
				fiscalYear: 2025,
				authorId: null,
				status: "published" as const,
			},
		]
		mockDb.select.mockReturnValueOnce(selectOrderBy(rows))

		const result = await service.listPublic({
			type: "program_project",
			fiscalYear: 2026,
			search: "mangrove",
			limit: 1,
		})

		expect(result).toHaveLength(1)
		expect(result[0]).toEqual(
			expect.objectContaining({
				id: 42,
				type: "program_project",
				title: "Buenavista Beach Mangrove Rehabilitation",
			})
		)
	})

	it("publishes immediately and fans out in-app plus push notifications only to push subscribers", async () => {
		const publishedItem = {
			...baseItem,
			status: "published" as const,
			notifyOnPublish: true,
			publishedAt: new Date("2026-06-10T08:00:00Z"),
		}
		mockDb.select
			.mockReturnValueOnce(selectWhere([baseItem]))
			.mockReturnValueOnce(selectWhere([{ userId: "citizen-with-push", pushEnabled: true }]))
			.mockReturnValueOnce(selectOrderBy([]))
			.mockReturnValueOnce(selectWhere([]))
		mockDb.update.mockReturnValueOnce({
			set: jest.fn(() => ({
				where: jest.fn(() => ({
					returning: jest.fn(async () => [publishedItem]),
				})),
			})),
		})

		const result = await service.publish(
			{ id: "staff-user", role: "content_editor" },
			{ id: 42, notifySubscribers: true }
		)

		const notificationRows = insertedValues.find(
			value => Array.isArray(value) && value.some(row => row.category === "transparency")
		) as Array<{ type: string; userId: string }>

		expect(result.status).toBe("published")
		expect(notificationRows).toEqual([
			expect.objectContaining({
				userId: "citizen-with-push",
				type: "in_app",
				metadata: expect.objectContaining({
					type: "transparency",
					slug: "prj-2026-014-buenavista-beach-mangrove-rehabilitation",
					itemId: 42,
					routeType: "program_project",
				}),
			}),
			expect.objectContaining({ userId: "citizen-with-push", type: "push" }),
		])
		expect(notificationRows.map(row => row.type)).not.toContain("email")
	})

	it("promotes due scheduled items and notifies subscribed users", async () => {
		const dueItem = {
			...baseItem,
			status: "scheduled" as const,
			notifyOnPublish: true,
			scheduledAt: new Date("2026-06-10T08:00:00Z"),
		}
		const publishedItem = {
			...dueItem,
			status: "published" as const,
			publishedAt: new Date("2026-06-10T08:01:00Z"),
		}
		mockDb.select
			.mockReturnValueOnce(selectWhere([dueItem]))
			.mockReturnValueOnce(selectWhere([{ userId: "citizen-user", pushEnabled: true }]))
		mockDb.update.mockReturnValueOnce(updateReturning(publishedItem))

		const result = await service.promoteScheduled()

		const notificationRows = insertedValues.find(
			value => Array.isArray(value) && value.some(row => row.category === "transparency")
		) as Array<{ type: string; userId: string }>

		expect(result).toEqual({ promoted: 1 })
		expect(notificationRows).toEqual([
			expect.objectContaining({ userId: "citizen-user", type: "in_app" }),
			expect.objectContaining({ userId: "citizen-user", type: "push" }),
		])
	})

	it("exports CSV in stable column order and audits the export", async () => {
		const publishedItem = {
			...baseItem,
			status: "published" as const,
			title: "Buenavista, Mangrove Rehabilitation",
			publishedAt: new Date("2026-06-10T08:00:00Z"),
		}
		mockDb.select.mockReturnValueOnce(selectOrderBy([publishedItem]))

		const result = await service.exportCsv({ id: "admin-user", role: "ict_admin" })

		expect(result.fileName).toBe("transparency-items.csv")
		expect(result.content.split("\n")).toEqual([
			"id,referenceNumber,title,type,fiscalYear,status,publishedAt",
			'42,PRJ-2026-014,"Buenavista, Mangrove Rehabilitation",Programs and Projects,2026,published,2026-06-10T08:00:00.000Z',
		])
		expect(insertedValues).toContainEqual(
			expect.objectContaining({
				actionType: "transparency.export_csv",
				entityType: "transparency_item",
				details: { count: 1 },
			})
		)
	})

	it("rejects CSV export for non-admin staff", async () => {
		await expect(
			service.exportCsv({ id: "staff-user", role: "content_editor" })
		).rejects.toBeInstanceOf(ForbiddenException)
		expect(mockDb.select).not.toHaveBeenCalled()
	})

	it("requires matching metadata when changing item type", async () => {
		mockDb.select.mockReturnValueOnce(selectWhere([baseItem]))

		await expect(
			service.update(
				{ id: "staff-user", role: "content_editor" },
				{ id: 42, type: "annual_budget" }
			)
		).rejects.toBeInstanceOf(BadRequestException)
		expect(mockDb.update).not.toHaveBeenCalled()
	})

	it("soft-deletes transparency items when permanent is false", async () => {
		mockDb.select.mockReturnValueOnce(selectWhere([baseItem]))
		mockDb.update.mockReturnValueOnce(updateSetWhere())

		const result = await service.remove(
			{ id: "staff-user", role: "content_editor" },
			{ id: 42, permanent: false }
		)

		expect(result).toEqual({ success: true, permanent: false })
		expect(mockDb.update).toHaveBeenCalledTimes(1)
		expect(mockDb.delete).not.toHaveBeenCalled()
	})

	it("allows permanent delete for admin users only", async () => {
		mockDb.select.mockReturnValueOnce(selectWhere([baseItem]))
		mockDb.delete.mockReturnValueOnce(deleteWhere())

		const result = await service.remove(
			{ id: "admin-user", role: "super_admin" },
			{ id: 42, permanent: true }
		)

		expect(result).toEqual({ success: true, permanent: true })
		expect(mockDb.delete).toHaveBeenCalledTimes(1)
	})

	it("rejects permanent delete for non-admin staff", async () => {
		mockDb.select.mockReturnValueOnce(selectWhere([baseItem]))

		await expect(
			service.remove({ id: "staff-user", role: "content_editor" }, { id: 42, permanent: true })
		).rejects.toBeInstanceOf(ForbiddenException)
		expect(mockDb.delete).not.toHaveBeenCalled()
	})
})
