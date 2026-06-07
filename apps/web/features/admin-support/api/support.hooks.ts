"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useHelpArticlesQuery() {
	return useQuery(orpc.igubat.public.help.queryOptions())
}

export function usePolicyDocumentQuery(slug: string) {
	return useQuery(
		orpc.igubat.public.policy.queryOptions({ input: { slug }, enabled: slug.length > 0 })
	)
}
