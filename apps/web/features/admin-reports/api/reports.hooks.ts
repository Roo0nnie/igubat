"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type ReportListInput = V1Inputs["igubat"]["admin"]["reports"]
type UpdateReportInput = V1Inputs["igubat"]["admin"]["updateReportStatus"]

export function useAdminReportsQuery(input?: ReportListInput) {
	return useQuery(orpc.igubat.admin.reports.queryOptions({ input }))
}

export function useAdminReportQuery(id: number) {
	return useQuery(
		orpc.igubat.admin.report.queryOptions({ input: { id }, enabled: Number.isFinite(id) })
	)
}

export function useUpdateReportStatusMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.admin.updateReportStatus.mutationOptions({
			onSuccess: async (_data, input: UpdateReportInput) => {
				await Promise.all([
					queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.reports.key() }),
					queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.dashboard.key() }),
					queryClient.invalidateQueries({
						queryKey: orpc.igubat.admin.report.key({ input: { id: Number(input.id) } }),
					}),
				])
			},
		})
	)
}
