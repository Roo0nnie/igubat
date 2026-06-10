import { Suspense } from "react"

import { TransparencyListPage } from "@/features/admin-transparency/components/transparency-list-page"

export const metadata = {
	title: "Transparency & Good Governance - iGubat",
}

export default function TransparencyPage() {
	return (
		<Suspense
			fallback={
				<div className="text-muted-foreground p-6 text-sm">Loading transparency content...</div>
			}
		>
			<TransparencyListPage />
		</Suspense>
	)
}
