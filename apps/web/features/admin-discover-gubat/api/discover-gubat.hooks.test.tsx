import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { act, renderHook, waitFor } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import {
	useArchiveDiscoverGubatMutation,
	useCreateDiscoverGubatMutation,
	useDeleteDiscoverGubatMutation,
	useDiscoverGubatDetailQuery,
	useDiscoverGubatListQuery,
	usePublishDiscoverGubatMutation,
	useUpdateDiscoverGubatMutation,
} from "./discover-gubat.hooks"

const api = vi.hoisted(() => ({
	list: vi.fn(async () => [{ id: 1 }]),
	detail: vi.fn(async (input: { id: number }) => ({ id: input.id })),
	mutation: vi.fn(async (input: unknown) => input),
}))

vi.mock("@/services/orpc/client", () => {
	const mutationProcedure = (name: string) => ({
		mutationOptions: (options: { onSuccess?: () => unknown }) => ({
			mutationKey: [name],
			mutationFn: api.mutation,
			...options,
		}),
	})
	return {
		orpc: {
			igubat: {
				admin: {
					discoverGubat: {
						list: {
							key: () => ["discover-gubat", "list"],
							queryOptions: ({ input }: { input?: unknown }) => ({
								queryKey: ["discover-gubat", "list", input],
								queryFn: api.list,
							}),
						},
						detail: {
							key: () => ["discover-gubat", "detail"],
							queryOptions: ({ input, enabled }: { input: { id: number }; enabled?: boolean }) => ({
								queryKey: ["discover-gubat", "detail", input.id],
								queryFn: () => api.detail(input),
								enabled,
							}),
						},
						create: mutationProcedure("create"),
						update: mutationProcedure("update"),
						publish: mutationProcedure("publish"),
						archive: mutationProcedure("archive"),
						delete: mutationProcedure("delete"),
					},
				},
			},
		},
	}
})

function setup() {
	const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
	const invalidate = vi.spyOn(queryClient, "invalidateQueries")
	const wrapper = ({ children }: { children: React.ReactNode }) => (
		<QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
	)
	return { invalidate, wrapper }
}

describe("Discover Gubat admin hooks", () => {
	it("loads the list and only fetches detail for a real id", async () => {
		const { wrapper } = setup()

		const list = renderHook(() => useDiscoverGubatListQuery({ type: "tourist_spot" }), { wrapper })
		await waitFor(() => expect(list.result.current.data).toEqual([{ id: 1 }]))

		renderHook(() => useDiscoverGubatDetailQuery(undefined), { wrapper })
		expect(api.detail).not.toHaveBeenCalled()

		const detail = renderHook(() => useDiscoverGubatDetailQuery(5), { wrapper })
		await waitFor(() => expect(detail.result.current.data).toEqual({ id: 5 }))
	})

	it.each([
		["create", useCreateDiscoverGubatMutation],
		["update", useUpdateDiscoverGubatMutation],
		["publish", usePublishDiscoverGubatMutation],
		["archive", useArchiveDiscoverGubatMutation],
		["delete", useDeleteDiscoverGubatMutation],
	] as const)("invalidates list and detail queries after %s", async (_name, useHook) => {
		const { invalidate, wrapper } = setup()
		const { result } = renderHook(() => useHook(), { wrapper })

		await act(async () => {
			await result.current.mutateAsync({ id: 1 } as never)
		})

		expect(invalidate).toHaveBeenCalledWith({ queryKey: ["discover-gubat", "list"] })
		expect(invalidate).toHaveBeenCalledWith({ queryKey: ["discover-gubat", "detail"] })
	})
})
