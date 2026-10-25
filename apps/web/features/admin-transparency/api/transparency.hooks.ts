"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type TransparencyListInput = V1Inputs["igubat"]["admin"]["transparency"]["list"]

export function useTransparencyListQuery(input?: TransparencyListInput) {
	return useQuery({
		...orpc.igubat.admin.transparency.list.queryOptions({ input }),
		staleTime: 60_000,
		placeholderData: previous => previous,
	})
}

export function useTransparencyDetailQuery(id: number | undefined) {
	return useQuery(
		orpc.igubat.admin.transparency.detail.queryOptions({
			input: { id: id ?? 0 },
			enabled: typeof id === "number" && id > 0,
		})
	)
}

function useInvalidateTransparency() {
	const queryClient = useQueryClient()
	return () =>
		Promise.all([
			queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.transparency.list.key() }),
			queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.transparency.detail.key() }),
		])
}

export function useCreateTransparencyMutation() {
	const invalidate = useInvalidateTransparency()
	return useMutation(
		orpc.igubat.admin.transparency.create.mutationOptions({ onSuccess: () => invalidate() })
	)
}

export function useUpdateTransparencyMutation() {
	const invalidate = useInvalidateTransparency()
	return useMutation(
		orpc.igubat.admin.transparency.update.mutationOptions({ onSuccess: () => invalidate() })
	)
}

export function usePublishTransparencyMutation() {
	const invalidate = useInvalidateTransparency()
	return useMutation(
		orpc.igubat.admin.transparency.publish.mutationOptions({ onSuccess: () => invalidate() })
	)
}

export function useArchiveTransparencyMutation() {
	const invalidate = useInvalidateTransparency()
	return useMutation(
		orpc.igubat.admin.transparency.archive.mutationOptions({ onSuccess: () => invalidate() })
	)
}

export function useDeleteTransparencyMutation() {
	const invalidate = useInvalidateTransparency()
	return useMutation(
		orpc.igubat.admin.transparency.delete.mutationOptions({ onSuccess: () => invalidate() })
	)
}
