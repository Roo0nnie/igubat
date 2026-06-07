"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useReportsQuery() {
	return useQuery(orpc.igubat.me.reports.queryOptions())
}

export function useReportQuery(id: number) {
	return useQuery(
		orpc.igubat.me.report.queryOptions({ input: { id }, enabled: Number.isFinite(id) })
	)
}

export function useCreateReportMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.me.createReport.mutationOptions({
			onSuccess: async () => {
				await queryClient.invalidateQueries({ queryKey: orpc.igubat.me.reports.key() })
			},
		})
	)
}
