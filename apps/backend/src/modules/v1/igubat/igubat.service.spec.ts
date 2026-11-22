import { ForbiddenException, NotFoundException } from "@nestjs/common"

import {
	auditLogs,
	citizenReports,
	citizenReportStatusHistory,
	notifications,
	serviceRequests,
	serviceRequestStatusHistory,
} from "@repo/db/schema"

import { db } from "@/common/database/database.client"

import { IgubatService } from "./igubat.service"

// The service only needs community-stats constants from the contracts package;
// loading the real package would pull in ESM-only oRPC modules Jest cannot parse.
jest.mock("@repo/contracts", () => ({
	COMMUNITY_STATS_SETTING_KEY: "community_stats",
	CommunityStatConfigSchema: { array: () => ({ safeParse: () => ({ success: false }) }) },
	DEFAULT_COMMUNITY_STATS: [],
}))

jest.mock("@/common/database/database.client", () => ({
	db: {
		select: jest.fn(),
		insert: jest.fn(),
		update: jest.fn(),
		delete: jest.fn(),
	},
}))

/**
 * Minimal stand-in for Drizzle's fluent query builder.
 *
 * Every builder method returns the same chain, and awaiting the chain resolves
 * to `result`. Writes are recorded so tests can assert which table received
 * which values without a real PostgreSQL instance.
 */
function chain(result: unknown) {
	const target: Record<string, unknown> = {
		then: (resolve: (v: unknown) => unknown, reject: (e: unknown) => unknown) =>
			Promise.resolve(result).then(resolve, reject),
	}
	const proxy: unknown = new Proxy(target, {
		get(obj, prop: string) {
			if (prop in obj) return obj[prop]
			return () => proxy
		},
	})
	return proxy
}

type Write = { table: unknown; values: unknown }

const mockDb = db as unknown as Record<"select" | "insert" | "update" | "delete", jest.Mock>

let selectResults: unknown[][]
let returningResults: Map<unknown, unknown[]>
let inserts: Write[]
let updates: Write[]

function queueSelects(...results: unknown[][]) {
	selectResults.push(...results)
}

function insertsInto(table: unknown) {
	return inserts.filter(write => write.table === table).map(write => write.values)
}

beforeEach(() => {
	jest.clearAllMocks()
	selectResults = []
	returningResults = new Map()
	inserts = []
	updates = []

	mockDb.select.mockImplementation(() => chain(selectResults.shift() ?? []))
	mockDb.insert.mockImplementation((table: unknown) => ({
		values: (values: unknown) => {
			inserts.push({ table, values })
			return chain(returningResults.get(table) ?? [])
		},
	}))
	mockDb.update.mockImplementation((table: unknown) => ({
		set: (values: unknown) => {
			updates.push({ table, values })
			return chain(returningResults.get(table) ?? [])
		},
	}))
})

const citizen = { id: "citizen-1", name: "Citizen", role: "registered_citizen" }
const officer = { id: "staff-1", name: "Officer", role: "frontline_officer" }
const ictAdmin = { id: "admin-1", name: "ICT Admin", role: "ict_admin" }

const requestRow = {
	id: 7,
	trackingNumber: "BP-2026-00007",
	serviceType: "Business Permit",
	status: "pending",
	authorId: citizen.id,
	publicRemarks: null,
	internalNotes: null,
}

const reportRow = {
	id: 11,
	category: "Road Damage",
	status: "received",
	authorId: citizen.id,
	publicRemarks: null,
	internalNotes: null,
}

const history = [
	{ id: 1, status: "received", visibility: "public" },
	{ id: 2, status: "in_progress", visibility: "internal" },
]

describe("IgubatService", () => {
	let service: IgubatService

	beforeEach(() => {
		service = new IgubatService()
	})

	describe("role checks", () => {
		it("rejects citizens from staff-only status updates", async () => {
			await expect(
				service.updateRequestStatus(citizen, { id: 7, status: "approved" })
			).rejects.toThrow(new ForbiddenException("Staff access required"))
			await expect(
				service.updateReportStatus(citizen, { id: 11, status: "resolved" })
			).rejects.toThrow(new ForbiddenException("Staff access required"))
			expect(mockDb.update).not.toHaveBeenCalled()
		})

		it("treats a missing role as non-staff", async () => {
			await expect(service.adminDashboard({ id: "anon", role: null })).rejects.toThrow(
				ForbiddenException
			)
		})

		it("rejects non-admin staff from the audit log", async () => {
			await expect(service.listAuditLogs(officer)).rejects.toThrow(
				new ForbiddenException("Admin access required")
			)
			expect(mockDb.select).not.toHaveBeenCalled()
		})

		it("allows ICT admins to read the audit log", async () => {
			const entry = { id: 1, actionType: "status_change", entityType: "service_request" }
			queueSelects([entry])

			await expect(service.listAuditLogs(ictAdmin)).resolves.toEqual([entry])
		})
	})

	describe("service request status changes", () => {
		it("updates the status, records history, notifies the citizen and appends an audit entry", async () => {
			queueSelects([requestRow], [], [])
			returningResults.set(serviceRequests, [{ ...requestRow, status: "approved" }])
			queueSelects([{ ...requestRow, status: "approved" }], [], [])

			await service.updateRequestStatus(officer, {
				id: 7,
				status: "approved",
				remarks: "Ready for payment.",
			})

			expect(updates).toHaveLength(1)
			expect(updates[0]).toMatchObject({
				table: serviceRequests,
				values: { status: "approved", publicRemarks: "Ready for payment." },
			})
			expect(insertsInto(serviceRequestStatusHistory)).toEqual([
				{
					serviceRequestId: 7,
					status: "approved",
					remarks: "Ready for payment.",
					visibility: "public",
					changedById: officer.id,
				},
			])
			expect(insertsInto(notifications)).toEqual([
				expect.objectContaining({
					userId: citizen.id,
					category: "service_request",
					body: "Ready for payment.",
					metadata: { entityType: "service_request", entityId: "BP-2026-00007" },
				}),
			])
			expect(insertsInto(auditLogs)).toEqual([
				expect.objectContaining({
					actorId: officer.id,
					actionType: "status_change",
					entityType: "service_request",
					entityId: "BP-2026-00007",
					details: { to: "approved" },
				}),
			])
		})

		it("does not write anything when the request does not exist", async () => {
			queueSelects([])

			await expect(
				service.updateRequestStatus(officer, { id: 999, status: "approved" })
			).rejects.toThrow(NotFoundException)
			expect(mockDb.update).not.toHaveBeenCalled()
			expect(mockDb.insert).not.toHaveBeenCalled()
		})
	})

	describe("citizen request cancellation", () => {
		it("refuses to cancel a request that is no longer pending", async () => {
			queueSelects([{ ...requestRow, status: "in_review" }], [], [])

			await expect(service.cancelRequest(citizen, 7)).rejects.toThrow(
				new ForbiddenException("Only pending requests can be cancelled")
			)
			expect(mockDb.update).not.toHaveBeenCalled()
		})

		it("marks a pending request as rejected with history and an audit entry", async () => {
			queueSelects([requestRow], [], [], [{ ...requestRow, status: "rejected" }], [], [])

			await service.cancelRequest(citizen, 7)

			expect(updates[0]).toMatchObject({
				table: serviceRequests,
				values: { status: "rejected", cancellationReason: "Cancelled by citizen" },
			})
			expect(insertsInto(serviceRequestStatusHistory)).toEqual([
				expect.objectContaining({ status: "rejected", changedById: citizen.id }),
			])
			expect(insertsInto(auditLogs)).toEqual([
				expect.objectContaining({
					actionType: "cancel",
					entityType: "service_request",
					entityId: "BP-2026-00007",
				}),
			])
		})
	})

	describe("citizen report status history", () => {
		it("records a public 'received' history entry and an audit entry when a report is filed", async () => {
			returningResults.set(citizenReports, [reportRow])
			queueSelects([reportRow], [], [history[0]])

			await service.createReport(citizen, {
				category: "Road Damage",
				description: "Pothole near the plaza",
			})

			expect(insertsInto(citizenReportStatusHistory)).toEqual([
				{
					citizenReportId: 11,
					status: "received",
					remarks: "Report received by the LGU.",
					visibility: "public",
					changedById: citizen.id,
				},
			])
			expect(insertsInto(auditLogs)).toEqual([
				expect.objectContaining({
					actorId: citizen.id,
					actionType: "create",
					entityType: "citizen_report",
					entityId: "11",
					details: { category: "Road Damage" },
				}),
			])
		})

		it("appends history, notifies the reporter and audits a staff status change", async () => {
			queueSelects([reportRow], [], history)
			returningResults.set(citizenReports, [{ ...reportRow, status: "in_progress" }])
			queueSelects([{ ...reportRow, status: "in_progress" }], [], history)

			await service.updateReportStatus(officer, { id: 11, status: "in_progress" })

			expect(insertsInto(citizenReportStatusHistory)).toEqual([
				expect.objectContaining({
					citizenReportId: 11,
					status: "in_progress",
					changedById: officer.id,
				}),
			])
			expect(insertsInto(notifications)).toEqual([
				expect.objectContaining({
					userId: citizen.id,
					category: "issue_report",
					body: "Your Road Damage report is now in_progress.",
				}),
			])
			expect(insertsInto(auditLogs)).toEqual([
				expect.objectContaining({
					actionType: "status_change",
					entityType: "citizen_report",
					entityId: "11",
					details: { to: "in_progress" },
				}),
			])
		})

		it("hides internal history entries from the citizen but shows them to staff", async () => {
			queueSelects([reportRow], [], history)
			const asCitizen = await service.getReportDetail(11, citizen)
			expect(asCitizen.history.map(entry => entry.visibility)).toEqual(["public"])

			queueSelects([reportRow], [], history)
			const asStaff = await service.getReportDetail(11, officer, true)
			expect(asStaff.history).toHaveLength(2)
		})

		it("requires a signed-in user for the citizen view", async () => {
			await expect(service.getReportDetail(11)).rejects.toThrow(ForbiddenException)
		})
	})
})
