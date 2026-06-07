"use client"

import { HelpCircle } from "lucide-react"

import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
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
					<p className="text-muted-foreground text-sm">Loading help articles...</p>
				)}
				{help.isError && (
					<p className="text-destructive text-sm">Help articles could not be loaded.</p>
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
						<CardContent className="text-muted-foreground py-6 text-sm">
							No help articles are published yet.
						</CardContent>
					</Card>
				)}
			</div>
		</div>
	)
}
