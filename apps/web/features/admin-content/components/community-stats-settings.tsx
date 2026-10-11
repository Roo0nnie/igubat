"use client"

import { useMemo, useState } from "react"
import { ArrowDown, ArrowUp, RotateCcw, Save } from "lucide-react"
import { toast } from "sonner"

import { DEFAULT_COMMUNITY_STATS } from "@repo/contracts"

import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { Input } from "@/core/components/ui/input"
import { ErrorState, LoadingStatus } from "@/core/components/ui/loading-state"
import { Skeleton } from "@/core/components/ui/skeleton"
import { Switch } from "@/core/components/ui/switch"
import type { V1Outputs } from "@/services/orpc/contract-types"
import {
	useCommunityStatsQuery,
	useUpdateCommunityStatsMutation,
} from "@/features/admin-content/api/community-stats.hooks"

type StatConfig = V1Outputs["igubat"]["admin"]["communityStats"][number]

const STAT_DESCRIPTIONS: Record<StatConfig["key"], string> = {
	registered_citizens: "Registered citizen accounts",
	pending_requests: "Service requests waiting for action (status: pending)",
	completed_requests: "Service requests marked completed",
	active_services: "Active services in the service catalog",
	new_reports: "Citizen reports not yet acted on (status: received)",
	published_news: "Published news and announcements",
	upcoming_events: "Published events that have not ended yet",
}

export function CommunityStatsSettings() {
	const statsQuery = useCommunityStatsQuery()
	const updateStats = useUpdateCommunityStatsMutation()
	const [edits, setEdits] = useState<StatConfig[] | null>(null)
	const draft = useMemo(() => edits ?? statsQuery.data ?? [], [edits, statsQuery.data])

	function setDraft(next: StatConfig[] | ((current: StatConfig[]) => StatConfig[])) {
		setEdits(typeof next === "function" ? next(draft) : next)
	}

	const isDirty = useMemo(
		() => JSON.stringify(draft) !== JSON.stringify(statsQuery.data ?? []),
		[draft, statsQuery.data]
	)
	const hasInvalidLabel = draft.some(stat => !stat.label.trim())
	const enabled = draft.filter(stat => stat.enabled)

	function update(index: number, patch: Partial<StatConfig>) {
		setDraft(current => current.map((stat, i) => (i === index ? { ...stat, ...patch } : stat)))
	}

	function move(index: number, direction: -1 | 1) {
		setDraft(current => {
			const target = index + direction
			if (target < 0 || target >= current.length) return current
			const next = [...current]
			const [item] = next.splice(index, 1)
			next.splice(target, 0, item!)
			return next
		})
	}

	async function save() {
		try {
			await updateStats.mutateAsync({
				stats: draft.map(stat => ({ ...stat, label: stat.label.trim() })),
			})
			setEdits(null)
			toast.success("Community Stats updated. The mobile app shows the change on next refresh.")
		} catch (error) {
			toast.error(
				error instanceof Error && error.message
					? error.message
					: "Community Stats could not be saved."
			)
		}
	}

	return (
		<Card>
			<CardHeader>
				<CardTitle>Community Stats</CardTitle>
				<CardDescription>
					Choose which live counters appear on the mobile Home screen, rename them, and set their
					order. Values are calculated automatically from iGubat data.
				</CardDescription>
			</CardHeader>
			<CardContent className="space-y-4">
				{statsQuery.isLoading && (
					<div className="space-y-3">
						<LoadingStatus
							message="Loading community stats..."
							onRetry={() => void statsQuery.refetch()}
							className="[&>div]:justify-start"
						/>
						<div className="space-y-2">
							{Array.from({ length: 5 }, (_, index) => (
								<Skeleton key={index} className="h-14 w-full" />
							))}
						</div>
					</div>
				)}
				{statsQuery.isError && (
					<div className="rounded-md border">
						<ErrorState
							compact
							title="Community Stats could not be loaded."
							onRetry={() => void statsQuery.refetch()}
						/>
					</div>
				)}

				{draft.length > 0 && (
					<>
						<ol className="divide-y rounded-md border">
							{draft.map((stat, index) => (
								<li key={stat.key} className="flex flex-col gap-3 p-3 sm:flex-row sm:items-center">
									<div className="flex items-center gap-3 sm:w-24">
										<Switch
											checked={stat.enabled}
											onCheckedChange={checked => update(index, { enabled: checked })}
											aria-label={`Show ${stat.label || stat.key} on mobile Home`}
										/>
										<span className="text-muted-foreground text-xs">
											{stat.enabled ? "Shown" : "Hidden"}
										</span>
									</div>
									<div className="flex-1 space-y-1">
										<Input
											value={stat.label}
											maxLength={40}
											aria-label={`Label for ${STAT_DESCRIPTIONS[stat.key]}`}
											aria-invalid={!stat.label.trim()}
											onChange={event => update(index, { label: event.target.value })}
										/>
										<p className="text-muted-foreground text-xs">{STAT_DESCRIPTIONS[stat.key]}</p>
									</div>
									<div className="flex gap-1">
										<Button
											variant="ghost"
											size="icon"
											disabled={index === 0}
											aria-label={`Move ${stat.label} up`}
											onClick={() => move(index, -1)}
										>
											<ArrowUp className="size-4" />
										</Button>
										<Button
											variant="ghost"
											size="icon"
											disabled={index === draft.length - 1}
											aria-label={`Move ${stat.label} down`}
											onClick={() => move(index, 1)}
										>
											<ArrowDown className="size-4" />
										</Button>
									</div>
								</li>
							))}
						</ol>

						<div className="bg-muted/40 rounded-md border p-3">
							<p className="mb-2 text-xs font-medium">Mobile preview</p>
							{enabled.length === 0 ? (
								<p className="text-muted-foreground text-sm">
									No stats enabled — the Community Stats section will be hidden in the app.
								</p>
							) : (
								<div className="flex flex-wrap gap-2">
									{enabled.map(stat => (
										<span
											key={stat.key}
											className="bg-background rounded-md border px-3 py-1.5 text-sm"
										>
											{stat.label || "(no label)"}
										</span>
									))}
								</div>
							)}
						</div>

						{hasInvalidLabel && (
							<p className="text-destructive text-sm" role="alert">
								Every stat needs a label.
							</p>
						)}

						<div className="flex flex-wrap gap-2">
							<Button
								disabled={!isDirty || hasInvalidLabel}
								loading={updateStats.isPending}
								loadingText="Saving..."
								onClick={save}
							>
								<Save className="size-4" /> Save changes
							</Button>
							<Button
								variant="outline"
								disabled={updateStats.isPending}
								onClick={() => setDraft(DEFAULT_COMMUNITY_STATS)}
							>
								<RotateCcw className="size-4" /> Reset to defaults
							</Button>
						</div>
					</>
				)}
			</CardContent>
		</Card>
	)
}
