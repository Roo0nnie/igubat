import Link from "next/link"
import { ShieldX } from "lucide-react"

import { Button } from "@/core/components/ui/button"

/**
 * 403 Forbidden view shown when a Moderator attempts to open an Admin-only
 * surface via direct URL (spec Section 7 — "refused at the API even if the
 * user constructs the URL manually").
 */
export function Forbidden({
	message = "You don't have permission to access this page.",
}: {
	message?: string
}) {
	return (
		<div className="flex min-h-[60vh] flex-col items-center justify-center gap-4 p-6 text-center">
			<div className="bg-destructive/10 flex h-16 w-16 items-center justify-center rounded-full">
				<ShieldX className="text-destructive h-8 w-8" />
			</div>
			<div className="space-y-1">
				<h1 className="text-2xl font-bold tracking-tight">403 — Forbidden</h1>
				<p className="text-muted-foreground max-w-md">{message}</p>
			</div>
			<Button render={<Link href="/dashboard" />}>Back to Dashboard</Button>
		</div>
	)
}
