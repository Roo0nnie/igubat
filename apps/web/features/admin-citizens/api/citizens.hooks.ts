"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useAdminCitizensQuery() {
	return useQuery(orpc.igubat.admin.citizens.queryOptions({ input: undefined }))
}

export function useAdminCitizenQuery(id: string) {
	return useQuery(orpc.igubat.admin.citizen.queryOptions({ input: { id }, enabled: id.length > 0 }))
}
