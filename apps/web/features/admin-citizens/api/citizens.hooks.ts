"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type CitizenListInput = V1Inputs["igubat"]["admin"]["citizens"]

export function useAdminCitizensQuery(input?: CitizenListInput) {
	return useQuery({
		...orpc.igubat.admin.citizens.queryOptions({ input }),
		staleTime: 60_000,
		placeholderData: previous => previous,
	})
}

export function useAdminCitizenQuery(id: string) {
	return useQuery(orpc.igubat.admin.citizen.queryOptions({ input: { id }, enabled: id.length > 0 }))
}
