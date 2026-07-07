"use client"

import { useCallback, useMemo, useRef, useState } from "react"
import { useQueryClient } from "@tanstack/react-query"
import { Archive, Plus, Save, Send, Trash2 } from "lucide-react"
import { toast } from "sonner"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { Checkbox } from "@/core/components/ui/checkbox"
import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/core/components/ui/select"
import { Textarea } from "@/core/components/ui/textarea"
import { useRole } from "@/core/context/role-provider"
import { orpc } from "@/services/orpc/client"
import type { V1Outputs } from "@/services/orpc/contract-types"
import {
	useArchiveDiscoverGubatMutation,
	useCreateDiscoverGubatMutation,
	useDeleteDiscoverGubatMutation,
	useDiscoverGubatListQuery,
	usePublishDiscoverGubatMutation,
	useUpdateDiscoverGubatMutation,
} from "@/features/admin-discover-gubat/api/discover-gubat.hooks"
import { DiscoverGubatListTable } from "@/features/admin-discover-gubat/components/discover-gubat-list-table"
import {
	DISCOVER_GUBAT_STATUSES,
	DISCOVER_GUBAT_TYPES,
	discoverGubatStatusBadgeVariant,
	type DiscoverGubatListInput,
	type DiscoverGubatListRow,
	type DiscoverGubatStatus,
	type DiscoverGubatType,
} from "@/features/admin-discover-gubat/lib/discover-gubat-types"

type Dateish = string | Date | null
type ContractDiscoverGubatDetail = V1Outputs["igubat"]["admin"]["discoverGubat"]["detail"]
type DiscoverGubatDetail = Omit<
	ContractDiscoverGubatDetail,
	"eventDate" | "scheduledAt" | "publishedAt" | "archivedAt" | "createdAt" | "updatedAt"
> & {
	eventDate: Dateish
	scheduledAt: Dateish
	publishedAt: Dateish
	archivedAt: Dateish
	createdAt: string | Date
	updatedAt: string | Date
}

type EditorState = {
	id?: number
	type: DiscoverGubatType
	title: string
	category: string
	summary: string
	body: string
	coverImageUrl: string
	mapLocation: string
	whereToBuy: string
	eventDate: string
	photoUrl: string
	photoAltText: string
	notifySubscribers: boolean
	scheduledAt: string
	status?: DiscoverGubatStatus
	publishedAt?: Dateish
}

const emptyEditor: EditorState = {
	type: "tourist_spot",
	title: "",
	category: "",
	summary: "",
	body: "",
	coverImageUrl: "",
	mapLocation: "",
	whereToBuy: "",
	eventDate: "",
	photoUrl: "",
	photoAltText: "",
	notifySubscribers: true,
	scheduledAt: "",
}

function padDatePart(value: number) {
	return String(value).padStart(2, "0")
}

function toDateInput(value: string | Date | null | undefined) {
	if (!value) return ""
	const date = new Date(value)
	if (Number.isNaN(date.getTime())) return ""
	return [date.getFullYear(), padDatePart(date.getMonth() + 1), padDatePart(date.getDate())].join(
		"-"
	)
}

function toDateTimeInput(value: string | Date | null | undefined) {
	if (!value) return ""
	const date = new Date(value)
	if (Number.isNaN(date.getTime())) return ""
	return `${toDateInput(date)}T${padDatePart(date.getHours())}:${padDatePart(date.getMinutes())}`
}

function editorFromRow(row: DiscoverGubatListRow): EditorState {
	return {
		...emptyEditor,
		id: row.id,
		type: row.type,
		title: row.title,
		category: row.category,
		summary: row.summary ?? "",
		coverImageUrl: row.coverImageUrl ?? "",
		mapLocation: row.mapLocation ?? "",
		whereToBuy: row.whereToBuy ?? "",
		eventDate: toDateInput(row.eventDate),
		status: row.status,
		publishedAt: row.publishedAt,
		scheduledAt: toDateTimeInput(row.scheduledAt),
	}
}

function editorFromDetail(item: DiscoverGubatDetail): EditorState {
	const firstPhoto = item.photos.at(0)
	return {
		...editorFromRow(item as DiscoverGubatListRow),
		body: item.body,
		notifySubscribers: item.notifyOnPublish,
		photoUrl: firstPhoto?.imageUrl ?? "",
		photoAltText: firstPhoto?.altText ?? "",
	}
}

function buildMetadata(editor: EditorState) {
	switch (editor.type) {
		case "tourist_spot":
			return {
				type: editor.type,
				mapLocation: editor.mapLocation.trim(),
			}
		case "festival_culture":
			return {
				type: editor.type,
				cultureKind: "festival" as const,
				eventDate: editor.eventDate || undefined,
				culturalNote: editor.summary || undefined,
			}
		case "local_product":
			return {
				type: editor.type,
				productKind: "pasalubong" as const,
				whereToBuy: editor.whereToBuy.trim(),
				pasalubongNote: editor.summary || undefined,
			}
	}
}

function buildPhotos(editor: EditorState) {
	if (!editor.photoUrl.trim()) return []
	return [
		{
			imageUrl: editor.photoUrl.trim(),
			altText: editor.photoAltText.trim() || undefined,
			sortOrder: 0,
		},
	]
}

function canSubmit(editor: EditorState) {
	if (!editor.title.trim() || !editor.category.trim()) return false
	if (editor.type === "tourist_spot") return Boolean(editor.mapLocation.trim())
	if (editor.type === "local_product") return Boolean(editor.whereToBuy.trim())
	return true
}

export function DiscoverGubatManagement() {
	const queryClient = useQueryClient()
	const { can } = useRole()
	const isAdmin = can("admin")
	const [typeFilter, setTypeFilter] = useState<string>("all")
	const [statusFilter, setStatusFilter] = useState<string>("all")
	const [search, setSearch] = useState("")
	const [editor, setEditor] = useState<EditorState>(emptyEditor)
	const [loadingItemId, setLoadingItemId] = useState<number | undefined>()
	const selectedItemIdRef = useRef<number | undefined>(undefined)

	const listInput = useMemo<DiscoverGubatListInput>(
		() => ({
			type: typeFilter === "all" ? undefined : (typeFilter as DiscoverGubatType),
			status: statusFilter === "all" ? undefined : (statusFilter as DiscoverGubatStatus),
			search: search.trim() || undefined,
		}),
		[typeFilter, statusFilter, search]
	)

	const listQuery = useDiscoverGubatListQuery(listInput)
	const createEntry = useCreateDiscoverGubatMutation()
	const updateEntry = useUpdateDiscoverGubatMutation()
	const publishEntry = usePublishDiscoverGubatMutation()
	const archiveEntry = useArchiveDiscoverGubatMutation()
	const deleteEntry = useDeleteDiscoverGubatMutation()

	const applyLoadedEditor = useCallback((item: DiscoverGubatDetail) => {
		selectedItemIdRef.current = item.id
		setEditor(editorFromDetail(item))
		setLoadingItemId(undefined)
	}, [])

	async function loadDetail(row: DiscoverGubatListRow) {
		selectedItemIdRef.current = row.id
		setEditor(editorFromRow(row))
		setLoadingItemId(row.id)
		try {
			const loaded = await queryClient.fetchQuery(
				orpc.igubat.admin.discoverGubat.detail.queryOptions({ input: { id: row.id } })
			)
			if (selectedItemIdRef.current === row.id) {
				applyLoadedEditor(loaded)
			}
		} catch (error) {
			setLoadingItemId(undefined)
			toast.error(
				error instanceof Error ? error.message : "Discover Gubat entry could not be loaded."
			)
		}
	}

	function resetEditor() {
		selectedItemIdRef.current = undefined
		setLoadingItemId(undefined)
		setEditor(emptyEditor)
	}

	function commonPayload() {
		return {
			type: editor.type,
			title: editor.title.trim(),
			category: editor.category.trim(),
			summary: editor.summary || undefined,
			body: editor.body,
			coverImageUrl: editor.coverImageUrl || undefined,
			mapLocation: editor.mapLocation || undefined,
			whereToBuy: editor.whereToBuy || undefined,
			eventDate: editor.eventDate || undefined,
			metadata: buildMetadata(editor),
			notifyOnPublish: editor.notifySubscribers,
			scheduledAt: editor.scheduledAt || undefined,
			photos: buildPhotos(editor),
		}
	}

	async function saveDraft() {
		try {
			const payload = commonPayload()
			const saved = editor.id
				? await updateEntry.mutateAsync({ id: editor.id, ...payload })
				: await createEntry.mutateAsync({ ...payload, status: "draft" })
			applyLoadedEditor(saved)
			toast.success("Discover Gubat draft saved.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Discover Gubat draft could not be saved."
			)
		}
	}

	async function publish() {
		try {
			const payload = commonPayload()
			const saved = editor.id
				? await updateEntry.mutateAsync({ id: editor.id, ...payload })
				: await createEntry.mutateAsync({ ...payload, status: "draft" })
			const published = await publishEntry.mutateAsync({
				id: saved.id,
				notifySubscribers: editor.notifySubscribers,
				publishAt: editor.scheduledAt || undefined,
			})
			applyLoadedEditor(published)
			toast.success(
				editor.scheduledAt ? "Discover Gubat entry scheduled." : "Discover Gubat entry published."
			)
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Discover Gubat entry could not be published."
			)
		}
	}

	async function archiveRow(row: DiscoverGubatListRow) {
		try {
			const archived = await archiveEntry.mutateAsync({ id: row.id })
			if (editor.id === row.id) {
				applyLoadedEditor(archived)
			}
			toast.success("Discover Gubat entry archived.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Discover Gubat entry could not be archived."
			)
		}
	}

	async function permanentlyDeleteRow(row: DiscoverGubatListRow) {
		if (!isAdmin) return
		if (!window.confirm(`Permanently delete "${row.title}"? This cannot be undone.`)) return

		try {
			await deleteEntry.mutateAsync({ id: row.id, permanent: true })
			if (editor.id === row.id) resetEditor()
			toast.success("Discover Gubat entry permanently deleted.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Discover Gubat entry could not be deleted."
			)
		}
	}

	const submitDisabled =
		!canSubmit(editor) ||
		Boolean(loadingItemId) ||
		createEntry.isPending ||
		updateEntry.isPending ||
		publishEntry.isPending

	return (
		<div className="flex flex-col gap-6 p-6">
			<div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
				<div>
					<p className="text-muted-foreground text-xs">Content &amp; Emergency / Discover Gubat</p>
					<h1 className="text-primary text-3xl font-bold tracking-tight">Discover Gubat Manager</h1>
					<p className="text-muted-foreground mt-1 max-w-2xl text-sm">
						Manage tourist spots, festivals and culture, and local delicacies and products for the
						public mobile surface.
					</p>
				</div>
				<Button onClick={resetEditor}>
					<Plus className="size-4" /> New Entry
				</Button>
			</div>

			<div className="grid gap-6 lg:grid-cols-5">
				<Card className="lg:col-span-3">
					<CardHeader className="gap-4">
						<CardTitle>Content List</CardTitle>
						<CardDescription>
							Filter entries, then edit the selected row in the panel.
						</CardDescription>
						<div className="flex flex-wrap gap-2">
							<Select value={typeFilter} onValueChange={value => setTypeFilter(value ?? "all")}>
								<SelectTrigger className="w-[210px]">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									<SelectItem value="all">All Types</SelectItem>
									{DISCOVER_GUBAT_TYPES.map(type => (
										<SelectItem key={type.value} value={type.value}>
											{type.label}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
							<Select value={statusFilter} onValueChange={value => setStatusFilter(value ?? "all")}>
								<SelectTrigger className="w-[150px]">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									<SelectItem value="all">All Statuses</SelectItem>
									{DISCOVER_GUBAT_STATUSES.map(status => (
										<SelectItem key={status} value={status}>
											{status}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
							<Input
								className="min-w-[220px] flex-1"
								placeholder="Search title, category, or summary"
								value={search}
								onChange={event => setSearch(event.target.value)}
							/>
						</div>
					</CardHeader>
					<CardContent>
						<DiscoverGubatListTable
							rows={(listQuery.data ?? []) as DiscoverGubatListRow[]}
							isAdmin={isAdmin}
							isLoading={listQuery.isLoading}
							isError={listQuery.isError}
							isArchiving={archiveEntry.isPending}
							isDeleting={deleteEntry.isPending}
							onEdit={row => void loadDetail(row)}
							onArchive={row => void archiveRow(row)}
							onPermanentDelete={row => void permanentlyDeleteRow(row)}
						/>
					</CardContent>
				</Card>

				<Card className="lg:col-span-2">
					<CardHeader>
						<div className="flex items-start justify-between gap-3">
							<div>
								<CardTitle>{editor.id ? "Edit Entry" : "New Entry"}</CardTitle>
								<CardDescription>
									{loadingItemId
										? "Loading the full entry before edits are enabled."
										: "Save a draft, schedule, or publish immediately."}
								</CardDescription>
							</div>
							{editor.status && (
								<Badge variant={discoverGubatStatusBadgeVariant(editor.status)}>
									{editor.status}
								</Badge>
							)}
						</div>
					</CardHeader>
					<CardContent className="flex flex-col gap-4">
						<div className="flex flex-col gap-2">
							<Label>Type</Label>
							<Select
								value={editor.type}
								disabled={Boolean(loadingItemId)}
								onValueChange={value =>
									setEditor(current => ({
										...current,
										type: value as DiscoverGubatType,
										mapLocation: value === "tourist_spot" ? current.mapLocation : "",
										whereToBuy: value === "local_product" ? current.whereToBuy : "",
									}))
								}
							>
								<SelectTrigger className="w-full">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{DISCOVER_GUBAT_TYPES.map(type => (
										<SelectItem key={type.value} value={type.value}>
											{type.label}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</div>

						<div className="flex flex-col gap-2">
							<Label htmlFor="discover-title">Title</Label>
							<Input
								id="discover-title"
								value={editor.title}
								disabled={Boolean(loadingItemId)}
								onChange={event =>
									setEditor(current => ({ ...current, title: event.target.value }))
								}
							/>
						</div>

						<div className="grid gap-4 md:grid-cols-2">
							<div className="flex flex-col gap-2">
								<Label htmlFor="discover-category">Category</Label>
								<Input
									id="discover-category"
									value={editor.category}
									disabled={Boolean(loadingItemId)}
									placeholder={editor.type === "local_product" ? "Delicacy" : "Beach"}
									onChange={event =>
										setEditor(current => ({ ...current, category: event.target.value }))
									}
								/>
							</div>
							<div className="flex flex-col gap-2">
								<Label htmlFor="discover-event-date">Event Date</Label>
								<Input
									id="discover-event-date"
									type="date"
									value={editor.eventDate}
									disabled={Boolean(loadingItemId)}
									onChange={event =>
										setEditor(current => ({ ...current, eventDate: event.target.value }))
									}
								/>
							</div>
						</div>

						{editor.type === "tourist_spot" && (
							<div className="flex flex-col gap-2">
								<Label htmlFor="discover-map-location">Map Location</Label>
								<Input
									id="discover-map-location"
									value={editor.mapLocation}
									disabled={Boolean(loadingItemId)}
									placeholder="Buenavista, Gubat, Sorsogon"
									onChange={event =>
										setEditor(current => ({ ...current, mapLocation: event.target.value }))
									}
								/>
							</div>
						)}

						{editor.type === "local_product" && (
							<div className="flex flex-col gap-2">
								<Label htmlFor="discover-where-to-buy">Where to Buy</Label>
								<Input
									id="discover-where-to-buy"
									value={editor.whereToBuy}
									disabled={Boolean(loadingItemId)}
									placeholder="Public Market pasalubong stalls"
									onChange={event =>
										setEditor(current => ({ ...current, whereToBuy: event.target.value }))
									}
								/>
							</div>
						)}

						<div className="flex flex-col gap-2">
							<Label htmlFor="discover-summary">Summary</Label>
							<Textarea
								id="discover-summary"
								rows={3}
								value={editor.summary}
								disabled={Boolean(loadingItemId)}
								onChange={event =>
									setEditor(current => ({ ...current, summary: event.target.value }))
								}
							/>
						</div>

						<div className="flex flex-col gap-2">
							<Label htmlFor="discover-body">Body</Label>
							<Textarea
								id="discover-body"
								rows={6}
								value={editor.body}
								disabled={Boolean(loadingItemId)}
								onChange={event => setEditor(current => ({ ...current, body: event.target.value }))}
							/>
						</div>

						<div className="grid gap-4 md:grid-cols-2">
							<div className="flex flex-col gap-2">
								<Label htmlFor="discover-cover">Cover Image URL</Label>
								<Input
									id="discover-cover"
									value={editor.coverImageUrl}
									disabled={Boolean(loadingItemId)}
									onChange={event =>
										setEditor(current => ({ ...current, coverImageUrl: event.target.value }))
									}
								/>
							</div>
							<div className="flex flex-col gap-2">
								<Label htmlFor="discover-photo">Photo URL</Label>
								<Input
									id="discover-photo"
									value={editor.photoUrl}
									disabled={Boolean(loadingItemId)}
									onChange={event =>
										setEditor(current => ({ ...current, photoUrl: event.target.value }))
									}
								/>
							</div>
						</div>

						<div className="flex flex-col gap-3 rounded-md border p-3">
							<Label className="text-xs font-semibold uppercase">Publish Controls</Label>
							<label className="flex items-center gap-2 text-sm">
								<Checkbox
									checked={editor.notifySubscribers}
									disabled={Boolean(loadingItemId)}
									onCheckedChange={checked =>
										setEditor(current => ({ ...current, notifySubscribers: checked === true }))
									}
								/>
								Notify subscribers on publish
							</label>
							<div className="flex flex-col gap-1">
								<Label htmlFor="discover-schedule" className="text-xs">
									Schedule Publish At
								</Label>
								<Input
									id="discover-schedule"
									type="datetime-local"
									value={editor.scheduledAt}
									disabled={Boolean(loadingItemId)}
									onChange={event =>
										setEditor(current => ({ ...current, scheduledAt: event.target.value }))
									}
								/>
							</div>
						</div>

						<div className="flex flex-wrap justify-end gap-2">
							{isAdmin && editor.id && (
								<Button
									variant="outline"
									className="text-destructive"
									disabled={deleteEntry.isPending}
									onClick={() =>
										void permanentlyDeleteRow({
											...(editor as unknown as DiscoverGubatListRow),
											id: editor.id!,
											title: editor.title,
										})
									}
								>
									<Trash2 className="size-4" /> Delete
								</Button>
							)}
							<Button
								variant="outline"
								disabled={!editor.id || archiveEntry.isPending || editor.status === "archived"}
								onClick={() =>
									editor.id &&
									void archiveRow({
										...(editor as unknown as DiscoverGubatListRow),
										id: editor.id,
										title: editor.title,
									})
								}
							>
								<Archive className="size-4" /> Archive
							</Button>
							<Button variant="outline" disabled={submitDisabled} onClick={saveDraft}>
								<Save className="size-4" /> Save Draft
							</Button>
							<Button disabled={submitDisabled} onClick={publish}>
								<Send className="size-4" /> {editor.scheduledAt ? "Schedule" : "Publish Now"}
							</Button>
						</div>
					</CardContent>
				</Card>
			</div>
		</div>
	)
}
