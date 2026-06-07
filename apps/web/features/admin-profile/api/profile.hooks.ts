"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import { sessionKeys } from "@/features/auth/api/session.hooks"

export function useStaffProfileQuery() {
	return useQuery(orpc.igubat.me.profile.queryOptions())
}

export function useUpdateStaffProfileMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.me.updateProfile.mutationOptions({
			onSuccess: async () => {
				await Promise.all([
					queryClient.invalidateQueries({ queryKey: orpc.igubat.me.profile.key() }),
					queryClient.invalidateQueries({ queryKey: sessionKeys.all }),
				])
			},
		})
	)
}
