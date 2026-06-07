import { requireStaff } from "@/core/lib/admin-guard"
import { ProfileContent } from "@/features/admin-profile/components/profile-content"

export const metadata = {
	title: "My Profile - iGubat",
}

export default async function ProfilePage() {
	// Staff-accessible self-service surface (Moderator + Admin). No admin gate:
	// every staff member may view their own profile and change their password.
	await requireStaff()
	return <ProfileContent />
}
