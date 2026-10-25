"use client"

import { useState } from "react"
import { FileDown, Lock } from "lucide-react"

import { Button } from "@/core/components/ui/button"
import { Card, CardContent } from "@/core/components/ui/card"
import { TableStateRows } from "@/core/components/ui/loading-state"
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/core/components/ui/table"
import { TablePagination } from "@/core/components/ui/table-pagination"
import { useAuditLogsQuery } from "@/features/admin-audit/api/audit.hooks"

const PAGE_SIZE = 25

function formatDate(value: string | Date) {
	return new Date(value).toLocaleString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
		hour: "numeric",
		minute: "2-digit",
	})
}

function exportAudit(rows: NonNullable<ReturnType<typeof useAuditLogsQuery>["data"]>) {
	const headers = ["id", "actor", "role", "action", "entity", "entityId", "createdAt"]
	const body = [
		headers.join(","),
		...rows.map(row =>
			[
				row.id,
				row.actorName ?? row.actorId ?? "system",
				row.actorRole ?? "",
				row.actionType,
				row.entityType,
				row.entityId ?? "",
				String(row.createdAt),
			]
				.map(value => JSON.stringify(value))
				.join(",")
		),
	].join("\n")
	const blob = new Blob([body], { type: "text/csv;charset=utf-8" })
	const url = URL.createObjectURL(blob)
	const link = document.createElement("a")
	link.href = url
	link.download = "igubat-audit-log.csv"
	link.click()
	URL.revokeObjectURL(url)
}

export function AuditContent() {
	const [page, setPage] = useState(1)
	const audit = useAuditLogsQuery({ page, limit: PAGE_SIZE })
	const fetchedRows = audit.data ?? []
	const rows = fetchedRows.slice(0, PAGE_SIZE)

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
				<div>
					<h1 className="text-primary text-3xl font-bold tracking-tight">Audit Log</h1>
					<p className="text-muted-foreground mt-2 flex items-center gap-2">
						<Lock className="size-4" /> Append-only. Entries cannot be edited or deleted by any
						role.
					</p>
				</div>
				<Button variant="outline" disabled={rows.length === 0} onClick={() => exportAudit(rows)}>
					<FileDown className="size-4" /> Export this page
				</Button>
			</div>

			<Card>
				<CardContent className="pt-6">
					<div className="rounded-md border">
						<Table>
							<TableHeader>
								<TableRow>
									<TableHead>Time</TableHead>
									<TableHead>Actor</TableHead>
									<TableHead>Action</TableHead>
									<TableHead>Entity</TableHead>
									<TableHead>IP</TableHead>
								</TableRow>
							</TableHeader>
							<TableBody>
								<TableStateRows
									colSpan={5}
									isLoading={audit.isLoading}
									isError={audit.isError}
									isEmpty={rows.length === 0}
									onRetry={() => void audit.refetch()}
									loadingText="Loading audit logs..."
									errorText="Audit logs could not be loaded."
									emptyText="No audit logs found."
								/>
								{rows.map(row => (
									<TableRow key={row.id}>
										<TableCell>{formatDate(row.createdAt)}</TableCell>
										<TableCell>
											<div>{row.actorName ?? row.actorId ?? "System"}</div>
											<div className="text-muted-foreground text-xs">
												{row.actorRole ?? "system"}
											</div>
										</TableCell>
										<TableCell>{row.actionType}</TableCell>
										<TableCell>
											<div>{row.entityType}</div>
											<div className="text-muted-foreground text-xs">{row.entityId ?? "n/a"}</div>
										</TableCell>
										<TableCell>{row.ipAddress ?? "n/a"}</TableCell>
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
