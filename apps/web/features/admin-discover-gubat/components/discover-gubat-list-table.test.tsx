import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { DiscoverGubatListTable } from "@/features/admin-discover-gubat/components/discover-gubat-list-table"
import type { DiscoverGubatListRow } from "@/features/admin-discover-gubat/lib/discover-gubat-types"

const rows: DiscoverGubatListRow[] = [
	{
		id: 7,
		type: "tourist_spot",
		title: "Buenavista Beach",
		slug: "buenavista-beach",
		summary: "Beginner-friendly surf and beach destination.",
		category: "Beach",
		status: "published",
		coverImageUrl: null,
		mapLocation: "Buenavista, Gubat, Sorsogon",
		whereToBuy: null,
		eventDate: null,
		authorId: "staff-user",
		scheduledAt: null,
		publishedAt: "2026-06-10T08:00:00.000Z",
		archivedAt: null,
		createdAt: "2026-06-09T08:00:00.000Z",
		updatedAt: "2026-06-10T08:00:00.000Z",
		authorName: "Content Editor",
	},
	{
		id: 8,
		type: "festival_culture",
		title: "Ginubat Festival",
		slug: "ginubat-festival",
		summary: "Annual fiesta and cultural celebration.",
		category: "Festival",
		status: "draft",
		coverImageUrl: null,
		mapLocation: null,
		whereToBuy: null,
		eventDate: "2026-06-13T00:00:00.000Z",
		authorId: "staff-user",
		scheduledAt: null,
		publishedAt: null,
		archivedAt: null,
		createdAt: "2026-06-09T08:00:00.000Z",
		updatedAt: "2026-06-10T08:00:00.000Z",
		authorName: "Content Editor",
	},
	{
		id: 9,
		type: "local_product",
		title: "Timitim",
		slug: "timitim",
		summary: "Cassava and pili delicacy.",
		category: "Delicacy",
		status: "scheduled",
		coverImageUrl: null,
		mapLocation: null,
		whereToBuy: "Public Market pasalubong stalls",
		eventDate: null,
		authorId: "staff-user",
		scheduledAt: "2026-07-01T08:00:00.000Z",
		publishedAt: null,
		archivedAt: null,
		createdAt: "2026-06-09T08:00:00.000Z",
		updatedAt: "2026-06-10T08:00:00.000Z",
		authorName: "Content Editor",
	},
]

const handlers = {
	onEdit: vi.fn(),
	onArchive: vi.fn(),
	onPermanentDelete: vi.fn(),
}

describe("DiscoverGubatListTable", () => {
	it("renders all three Discover Gubat content types", () => {
		render(<DiscoverGubatListTable rows={rows} isAdmin {...handlers} />)

		expect(screen.getByText("Buenavista Beach")).toBeInTheDocument()
		expect(screen.getByText("Tourist Spot")).toBeInTheDocument()
		expect(screen.getByText("Ginubat Festival")).toBeInTheDocument()
		expect(screen.getByText("Festivals & Culture")).toBeInTheDocument()
		expect(screen.getByText("Timitim")).toBeInTheDocument()
		expect(screen.getByText("Local Delicacies & Products")).toBeInTheDocument()
		expect(screen.getByText("Public Market pasalubong stalls")).toBeInTheDocument()
	})

	it("hides permanent delete from non-admin users", async () => {
		const user = userEvent.setup()
		render(<DiscoverGubatListTable rows={rows.slice(0, 1)} isAdmin={false} {...handlers} />)

		await user.click(screen.getByRole("button", { name: /archive buenavista beach/i }))

		expect(handlers.onArchive).toHaveBeenCalledWith(rows[0])
		expect(
			screen.queryByRole("button", { name: /permanently delete buenavista beach/i })
		).not.toBeInTheDocument()
	})
})
