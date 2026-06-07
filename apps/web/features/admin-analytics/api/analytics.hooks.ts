"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useAdminAnalyticsQuery() {
	return useQuery(orpc.igubat.admin.analytics.queryOptions({ input: undefined }))
}
