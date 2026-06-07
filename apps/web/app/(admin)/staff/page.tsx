import { forbidden } from "next/navigation"

import { requireStaff } from "@/core/lib/admin-guard"
import { StaffContent } from "@/features/admin-staff/components/staff-content"

export const metadata = {
	title: "Staff Management - iGubat",
}

export default async function StaffPage() {
	const user = await requireStaff()
	if (user.portalRole !== "admin") {
		forbidden()
	}
	return <StaffContent />
}
