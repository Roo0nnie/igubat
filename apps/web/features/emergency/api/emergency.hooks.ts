"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useEmergencyQuery() {
	return useQuery(orpc.igubat.public.emergencyDirectory.queryOptions())
}
