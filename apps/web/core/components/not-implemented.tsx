import { Construction } from "lucide-react"

import {
	Empty,
	EmptyDescription,
	EmptyHeader,
	EmptyMedia,
	EmptyTitle,
} from "@/core/components/ui/empty"

/**
 * Explicit "not yet implemented" placeholder for admin surfaces whose backend
 * (queries, mutations, export endpoints) is not wired yet.
 *
 * This intentionally replaces interactive-looking tooling (fake KPIs, dead
 * export buttons, local-only toggles) so the page does not read as
 * production-ready while the underlying feature is untestable. It states the
 * status plainly instead of presenting controls that silently do nothing.
 */
export function NotImplemented({
	title = "Not yet implemented",
	description,
}: {
	title?: string
	description: string
}) {
	return (
		<Empty className="min-h-[40vh] border">
			<EmptyHeader>
				<EmptyMedia variant="icon">
					<Construction />
				</EmptyMedia>
				<EmptyTitle>{title}</EmptyTitle>
				<EmptyDescription>{description}</EmptyDescription>
			</EmptyHeader>
		</Empty>
	)
}
