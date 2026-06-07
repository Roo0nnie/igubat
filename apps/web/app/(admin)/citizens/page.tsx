import { forbidden } from "next/navigation"

import { requireStaff } from "@/core/lib/admin-guard"
import { CitizensContent } from "@/features/admin-citizens/components/citizens-content"

export const metadata = {
	title: "User Management - iGubat",
}

export default async function CitizensPage() {
	// Admin-only surface (spec Section 6). Moderators reaching this URL directly
	// get a real HTTP 403 via the App Router forbidden boundary.
	const user = await requireStaff()
	if (user.portalRole !== "admin") {
		forbidden()
	}
	return <CitizensContent />
}
