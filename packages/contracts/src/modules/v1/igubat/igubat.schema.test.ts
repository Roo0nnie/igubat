import { describe, expect, it } from "vitest"

import {
	CreateDiscoverGubatItemSchema,
	CreateTransparencyItemSchema,
	DateLikeSchema,
	DEFAULT_COMMUNITY_STATS,
	DeleteTransparencyItemSchema,
	DiscoverGubatItemDetailSchema,
	DiscoverGubatItemSummarySchema,
	NotificationPreferenceSchema,
	TransparencyItemDetailSchema,
	TransparencyItemSummarySchema,
	TransparencyMetadataSchema,
	UpdateCommunityStatsSchema,
	UpdateDiscoverGubatItemSchema,
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
			discoverGubat: true,
			emergencyBroadcasts: true,
			transparency: false,
			pushEnabled: true,
			emailEnabled: false,
		})

		expect(result.transparency).toBe(false)
	})
})

describe("Discover Gubat contracts", () => {
	it("keeps public summaries lighter than detail payloads", () => {
		const base = {
			id: 7,
			type: "tourist_spot",
			category: "beaches_surfing",
			title: "Rizal Beach",
			slug: "rizal-beach",
			summary: "A public beach destination",
			status: "published",
			featuredImageUrl: null,
			featuredImageAlt: null,
			locationName: "Rizal Beach",
			locationAddress: "Gubat, Sorsogon",
			latitude: null,
			longitude: null,
			whereToBuy: null,
			priceRange: null,
			contactInfo: null,
			authorId: "admin-user",
			scheduledAt: null,
			publishedAt: new Date("2026-01-01T00:00:00.000Z"),
			archivedAt: null,
			createdAt: new Date("2026-01-01T00:00:00.000Z"),
			updatedAt: new Date("2026-01-01T00:00:00.000Z"),
		} as const

		const summary = DiscoverGubatItemSummarySchema.parse({
			...base,
			body: "Full detail body",
			media: [],
		})
		const detail = DiscoverGubatItemDetailSchema.parse({
			...base,
			body: "Full detail body",
			media: [],
			notifyOnPublish: false,
		})

		expect("body" in summary).toBe(false)
		expect("media" in summary).toBe(false)
		expect(detail.body).toBe("Full detail body")
	})

	it("requires local product fields only for local product entries", () => {
		const result = CreateDiscoverGubatItemSchema.safeParse({
			type: "local_product",
			category: "delicacies_kakanin",
			title: "Pili Tart",
			slug: "pili-tart",
			body: "Local delicacy from Gubat.",
		})

		expect(result.success).toBe(false)

		const complete = CreateDiscoverGubatItemSchema.parse({
			type: "local_product",
			category: "delicacies_kakanin",
			title: "Pili Tart",
			slug: "pili-tart",
			body: "Local delicacy from Gubat.",
			whereToBuy: "Gubat Public Market",
		})

		expect(complete.whereToBuy).toBe("Gubat Public Market")
	})

	it("requires a location name for tourist and festival entries", () => {
		const result = CreateDiscoverGubatItemSchema.safeParse({
			type: "tourist_spot",
			category: "beaches_surfing",
			title: "Rizal Beach",
			slug: "rizal-beach",
			locationName: "   ",
		})

		expect(result.success).toBe(false)
		expect(result.error?.issues[0]?.path).toEqual(["locationName"])

		const update = UpdateDiscoverGubatItemSchema.parse({
			id: "7",
			type: "festival_culture",
			locationName: "Gubat Town Plaza",
		})

		expect(update).toMatchObject({ id: 7, locationName: "Gubat Town Plaza" })
	})
})

describe("Community stats contracts", () => {
	it("accepts the default community stats configuration", () => {
		expect(UpdateCommunityStatsSchema.parse({ stats: DEFAULT_COMMUNITY_STATS }).stats).toHaveLength(
			DEFAULT_COMMUNITY_STATS.length
		)
	})

	it("rejects duplicate stat keys", () => {
		const result = UpdateCommunityStatsSchema.safeParse({
			stats: [
				{ key: "pending_requests", label: "Pending", enabled: true },
				{ key: "pending_requests", label: "Pending again", enabled: false },
			],
		})

		expect(result.success).toBe(false)
	})
})

describe("Shared contract helpers", () => {
	it("coerces date strings into Date instances", () => {
		const parsed = DateLikeSchema.parse("2026-01-01T00:00:00.000Z")

		expect(parsed).toBeInstanceOf(Date)
		expect(parsed.toISOString()).toBe("2026-01-01T00:00:00.000Z")
	})

	it("accepts native boolean and rejects non-string permanent delete flags", () => {
		expect(DeleteTransparencyItemSchema.parse({ id: 3, permanent: true }).permanent).toBe(true)
		expect(DeleteTransparencyItemSchema.safeParse({ id: 3, permanent: 1 }).success).toBe(false)
	})
})
