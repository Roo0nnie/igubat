"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useRequestsQuery() {
	return useQuery(orpc.igubat.me.requests.queryOptions())
}

export function useRequestQuery(id: number) {
	return useQuery(
		orpc.igubat.me.request.queryOptions({ input: { id }, enabled: Number.isFinite(id) })
	)
}

export function useCreateRequestMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.me.createRequest.mutationOptions({
			onSuccess: async () => {
				await queryClient.invalidateQueries({ queryKey: orpc.igubat.me.requests.key() })
			},
		})
	)
}
