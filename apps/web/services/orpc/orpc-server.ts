import "server-only"

import { createORPCClient } from "@orpc/client"
import type { ContractRouterClient } from "@orpc/contract"
import type { JsonifiedClient } from "@orpc/openapi-client"

import type { v1Contract } from "@repo/contracts"

import { getCookieHeader } from "@/core/lib/cookie-utils"
import { createOrpcLink } from "@/services/orpc/client"

const link = createOrpcLink({ getCookieHeader })
type V1Client = JsonifiedClient<ContractRouterClient<typeof v1Contract>>

const globalThisRef = globalThis as typeof globalThis & {
	$orpc?: V1Client
}

globalThisRef.$orpc = createORPCClient<V1Client>(link)
