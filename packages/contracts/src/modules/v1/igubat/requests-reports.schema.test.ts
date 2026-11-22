import { describe, expect, it } from "vitest"

import {
	CitizenReportDetailSchema,
	CitizenReportStatusSchema,
	CreateCitizenReportSchema,
	CreateServiceRequestSchema,
	ServiceRequestStatusSchema,
	UpdateReportStatusSchema,
	UpdateRequestStatusSchema,
} from "./igubat.schema"

const attachment = (n: number) => ({ fileName: `file-${n}.pdf`, fileUrl: `/uploads/file-${n}.pdf` })

describe("service request schemas", () => {
	const validRequest = {
		serviceTypeId: 3,
		description: "Requesting a barangay clearance for employment.",
		preferredDate: "2026-02-14",
		attachments: [attachment(1), attachment(2), attachment(3)],
	}

	it("accepts a complete service request with up to three attachments", () => {
		expect(CreateServiceRequestSchema.parse(validRequest)).toEqual(validRequest)
	})

	it("accepts the minimal service request", () => {
		expect(
			CreateServiceRequestSchema.safeParse({ serviceTypeId: 1, description: "x" }).success
		).toBe(true)
	})

	it.each([
		["zero service type", { ...validRequest, serviceTypeId: 0 }],
		["negative service type", { ...validRequest, serviceTypeId: -2 }],
		["fractional service type", { ...validRequest, serviceTypeId: 1.5 }],
		["service type as string", { ...validRequest, serviceTypeId: "3" }],
		["empty description", { ...validRequest, description: "" }],
		["missing description", { serviceTypeId: 3 }],
		["four attachments", { ...validRequest, attachments: [1, 2, 3, 4].map(attachment) }],
		["attachment without url", { ...validRequest, attachments: [{ fileName: "a.pdf" }] }],
	])("rejects %s", (_label, payload) => {
		expect(CreateServiceRequestSchema.safeParse(payload).success).toBe(false)
	})

	it("lists exactly the statuses the staff portal can set", () => {
		expect(ServiceRequestStatusSchema.options).toEqual([
			"pending",
			"in_review",
			"approved",
			"rejected",
			"for_pickup",
			"completed",
		])
	})

	it("accepts a status update and coerces the route id to a number", () => {
		const parsed = UpdateRequestStatusSchema.parse({
			id: "42",
			status: "for_pickup",
			remarks: "Ready at the Municipal Treasurer's Office.",
			internalNotes: "Paid OR #1234",
		})
		expect(parsed.id).toBe(42)
		expect(parsed.status).toBe("for_pickup")
	})

	it.each([
		["unknown status", { id: 1, status: "done" }],
		["report status on a request", { id: 1, status: "resolved" }],
		["non-positive id", { id: 0, status: "approved" }],
		["non-numeric id", { id: "abc", status: "approved" }],
	])("rejects a request status update with %s", (_label, payload) => {
		expect(UpdateRequestStatusSchema.safeParse(payload).success).toBe(false)
	})
})

describe("citizen report schemas", () => {
	const validReport = {
		category: "Flooding",
		description: "Knee-deep flood on the national road after heavy rain.",
		barangay: "Poblacion",
		locationAddress: "Near the public market",
		latitude: "12.9203",
		longitude: "124.1234",
		attachments: [attachment(1)],
	}

	it("accepts a complete citizen report", () => {
		expect(CreateCitizenReportSchema.parse(validReport)).toEqual(validReport)
	})

	it("accepts a report with only category and description", () => {
		expect(
			CreateCitizenReportSchema.safeParse({ category: "Others", description: "Stray animals" })
				.success
		).toBe(true)
	})

	it.each([
		["unknown category", { ...validReport, category: "Noise" }],
		["lower-case category", { ...validReport, category: "flooding" }],
		["empty description", { ...validReport, description: "" }],
		["numeric latitude", { ...validReport, latitude: 12.92 }],
		["four attachments", { ...validReport, attachments: [1, 2, 3, 4].map(attachment) }],
	])("rejects %s", (_label, payload) => {
		expect(CreateCitizenReportSchema.safeParse(payload).success).toBe(false)
	})

	it("lists the report lifecycle statuses", () => {
		expect(CitizenReportStatusSchema.options).toEqual([
			"received",
			"in_progress",
			"resolved",
			"closed",
		])
	})

	it("accepts a report status update and rejects request-only statuses", () => {
		expect(UpdateReportStatusSchema.safeParse({ id: 5, status: "resolved" }).success).toBe(true)
		expect(UpdateReportStatusSchema.safeParse({ id: 5, status: "approved" }).success).toBe(false)
	})

	it("parses report details with public and internal history entries", () => {
		const detail = CitizenReportDetailSchema.parse({
			id: 5,
			category: "Road Damage",
			description: "Pothole",
			status: "in_progress",
			barangay: null,
			locationAddress: null,
			latitude: null,
			longitude: null,
			publicRemarks: null,
			internalNotes: null,
			departmentId: null,
			assignedOfficerId: null,
			authorId: "citizen-1",
			createdAt: "2026-01-01T00:00:00.000Z",
			updatedAt: "2026-01-02T00:00:00.000Z",
			attachments: [],
			history: [
				{
					id: 1,
					status: "received",
					remarks: "Report received by the LGU.",
					visibility: "public",
					changedById: "citizen-1",
					createdAt: "2026-01-01T00:00:00.000Z",
				},
				{
					id: 2,
					status: "in_progress",
					remarks: null,
					visibility: "internal",
					changedById: "staff-1",
					createdAt: "2026-01-02T00:00:00.000Z",
				},
			],
		})
		expect(detail.createdAt).toBeInstanceOf(Date)
		expect(detail.history.map(entry => entry.visibility)).toEqual(["public", "internal"])
	})

	it("rejects history entries with an unknown visibility", () => {
		const result = CitizenReportDetailSchema.shape.history.safeParse([
			{
				id: 1,
				status: "received",
				remarks: null,
				visibility: "private",
				changedById: null,
				createdAt: "2026-01-01T00:00:00.000Z",
			},
		])
		expect(result.success).toBe(false)
	})
})
