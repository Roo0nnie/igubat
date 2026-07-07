"use client"

import { Archive, Pencil, Trash2 } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/core/components/ui/table"
import {
	discoverGubatStatusBadgeVariant,
	discoverGubatStatusLabel,
	discoverGubatTypeLabel,
	type DiscoverGubatListRow,
} from "@/features/admin-discover-gubat/lib/discover-gubat-types"

function formatDate(value: string | Date | null) {
	if (!value) return "-"
	return new Date(value).toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
	})
}

export function DiscoverGubatListTable({
	rows,
	isAdmin,
	isLoading = false,
	isError = false,
	isArchiving = false,
	isDeleting = false,
	onEdit,
	onArchive,
	onPermanentDelete,
}: {
	rows: DiscoverGubatListRow[]
	isAdmin: boolean
	isLoading?: boolean
	isError?: boolean
	isArchiving?: boolean
	isDeleting?: boolean
	onEdit: (row: DiscoverGubatListRow) => void
	onArchive: (row: DiscoverGubatListRow) => void
	onPermanentDelete: (row: DiscoverGubatListRow) => void
}) {
	return (
		<div className="rounded-md border">
			<Table>
				<TableHeader>
					<TableRow>
						<TableHead>Title</TableHead>
						<TableHead>Type</TableHead>
						<TableHead>Category</TableHead>
						<TableHead>Location / Where to Buy</TableHead>
						<TableHead>Status</TableHead>
						<TableHead>Published</TableHead>
						<TableHead>Author</TableHead>
						<TableHead className="text-right">Actions</TableHead>
					</TableRow>
				</TableHeader>
				<TableBody>
					{isLoading && (
						<TableRow>
							<TableCell colSpan={8} className="text-muted-foreground h-24 text-center">
								Loading Discover Gubat entries...
							</TableCell>
						</TableRow>
					)}
					{isError && (
						<TableRow>
							<TableCell colSpan={8} className="text-destructive h-24 text-center">
								Discover Gubat entries could not be loaded.
							</TableCell>
						</TableRow>
					)}
					{!isLoading && !isError && rows.length === 0 && (
						<TableRow>
							<TableCell colSpan={8} className="text-muted-foreground h-24 text-center">
								No Discover Gubat entries found.
							</TableCell>
						</TableRow>
					)}
					{rows.map(row => (
						<TableRow key={row.id}>
							<TableCell className="max-w-[260px]">
								<div className="truncate font-medium">{row.title}</div>
								{row.summary && (
									<div className="text-muted-foreground truncate text-xs">{row.summary}</div>
								)}
							</TableCell>
							<TableCell className="text-xs">{discoverGubatTypeLabel(row.type)}</TableCell>
							<TableCell>{row.category}</TableCell>
							<TableCell className="max-w-[220px] truncate text-xs">
								{row.mapLocation ?? row.whereToBuy ?? "-"}
							</TableCell>
							<TableCell>
								<Badge variant={discoverGubatStatusBadgeVariant(row.status)}>
									{discoverGubatStatusLabel(row.status)}
								</Badge>
							</TableCell>
							<TableCell className="text-xs">{formatDate(row.publishedAt)}</TableCell>
							<TableCell className="text-xs">{row.authorName ?? "-"}</TableCell>
							<TableCell className="text-right">
								<div className="flex justify-end gap-1">
									<Button
										variant="ghost"
										size="icon"
										aria-label={`Edit ${row.title}`}
										onClick={() => onEdit(row)}
									>
										<Pencil className="size-4" />
									</Button>
									<Button
										variant="ghost"
										size="icon"
										aria-label={`Archive ${row.title}`}
										disabled={isArchiving || row.status === "archived"}
										onClick={() => onArchive(row)}
									>
										<Archive className="size-4" />
									</Button>
									{isAdmin && (
										<Button
											variant="ghost"
											size="icon"
											aria-label={`Permanently delete ${row.title}`}
											className="text-destructive"
											disabled={isDeleting}
											onClick={() => onPermanentDelete(row)}
										>
											<Trash2 className="size-4" />
										</Button>
									)}
								</div>
							</TableCell>
						</TableRow>
					))}
				</TableBody>
			</Table>
		</div>
	)
}
