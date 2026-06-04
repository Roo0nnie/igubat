import { Forbidden } from "@/core/components/forbidden"

/**
 * Forbidden boundary for admin surfaces. Rendered with an HTTP 403 status
 * whenever a route guard calls `forbidden()` (e.g. a Moderator opening an
 * admin-only URL directly). Lives inside `(admin)` so it renders within the
 * portal chrome (sidebar/header) rather than as a bare page.
 */
export default function AdminForbidden() {
	return <Forbidden message="This area is restricted to Administrators." />
}
