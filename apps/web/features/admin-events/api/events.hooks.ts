"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type EventListInput = V1Inputs["igubat"]["admin"]["events"]

export function useAdminEventsQuery(input?: EventListInput) {
	return useQuery({
		...orpc.igubat.admin.events.queryOptions({ input }),
		staleTime: 60_000,
		placeholderData: previous => previous,
	})
}

function useInvalidateEvents() {
	const queryClient = useQueryClient()
	return () =>
		Promise.all([
			queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.events.key() }),
			queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.dashboard.key() }),
		])
}

export function useUpsertEventMutation() {
	const invalidate = useInvalidateEvents()
	return useMutation(orpc.igubat.admin.upsertEvent.mutationOptions({ onSuccess: invalidate }))
}

export function useDeleteEventMutation() {
	const invalidate = useInvalidateEvents()
	return useMutation(orpc.igubat.admin.deleteEvent.mutationOptions({ onSuccess: invalidate }))
}
