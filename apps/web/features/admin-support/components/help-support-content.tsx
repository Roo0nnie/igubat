"use client"

import { HelpCircle } from "lucide-react"

import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import {
	EmptyState,
	ErrorState,
	ListSkeleton,
	LoadingStatus,
} from "@/core/components/ui/loading-state"
import { useHelpArticlesQuery } from "@/features/admin-support/api/support.hooks"

export function HelpSupportContent() {
	const help = useHelpArticlesQuery()
	const rows = help.data ?? []

	return (
		<div className="mx-auto max-w-5xl space-y-6 p-6 md:p-8">
			<div>
				<h1 className="text-primary text-3xl font-bold tracking-tight">Help & Support</h1>
				<p className="text-muted-foreground mt-2">
					Staff and citizen guidance for using iGubat workflows.
				</p>
			</div>

			<div className="grid gap-4">
				{help.isLoading && (
					<>
						<LoadingStatus message="Loading help articles..." onRetry={() => void help.refetch()} />
						<ListSkeleton count={4} />
					</>
				)}
				{help.isError && (
					<ErrorState
						title="Help articles could not be loaded."
						onRetry={() => void help.refetch()}
					/>
				)}
				{rows.map(article => (
					<Card key={article.id}>
						<CardHeader>
							<CardTitle className="flex items-center gap-2">
								<HelpCircle className="text-primary size-5" /> {article.title}
							</CardTitle>
							<CardDescription>
								{article.category} - {article.audience}
							</CardDescription>
						</CardHeader>
						<CardContent>
							<p className="text-muted-foreground text-sm whitespace-pre-wrap">{article.content}</p>
						</CardContent>
					</Card>
				))}
				{!help.isLoading && !help.isError && rows.length === 0 && (
					<Card>
						<CardContent>
							<EmptyState
								icon={HelpCircle}
								title="No help articles yet"
								description="Published guides for staff and citizens will appear here."
							/>
						</CardContent>
					</Card>
				)}
			</div>
		</div>
	)
}
