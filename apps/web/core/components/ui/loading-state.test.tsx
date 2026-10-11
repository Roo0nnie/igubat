import { act, render, renderHook, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { afterEach, describe, expect, it, vi } from "vitest"

import {
	BrandedPageLoader,
	CardGridSkeleton,
	DetailPageSkeleton,
	EmptyState,
	ErrorState,
	FormSkeleton,
	ListSkeleton,
	LoadingStatus,
	PageSkeleton,
	SLOW_LOADING_MS,
	StatCardsSkeleton,
	TableStateRows,
	useSlowLoading,
} from "./loading-state"
import { Table, TableBody } from "./table"

function renderRows(props: Partial<React.ComponentProps<typeof TableStateRows>>) {
	return render(
		<Table>
			<TableBody>
				<TableStateRows colSpan={3} isLoading={false} isError={false} isEmpty={false} {...props} />
			</TableBody>
		</Table>
	)
}

afterEach(() => {
	vi.useRealTimers()
})

describe("useSlowLoading", () => {
	it("flips to true only after the delay while loading", () => {
		vi.useFakeTimers()
		const { result, rerender } = renderHook(({ loading }) => useSlowLoading(loading, 1000), {
			initialProps: { loading: true },
		})

		expect(result.current).toBe(false)
		act(() => vi.advanceTimersByTime(1000))
		expect(result.current).toBe(true)

		rerender({ loading: false })
		expect(result.current).toBe(false)
	})
})

describe("LoadingStatus", () => {
	it("shows the message, then a connection hint with retry once loading is slow", async () => {
		vi.useFakeTimers()
		const onRetry = vi.fn()
		render(<LoadingStatus message="Loading reports..." onRetry={onRetry} />)

		expect(screen.getByRole("status")).toHaveTextContent("Loading reports...")

		act(() => vi.advanceTimersByTime(SLOW_LOADING_MS))
		expect(screen.getByText(/check your internet connection/i)).toBeInTheDocument()

		vi.useRealTimers()
		await userEvent.setup().click(screen.getByRole("button", { name: /retry/i }))

		expect(onRetry).toHaveBeenCalledOnce()
		expect(screen.getByText("Loading reports...")).toBeInTheDocument()
	})

	it("omits the retry button when no handler is provided", () => {
		vi.useFakeTimers()
		render(<LoadingStatus />)

		act(() => vi.advanceTimersByTime(SLOW_LOADING_MS))

		expect(screen.queryByRole("button")).not.toBeInTheDocument()
	})
})

describe("TableStateRows", () => {
	it("renders a status row plus skeleton rows while loading", () => {
		const { container } = renderRows({ isLoading: true, rows: 2, loadingText: "Fetching..." })

		expect(screen.getByRole("status")).toHaveTextContent("Fetching...")
		expect(container.querySelectorAll("tr")).toHaveLength(3)
	})

	it("skips the status row when showStatus is false", () => {
		const { container } = renderRows({ isLoading: true, rows: 2, showStatus: false })

		expect(screen.queryByRole("status")).not.toBeInTheDocument()
		expect(container.querySelectorAll("tr")).toHaveLength(2)
	})

	it("renders an error row with retry", async () => {
		const onRetry = vi.fn()
		renderRows({ isError: true, onRetry, errorText: "Could not load." })

		expect(screen.getByRole("alert")).toHaveTextContent("Could not load.")
		await userEvent.setup().click(screen.getByRole("button", { name: /try again/i }))
		expect(onRetry).toHaveBeenCalledOnce()
	})

	it("renders an empty row with an optional hint", () => {
		renderRows({ isEmpty: true, emptyText: "Nothing here", emptyHint: "Try another filter" })

		expect(screen.getByText("Nothing here")).toBeInTheDocument()
		expect(screen.getByText("Try another filter")).toBeInTheDocument()
	})

	it("renders nothing once data is ready", () => {
		const { container } = renderRows({})

		expect(container.querySelectorAll("tr")).toHaveLength(0)
	})
})

describe("state blocks", () => {
	it("renders ErrorState defaults without a retry button", () => {
		render(<ErrorState />)

		expect(screen.getByRole("alert")).toHaveTextContent("Something went wrong")
		expect(screen.queryByRole("button")).not.toBeInTheDocument()
	})

	it("renders EmptyState with a custom action", () => {
		render(<EmptyState title="No events" action={<button type="button">Create event</button>} />)

		expect(screen.getByText("No events")).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Create event" })).toBeInTheDocument()
	})
})

describe("skeletons", () => {
	it("renders the requested number of placeholder items", () => {
		const { container: stats } = render(<StatCardsSkeleton count={2} />)
		const { container: cards } = render(<CardGridSkeleton count={3} />)
		const { container: list } = render(<ListSkeleton count={5} />)
		const { container: form } = render(<FormSkeleton fields={2} />)

		expect(stats.firstElementChild?.children).toHaveLength(2)
		expect(cards.firstElementChild?.children).toHaveLength(3)
		expect(list.firstElementChild?.children).toHaveLength(5)
		expect(form.firstElementChild?.children).toHaveLength(3)
	})

	it("renders the detail skeleton hero only when requested", () => {
		const { container: withHero } = render(<DetailPageSkeleton showHero />)
		const { container: withoutHero } = render(<DetailPageSkeleton />)

		expect(withHero.querySelector(".aspect-16\\/7")).not.toBeNull()
		expect(withoutHero.querySelector(".aspect-16\\/7")).toBeNull()
	})

	it("wraps page content with a loading status", () => {
		render(
			<PageSkeleton message="Loading dashboard...">
				<p>Body</p>
			</PageSkeleton>
		)

		expect(screen.getByRole("status")).toHaveTextContent("Loading dashboard...")
		expect(screen.getByText("Body")).toBeInTheDocument()
	})

	it("renders the branded page loader with its message", () => {
		render(<BrandedPageLoader message="Signing you in..." />)

		expect(screen.getByRole("status")).toHaveTextContent("Signing you in...")
		expect(screen.getByText("iGubat")).toBeInTheDocument()
	})
})
