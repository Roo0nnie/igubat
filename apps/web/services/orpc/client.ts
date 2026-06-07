import { createORPCClient } from "@orpc/client"
import type { ContractRouterClient } from "@orpc/contract"
import type { JsonifiedClient } from "@orpc/openapi-client"
import { OpenAPILink } from "@orpc/openapi-client/fetch"
import { createTanstackQueryUtils } from "@orpc/tanstack-query"

import { v1Contract } from "@repo/contracts"

import { env } from "@/env"

type CookieHeaderProvider = () => Promise<string | undefined> | string | undefined
type V1Client = JsonifiedClient<ContractRouterClient<typeof v1Contract>>

export function createOrpcLink(options?: { getCookieHeader?: CookieHeaderProvider }) {
	return new OpenAPILink(v1Contract, {
		url: env.NEXT_PUBLIC_API_BASE_URL,
		fetch: async (request, init) => {
			const cookieHeader = await options?.getCookieHeader?.()
			const headers = new Headers(request.headers)

			if (cookieHeader) {
				headers.set("cookie", cookieHeader)
			}

			return fetch(request, {
				...init,
				credentials: "include",
				headers,
			})
		},
	})
}

const link = createOrpcLink()

const globalThisRef = globalThis as typeof globalThis & {
	$orpc?: V1Client
}

globalThisRef.$orpc ??= createORPCClient<V1Client>(link)

export const orpc = createTanstackQueryUtils(globalThisRef.$orpc, { path: ["orpc"] })
