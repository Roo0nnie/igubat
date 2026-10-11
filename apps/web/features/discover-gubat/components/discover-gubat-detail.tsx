"use client"

import Link from "next/link"

import { Badge } from "@/core/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/core/components/ui/card"
import { ErrorState, LoadingStatus } from "@/core/components/ui/loading-state"
import { Skeleton } from "@/core/components/ui/skeleton"
import { useDiscoverGubatDetailQuery } from "@/features/discover-gubat/api/discover-gubat.hooks"

function label(value: string) {
	return value
		.split("_")
		.map(word => `${word.charAt(0).toUpperCase()}${word.slice(1)}`)
		.join(" ")
}

export function DiscoverGubatDetail({ slug }: { slug: string }) {
	const query = useDiscoverGubatDetailQuery(slug)

	if (query.isLoading) {
		return (
			<div className="flex w-full max-w-3xl flex-col gap-4">
				<LoadingStatus
					message="Loading details..."
					onRetry={() => void query.refetch()}
					className="[&>div]:justify-start"
				/>
				<div className="bg-card space-y-4 rounded-xl border p-6" aria-hidden="true">
					<div className="flex gap-2">
						<Skeleton className="h-5 w-20 rounded-full" />
						<Skeleton className="h-5 w-16 rounded-full" />
					</div>
					<Skeleton className="h-7 w-2/3" />
					<Skeleton className="h-4 w-1/3" />
					<div className="space-y-2 pt-2">
						{Array.from({ length: 6 }).map((_, index) => (
							<Skeleton key={index} className={index === 5 ? "h-4 w-1/2" : "h-4 w-full"} />
						))}
					</div>
				</div>
			</div>
		)
	}

	if (query.isError || !query.data) {
		return (
			<div className="flex w-full max-w-3xl flex-col gap-4">
				<Link
					href="/discover-gubat"
					className="text-muted-foreground hover:text-foreground text-sm"
				>
					Back to Discover Gubat
				</Link>
				<ErrorState
					title="Could not load this Discover Gubat item."
					description="It may have been unpublished, or your connection dropped."
					onRetry={() => void query.refetch()}
				/>
			</div>
		)
	}

	const item = query.data

	return (
		<article className="flex w-full max-w-3xl flex-col gap-4">
			<Link href="/discover-gubat" className="text-muted-foreground hover:text-foreground text-sm">
				Back to Discover Gubat
			</Link>
			<Card>
				<CardHeader>
					<div className="flex flex-wrap gap-2">
						<Badge variant="secondary">{label(item.type)}</Badge>
						<Badge variant="outline">{label(item.category)}</Badge>
					</div>
					<CardTitle className="text-2xl">{item.title}</CardTitle>
					{(item.locationName || item.whereToBuy) && (
						<p className="text-muted-foreground text-sm">
							{item.locationName ?? `Where to buy: ${item.whereToBuy}`}
						</p>
					)}
				</CardHeader>
				<CardContent className="space-y-4">
					<p className="leading-7 whitespace-pre-line">{item.body || item.summary}</p>
					{item.locationAddress && (
						<p className="text-muted-foreground text-sm">Location: {item.locationAddress}</p>
					)}
					{item.priceRange && (
						<p className="text-muted-foreground text-sm">Price range: {item.priceRange}</p>
					)}
					{item.contactInfo && (
						<p className="text-muted-foreground text-sm">Contact: {item.contactInfo}</p>
					)}
				</CardContent>
			</Card>
		</article>
	)
}
