"use client"

import { ShieldCheck } from "lucide-react"

import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { ErrorState, LoadingStatus } from "@/core/components/ui/loading-state"
import { Skeleton } from "@/core/components/ui/skeleton"
import { usePolicyDocumentQuery } from "@/features/admin-support/api/support.hooks"

export function PolicyContent({ slug }: { slug: string }) {
	const policy = usePolicyDocumentQuery(slug)
	const data = policy.data

	return (
		<div className="mx-auto max-w-4xl space-y-6 p-6 md:p-8">
			<div>
				<h1 className="text-primary text-3xl font-bold tracking-tight">
					{data?.title ?? "Policy"}
				</h1>
				<p className="text-muted-foreground mt-2">Municipality of Gubat iGubat policy document.</p>
			</div>

			<Card>
				<CardHeader>
					<CardTitle className="flex items-center gap-2">
						<ShieldCheck className="text-primary size-5" />
						{data?.title ?? <Skeleton className="h-5 w-48" />}
					</CardTitle>
					<CardDescription>
						{data ? `Version ${data.version}` : <Skeleton className="mt-1 h-3 w-20" />}
					</CardDescription>
				</CardHeader>
				<CardContent>
					{policy.isLoading && (
						<div className="space-y-4">
							<LoadingStatus
								message="Loading policy document..."
								onRetry={() => void policy.refetch()}
								className="[&>div]:justify-start"
							/>
							<div className="space-y-2.5" aria-hidden="true">
								{Array.from({ length: 10 }).map((_, index) => (
									<Skeleton key={index} className={index % 4 === 3 ? "h-4 w-2/3" : "h-4 w-full"} />
								))}
							</div>
						</div>
					)}
					{policy.isError && (
						<ErrorState title="Policy could not be loaded." onRetry={() => void policy.refetch()} />
					)}
					{data && (
						<p className="text-muted-foreground text-sm leading-6 whitespace-pre-wrap">
							{data.content}
						</p>
					)}
				</CardContent>
			</Card>
		</div>
	)
}
