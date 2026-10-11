"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useCommunityStatsQuery() {
	return useQuery(orpc.igubat.admin.communityStats.queryOptions())
}

export function useUpdateCommunityStatsMutation() {
	const queryClient = useQueryClient()
	return useMutation(
		orpc.igubat.admin.updateCommunityStats.mutationOptions({
			onSuccess: async saved => {
				queryClient.setQueryData(orpc.igubat.admin.communityStats.queryKey(), saved)
				await queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.dashboard.key() })
			},
		})
	)
}
