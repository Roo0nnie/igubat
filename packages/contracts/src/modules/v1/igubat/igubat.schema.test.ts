import { describe, expect, it } from "vitest"

import {
	CreateDiscoverGubatEntrySchema,
	CreateTransparencyItemSchema,
	DeleteDiscoverGubatEntrySchema,
	DeleteTransparencyItemSchema,
	DiscoverGubatEntryDetailSchema,
	DiscoverGubatEntrySummarySchema,
	DiscoverGubatMetadataSchema,
	NotificationPreferenceSchema,
	TransparencyItemDetailSchema,
	TransparencyItemSummarySchema,
	TransparencyMetadataSchema,
} from "./igubat.schema"

describe("Transparency contracts", () => {
	it("parses permanent delete query flags without treating 'false' as true", () => {
		expect(DeleteTransparencyItemSchema.parse({ id: "12", permanent: "true" })).toEqual({
			id: 12,
			permanent: true,
		})
		expect(DeleteTransparencyItemSchema.parse({ id: "12", permanent: "false" })).toEqual({
			id: 12,
			permanent: false,
		})
		expect(DeleteTransparencyItemSchema.parse({ id: "12", permanent: "0" })).toEqual({
			id: 12,
			permanent: false,
		})
	})

	it("rejects ambiguous permanent delete query flags", () => {
		const result = DeleteTransparencyItemSchema.safeParse({ id: 12, permanent: "definitely" })

		expect(result.success).toBe(false)
	})

	it("requires transparency metadata to match the selected type", () => {
		const result = CreateTransparencyItemSchema.safeParse({
			type: "annual_budget",
			title: "Annual Budget FY 2026",
			metadata: {
				type: "program_project",
				projectStatus: "ongoing",
				startDate: "2026-01-01",
				costPhp: 1000,
				implementingOffice: "Municipal Budget Office",
			},
		})

		expect(result.success).toBe(false)
	})

	it("enforces per-type required transparency metadata fields", () => {
		const incompleteBid = TransparencyMetadataSchema.safeParse({
			type: "bid_procurement",
			procurementMode: "public_bidding",
			closingDate: "2026-07-15",
			bidStatus: "posted",
		})

		expect(incompleteBid.success).toBe(false)

		const annualBudget = TransparencyMetadataSchema.parse({
			type: "annual_budget",
			budgetType: "annual",
			totalAmountPhp: 25_000_000,
		})

		if (annualBudget.type === "annual_budget") {
			expect(annualBudget.totalAmountPhp).toBe(25_000_000)
		}
	})

	it("keeps transparency summary payloads lighter than detail payloads", () => {
		const base = {
			id: 1,
			type: "annual_budget",
			referenceNumber: "AB-2026",
			title: "Annual Budget FY 2026",
			slug: "ab-2026-annual-budget-fy-2026",
			summary: "Budget summary",
			fiscalYear: 2026,
			effectiveDate: null,
			barangay: null,
			status: "published",
			coverImageUrl: null,
			authorId: "admin-user",
			scheduledAt: null,
			publishedAt: new Date("2026-01-01T00:00:00.000Z"),
			archivedAt: null,
			createdAt: new Date("2026-01-01T00:00:00.000Z"),
			updatedAt: new Date("2026-01-01T00:00:00.000Z"),
		} as const
		const metadata = {
			type: "annual_budget",
			budgetType: "annual",
			totalAmountPhp: 25_000_000,
		} as const

		const summary = TransparencyItemSummarySchema.parse({
			...base,
			body: "Should not be part of the summary contract",
			metadata,
		})
		const detail = TransparencyItemDetailSchema.parse({
			...base,
			body: "Full detail body",
			metadata,
			notifyOnPublish: false,
			attachments: [],
		})

		expect("body" in summary).toBe(false)
		expect("metadata" in summary).toBe(false)
		expect(detail.metadata?.type).toBe("annual_budget")
	})

	it("includes transparency in notification preferences", () => {
		const result = NotificationPreferenceSchema.parse({
			news: true,
			serviceRequests: true,
			issueReports: true,
			emergencyBroadcasts: true,
			discoverGubat: true,
			transparency: false,
			pushEnabled: true,
			emailEnabled: false,
		})

		expect(result.transparency).toBe(false)
	})
})

describe("Discover Gubat contracts", () => {
	it("parses permanent delete query flags without treating 'false' as true", () => {
		expect(DeleteDiscoverGubatEntrySchema.parse({ id: "7", permanent: "true" })).toEqual({
			id: 7,
			permanent: true,
		})
		expect(DeleteDiscoverGubatEntrySchema.parse({ id: "7", permanent: "false" })).toEqual({
			id: 7,
			permanent: false,
		})
	})

	it("requires type-specific Discover Gubat metadata", () => {
		const missingMapLocation = CreateDiscoverGubatEntrySchema.safeParse({
			type: "tourist_spot",
			title: "Buenavista Beach",
			category: "Beach",
			body: "Surfing beach in Gubat.",
			metadata: {
				type: "tourist_spot",
			},
		})
		const product = DiscoverGubatMetadataSchema.parse({
			type: "local_product",
			productKind: "delicacy",
			whereToBuy: "Public Market pasalubong stalls",
			pasalubongNote: "Best bought fresh in the morning.",
		})

		expect(missingMapLocation.success).toBe(false)
		if (product.type === "local_product") {
			expect(product.whereToBuy).toBe("Public Market pasalubong stalls")
		}
	})

	it("keeps Discover Gubat summaries lighter than detail payloads", () => {
		const base = {
			id: 1,
			type: "tourist_spot",
			title: "Buenavista Beach",
			slug: "buenavista-beach",
			summary: "Surfing beach in Gubat.",
			category: "Beach",
			status: "published",
			coverImageUrl: null,
			mapLocation: "Buenavista, Gubat, Sorsogon",
			whereToBuy: null,
			eventDate: null,
			authorId: "staff-user",
			scheduledAt: null,
			publishedAt: new Date("2026-06-01T00:00:00.000Z"),
			archivedAt: null,
			createdAt: new Date("2026-06-01T00:00:00.000Z"),
			updatedAt: new Date("2026-06-01T00:00:00.000Z"),
		} as const
		const metadata = {
			type: "tourist_spot",
			mapLocation: "Buenavista, Gubat, Sorsogon",
			latitude: 12.9201,
			longitude: 124.1234,
		} as const

		const summary = DiscoverGubatEntrySummarySchema.parse({
			...base,
			body: "Should not be exposed in summary rows.",
			metadata,
		})
		const detail = DiscoverGubatEntryDetailSchema.parse({
			...base,
			body: "Full destination write-up.",
			metadata,
			notifyOnPublish: false,
			photos: [],
		})

		expect("body" in summary).toBe(false)
		expect("metadata" in summary).toBe(false)
		expect(detail.metadata?.type).toBe("tourist_spot")
	})

	it("includes Discover Gubat in notification preferences", () => {
		const result = NotificationPreferenceSchema.parse({
			news: true,
			serviceRequests: true,
			issueReports: true,
			emergencyBroadcasts: true,
			discoverGubat: false,
			transparency: true,
			pushEnabled: true,
			emailEnabled: false,
		})

		expect(result.discoverGubat).toBe(false)
	})
})
