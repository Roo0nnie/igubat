"use client"

import { BarChart3, FileDown } from "lucide-react"

import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { ErrorState, LoadingStatus, TableStateRows } from "@/core/components/ui/loading-state"
import { Skeleton } from "@/core/components/ui/skeleton"
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/core/components/ui/table"
import { useAdminAnalyticsQuery } from "@/features/admin-analytics/api/analytics.hooks"

function downloadCsv(filename: string, rows: Array<Record<string, string | number>>) {
	const headers = Object.keys(rows[0] ?? { metric: "", value: "" })
	const body = [
		headers.join(","),
		...rows.map(row => headers.map(header => JSON.stringify(row[header] ?? "")).join(",")),
	].join("\n")
	const blob = new Blob([body], { type: "text/csv;charset=utf-8" })
	const url = URL.createObjectURL(blob)
	const link = document.createElement("a")
	link.href = url
	link.download = filename
	link.click()
	URL.revokeObjectURL(url)
}

export function AnalyticsContent() {
	const analytics = useAdminAnalyticsQuery()
	const data = analytics.data
	const requestRows = Object.entries(data?.byRequestStatus ?? {}).map(([status, count]) => ({
		metric: status,
		value: count,
	}))
	const reportRows = Object.entries(data?.byReportStatus ?? {}).map(([status, count]) => ({
		metric: status,
		value: count,
	}))
	const barangayRows = Object.entries(data?.byBarangay ?? {}).map(([barangay, count]) => ({
		barangay,
		requests: count,
	}))

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
				<div>
					<h1 className="text-primary text-3xl font-bold tracking-tight">Analytics & Reports</h1>
					<p className="text-muted-foreground mt-2">
						Usage, request volume, report distribution, and local exports.
					</p>
				</div>
				<Button
					variant="outline"
					disabled={!data}
					onClick={() => downloadCsv("igubat-analytics.csv", [...requestRows, ...reportRows])}
				>
					<FileDown className="size-4" /> Export CSV
				</Button>
			</div>

			{analytics.isLoading && (
				<LoadingStatus
					message="Crunching the latest numbers..."
					onRetry={() => void analytics.refetch()}
					className="[&>div]:justify-start"
				/>
			)}
			{analytics.isError && (
				<Card className="border-destructive/40">
					<CardContent>
						<ErrorState
							compact
							title="Analytics could not be loaded."
							onRetry={() => void analytics.refetch()}
						/>
					</CardContent>
				</Card>
			)}

			<div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
				{[
					{ label: "Citizens", value: data?.users ?? 0 },
					{ label: "Requests", value: data?.requests ?? 0 },
					{ label: "Reports", value: data?.reports ?? 0 },
					{ label: "Articles", value: data?.articles ?? 0 },
				].map(item => (
					<Card key={item.label}>
						<CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
							<CardTitle className="text-sm font-medium">{item.label}</CardTitle>
							<BarChart3 className="text-primary size-4" />
						</CardHeader>
						<CardContent>
							{analytics.isLoading ? (
								<Skeleton className="my-1 h-7 w-14" />
							) : (
								<div className="text-2xl font-bold">{item.value}</div>
							)}
						</CardContent>
					</Card>
				))}
			</div>

			<div className="grid gap-6 lg:grid-cols-3">
				<MetricTable
					title="Request Status"
					description="Service request lifecycle distribution."
					rows={requestRows}
					isLoading={analytics.isLoading}
				/>
				<MetricTable
					title="Report Status"
					description="Citizen report lifecycle distribution."
					rows={reportRows}
					isLoading={analytics.isLoading}
				/>
				<Card>
					<CardHeader>
						<CardTitle>Barangay Requests</CardTitle>
						<CardDescription>Requests grouped by citizen barangay.</CardDescription>
					</CardHeader>
					<CardContent>
						<Table>
							<TableHeader>
								<TableRow>
									<TableHead>Barangay</TableHead>
									<TableHead className="text-right">Requests</TableHead>
								</TableRow>
							</TableHeader>
							<TableBody>
								{barangayRows.map(row => (
									<TableRow key={row.barangay}>
										<TableCell>{row.barangay}</TableCell>
										<TableCell className="text-right">{row.requests}</TableCell>
									</TableRow>
								))}
								<TableStateRows
									colSpan={2}
									rows={4}
									showStatus={false}
									isLoading={analytics.isLoading}
									isError={false}
									isEmpty={barangayRows.length === 0}
									emptyText="No barangay data yet."
								/>
							</TableBody>
						</Table>
					</CardContent>
				</Card>
			</div>
		</div>
	)
}

function MetricTable({
	title,
	description,
	rows,
	isLoading,
}: {
	title: string
	description: string
	rows: Array<{ metric: string; value: number }>
	isLoading: boolean
}) {
	return (
		<Card>
			<CardHeader>
				<CardTitle>{title}</CardTitle>
				<CardDescription>{description}</CardDescription>
			</CardHeader>
			<CardContent>
				<Table>
					<TableHeader>
						<TableRow>
							<TableHead>Metric</TableHead>
							<TableHead className="text-right">Count</TableHead>
						</TableRow>
					</TableHeader>
					<TableBody>
						{rows.map(row => (
							<TableRow key={row.metric}>
								<TableCell>{row.metric.replace(/_/g, " ")}</TableCell>
								<TableCell className="text-right">{row.value}</TableCell>
							</TableRow>
						))}
						<TableStateRows
							colSpan={2}
							rows={4}
							showStatus={false}
							isLoading={isLoading}
							isError={false}
							isEmpty={rows.length === 0}
							emptyText="No data yet."
						/>
					</TableBody>
				</Table>
			</CardContent>
		</Card>
	)
}
