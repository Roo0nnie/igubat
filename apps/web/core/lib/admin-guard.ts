import "server-only"

import { redirect } from "next/navigation"

import { getSession } from "@/services/better-auth/auth-server"
import { getPortalRole, type PortalRole } from "@/core/lib/roles"

/** The authenticated staff member resolved for the portal. */
export type PortalUser = {
	id: string
	name: string
	email: string
	role: string
	portalRole: PortalRole
}

/**
 * Resolve the current portal user from the session.
 *
 * - Unauthenticated visitors are redirected to `/login`.
 * - Authenticated citizens (no portal role) are redirected to `/login` as well;
 *   the portal is staff-only (spec Section 7 — strict RBAC).
 *
 * Use this in the admin layout so every admin surface has a known staff user,
 * and in admin-only pages to gate access (combine with `user.portalRole`).
 */
export async function requireStaff(): Promise<PortalUser> {
	const session = await getSession()
	const user = session?.user as
		| { id: string; name: string; email: string; role?: string | null }
		| undefined

	if (!user) {
		redirect("/login")
	}

	const portalRole = getPortalRole(user.role)
	if (portalRole === null) {
		// Authenticated but not staff — deny portal access entirely.
		redirect("/login")
	}

	return {
		id: user.id,
		name: user.name,
		email: user.email,
		role: user.role ?? "",
		portalRole,
	}
}
