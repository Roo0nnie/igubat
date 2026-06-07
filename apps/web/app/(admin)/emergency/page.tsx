import { EmergencyContent } from "@/features/admin-emergency/components/emergency-content"

export const metadata = {
	title: "Emergency - iGubat",
}

// Moderator + Admin surface (spec Step 5). The admin layout already enforces
// that only staff reach this route.
export default function EmergencyPage() {
	return <EmergencyContent />
}
