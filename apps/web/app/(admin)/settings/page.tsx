import { forbidden } from "next/navigation"

import { requireStaff } from "@/core/lib/admin-guard"
import { SettingsContent } from "@/features/admin-settings/components/settings-content"

export const metadata = {
	title: "System Settings - iGubat",
}

export default async function SettingsPage() {
	// Admin-only: global system configuration (spec Section 9). Moderators reaching
	// this URL directly get a real HTTP 403 via the App Router forbidden boundary.
	// Self-service profile/password lives at /profile and stays staff-accessible.
	const user = await requireStaff()
	if (user.portalRole !== "admin") {
		forbidden()
	}
	return <SettingsContent />
}
