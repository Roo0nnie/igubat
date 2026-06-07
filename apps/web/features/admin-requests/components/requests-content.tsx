"use client"

import { useMemo, useState } from "react"
import type { Route } from "next"
import Link from "next/link"
import { Eye, Filter, Search } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import { Card, CardContent, CardHeader } from "@/core/components/ui/card"
import { Input } from "@/core/components/ui/input"
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
import { useAdminRequestsQuery } from "@/features/admin-requests/api/requests.hooks"

const STATUS_OPTIONS = [
	"all",
	"pending",
	"in_review",
	"approved",
	"rejected",
	"for_pickup",
	"completed",
] as const

function formatStatus(status: string) {
	return status.replace(/_/g, " ").replace(/\b\w/g, char => char.toUpperCase())
}

function statusVariant(status: string) {
	if (["approved", "completed"].includes(status)) return "default" as const
	if (status === "rejected") return "destructive" as const
	if (status === "pending") return "outline" as const
	return "secondary" as const
}

function formatDate(value: string | Date) {
	return new Date(value).toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
	})
}

export function RequestsContent() {
	const [search, setSearch] = useState("")
	const [status, setStatus] = useState<(typeof STATUS_OPTIONS)[number]>("all")
	const requests = useAdminRequestsQuery({
		search: search.trim() || undefined,
		status: status === "all" ? undefined : status,
	})

	const rows = useMemo(() => requests.data ?? [], [requests.data])

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
				<div>
					<h1 className="text-primary text-3xl font-bold tracking-tight">Service Requests</h1>
					<p className="text-muted-foreground mt-2">
						Manage, review, and update citizen service requests.
					</p>
				</div>
			</div>

			<Card>
				<CardHeader className="pb-3">
					<div className="flex flex-col justify-between gap-4 sm:flex-row">
						<div className="flex w-full max-w-sm items-center gap-2">
							<div className="relative w-full">
								<Search className="text-muted-foreground absolute top-2.5 left-2.5 size-4" />
								<Input
									type="search"
									placeholder="Search by tracking ID, name, or service..."
									className="pl-8"
									value={search}
									onChange={event => setSearch(event.target.value)}
								/>
							</div>
						</div>
						<div className="flex items-center gap-2">
							<Select
								value={status}
								onValueChange={value => setStatus(value as (typeof STATUS_OPTIONS)[number])}
							>
								<SelectTrigger className="w-[165px]">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{STATUS_OPTIONS.map(option => (
										<SelectItem key={option} value={option}>
											{option === "all" ? "All Statuses" : formatStatus(option)}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
							<Button variant="outline" size="icon" aria-label="Filter requests">
								<Filter className="size-4" />
							</Button>
						</div>
					</div>
				</CardHeader>
				<CardContent>
					<div className="rounded-md border">
						<Table>
							<TableHeader>
								<TableRow>
									<TableHead>Tracking ID</TableHead>
									<TableHead>Citizen</TableHead>
									<TableHead>Service</TableHead>
									<TableHead>Barangay</TableHead>
									<TableHead>Date</TableHead>
									<TableHead>Status</TableHead>
									<TableHead className="text-right">Actions</TableHead>
								</TableRow>
							</TableHeader>
							<TableBody>
								{requests.isLoading && (
									<TableRow>
										<TableCell colSpan={7} className="text-muted-foreground h-24 text-center">
											Loading service requests...
										</TableCell>
									</TableRow>
								)}
								{requests.isError && (
									<TableRow>
										<TableCell colSpan={7} className="text-destructive h-24 text-center">
											Service requests could not be loaded.
										</TableCell>
									</TableRow>
								)}
								{!requests.isLoading && !requests.isError && rows.length === 0 && (
									<TableRow>
										<TableCell colSpan={7} className="text-muted-foreground h-24 text-center">
											No service requests found.
										</TableCell>
									</TableRow>
								)}
								{rows.map(request => (
									<TableRow key={request.id}>
										<TableCell className="font-medium">{request.trackingNumber}</TableCell>
										<TableCell>
											<div>{request.citizenName ?? "Citizen"}</div>
											<div className="text-muted-foreground text-xs">
												{request.authorId ?? "Walk-in"}
											</div>
										</TableCell>
										<TableCell>{request.serviceType}</TableCell>
										<TableCell>{request.barangay ?? "Not set"}</TableCell>
										<TableCell>{formatDate(request.createdAt)}</TableCell>
										<TableCell>
											<Badge variant={statusVariant(request.status)}>
												{formatStatus(request.status)}
											</Badge>
										</TableCell>
										<TableCell className="text-right">
											<Button
												variant="outline"
												size="sm"
												render={<Link href={`/requests/${request.id}` as Route} />}
											>
												<Eye className="size-4" /> View
											</Button>
										</TableCell>
									</TableRow>
								))}
							</TableBody>
						</Table>
					</div>
				</CardContent>
			</Card>
		</div>
	)
}
