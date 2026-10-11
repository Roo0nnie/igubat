"use client"

import { useState } from "react"
import { AlertTriangle, Bell, Send } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"
import {
	EmptyState,
	ErrorState,
	ListSkeleton,
	LoadingStatus,
} from "@/core/components/ui/loading-state"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/core/components/ui/select"
import { Textarea } from "@/core/components/ui/textarea"
import {
	useCreateBroadcastMutation,
	useEmergencyBroadcastsQuery,
} from "@/features/admin-emergency/api/emergency.hooks"

const SEVERITIES = ["info", "warning", "critical"] as const

function formatDate(value: string | Date | null) {
	if (!value) return "Scheduled"
	return new Date(value).toLocaleString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
		hour: "numeric",
		minute: "2-digit",
	})
}

export function NotificationsContent() {
	const broadcasts = useEmergencyBroadcastsQuery()
	const createBroadcast = useCreateBroadcastMutation()
	const [title, setTitle] = useState("")
	const [message, setMessage] = useState("")
	const [severity, setSeverity] = useState<(typeof SEVERITIES)[number]>("info")

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
				<div>
					<h1 className="text-primary text-3xl font-bold tracking-tight">Alerts & Notifications</h1>
					<p className="text-muted-foreground mt-2">
						Send citizen broadcasts and review recent alert history.
					</p>
				</div>
			</div>

			<div className="grid gap-6 md:grid-cols-2">
				<Card className="flex flex-col">
					<CardHeader>
						<CardTitle className="flex items-center gap-2">
							<AlertTriangle className="text-destructive size-5" />
							Send Broadcast Alert
						</CardTitle>
						<CardDescription>
							Push a notification to all opted-in citizens immediately.
						</CardDescription>
					</CardHeader>
					<CardContent className="flex-1 space-y-4">
						<div className="space-y-2">
							<Label htmlFor="title">Alert Title</Label>
							<Input
								id="title"
								value={title}
								onChange={event => setTitle(event.target.value)}
								placeholder="Typhoon advisory"
							/>
						</div>
						<div className="space-y-2">
							<Label>Severity Level</Label>
							<Select
								value={severity}
								onValueChange={value => setSeverity(value as (typeof SEVERITIES)[number])}
							>
								<SelectTrigger className="w-full">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{SEVERITIES.map(option => (
										<SelectItem key={option} value={option}>
											{option}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</div>
						<div className="space-y-2">
							<Label htmlFor="message">Message Content</Label>
							<Textarea
								id="message"
								value={message}
								onChange={event => setMessage(event.target.value)}
								className="min-h-[120px]"
							/>
						</div>
					</CardContent>
					<CardFooter>
						<Button
							className="w-full"
							variant="destructive"
							disabled={!title || !message}
							loading={createBroadcast.isPending}
							loadingText="Sending broadcast..."
							onClick={() => createBroadcast.mutate({ title, message, severity, sendNow: true })}
						>
							<Send className="size-4" /> Send broadcast now
						</Button>
					</CardFooter>
				</Card>

				<Card>
					<CardHeader>
						<CardTitle className="flex items-center gap-2">
							<Bell className="text-primary size-5" />
							Recent Broadcasts
						</CardTitle>
						<CardDescription>History of alerts sent from the system.</CardDescription>
					</CardHeader>
					<CardContent>
						<div className="space-y-4">
							{broadcasts.isLoading && (
								<>
									<LoadingStatus
										message="Loading broadcasts..."
										onRetry={() => void broadcasts.refetch()}
									/>
									<ListSkeleton count={3} />
								</>
							)}
							{broadcasts.isError && (
								<ErrorState
									compact
									title="Broadcast history could not be loaded."
									onRetry={() => void broadcasts.refetch()}
								/>
							)}
							{broadcasts.data?.map(broadcast => (
								<div key={broadcast.id} className="space-y-2 rounded-lg border p-4">
									<div className="flex items-start justify-between gap-2">
										<h4 className="font-semibold">{broadcast.title}</h4>
										<Badge
											variant={
												broadcast.severity === "critical"
													? "destructive"
													: broadcast.severity === "warning"
														? "secondary"
														: "default"
											}
										>
											{broadcast.severity}
										</Badge>
									</div>
									<p className="text-muted-foreground text-sm">{broadcast.message}</p>
									<div className="text-muted-foreground pt-2 text-xs">
										{broadcast.status} on {formatDate(broadcast.sentAt ?? broadcast.scheduledAt)}
									</div>
								</div>
							))}
							{!broadcasts.isLoading &&
								!broadcasts.isError &&
								(broadcasts.data ?? []).length === 0 && (
									<EmptyState
										compact
										icon={Bell}
										title="No broadcasts sent yet"
										description="Alerts you send will be listed here."
									/>
								)}
						</div>
					</CardContent>
				</Card>
			</div>
		</div>
	)
}
