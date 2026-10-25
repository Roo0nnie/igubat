"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type StaffListInput = V1Inputs["igubat"]["admin"]["staff"]

export function useAdminStaffQuery(input?: StaffListInput) {
	return useQuery({
		...orpc.igubat.admin.staff.queryOptions({ input }),
		staleTime: 60_000,
		placeholderData: previous => previous,
	})
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
