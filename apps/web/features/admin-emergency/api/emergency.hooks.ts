"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type BroadcastListInput = V1Inputs["igubat"]["admin"]["broadcasts"]

export function useAdminEmergencyDirectoryQuery() {
	return useQuery(orpc.igubat.admin.emergencyDirectory.queryOptions())
}

export function useEmergencyBroadcastsQuery(input?: BroadcastListInput) {
	return useQuery({
		...orpc.igubat.admin.broadcasts.queryOptions({ input }),
		staleTime: 60_000,
		placeholderData: previous => previous,
	})
}

export function useCreateBroadcastMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.admin.createBroadcast.mutationOptions({
			onSuccess: async () => {
				await Promise.all([
					queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.broadcasts.key() }),
					queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.dashboard.key() }),
				])
			},
		})
	)
}
