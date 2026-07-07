import { describe, expect, it } from "vitest"

import { NAV_GROUPS } from "@/features/admin-layout/nav-items"

describe("NAV_GROUPS", () => {
	it("shows Discover Gubat as a staff Content & Emergency surface", () => {
		const group = NAV_GROUPS.find(item => item.label === "Content & Emergency")

		expect(group?.items).toEqual(
			expect.arrayContaining([
				expect.objectContaining({
					title: "Discover Gubat",
					url: "/discover-gubat",
					access: "staff",
				}),
			])
		)
	})
})
