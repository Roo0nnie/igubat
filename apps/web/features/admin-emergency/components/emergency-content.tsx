"use client"

import { useState } from "react"
import { AlertCircle, History, Phone, Plus, Radio, Send } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"
import { TableStateRows } from "@/core/components/ui/loading-state"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/core/components/ui/select"
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/core/components/ui/table"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/core/components/ui/tabs"
import { Textarea } from "@/core/components/ui/textarea"
import {
	useAdminEmergencyDirectoryQuery,
	useCreateBroadcastMutation,
	useEmergencyBroadcastsQuery,
} from "@/features/admin-emergency/api/emergency.hooks"

const MAX_BROADCAST_LENGTH = 480
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

export function EmergencyContent() {
	const directory = useAdminEmergencyDirectoryQuery()
	const broadcasts = useEmergencyBroadcastsQuery()
	const createBroadcast = useCreateBroadcastMutation()
	const [title, setTitle] = useState("")
	const [message, setMessage] = useState("")
	const [severity, setSeverity] = useState<(typeof SEVERITIES)[number]>("info")
	const [scheduledAt, setScheduledAt] = useState("")

	function submitBroadcast(sendNow: boolean) {
		createBroadcast.mutate({
			title,
			message,
			severity,
			scheduledAt: !sendNow && scheduledAt ? scheduledAt : undefined,
			sendNow,
		})
	}

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div>
				<h1 className="text-primary text-3xl font-bold tracking-tight">Emergency</h1>
				<p className="text-muted-foreground mt-2">
					Manage COMCEN contacts and emergency broadcasts.
				</p>
			</div>

			<Tabs defaultValue="directory">
				<TabsList>
					<TabsTrigger value="directory">
						<Phone className="mr-2 size-4" /> Directory
					</TabsTrigger>
					<TabsTrigger value="broadcast">
						<Radio className="mr-2 size-4" /> Compose
					</TabsTrigger>
					<TabsTrigger value="history">
						<History className="mr-2 size-4" /> History
					</TabsTrigger>
				</TabsList>

				<TabsContent value="directory" className="mt-4">
					<Card>
						<CardHeader className="flex flex-row items-center justify-between">
							<div>
								<CardTitle>COMCEN & Directory</CardTitle>
								<CardDescription>
									Hospitals, BFP, PNP, disaster response, and COMCEN hotlines.
								</CardDescription>
							</div>
							<Button variant="outline">
								<Plus className="size-4" /> Add entry
							</Button>
						</CardHeader>
						<CardContent>
							<div className="rounded-md border">
								<Table>
									<TableHeader>
										<TableRow>
											<TableHead>Name</TableHead>
											<TableHead>Category</TableHead>
											<TableHead>Contact</TableHead>
											<TableHead>Address</TableHead>
											<TableHead>Hours</TableHead>
											<TableHead>Status</TableHead>
										</TableRow>
									</TableHeader>
									<TableBody>
										<TableStateRows
											colSpan={6}
											isLoading={directory.isLoading}
											isError={directory.isError}
											isEmpty={(directory.data ?? []).length === 0}
											onRetry={() => void directory.refetch()}
											loadingText="Loading emergency directory..."
											errorText="Directory could not be loaded."
											emptyText="No directory entries yet."
										/>
										{directory.data?.map(entry => (
											<TableRow key={entry.id}>
												<TableCell className="font-medium">{entry.name}</TableCell>
												<TableCell>{entry.type.toUpperCase()}</TableCell>
												<TableCell>{entry.contactNumber}</TableCell>
												<TableCell>{entry.address ?? "Not set"}</TableCell>
												<TableCell>{entry.hours ?? "24/7"}</TableCell>
												<TableCell>
													<Badge variant={entry.isActive ? "default" : "secondary"}>
														{entry.isActive ? "Active" : "Inactive"}
													</Badge>
												</TableCell>
											</TableRow>
										))}
									</TableBody>
								</Table>
							</div>
						</CardContent>
					</Card>
				</TabsContent>

				<TabsContent value="broadcast" className="mt-4">
					<Card>
						<CardHeader>
							<CardTitle>Compose Broadcast</CardTitle>
							<CardDescription>
								Send or schedule high-priority notices to opted-in citizens.
							</CardDescription>
						</CardHeader>
						<CardContent className="space-y-4">
							<div className="grid gap-4 md:grid-cols-2">
								<div className="space-y-2">
									<Label htmlFor="title">Title</Label>
									<Input
										id="title"
										value={title}
										onChange={event => setTitle(event.target.value)}
										placeholder="Weather advisory"
									/>
								</div>
								<div className="space-y-2">
									<Label>Severity</Label>
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
							</div>
							<div className="space-y-2">
								<Label htmlFor="message">Message</Label>
								<Textarea
									id="message"
									value={message}
									maxLength={MAX_BROADCAST_LENGTH}
									onChange={event => setMessage(event.target.value)}
									rows={5}
								/>
								<p className="text-muted-foreground text-right text-xs">
									{message.length}/{MAX_BROADCAST_LENGTH}
								</p>
							</div>
							<div className="flex flex-wrap items-end gap-3">
								<div className="space-y-2">
									<Label htmlFor="schedule">Schedule</Label>
									<Input
										id="schedule"
										type="datetime-local"
										value={scheduledAt}
										onChange={event => setScheduledAt(event.target.value)}
									/>
								</div>
								<Button
									disabled={
										createBroadcast.isPending ||
										title.trim().length === 0 ||
										message.trim().length === 0
									}
									loading={createBroadcast.isPending && createBroadcast.variables?.sendNow === true}
									loadingText="Sending..."
									onClick={() => submitBroadcast(true)}
								>
									<Send className="size-4" /> Send now
								</Button>
								<Button
									variant="outline"
									disabled={
										createBroadcast.isPending ||
										title.trim().length === 0 ||
										message.trim().length === 0 ||
										!scheduledAt
									}
									loading={
										createBroadcast.isPending && createBroadcast.variables?.sendNow === false
									}
									loadingText="Scheduling..."
									onClick={() => submitBroadcast(false)}
								>
									<AlertCircle className="size-4" /> Schedule
								</Button>
							</div>
						</CardContent>
					</Card>
				</TabsContent>

				<TabsContent value="history" className="mt-4">
					<Card>
						<CardHeader>
							<CardTitle>Broadcast History</CardTitle>
							<CardDescription>
								Sent and scheduled broadcasts with delivery summary.
							</CardDescription>
						</CardHeader>
						<CardContent>
							<div className="rounded-md border">
								<Table>
									<TableHeader>
										<TableRow>
											<TableHead>Title</TableHead>
											<TableHead>Severity</TableHead>
											<TableHead>Sent/Scheduled</TableHead>
											<TableHead>Recipients</TableHead>
											<TableHead>Status</TableHead>
										</TableRow>
									</TableHeader>
									<TableBody>
										<TableStateRows
											colSpan={5}
											isLoading={broadcasts.isLoading}
											isError={broadcasts.isError}
											isEmpty={(broadcasts.data ?? []).length === 0}
											onRetry={() => void broadcasts.refetch()}
											loadingText="Loading broadcasts..."
											errorText="Broadcasts could not be loaded."
											emptyText="No broadcasts sent yet."
										/>
										{broadcasts.data?.map(broadcast => (
											<TableRow key={broadcast.id}>
												<TableCell>
													<div className="font-medium">{broadcast.title}</div>
													<div className="text-muted-foreground max-w-md truncate text-xs">
														{broadcast.message}
													</div>
												</TableCell>
												<TableCell>
													<Badge
														variant={
															broadcast.severity === "critical"
																? "destructive"
																: broadcast.severity === "warning"
																	? "secondary"
																	: "outline"
														}
													>
														{broadcast.severity}
													</Badge>
												</TableCell>
												<TableCell>
													{formatDate(broadcast.sentAt ?? broadcast.scheduledAt)}
												</TableCell>
												<TableCell>{broadcast.recipientCount}</TableCell>
												<TableCell>{broadcast.status}</TableCell>
											</TableRow>
										))}
									</TableBody>
								</Table>
							</div>
						</CardContent>
					</Card>
				</TabsContent>
			</Tabs>
		</div>
	)
}
