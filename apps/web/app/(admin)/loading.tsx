import { PageSkeleton, StatCardsSkeleton } from "@/core/components/ui/loading-state"
import { Skeleton } from "@/core/components/ui/skeleton"

export default function AdminLoading() {
	return (
		<PageSkeleton message="Loading page...">
			<StatCardsSkeleton />
			<div className="bg-card space-y-3 rounded-xl border p-6" aria-hidden="true">
				<div className="flex flex-col justify-between gap-3 sm:flex-row">
					<Skeleton className="h-9 w-full max-w-sm" />
					<Skeleton className="h-9 w-40" />
				</div>
				{Array.from({ length: 6 }).map((_, index) => (
					<Skeleton key={index} className="h-10 w-full" />
				))}
			</div>
		</PageSkeleton>
	)
}
