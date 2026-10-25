"use client"

import { useState } from "react"
import { Filter, Search, UserCheck } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import { Card, CardContent, CardHeader } from "@/core/components/ui/card"
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
import { useAdminCitizensQuery } from "@/features/admin-citizens/api/citizens.hooks"

const STATUS_OPTIONS = ["all", "active", "locked", "deactivated"] as const
const PAGE_SIZE = 25

function formatDate(value: string | Date | undefined) {
	if (!value) return "Not available"
	return new Date(value).toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
	})
}

export function CitizensContent() {
	const [search, setSearch] = useState("")
	const [status, setStatus] = useState<(typeof STATUS_OPTIONS)[number]>("all")
	const [page, setPage] = useState(1)
	const debouncedSearch = useDebouncedValue(search.trim())
	const citizens = useAdminCitizensQuery({
		search: debouncedSearch || undefined,
		status: status === "all" ? undefined : status,
		page,
		limit: PAGE_SIZE,
	})
	const fetchedRows = citizens.data ?? []
	const rows = fetchedRows.slice(0, PAGE_SIZE)

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
				<div>
					<h1 className="text-primary text-3xl font-bold tracking-tight">Citizen Management</h1>
					<p className="text-muted-foreground mt-2">
						View registered citizens, contact details, and account status.
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
									placeholder="Search by name, email, or barangay..."
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
											{option === "all" ? "All Users" : option}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
							<Button variant="outline" size="icon" aria-label="Filter citizens">
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
									<TableHead>Name</TableHead>
									<TableHead>Contact</TableHead>
									<TableHead>Barangay</TableHead>
									<TableHead>Registered</TableHead>
									<TableHead>Status</TableHead>
									<TableHead>Consent</TableHead>
								</TableRow>
							</TableHeader>
							<TableBody>
								<TableStateRows
									colSpan={6}
									isLoading={citizens.isLoading}
									isError={citizens.isError}
									isEmpty={rows.length === 0}
									onRetry={() => void citizens.refetch()}
									loadingText="Loading citizens..."
									errorText="Citizens could not be loaded."
									emptyText="No citizens found."
									emptyHint="Try a different name, email, or barangay."
								/>
								{rows.map(user => (
									<TableRow key={user.id}>
										<TableCell className="font-medium">
											<div>{user.name}</div>
											<div className="text-muted-foreground text-sm">{user.email}</div>
										</TableCell>
										<TableCell>{user.mobileNumber ?? "Not set"}</TableCell>
										<TableCell>{user.barangay ?? "Not set"}</TableCell>
										<TableCell>{formatDate(user.createdAt)}</TableCell>
										<TableCell>
											<Badge
												variant={
													user.status === "active"
														? "default"
														: user.status === "locked"
															? "destructive"
															: "secondary"
												}
											>
												{user.status ?? "active"}
											</Badge>
										</TableCell>
										<TableCell>
											<Badge variant="outline">
												<UserCheck className="mr-1 size-3" /> DPA tracked
											</Badge>
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
		</div>
	)
}
