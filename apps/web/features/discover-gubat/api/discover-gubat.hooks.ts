"use client"

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { orpc } from "@/services/orpc/client"
import type { V1Inputs } from "@/services/orpc/contract-types"

type DiscoverListInput = V1Inputs["igubat"]["public"]["discoverGubat"]["list"]
type CreateDiscoverInput = V1Inputs["igubat"]["admin"]["discoverGubat"]["create"]
type UpdateDiscoverInput = V1Inputs["igubat"]["admin"]["discoverGubat"]["update"]

export function useDiscoverGubatListQuery(input?: DiscoverListInput) {
	return useQuery(orpc.igubat.public.discoverGubat.list.queryOptions({ input }))
}

export function useDiscoverGubatDetailQuery(slug: string) {
	return useQuery(
		orpc.igubat.public.discoverGubat.detail.queryOptions({
			input: { slug },
			enabled: slug.length > 0,
		})
	)
}

export function useAdminDiscoverGubatListQuery(input?: DiscoverListInput) {
	return useQuery(orpc.igubat.admin.discoverGubat.list.queryOptions({ input }))
}

export function useCreateDiscoverGubatMutation() {
	const queryClient = useQueryClient()
	return useMutation(
		orpc.igubat.admin.discoverGubat.create.mutationOptions({
			onSuccess: () =>
				queryClient.invalidateQueries({ queryKey: orpc.igubat.admin.discoverGubat.list.key() }),
		})
	)
}

export function useUpdateDiscoverGubatMutation() {
	const queryClient = useQueryClient()
	return useMutation(
		orpc.igubat.admin.discoverGubat.update.mutationOptions({
			onSuccess: (_data, input: UpdateDiscoverInput | CreateDiscoverInput) => {
				void queryClient.invalidateQueries({
					queryKey: orpc.igubat.admin.discoverGubat.list.key(),
				})
				if ("id" in input) {
					void queryClient.invalidateQueries({
						queryKey: orpc.igubat.admin.discoverGubat.detail.key({ input: { id: input.id } }),
					})
				}
			},
		})
	)
}
