/**
 * Portal role model and role-based access control (RBAC) helpers.
 *
 * Source of truth: `igubat_admin_portal.md` — Web Administration Portal Workflow
 * (Section 7 "Strict RBAC at UI and API" and Section 8 "Permission Matrix").
 *
 * The database stores fine-grained staff roles (see `users.role` in
 * `@repo/db/schema`). For the web portal those collapse into two effective
 * portal roles, exactly as the spec describes:
 *
 *   - **Moderator** — LGU operational staff. Operations + content surfaces.
 *   - **Admin** — Super administrator. All Moderator capabilities plus the
 *     admin-only surfaces (User Management, Analytics, Audit Logs, Settings).
 *
 * Citizens have no portal access at all.
 *
 * This module is intentionally framework-agnostic (no `server-only`) so it can
 * be shared by server guards and client components (sidebar, header).
 */

/** Fine-grained roles persisted on the user record. */
export type DbRole =
	| "registered_citizen"
	| "frontline_officer"
	| "department_supervisor"
	| "content_editor"
	| "emergency_operator"
	| "ict_admin"
	| "super_admin"

/** Effective role within the web administration portal. */
export type PortalRole = "moderator" | "admin"

/** DB roles that map to the Admin portal role. */
const ADMIN_DB_ROLES: ReadonlySet<DbRole> = new Set<DbRole>(["ict_admin", "super_admin"])

/** DB roles that map to the Moderator portal role. */
const MODERATOR_DB_ROLES: ReadonlySet<DbRole> = new Set<DbRole>([
	"frontline_officer",
	"department_supervisor",
	"content_editor",
	"emergency_operator",
])

/**
 * Resolve the effective portal role for a stored DB role.
 *
 * Returns `null` for citizens and any unknown/missing role, i.e. anyone who
 * must not reach the portal.
 */
export function getPortalRole(role: string | null | undefined): PortalRole | null {
	if (!role) return null
	if (ADMIN_DB_ROLES.has(role as DbRole)) return "admin"
	if (MODERATOR_DB_ROLES.has(role as DbRole)) return "moderator"
	return null
}

/** Whether the given DB role may access the portal at all (Moderator or Admin). */
export function isStaffRole(role: string | null | undefined): boolean {
	return getPortalRole(role) !== null
}

/** Whether the given DB role has Admin (super administrator) portal access. */
export function isAdminRole(role: string | null | undefined): boolean {
	return getPortalRole(role) === "admin"
}

/**
 * Access level required to view a portal surface.
 * `"staff"` = Moderator or Admin; `"admin"` = Admin only.
 */
export type RequiredAccess = "staff" | "admin"

/** Whether a portal role satisfies the required access level for a surface. */
export function canAccess(portalRole: PortalRole | null, required: RequiredAccess): boolean {
	if (portalRole === null) return false
	if (required === "admin") return portalRole === "admin"
	return true // "staff" — both moderator and admin
}

/** Human-readable label for a DB role, for display in the header/profile. */
export function getRoleLabel(role: string | null | undefined): string {
	switch (role) {
		case "super_admin":
			return "Super Administrator"
		case "ict_admin":
			return "ICT Administrator"
		case "department_supervisor":
			return "Department Supervisor"
		case "frontline_officer":
			return "Frontline Officer"
		case "content_editor":
			return "Content Editor"
		case "emergency_operator":
			return "Emergency Operator"
		case "registered_citizen":
			return "Citizen"
		default:
			return "Staff"
	}
}
