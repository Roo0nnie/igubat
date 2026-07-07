import { beforeEach, describe, expect, it, vi } from "vitest"

import type { PortalUser } from "@/core/lib/admin-guard"

import AnalyticsPage from "./analytics/page"
import AuditLogsPage from "./audit-logs/page"
import CitizensPage from "./citizens/page"
import DiscoverGubatPage from "./discover-gubat/page"
import SettingsPage from "./settings/page"
import StaffPage from "./staff/page"
import TransparencyPage from "./transparency/page"

const mocks = vi.hoisted(() => ({
	requireStaff: vi.fn(),
	// `forbidden()` throws in Next to trigger the 403 boundary; emulate that so a
	// guarded page rejects exactly as it would when serving a forbidden response.
	forbidden: vi.fn(() => {
		throw new Error("NEXT_FORBIDDEN")
	}),
}))

vi.mock("@/core/lib/admin-guard", () => ({ requireStaff: mocks.requireStaff }))
vi.mock("next/navigation", () => ({ forbidden: mocks.forbidden }))

// Stub heavy content components so we exercise only the guard logic.
vi.mock("@/features/admin-citizens/components/citizens-content", () => ({
	CitizensContent: () => "citizens",
}))
vi.mock("@/features/admin-analytics/components/analytics-content", () => ({
	AnalyticsContent: () => "analytics",
}))
vi.mock("@/features/admin-audit/components/audit-content", () => ({
	AuditContent: () => "audit",
}))
vi.mock("@/features/admin-settings/components/settings-content", () => ({
	SettingsContent: () => "settings",
}))
vi.mock("@/features/admin-staff/components/staff-content", () => ({
	StaffContent: () => "staff",
}))
vi.mock("@/features/admin-transparency/components/transparency-list-page", () => ({
	TransparencyListPage: () => "transparency",
}))

const moderator: PortalUser = {
	id: "m1",
	name: "Mod",
	email: "mod@igubat.gov.ph",
	role: "frontline_officer",
	portalRole: "moderator",
}

const admin: PortalUser = {
	id: "a1",
	name: "Admin",
	email: "admin@igubat.gov.ph",
	role: "super_admin",
	portalRole: "admin",
}

const adminOnlyRoutes = [
	{ name: "User Management", Page: CitizensPage },
	{ name: "Staff Management", Page: StaffPage },
	{ name: "Analytics", Page: AnalyticsPage },
	{ name: "Audit Log", Page: AuditLogsPage },
	{ name: "Settings", Page: SettingsPage },
]

describe("admin-only route guards", () => {
	beforeEach(() => {
		mocks.requireStaff.mockReset()
		mocks.forbidden.mockClear()
	})

	for (const { name, Page } of adminOnlyRoutes) {
		it(`${name}: moderator direct navigation triggers a forbidden (403) response`, async () => {
			mocks.requireStaff.mockResolvedValue(moderator)

			await expect((Page as () => Promise<unknown>)()).rejects.toThrow("NEXT_FORBIDDEN")
			expect(mocks.forbidden).toHaveBeenCalledTimes(1)
		})

		it(`${name}: admin is allowed through`, async () => {
			mocks.requireStaff.mockResolvedValue(admin)

			await expect((Page as () => Promise<unknown>)()).resolves.toBeTruthy()
			expect(mocks.forbidden).not.toHaveBeenCalled()
		})
	}
})

describe("staff route reachability", () => {
	beforeEach(() => {
		mocks.requireStaff.mockReset()
		mocks.forbidden.mockClear()
	})

	it("Transparency: moderator is allowed through the staff-level page", () => {
		mocks.requireStaff.mockResolvedValue(moderator)

		expect(TransparencyPage()).toBeTruthy()
		expect(mocks.forbidden).not.toHaveBeenCalled()
	})

	it("Transparency: admin is allowed through the staff-level page", () => {
		mocks.requireStaff.mockResolvedValue(admin)

		expect(TransparencyPage()).toBeTruthy()
		expect(mocks.forbidden).not.toHaveBeenCalled()
	})

	it("Discover Gubat: moderator is allowed through the staff-level page", async () => {
		mocks.requireStaff.mockResolvedValue(moderator)

		await expect(DiscoverGubatPage()).resolves.toBeTruthy()
		expect(mocks.forbidden).not.toHaveBeenCalled()
	})

	it("Discover Gubat: admin is allowed through the staff-level page", async () => {
		mocks.requireStaff.mockResolvedValue(admin)

		await expect(DiscoverGubatPage()).resolves.toBeTruthy()
		expect(mocks.forbidden).not.toHaveBeenCalled()
	})
})
