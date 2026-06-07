"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useAdminDashboardQuery() {
	return useQuery(orpc.igubat.admin.dashboard.queryOptions())
}
