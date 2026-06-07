"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"

export function useSystemSettingsQuery() {
	return useQuery(orpc.igubat.admin.settings.queryOptions())
}

export function useUpsertSystemSettingMutation() {
	const queryClient = useQueryClient()

	return useMutation(
		orpc.igubat.admin.upsertSetting.mutationOptions({
			onSuccess: async () => {
				await queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.settings.key() })
			},
		})
	)
}
