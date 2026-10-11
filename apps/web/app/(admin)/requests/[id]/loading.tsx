import { DetailPageSkeleton, LoadingStatus } from "@/core/components/ui/loading-state"

export default function RequestDetailLoading() {
	return (
		<div className="mx-auto max-w-6xl space-y-6 p-6 md:p-8">
			<LoadingStatus message="Loading request details..." className="[&>div]:justify-start" />
			<DetailPageSkeleton />
		</div>
	)
}
