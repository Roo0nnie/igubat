"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useAuditLogsQuery() {
	return useQuery(orpc.igubat.admin.auditLogs.queryOptions({ input: undefined }))
}
