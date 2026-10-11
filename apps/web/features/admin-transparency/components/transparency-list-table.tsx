"use client"

import { Archive, Edit, Eye, MoreHorizontal, Trash2 } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuItem,
	DropdownMenuSeparator,
	DropdownMenuTrigger,
} from "@/core/components/ui/dropdown-menu"
import { TableStateRows } from "@/core/components/ui/loading-state"
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/core/components/ui/table"
import {
	transparencyStatusBadgeVariant,
	transparencyTypeLabel,
	type TransparencyListRow,
} from "@/features/admin-transparency/lib/transparency-types"

type TransparencyListTableProps = {
	rows: TransparencyListRow[]
	isAdmin: boolean
	isLoading?: boolean
	isError?: boolean
	isArchiving?: boolean
	isDeleting?: boolean
	onRetry?: () => void
	onEdit: (row: TransparencyListRow) => void
	onPreview: (row: TransparencyListRow) => void
	onArchive: (row: TransparencyListRow) => void
	onPermanentDelete: (row: TransparencyListRow) => void
}

function formatDate(value: string | Date | null | undefined) {
	if (!value) return "-"
	return new Date(value).toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
	})
}

function statusText(status: string) {
	return status.charAt(0).toUpperCase() + status.slice(1)
}

export function TransparencyListTable({
	rows,
	isAdmin,
	isLoading,
	isError,
	isArchiving,
	isDeleting,
	onRetry,
	onEdit,
	onPreview,
	onArchive,
	onPermanentDelete,
}: TransparencyListTableProps) {
	return (
		<div className="rounded-md border">
			<Table>
				<TableHeader>
					<TableRow>
						<TableHead>Ref. No.</TableHead>
						<TableHead>Title</TableHead>
						<TableHead>Type</TableHead>
						<TableHead>FY</TableHead>
						<TableHead>Status</TableHead>
						<TableHead>Published</TableHead>
						<TableHead>Author</TableHead>
						<TableHead className="text-right">Actions</TableHead>
					</TableRow>
				</TableHeader>
				<TableBody>
					<TableStateRows
						colSpan={8}
						isLoading={Boolean(isLoading)}
						isError={Boolean(isError)}
						isEmpty={rows.length === 0}
						onRetry={onRetry}
						loadingText="Loading transparency items..."
						errorText="Transparency items could not be loaded."
						emptyText="No transparency items found."
						emptyHint="Try adjusting the filters, or create a new item."
					/>
					{!isLoading &&
						!isError &&
						rows.map(row => (
							<TableRow key={row.id}>
								<TableCell className="text-xs font-medium">
									{row.referenceNumber ?? `TR-${row.id}`}
								</TableCell>
								<TableCell className="max-w-[320px]">
									<div className="truncate font-medium">{row.title}</div>
									<div className="text-muted-foreground truncate text-xs">
										{row.slug ?? "No slug"}
									</div>
								</TableCell>
								<TableCell className="text-xs">{transparencyTypeLabel(row.type)}</TableCell>
								<TableCell>{row.fiscalYear ?? "-"}</TableCell>
								<TableCell>
									<Badge variant={transparencyStatusBadgeVariant(row.status)}>
										{statusText(row.status)}
									</Badge>
								</TableCell>
								<TableCell className="text-xs">{formatDate(row.publishedAt)}</TableCell>
								<TableCell className="text-xs">{row.authorName ?? "-"}</TableCell>
								<TableCell className="text-right">
									<DropdownMenu>
										<DropdownMenuTrigger
											render={
												<Button variant="ghost" size="icon" aria-label={`Actions for ${row.title}`}>
													<MoreHorizontal className="size-4" />
												</Button>
											}
										/>
										<DropdownMenuContent align="end" className="w-48">
											<DropdownMenuItem
												onSelect={event => {
													event.preventDefault()
													onEdit(row)
												}}
											>
												<Edit className="size-4" />
												Edit
											</DropdownMenuItem>
											<DropdownMenuItem
												onSelect={event => {
													event.preventDefault()
													onPreview(row)
												}}
											>
												<Eye className="size-4" />
												Preview
											</DropdownMenuItem>
											<DropdownMenuItem
												disabled={isArchiving || row.status === "archived"}
												onSelect={event => {
													event.preventDefault()
													onArchive(row)
												}}
											>
												<Archive className="size-4" />
												Archive
											</DropdownMenuItem>
											{isAdmin && (
												<>
													<DropdownMenuSeparator />
													<DropdownMenuItem
														variant="destructive"
														disabled={isDeleting}
														onSelect={event => {
															event.preventDefault()
															onPermanentDelete(row)
														}}
													>
														<Trash2 className="size-4" />
														Permanently Delete
													</DropdownMenuItem>
												</>
											)}
										</DropdownMenuContent>
									</DropdownMenu>
								</TableCell>
							</TableRow>
						))}
				</TableBody>
			</Table>
		</div>
	)
}
