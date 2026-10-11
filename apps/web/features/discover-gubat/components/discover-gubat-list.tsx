"use client"

import Link from "next/link"
import { Compass } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import {
	CardGridSkeleton,
	EmptyState,
	ErrorState,
	LoadingStatus,
} from "@/core/components/ui/loading-state"
import { useDiscoverGubatListQuery } from "@/features/discover-gubat/api/discover-gubat.hooks"

function label(value: string) {
	return value
		.split("_")
		.map(word => `${word.charAt(0).toUpperCase()}${word.slice(1)}`)
		.join(" ")
}

export function DiscoverGubatList() {
	const query = useDiscoverGubatListQuery()

	const items = query.data ?? []

	return (
		<section className="flex w-full max-w-5xl flex-col gap-5">
			<div>
				<h1 className="text-3xl font-semibold">Discover Gubat</h1>
				<p className="text-muted-foreground text-sm">
					Tourist spots, festivals, culture, and local products published by the LGU.
				</p>
			</div>
			{query.isLoading && (
				<>
					<LoadingStatus
						message="Loading places, festivals and local products..."
						onRetry={() => void query.refetch()}
						className="[&>div]:justify-start"
					/>
					<CardGridSkeleton count={4} className="md:grid-cols-2 lg:grid-cols-2" />
				</>
			)}
			{query.isError && (
				<ErrorState title="Could not load Discover Gubat." onRetry={() => void query.refetch()} />
			)}
			{query.isSuccess && items.length === 0 && (
				<EmptyState
					icon={Compass}
					title="Nothing to discover yet"
					description="Tourist spots, festivals and local products will appear here soon."
				/>
			)}
			<div className="grid gap-4 md:grid-cols-2">
				{items.map(item => (
					<Link key={item.id} href={`/discover-gubat/${item.slug}`}>
						<Card className="h-full transition hover:shadow-md">
							<CardHeader>
								<div className="flex items-center justify-between gap-3">
									<Badge variant="secondary">{label(item.type)}</Badge>
									<span className="text-muted-foreground text-xs">{label(item.category)}</span>
								</div>
								<CardTitle>{item.title}</CardTitle>
								<CardDescription>
									{item.locationName ?? item.whereToBuy ?? "Gubat, Sorsogon"}
								</CardDescription>
							</CardHeader>
							<CardContent>
								<p className="text-muted-foreground line-clamp-3 text-sm">
									{item.summary ?? "Read more about this Discover Gubat entry."}
								</p>
							</CardContent>
						</Card>
					</Link>
				))}
			</div>
		</section>
	)
}
