"use client"

import { ShieldCheck } from "lucide-react"

import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
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
						<ShieldCheck className="text-primary size-5" /> {data?.title ?? "Loading..."}
					</CardTitle>
					<CardDescription>Version {data?.version ?? "..."}</CardDescription>
				</CardHeader>
				<CardContent>
					{policy.isLoading && <p className="text-muted-foreground text-sm">Loading policy...</p>}
					{policy.isError && (
						<p className="text-destructive text-sm">Policy could not be loaded.</p>
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
