"use client"

import { useMemo, useState } from "react"
import Link from "next/link"
import { usePathname, useRouter, useSearchParams } from "next/navigation"
import { useQueryClient } from "@tanstack/react-query"
import { Download, Plus } from "lucide-react"
import { toast } from "sonner"

import { Button } from "@/core/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/core/components/ui/card"
import { Pagination, PaginationContent, PaginationItem } from "@/core/components/ui/pagination"
import { useRole } from "@/core/context/role-provider"
import { orpc } from "@/services/orpc/client"
import {
	useArchiveTransparencyMutation,
	useDeleteTransparencyMutation,
	useTransparencyListQuery,
} from "@/features/admin-transparency/api/transparency.hooks"
import {
	parseTransparencyFilters,
	TransparencyFiltersBar,
} from "@/features/admin-transparency/components/transparency-filters-bar"
import { TransparencyListTable } from "@/features/admin-transparency/components/transparency-list-table"
import type {
	TransparencyListInput,
	TransparencyListRow,
} from "@/features/admin-transparency/lib/transparency-types"

const PAGE_SIZE = 10

function parseCursor(value: string | null) {
	if (!value) return undefined
	const parsed = Number(value)
	return Number.isInteger(parsed) && parsed > 0 ? parsed : undefined
}

function downloadCsv(fileName: string, content: string) {
	const blob = new Blob([content], { type: "text/csv;charset=utf-8" })
	const url = URL.createObjectURL(blob)
	const anchor = document.createElement("a")
	anchor.href = url
	anchor.download = fileName
	anchor.click()
	URL.revokeObjectURL(url)
}

export function TransparencyListPage() {
	const router = useRouter()
	const pathname = usePathname()
	const searchParams = useSearchParams()
	const queryClient = useQueryClient()
	const { portalRole } = useRole()
	const isAdmin = portalRole === "admin"
	const [cursorHistory, setCursorHistory] = useState<{
		filterKey: string
		cursors: Array<number | undefined>
	}>({
		filterKey: "",
		cursors: [],
	})

	const filterInput = useMemo(() => {
		return parseTransparencyFilters(new URLSearchParams(searchParams.toString()))
	}, [searchParams])
	const cursor = parseCursor(searchParams.get("cursor"))
	const filterKey = JSON.stringify(filterInput)
	const previousCursors = cursorHistory.filterKey === filterKey ? cursorHistory.cursors : []

	const listInput = useMemo<TransparencyListInput>(
		() => ({
			...filterInput,
			cursor,
			limit: PAGE_SIZE + 1,
		}),
		[cursor, filterInput]
	)
	const exportInput = useMemo<TransparencyListInput>(() => ({ ...filterInput }), [filterInput])

	const listQuery = useTransparencyListQuery(listInput)
	const archiveItem = useArchiveTransparencyMutation()
	const deleteItem = useDeleteTransparencyMutation()
	const rows = listQuery.data ?? []
	const visibleRows = rows.slice(0, PAGE_SIZE)
	const hasNextPage = rows.length > PAGE_SIZE

	function replaceCursor(nextCursor: number | undefined) {
		const next = new URLSearchParams(searchParams.toString())
		if (nextCursor) {
			next.set("cursor", String(nextCursor))
		} else {
			next.delete("cursor")
		}

		const query = next.toString()
		router.push(query ? `${pathname}?${query}` : pathname, { scroll: false })
	}

	function goToNextPage() {
		const last = visibleRows.at(-1)
		if (!last) return
		setCursorHistory(current => ({
			filterKey,
			cursors: [...(current.filterKey === filterKey ? current.cursors : []), cursor],
		}))
		replaceCursor(last.id)
	}

	function goToPreviousPage() {
		const previous = previousCursors.at(-1)
		setCursorHistory(current => ({
			filterKey,
			cursors: (current.filterKey === filterKey ? current.cursors : []).slice(0, -1),
		}))
		replaceCursor(previous)
	}

	function editRow(row: TransparencyListRow) {
		router.push(`/transparency/${row.id}/edit`)
	}

	function previewRow(row: TransparencyListRow) {
		router.push(`/transparency/${row.id}/preview`)
	}

	async function archiveRow(row: TransparencyListRow) {
		try {
			await archiveItem.mutateAsync({ id: row.id })
			toast.success("Transparency item archived.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Transparency item could not be archived."
			)
		}
	}

	async function permanentlyDeleteRow(row: TransparencyListRow) {
		if (!isAdmin) return
		if (!window.confirm(`Permanently delete "${row.title}"? This cannot be undone.`)) return

		try {
			await deleteItem.mutateAsync({ id: row.id, permanent: true })
			toast.success("Transparency item permanently deleted.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Transparency item could not be deleted."
			)
		}
	}

	async function exportCsv() {
		if (!isAdmin) return

		try {
			const result = await queryClient.fetchQuery(
				orpc.igubat.admin.transparency.exportCsv.queryOptions({ input: exportInput })
			)
			downloadCsv(result.fileName, result.content)
			toast.success("Transparency CSV exported.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Transparency CSV could not be exported."
			)
		}
	}

	return (
		<div className="space-y-6 p-6">
			<div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
				<div>
					<p className="text-muted-foreground text-xs">Content &amp; Emergency / Transparency</p>
					<h1 className="text-primary text-3xl font-bold tracking-tight">
						Transparency &amp; Good Governance
					</h1>
					<p className="text-muted-foreground mt-1 max-w-2xl text-sm">
						Review and manage public disclosure entries for programs, procurements, reports,
						budgets, ordinances, and executive orders.
					</p>
				</div>
				<div className="flex flex-wrap gap-2">
					{isAdmin && (
						<Button variant="outline" onClick={() => void exportCsv()}>
							<Download className="size-4" /> Export CSV
						</Button>
					)}
					<Button
						nativeButton={false}
						render={
							<Link href="/transparency/new">
								<Plus className="size-4" /> New Item
							</Link>
						}
					/>
				</div>
			</div>

			<Card>
				<CardHeader className="gap-4">
					<CardTitle>Content List</CardTitle>
					<TransparencyFiltersBar />
				</CardHeader>
				<CardContent className="space-y-4">
					<TransparencyListTable
						rows={visibleRows}
						isAdmin={isAdmin}
						isLoading={listQuery.isLoading}
						isError={listQuery.isError}
						isArchiving={archiveItem.isPending}
						isDeleting={deleteItem.isPending}
						onRetry={() => void listQuery.refetch()}
						onEdit={editRow}
						onPreview={previewRow}
						onArchive={archiveRow}
						onPermanentDelete={permanentlyDeleteRow}
					/>

					<Pagination className="justify-end">
						<PaginationContent>
							<PaginationItem>
								<Button
									variant="outline"
									size="sm"
									disabled={previousCursors.length === 0 || listQuery.isFetching}
									onClick={goToPreviousPage}
								>
									Previous
								</Button>
							</PaginationItem>
							<PaginationItem>
								<Button
									variant="outline"
									size="sm"
									disabled={!hasNextPage || listQuery.isFetching}
									onClick={goToNextPage}
								>
									Next
								</Button>
							</PaginationItem>
						</PaginationContent>
					</Pagination>
				</CardContent>
			</Card>
		</div>
	)
}
