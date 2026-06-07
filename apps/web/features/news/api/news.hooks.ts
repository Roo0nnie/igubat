"use client"

import { useQuery } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type NewsListInput = V1Inputs["igubat"]["public"]["news"]

export function useNewsQuery() {
	return useQuery(orpc.igubat.public.news.queryOptions({ input: undefined }))
}

export function useNewsListQuery(input?: NewsListInput) {
	return useQuery(orpc.igubat.public.news.queryOptions({ input }))
}

export function useArticleQuery(slug: string) {
	return useQuery(
		orpc.igubat.public.article.queryOptions({ input: { slug }, enabled: slug.length > 0 })
	)
}
