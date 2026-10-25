"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type AuditLogListInput = V1Inputs["igubat"]["admin"]["auditLogs"]

export function useAuditLogsQuery(input?: AuditLogListInput) {
	return useQuery({
		...orpc.igubat.admin.auditLogs.queryOptions({ input }),
		staleTime: 60_000,
		placeholderData: previous => previous,
	})
}
