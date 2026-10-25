"use client"

import { Button } from "@/core/components/ui/button"

interface TablePaginationProps {
	page: number
	pageSize: number
	rowCount: number
	onPageChange: (page: number) => void
}

export function TablePagination({ page, pageSize, rowCount, onPageChange }: TablePaginationProps) {
	const hasPreviousPage = page > 1
	const hasNextPage = rowCount > pageSize
	const visibleCount = Math.min(rowCount, pageSize)

	return (
		<div className="flex flex-col gap-3 border-t px-4 py-3 sm:flex-row sm:items-center sm:justify-between">
			<p className="text-muted-foreground text-sm">
				Page {page} · Showing {visibleCount === 0 ? 0 : (page - 1) * pageSize + 1}–
				{(page - 1) * pageSize + visibleCount}
			</p>
			<div className="flex items-center gap-2">
				<Button
					variant="outline"
					size="sm"
					disabled={!hasPreviousPage}
					onClick={() => onPageChange(page - 1)}
				>
					Previous
				</Button>
				<Button
					variant="outline"
					size="sm"
					disabled={!hasNextPage}
					onClick={() => onPageChange(page + 1)}
				>
					Next
				</Button>
			</div>
		</div>
	)
}
