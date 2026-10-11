import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { fireEvent, render, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { DiscoverGubatManagement } from "@/features/admin-discover-gubat/components/discover-gubat-management"
import type { DiscoverGubatListRow } from "@/features/admin-discover-gubat/lib/discover-gubat-types"

const mocks = vi.hoisted(() => ({
	can: vi.fn(() => true),
	list: { data: [] as unknown[], isLoading: false, isError: false },
	create: vi.fn(),
	update: vi.fn(),
	publish: vi.fn(),
	archive: vi.fn(),
	remove: vi.fn(),
	fetchDetail: vi.fn(),
	toastSuccess: vi.fn(),
	toastError: vi.fn(),
}))

vi.mock("@/core/context/role-provider", () => ({
	useRole: () => ({ can: mocks.can }),
}))

vi.mock("sonner", () => ({
	toast: { success: mocks.toastSuccess, error: mocks.toastError },
}))

vi.mock("@/services/orpc/client", () => ({
	orpc: {
		igubat: {
			admin: {
				discoverGubat: {
					detail: {
						queryOptions: ({ input }: { input: { id: number } }) => ({
							queryKey: ["discover-gubat-detail", input.id],
							queryFn: () => mocks.fetchDetail(input.id),
						}),
					},
				},
			},
		},
	},
}))

vi.mock("@/features/admin-discover-gubat/api/discover-gubat.hooks", () => {
	const mutation = (fn: (...args: unknown[]) => unknown) => ({ mutateAsync: fn, isPending: false })
	return {
		useDiscoverGubatListQuery: () => mocks.list,
		useCreateDiscoverGubatMutation: () => mutation(mocks.create),
		useUpdateDiscoverGubatMutation: () => mutation(mocks.update),
		usePublishDiscoverGubatMutation: () => mutation(mocks.publish),
		useArchiveDiscoverGubatMutation: () => mutation(mocks.archive),
		useDeleteDiscoverGubatMutation: () => mutation(mocks.remove),
	}
})

const row: DiscoverGubatListRow = {
	id: 7,
	type: "tourist_spot",
	title: "Buenavista Beach",
	slug: "buenavista-beach",
	summary: "Surf spot",
	category: "Beach",
	status: "draft",
	coverImageUrl: null,
	mapLocation: "Buenavista, Gubat",
	whereToBuy: null,
	eventDate: null,
	authorId: "staff-user",
	scheduledAt: null,
	publishedAt: null,
	archivedAt: null,
	createdAt: "2026-06-09T08:00:00.000Z",
	updatedAt: "2026-06-10T08:00:00.000Z",
	authorName: "Content Editor",
}

const detail = {
	...row,
	body: "Full guide to Buenavista Beach.",
	notifyOnPublish: false,
	metadata: { type: "tourist_spot", mapLocation: "Buenavista, Gubat" },
	photos: [{ id: 1, imageUrl: "https://example.com/beach.jpg", altText: "Beach", sortOrder: 0 }],
}

function renderManager() {
	const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
	return render(
		<QueryClientProvider client={queryClient}>
			<DiscoverGubatManagement />
		</QueryClientProvider>
	)
}

async function fillNewTouristSpot(user: ReturnType<typeof userEvent.setup>) {
	await user.type(screen.getByLabelText("Title"), "Rizal Beach")
	await user.type(screen.getByLabelText("Category"), "Beach")
	await user.type(screen.getByLabelText("Map Location"), "Rizal, Gubat")
}

beforeEach(() => {
	vi.clearAllMocks()
	mocks.can.mockReturnValue(true)
	mocks.list = { data: [row], isLoading: false, isError: false }
	mocks.fetchDetail.mockResolvedValue(detail)
})

describe("DiscoverGubatManagement", () => {
	it("keeps submit actions disabled until required tourist spot fields are filled", async () => {
		const user = userEvent.setup()
		renderManager()

		expect(screen.getByText("Buenavista Beach")).toBeInTheDocument()
		expect(screen.getByRole("button", { name: /save draft/i })).toBeDisabled()

		await fillNewTouristSpot(user)

		expect(screen.getByRole("button", { name: /save draft/i })).toBeEnabled()
		expect(screen.getByRole("button", { name: /publish now/i })).toBeEnabled()
	})

	it("creates a draft with tourist spot metadata", async () => {
		const user = userEvent.setup()
		mocks.create.mockResolvedValue({ ...detail, id: 11, title: "Rizal Beach", photos: [] })
		renderManager()

		await fillNewTouristSpot(user)
		await user.click(screen.getByRole("button", { name: /save draft/i }))

		await waitFor(() => expect(mocks.create).toHaveBeenCalled())
		expect(mocks.create.mock.calls[0]?.[0]).toMatchObject({
			type: "tourist_spot",
			title: "Rizal Beach",
			category: "Beach",
			status: "draft",
			metadata: { type: "tourist_spot", mapLocation: "Rizal, Gubat" },
			photos: [],
		})
		expect(mocks.toastSuccess).toHaveBeenCalledWith("Discover Gubat draft saved.")
	})

	it("creates then publishes a new entry, or schedules it when a date is set", async () => {
		const user = userEvent.setup()
		mocks.create.mockResolvedValue({ ...detail, id: 12 })
		mocks.update.mockResolvedValue({ ...detail, id: 12 })
		mocks.publish.mockResolvedValue({ ...detail, id: 12, status: "published" })
		renderManager()

		await fillNewTouristSpot(user)
		await user.click(screen.getByRole("button", { name: /publish now/i }))

		await waitFor(() =>
			expect(mocks.publish).toHaveBeenCalledWith({
				id: 12,
				notifySubscribers: true,
				publishAt: undefined,
			})
		)
		expect(mocks.toastSuccess).toHaveBeenCalledWith("Discover Gubat entry published.")

		fireEvent.change(screen.getByLabelText("Schedule Publish At"), {
			target: { value: "2026-12-01T09:30" },
		})
		await user.click(screen.getByRole("button", { name: /^schedule$/i }))

		await waitFor(() =>
			expect(mocks.publish).toHaveBeenLastCalledWith(
				expect.objectContaining({ publishAt: "2026-12-01T09:30" })
			)
		)
		expect(mocks.toastSuccess).toHaveBeenCalledWith("Discover Gubat entry scheduled.")
	})

	it("loads the full entry before editing and saves updates by id", async () => {
		const user = userEvent.setup()
		mocks.update.mockResolvedValue({ ...detail, title: "Buenavista Beach Resort" })
		renderManager()

		await user.click(screen.getByRole("button", { name: /edit buenavista beach/i }))

		await waitFor(() =>
			expect(screen.getByLabelText("Body")).toHaveValue("Full guide to Buenavista Beach.")
		)
		expect(screen.getByText("Edit Entry")).toBeInTheDocument()

		await user.clear(screen.getByLabelText("Title"))
		await user.type(screen.getByLabelText("Title"), "Buenavista Beach Resort")
		await user.click(screen.getByRole("button", { name: /save draft/i }))

		await waitFor(() => expect(mocks.update).toHaveBeenCalled())
		expect(mocks.update.mock.calls[0]?.[0]).toMatchObject({
			id: 7,
			title: "Buenavista Beach Resort",
			photos: [{ imageUrl: "https://example.com/beach.jpg", altText: "Beach", sortOrder: 0 }],
		})
	})

	it("reports a toast error when the entry detail cannot be loaded", async () => {
		const user = userEvent.setup()
		mocks.fetchDetail.mockRejectedValue(new Error("Detail unavailable"))
		renderManager()

		await user.click(screen.getByRole("button", { name: /edit buenavista beach/i }))

		await waitFor(() => expect(mocks.toastError).toHaveBeenCalledWith("Detail unavailable"))
	})

	it("archives and permanently deletes rows for admins", async () => {
		const user = userEvent.setup()
		mocks.archive.mockResolvedValue({ ...detail, status: "archived" })
		mocks.remove.mockResolvedValue({ success: true })
		vi.spyOn(window, "confirm").mockReturnValue(true)
		renderManager()

		await user.click(screen.getByRole("button", { name: /^archive buenavista beach/i }))
		await waitFor(() => expect(mocks.archive).toHaveBeenCalledWith({ id: 7 }))
		expect(mocks.toastSuccess).toHaveBeenCalledWith("Discover Gubat entry archived.")

		await user.click(screen.getByRole("button", { name: /permanently delete buenavista beach/i }))
		await waitFor(() => expect(mocks.remove).toHaveBeenCalledWith({ id: 7, permanent: true }))
		expect(mocks.toastSuccess).toHaveBeenCalledWith("Discover Gubat entry permanently deleted.")
	})

	it("surfaces mutation failures as toast errors", async () => {
		const user = userEvent.setup()
		mocks.create.mockRejectedValue(new Error("Slug already exists"))
		mocks.archive.mockRejectedValue(new Error("Archive failed"))
		renderManager()

		await fillNewTouristSpot(user)
		await user.click(screen.getByRole("button", { name: /save draft/i }))
		await waitFor(() => expect(mocks.toastError).toHaveBeenCalledWith("Slug already exists"))

		await user.click(screen.getByRole("button", { name: /publish now/i }))
		await waitFor(() => expect(mocks.toastError).toHaveBeenCalledTimes(2))

		await user.click(screen.getByRole("button", { name: /^archive buenavista beach/i }))
		await waitFor(() => expect(mocks.toastError).toHaveBeenCalledWith("Archive failed"))
	})

	it("toggles the citizen-view preview and resets to a new entry", async () => {
		const user = userEvent.setup()
		renderManager()

		await user.type(screen.getByLabelText("Title"), "Preview Title")
		await user.click(screen.getByRole("button", { name: /^preview$/i }))
		expect(screen.getByText("Citizen-view preview")).toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: /hide preview/i }))
		expect(screen.queryByText("Citizen-view preview")).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: /new entry/i }))
		expect(screen.getByLabelText("Title")).toHaveValue("")
	})
})
