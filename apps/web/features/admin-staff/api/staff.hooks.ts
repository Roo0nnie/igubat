"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useAdminStaffQuery() {
	return useQuery(orpc.igubat.admin.staff.queryOptions())
}

export function useCreateStaffMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.admin.createStaff.mutationOptions({
			onSuccess: async () => {
				await queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.staff.key() })
			},
		})
	)
}
