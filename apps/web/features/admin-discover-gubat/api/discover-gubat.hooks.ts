"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type DiscoverGubatListInput = V1Inputs["igubat"]["admin"]["discoverGubat"]["list"]

export function useDiscoverGubatListQuery(input?: DiscoverGubatListInput) {
	return useQuery({
		...orpc.igubat.admin.discoverGubat.list.queryOptions({ input }),
		staleTime: 60_000,
		placeholderData: previous => previous,
	})
}

export function useDiscoverGubatDetailQuery(id: number | undefined) {
	return useQuery(
		orpc.igubat.admin.discoverGubat.detail.queryOptions({
			input: { id: id ?? 0 },
			enabled: typeof id === "number" && id > 0,
		})
	)
}

function useInvalidateDiscoverGubat() {
	const queryClient = useQueryClient()
	return () =>
		Promise.all([
			queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.discoverGubat.list.key() }),
			queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.discoverGubat.detail.key() }),
		])
}

export function useCreateDiscoverGubatMutation() {
	const invalidate = useInvalidateDiscoverGubat()
	return useMutation(
		orpc.igubat.admin.discoverGubat.create.mutationOptions({ onSuccess: () => invalidate() })
	)
}

export function useUpdateDiscoverGubatMutation() {
	const invalidate = useInvalidateDiscoverGubat()
	return useMutation(
		orpc.igubat.admin.discoverGubat.update.mutationOptions({ onSuccess: () => invalidate() })
	)
}

export function usePublishDiscoverGubatMutation() {
	const invalidate = useInvalidateDiscoverGubat()
	return useMutation(
		orpc.igubat.admin.discoverGubat.publish.mutationOptions({ onSuccess: () => invalidate() })
	)
}

export function useArchiveDiscoverGubatMutation() {
	const invalidate = useInvalidateDiscoverGubat()
	return useMutation(
		orpc.igubat.admin.discoverGubat.archive.mutationOptions({ onSuccess: () => invalidate() })
	)
}

export function useDeleteDiscoverGubatMutation() {
	const invalidate = useInvalidateDiscoverGubat()
	return useMutation(
		orpc.igubat.admin.discoverGubat.delete.mutationOptions({ onSuccess: () => invalidate() })
	)
}
