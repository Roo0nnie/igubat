"use client"

import { useRouter } from "next/navigation"
import { useMutation, useQueryClient } from "@tanstack/react-query"

import { getPortalRole } from "@/core/lib/roles"
import { authClient } from "@/services/better-auth/auth-client"
import { sessionKeys } from "@/features/auth/api/session.hooks"

import type { Login } from "./login.schema"

/** Shown when a non-staff (citizen) account authenticates against the portal. */
export const STAFF_ONLY_MESSAGE =
	"This portal is for authorized staff only. Your account does not have access."

export function useLoginMutation() {
	const router = useRouter()
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: async (data: Login) => {
			const result = await authClient.signIn.email(data)
			if (result.error) {
				throw new Error(result.error.message || "Failed to sign in")
			}

			// Role-based gate as the FIRST user-facing check (spec: /login is the
			// staff portal entry point). Inspect the authenticated role immediately
			// instead of relying on the admin layout's post-render redirect.
			const role = (result.data?.user as { role?: string | null } | undefined)?.role
			if (getPortalRole(role) === null) {
				// Citizen / unknown role signed in successfully — isolate the session
				// and surface a clear denial rather than bouncing back to /login.
				await authClient.signOut()
				queryClient.invalidateQueries({ queryKey: sessionKeys.all })
				throw new Error(STAFF_ONLY_MESSAGE)
			}

			return result
		},
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: sessionKeys.all })
			// Only staff reach this point — route straight to the portal dashboard.
			router.push("/dashboard")
		},
	})
}
