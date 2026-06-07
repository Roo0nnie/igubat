"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useAdminEmergencyDirectoryQuery() {
	return useQuery(orpc.igubat.admin.emergencyDirectory.queryOptions())
}

export function useEmergencyBroadcastsQuery() {
	return useQuery(orpc.igubat.admin.broadcasts.queryOptions())
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
