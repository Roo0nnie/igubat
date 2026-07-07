import { Suspense } from "react"

import { requireStaff } from "@/core/lib/admin-guard"
import { DiscoverGubatManagement } from "@/features/admin-discover-gubat/components/discover-gubat-management"

export const metadata = {
	title: "Discover Gubat - iGubat",
}

export default async function DiscoverGubatPage() {
	await requireStaff()

	return (
		<Suspense
			fallback={
				<div className="text-muted-foreground p-6 text-sm">Loading Discover Gubat manager...</div>
			}
		>
			<DiscoverGubatManagement />
		</Suspense>
	)
}
