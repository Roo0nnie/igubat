import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { TransparencyListTable } from "@/features/admin-transparency/components/transparency-list-table"
import type { TransparencyListRow } from "@/features/admin-transparency/lib/transparency-types"

const rows: TransparencyListRow[] = [
	{
		id: 42,
		type: "program_project",
		referenceNumber: "PRJ-2026-014",
		title: "Buenavista Mangrove Rehabilitation",
		slug: "buenavista-mangrove-rehabilitation",
		summary: "Quarterly project disclosure",
		fiscalYear: 2026,
		effectiveDate: null,
		barangay: "Buenavista",
		status: "published",
		coverImageUrl: null,
		authorId: "admin-user",
		scheduledAt: null,
		publishedAt: "2026-06-10T08:00:00.000Z",
		archivedAt: null,
		createdAt: "2026-06-09T08:00:00.000Z",
		updatedAt: "2026-06-10T08:00:00.000Z",
		authorName: "Maria Santos",
	},
]

const handlers = {
	onEdit: vi.fn(),
	onPreview: vi.fn(),
	onArchive: vi.fn(),
	onPermanentDelete: vi.fn(),
}

describe("TransparencyListTable", () => {
	it("renders transparency rows", () => {
		render(<TransparencyListTable rows={rows} isAdmin {...handlers} />)

		expect(screen.getByText("PRJ-2026-014")).toBeInTheDocument()
		expect(screen.getByText("Buenavista Mangrove Rehabilitation")).toBeInTheDocument()
		expect(screen.getByText("Program and Projects")).toBeInTheDocument()
		expect(screen.getByText("2026")).toBeInTheDocument()
		expect(screen.getAllByText("Published")).toHaveLength(2)
		expect(screen.getByText("Maria Santos")).toBeInTheDocument()
	})

	it("hides permanent delete from non-admin users", async () => {
		const user = userEvent.setup()
		render(<TransparencyListTable rows={rows} isAdmin={false} {...handlers} />)

		await user.click(screen.getByRole("button", { name: /actions for buenavista/i }))

		expect(await screen.findByText("Edit")).toBeInTheDocument()
		expect(screen.queryByText("Permanently Delete")).not.toBeInTheDocument()
	})
})
