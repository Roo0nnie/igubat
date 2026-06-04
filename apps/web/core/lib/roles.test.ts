import { describe, expect, it } from "vitest"

import {
	getPortalRole,
	isStaffRole,
	isAdminRole,
	canAccess,
	getRoleLabel,
} from "./roles"

describe("getPortalRole", () => {
	it("maps super_admin and ict_admin to admin", () => {
		expect(getPortalRole("super_admin")).toBe("admin")
		expect(getPortalRole("ict_admin")).toBe("admin")
	})

	it("maps operational staff roles to moderator", () => {
		expect(getPortalRole("frontline_officer")).toBe("moderator")
		expect(getPortalRole("department_supervisor")).toBe("moderator")
		expect(getPortalRole("content_editor")).toBe("moderator")
		expect(getPortalRole("emergency_operator")).toBe("moderator")
	})

	it("returns null for citizens and unknown/missing roles", () => {
		expect(getPortalRole("registered_citizen")).toBeNull()
		expect(getPortalRole("nonsense")).toBeNull()
		expect(getPortalRole(null)).toBeNull()
		expect(getPortalRole(undefined)).toBeNull()
		expect(getPortalRole("")).toBeNull()
	})
})

describe("isStaffRole / isAdminRole", () => {
	it("treats both moderator and admin roles as staff", () => {
		expect(isStaffRole("frontline_officer")).toBe(true)
		expect(isStaffRole("super_admin")).toBe(true)
		expect(isStaffRole("registered_citizen")).toBe(false)
	})

	it("treats only admin roles as admin", () => {
		expect(isAdminRole("super_admin")).toBe(true)
		expect(isAdminRole("ict_admin")).toBe(true)
		expect(isAdminRole("content_editor")).toBe(false)
		expect(isAdminRole("registered_citizen")).toBe(false)
	})
})

describe("canAccess", () => {
	it("allows staff-level surfaces for moderator and admin", () => {
		expect(canAccess("moderator", "staff")).toBe(true)
		expect(canAccess("admin", "staff")).toBe(true)
	})

	it("restricts admin-level surfaces to admin only", () => {
		expect(canAccess("admin", "admin")).toBe(true)
		expect(canAccess("moderator", "admin")).toBe(false)
	})

	it("denies everything when there is no portal role", () => {
		expect(canAccess(null, "staff")).toBe(false)
		expect(canAccess(null, "admin")).toBe(false)
	})
})

describe("getRoleLabel", () => {
	it("returns friendly labels", () => {
		expect(getRoleLabel("super_admin")).toBe("Super Administrator")
		expect(getRoleLabel("frontline_officer")).toBe("Frontline Officer")
	})

	it("falls back to Staff for unknown roles", () => {
		expect(getRoleLabel("mystery")).toBe("Staff")
		expect(getRoleLabel(null)).toBe("Staff")
	})
})
