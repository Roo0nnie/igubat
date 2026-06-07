"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type RequestListInput = V1Inputs["igubat"]["admin"]["requests"]
type UpdateRequestInput = V1Inputs["igubat"]["admin"]["updateRequestStatus"]

export function useAdminRequestsQuery(input?: RequestListInput) {
	return useQuery(orpc.igubat.admin.requests.queryOptions({ input }))
}

export function useAdminRequestQuery(id: number) {
	return useQuery(
		orpc.igubat.admin.request.queryOptions({ input: { id }, enabled: Number.isFinite(id) })
	)
}

export function useUpdateRequestStatusMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.admin.updateRequestStatus.mutationOptions({
			onSuccess: async (_data, input: UpdateRequestInput) => {
				await Promise.all([
					queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.requests.key() }),
					queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.dashboard.key() }),
					queryClient.invalidateQueries({
						queryKey: orpc.igubat.admin.request.key({ input: { id: Number(input.id) } }),
					}),
				])
			},
		})
	)
}
