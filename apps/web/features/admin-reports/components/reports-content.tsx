"use client"

import { useState } from "react"
import type { Route } from "next"
import Link from "next/link"
import { Eye, Filter, MapPin, Search } from "lucide-react"

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
import { TablePagination } from "@/core/components/ui/table-pagination"
import { useDebouncedValue } from "@/core/hooks/use-debounced-value"
import { useAdminReportsQuery } from "@/features/admin-reports/api/reports.hooks"

const PAGE_SIZE = 25

const STATUS_OPTIONS = ["all", "received", "in_progress", "resolved", "closed"] as const

function formatStatus(status: string) {
	return status.replace(/_/g, " ").replace(/\b\w/g, char => char.toUpperCase())
}

function statusVariant(status: string) {
	if (status === "resolved") return "default" as const
	if (status === "closed") return "destructive" as const
	if (status === "received") return "outline" as const
	return "secondary" as const
}

function formatDate(value: string | Date) {
	return new Date(value).toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
	})
}

export function ReportsContent() {
	const [search, setSearch] = useState("")
	const [status, setStatus] = useState<(typeof STATUS_OPTIONS)[number]>("all")
	const [page, setPage] = useState(1)
	const debouncedSearch = useDebouncedValue(search.trim())
	const reports = useAdminReportsQuery({
		search: debouncedSearch || undefined,
		status: status === "all" ? undefined : status,
		page,
		limit: PAGE_SIZE,
	})

	const fetchedRows = reports.data ?? []
	const rows = fetchedRows.slice(0, PAGE_SIZE)

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
				<div>
					<h1 className="text-primary text-3xl font-bold tracking-tight">Citizen Reports</h1>
					<p className="text-muted-foreground mt-2">
						Manage and resolve community concerns and issue reports.
					</p>
				</div>
			</div>

			<div className="grid gap-6 lg:grid-cols-3">
				<Card className="lg:col-span-2">
					<CardHeader className="pb-3">
						<div className="flex flex-col justify-between gap-4 sm:flex-row">
							<div className="flex w-full max-w-sm items-center gap-2">
								<div className="relative w-full">
									<Search className="text-muted-foreground absolute top-2.5 left-2.5 size-4" />
									<Input
										type="search"
										placeholder="Search reports..."
										className="pl-8"
										value={search}
										onChange={event => {
											setSearch(event.target.value)
											setPage(1)
										}}
									/>
								</div>
							</div>
							<div className="flex items-center gap-2">
								<Select
									value={status}
									onValueChange={value => {
										setStatus(value as (typeof STATUS_OPTIONS)[number])
										setPage(1)
									}}
								>
									<SelectTrigger className="w-[150px]">
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
								<Button variant="outline" size="icon" aria-label="Filter reports">
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
										<TableHead>ID & Category</TableHead>
										<TableHead>Location</TableHead>
										<TableHead>Citizen</TableHead>
										<TableHead>Date</TableHead>
										<TableHead>Status</TableHead>
										<TableHead className="text-right">Actions</TableHead>
									</TableRow>
								</TableHeader>
								<TableBody>
									<TableStateRows
										colSpan={6}
										isLoading={reports.isLoading}
										isError={reports.isError}
										isEmpty={rows.length === 0}
										onRetry={() => void reports.refetch()}
										loadingText="Loading citizen reports..."
										errorText="Citizen reports could not be loaded."
										emptyText="No reports found."
										emptyHint="Try adjusting your search or filters."
									/>
									{rows.map(report => (
										<TableRow key={report.id}>
											<TableCell className="font-medium">
												<div>IR-{String(report.id).padStart(5, "0")}</div>
												<div className="text-muted-foreground text-sm">{report.category}</div>
											</TableCell>
											<TableCell>
												<div className="flex max-w-[220px] items-center gap-1">
													<MapPin className="text-muted-foreground size-3 shrink-0" />
													<span
														className="truncate"
														title={report.locationAddress ?? report.barangay ?? ""}
													>
														{report.locationAddress ?? report.barangay ?? "Not set"}
													</span>
												</div>
											</TableCell>
											<TableCell>{report.citizenName ?? "Citizen"}</TableCell>
											<TableCell>{formatDate(report.createdAt)}</TableCell>
											<TableCell>
												<Badge variant={statusVariant(report.status)}>
													{formatStatus(report.status)}
												</Badge>
											</TableCell>
											<TableCell className="text-right">
												<Button
													variant="outline"
													size="sm"
													render={<Link href={`/reports/${report.id}` as Route} />}
												>
													<Eye className="size-4" /> View
												</Button>
											</TableCell>
										</TableRow>
									))}
								</TableBody>
							</Table>
						</div>
						<TablePagination
							page={page}
							pageSize={PAGE_SIZE}
							rowCount={fetchedRows.length}
							onPageChange={setPage}
						/>
					</CardContent>
				</Card>

				<Card className="h-full">
					<CardHeader>
						<CardTitle>Location Summary</CardTitle>
						<CardDescription>
							Geographic distribution for the current page of reports.
						</CardDescription>
					</CardHeader>
					<CardContent>
						<div className="space-y-3">
							{rows.slice(0, 6).map(report => (
								<Link
									key={report.id}
									href={`/reports/${report.id}` as Route}
									className="hover:bg-muted flex items-start gap-2 rounded-md border p-3 text-sm"
								>
									<MapPin className="text-primary mt-0.5 size-4" />
									<div className="min-w-0">
										<p className="truncate font-medium">
											{report.locationAddress ?? report.barangay ?? "Unspecified location"}
										</p>
										<p className="text-muted-foreground truncate text-xs">{report.category}</p>
									</div>
								</Link>
							))}
							{rows.length === 0 && (
								<p className="text-muted-foreground text-sm">No report locations to display.</p>
							)}
						</div>
					</CardContent>
				</Card>
			</div>
		</div>
	)
}
