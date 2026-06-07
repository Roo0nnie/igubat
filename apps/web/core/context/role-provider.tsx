"use client"

import { createContext, useContext, type PropsWithChildren } from "react"

import { canAccess, type PortalRole, type RequiredAccess } from "@/core/lib/roles"

export type PortalUserContext = {
	id: string
	name: string
	email: string
	role: string
	portalRole: PortalRole
}

const RoleContext = createContext<PortalUserContext | null>(null)

/**
 * Provides the authenticated staff member (resolved server-side in the admin
 * layout) to client components such as the sidebar and header, so they can
 * render role-aware navigation without re-fetching the session.
 */
export function RoleProvider({ user, children }: PropsWithChildren<{ user: PortalUserContext }>) {
	return <RoleContext.Provider value={user}>{children}</RoleContext.Provider>
}

/** Access the current portal user. Throws if used outside the admin layout. */
export function usePortalUser(): PortalUserContext {
	const ctx = useContext(RoleContext)
	if (!ctx) {
		throw new Error("usePortalUser must be used within a RoleProvider")
	}
	return ctx
}

/** Convenience hook for role checks in client components. */
export function useRole() {
	const user = usePortalUser()
	return {
		...user,
		isAdmin: user.portalRole === "admin",
		isModerator: user.portalRole === "moderator",
		can: (required: RequiredAccess) => canAccess(user.portalRole, required),
	}
}
