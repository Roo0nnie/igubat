"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type ArticleListInput = V1Inputs["igubat"]["admin"]["articles"]

export function useAdminArticlesQuery(input?: ArticleListInput) {
	return useQuery(orpc.igubat.admin.articles.queryOptions({ input }))
}

export function useUpsertArticleMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.admin.upsertArticle.mutationOptions({
			onSuccess: async () => {
				await Promise.all([
					queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.articles.key() }),
					queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.dashboard.key() }),
				])
			},
		})
	)
}
