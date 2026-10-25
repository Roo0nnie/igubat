"use client"

import { useCallback, useEffect, useMemo, useRef, useState } from "react"
import { useQueryClient } from "@tanstack/react-query"
import { Archive, Download, Eye, FileText, Plus, Save, Search, Send, Trash2 } from "lucide-react"
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
import { Textarea } from "@/core/components/ui/textarea"
import { useRole } from "@/core/context/role-provider"
import { useDebouncedValue } from "@/core/hooks/use-debounced-value"
import { cn } from "@/core/lib/utils"
import { orpc } from "@/services/orpc/client"
import type { V1Outputs } from "@/services/orpc/contract-types"
import {
	useArchiveTransparencyMutation,
	useCreateTransparencyMutation,
	useDeleteTransparencyMutation,
	usePublishTransparencyMutation,
	useTransparencyListQuery,
	useUpdateTransparencyMutation,
} from "@/features/admin-transparency/api/transparency.hooks"
import {
	TransparencyAttachmentsUploader,
	type TransparencyAttachmentDraft,
} from "@/features/admin-transparency/components/transparency-attachments-uploader"
import { TransparencyTypeFields } from "@/features/admin-transparency/components/transparency-type-fields"
import {
	TRANSPARENCY_STATUSES,
	TRANSPARENCY_TYPES,
	transparencyStatusBadgeVariant,
	transparencyTypeLabel,
	type TransparencyStatus,
	type TransparencyType,
} from "@/features/admin-transparency/lib/transparency-types"

type TransparencyDetail = V1Outputs["igubat"]["admin"]["transparency"]["detail"]
type Dateish = string | Date | null
type TransparencyListItemLike = {
	archivedAt?: Dateish
	authorName?: string | null
	barangay: string | null
	coverImageUrl: string | null
	effectiveDate: Dateish
	fiscalYear: number | null
	id: number
	metadata?: unknown
	publishedAt?: Dateish
	referenceNumber: string | null
	scheduledAt: Dateish
	slug: string | null
	status: TransparencyStatus
	summary: string | null
	title: string
	type: TransparencyType
}
type TransparencyDetailLike = TransparencyListItemLike & {
	archivedAt?: Dateish
	attachments: TransparencyDetail["attachments"]
	body: string
	notifyOnPublish: boolean
	publishedAt: Dateish
}

const PAGE_SIZE = 25

type EditorState = {
	id?: number
	slug?: string | null
	type: TransparencyType
	referenceNumber: string
	title: string
	fiscalYear: string
	summary: string
	body: string
	barangay: string
	coverImageUrl: string
	effectiveDate: string
	metadata: Record<string, string>
	attachments: TransparencyAttachmentDraft[]
	notifySubscribers: boolean
	publishedAt?: Dateish
	scheduledAt: string
	status?: TransparencyStatus
	authorName?: string | null
}

const emptyEditor: EditorState = {
	type: "program_project",
	referenceNumber: "",
	title: "",
	fiscalYear: "",
	summary: "",
	body: "",
	barangay: "",
	coverImageUrl: "",
	effectiveDate: "",
	metadata: {},
	attachments: [],
	notifySubscribers: true,
	scheduledAt: "",
}

const REQUIRED_METADATA_FIELDS: Record<TransparencyType, string[]> = {
	program_project: ["projectStatus", "startDate", "costPhp", "implementingOffice"],
	bid_procurement: ["approvedBudgetForContractPhp", "procurementMode", "closingDate", "bidStatus"],
	financial_report: ["reportType", "fiscalPeriod"],
	annual_budget: ["budgetType", "totalAmountPhp"],
	legislative_ordinance: ["dateApproved", "principalAuthor"],
	executive_order: ["dateIssued", "issuedBy"],
}

function formatDate(value: string | Date | null) {
	if (!value) return "-"
	return new Date(value).toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
	})
}

function formatDateTime(value: string | Date | null) {
	if (!value) return "-"
	return new Date(value).toLocaleString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
		hour: "numeric",
		minute: "2-digit",
	})
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

function metadataToForm(metadata: unknown): Record<string, string> {
	if (!metadata || typeof metadata !== "object") return {}
	return Object.fromEntries(
		Object.entries(metadata)
			.filter(([key]) => key !== "type")
			.map(([key, value]) => [key, value === null || value === undefined ? "" : String(value)])
	)
}

function attachmentsToForm(
	attachments: TransparencyDetail["attachments"]
): TransparencyAttachmentDraft[] {
	return attachments.map((attachment, index) => ({
		id: attachment.id,
		fileName: attachment.fileName,
		fileUrl: attachment.fileUrl,
		mimeType: attachment.mimeType as TransparencyAttachmentDraft["mimeType"],
		sizeBytes: String(attachment.sizeBytes),
		sortOrder: String(attachment.sortOrder ?? index),
	}))
}

function editorFromSummary(item: TransparencyListItemLike): EditorState {
	return {
		...emptyEditor,
		id: item.id,
		slug: item.slug,
		type: item.type,
		referenceNumber: item.referenceNumber ?? "",
		title: item.title,
		fiscalYear: item.fiscalYear ? String(item.fiscalYear) : "",
		summary: item.summary ?? "",
		barangay: item.barangay ?? "",
		coverImageUrl: item.coverImageUrl ?? "",
		effectiveDate: toDateInput(item.effectiveDate),
		metadata: metadataToForm(item.metadata),
		publishedAt: item.publishedAt ?? null,
		scheduledAt: toDateTimeInput(item.scheduledAt),
		status: item.status,
		authorName: item.authorName ?? null,
	}
}

function editorFromDetail(item: TransparencyDetailLike): EditorState {
	return {
		...editorFromSummary(item),
		body: item.body,
		attachments: attachmentsToForm(item.attachments),
		notifySubscribers: item.notifyOnPublish,
	}
}

function buildMetadata(type: TransparencyType, raw: Record<string, string>) {
	const num = (key: string) => (raw[key] ? Number(raw[key]) : 0)
	const text = (key: string) => raw[key]?.trim() ?? ""
	const optional = (key: string) => text(key) || undefined

	switch (type) {
		case "program_project":
			return {
				type,
				projectStatus: (raw.projectStatus || "planned") as
					| "planned"
					| "ongoing"
					| "completed"
					| "suspended",
				startDate: text("startDate"),
				endDate: optional("endDate"),
				costPhp: num("costPhp"),
				implementingOffice: text("implementingOffice"),
				beneficiaries: optional("beneficiaries"),
				locationAddress: optional("locationAddress"),
			}
		case "bid_procurement":
			return {
				type,
				approvedBudgetForContractPhp: num("approvedBudgetForContractPhp"),
				procurementMode: (raw.procurementMode || "public_bidding") as
					| "public_bidding"
					| "small_value"
					| "shopping"
					| "negotiated",
				closingDate: text("closingDate"),
				awardedTo: optional("awardedTo"),
				awardedAmountPhp: raw.awardedAmountPhp ? num("awardedAmountPhp") : undefined,
				bidStatus: (raw.bidStatus || "posted") as
					| "posted"
					| "pre_bid"
					| "open"
					| "awarded"
					| "cancelled",
			}
		case "financial_report":
			return {
				type,
				reportType: (raw.reportType || "other") as
					| "saob"
					| "sre"
					| "coa_annual"
					| "quarterly_financial_statement"
					| "other",
				fiscalPeriod: text("fiscalPeriod"),
				preparedBy: optional("preparedBy"),
			}
		case "annual_budget":
			return {
				type,
				budgetType: (raw.budgetType || "annual") as "annual" | "supplemental" | "executive_budget",
				totalAmountPhp: num("totalAmountPhp"),
				endorsedBy: optional("endorsedBy"),
			}
		case "legislative_ordinance":
			return {
				type,
				dateApproved: text("dateApproved"),
				principalAuthor: text("principalAuthor"),
				sponsors: optional("sponsors"),
				sbSessionDate: optional("sbSessionDate"),
			}
		case "executive_order":
			return {
				type,
				dateIssued: text("dateIssued"),
				issuedBy: text("issuedBy"),
				revokes: optional("revokes"),
			}
	}
}

function buildAttachments(attachments: TransparencyAttachmentDraft[]) {
	return attachments
		.filter(attachment => attachment.fileName.trim() || attachment.fileUrl.trim())
		.map((attachment, index) => ({
			fileName: attachment.fileName.trim(),
			fileUrl: attachment.fileUrl.trim(),
			mimeType: attachment.mimeType,
			sizeBytes: Number(attachment.sizeBytes || 0),
			sortOrder: attachment.sortOrder ? Number(attachment.sortOrder) : index,
		}))
}

function hasRequiredMetadata(editor: EditorState) {
	return REQUIRED_METADATA_FIELDS[editor.type].every(key => editor.metadata[key]?.trim())
}

function hasValidAttachments(attachments: TransparencyAttachmentDraft[]) {
	return attachments.every(attachment => {
		const hasAnyValue =
			attachment.fileName.trim() || attachment.fileUrl.trim() || attachment.sizeBytes.trim() !== "0"
		if (!hasAnyValue) return true
		const sizeBytes = Number(attachment.sizeBytes || 0)
		return (
			attachment.fileName.trim().length > 0 &&
			attachment.fileUrl.trim().length > 0 &&
			Number.isFinite(sizeBytes) &&
			sizeBytes >= 0 &&
			sizeBytes <= 10 * 1024 * 1024
		)
	})
}

export function TransparencyManagement({
	initialItemId,
	initialPreview = false,
}: {
	initialItemId?: number
	initialPreview?: boolean
}) {
	const { can } = useRole()
	const canUseAdminActions = can("admin")
	const queryClient = useQueryClient()

	const [typeFilter, setTypeFilter] = useState<string>("all")
	const [statusFilter, setStatusFilter] = useState<string>("all")
	const [fiscalYear, setFiscalYear] = useState("")
	const [search, setSearch] = useState("")
	const [page, setPage] = useState(1)
	const [editor, setEditor] = useState<EditorState>(emptyEditor)
	const [loadingItemId, setLoadingItemId] = useState<number | undefined>(initialItemId)
	const [showPreview, setShowPreview] = useState(initialPreview)
	const selectedItemIdRef = useRef(initialItemId)
	const debouncedSearch = useDebouncedValue(search.trim())

	const filterInput = useMemo(
		() => ({
			type: typeFilter === "all" ? undefined : (typeFilter as TransparencyType),
			status: statusFilter === "all" ? undefined : (statusFilter as TransparencyStatus),
			fiscalYear: fiscalYear ? Number(fiscalYear) : undefined,
			search: debouncedSearch || undefined,
		}),
		[typeFilter, statusFilter, fiscalYear, debouncedSearch]
	)
	const listInput = useMemo(() => ({ ...filterInput, page, limit: PAGE_SIZE }), [filterInput, page])

	const items = useTransparencyListQuery(listInput)
	const fetchedItems = items.data ?? []
	const itemRows = fetchedItems.slice(0, PAGE_SIZE)
	const createItem = useCreateTransparencyMutation()
	const updateItem = useUpdateTransparencyMutation()
	const publishItem = usePublishTransparencyMutation()
	const archiveItem = useArchiveTransparencyMutation()
	const deleteItem = useDeleteTransparencyMutation()

	const applyLoadedEditor = useCallback((item: TransparencyDetailLike) => {
		selectedItemIdRef.current = item.id
		setEditor(editorFromDetail(item))
		setLoadingItemId(undefined)
	}, [])

	const loadTransparencyDetail = useCallback(
		async (id: number) => {
			selectedItemIdRef.current = id
			setLoadingItemId(id)
			try {
				const loaded = await queryClient.fetchQuery(
					orpc.igubat.admin.transparency.detail.queryOptions({ input: { id } })
				)
				if (selectedItemIdRef.current !== id) return
				applyLoadedEditor(loaded)
			} catch (error) {
				if (selectedItemIdRef.current === id) {
					setLoadingItemId(undefined)
				}
				toast.error(
					error instanceof Error ? error.message : "Transparency item could not be loaded."
				)
			}
		},
		[applyLoadedEditor, queryClient]
	)

	useEffect(() => {
		if (!initialItemId) return
		let cancelled = false

		async function loadInitialItem() {
			try {
				const loaded = await queryClient.fetchQuery(
					orpc.igubat.admin.transparency.detail.queryOptions({
						input: { id: initialItemId },
					})
				)
				if (cancelled) return
				selectedItemIdRef.current = loaded.id
				setEditor(editorFromDetail(loaded))
			} catch (error) {
				if (!cancelled) {
					toast.error(
						error instanceof Error ? error.message : "Transparency item could not be loaded."
					)
				}
			} finally {
				if (!cancelled) {
					setLoadingItemId(undefined)
				}
			}
		}

		void loadInitialItem()

		return () => {
			cancelled = true
		}
	}, [initialItemId, queryClient])

	const isSaving = createItem.isPending || updateItem.isPending
	const isDetailLoading = Boolean(loadingItemId)
	const canSubmit =
		editor.title.trim().length > 0 &&
		hasRequiredMetadata(editor) &&
		hasValidAttachments(editor.attachments) &&
		!isDetailLoading

	function resetEditor() {
		selectedItemIdRef.current = undefined
		setLoadingItemId(undefined)
		setEditor(emptyEditor)
		setShowPreview(false)
	}

	function selectItem(item: TransparencyListItemLike) {
		selectedItemIdRef.current = item.id
		setEditor(editorFromSummary(item))
		setShowPreview(false)
		void loadTransparencyDetail(item.id)
	}

	function commonPayload() {
		return {
			type: editor.type,
			referenceNumber: editor.referenceNumber || undefined,
			title: editor.title.trim(),
			fiscalYear: editor.fiscalYear ? Number(editor.fiscalYear) : undefined,
			summary: editor.summary || undefined,
			body: editor.body,
			barangay: editor.barangay || undefined,
			coverImageUrl: editor.coverImageUrl || undefined,
			effectiveDate: editor.effectiveDate || undefined,
			metadata: buildMetadata(editor.type, editor.metadata),
			notifyOnPublish: editor.notifySubscribers,
			scheduledAt: editor.scheduledAt || undefined,
			attachments: buildAttachments(editor.attachments),
		}
	}

	async function saveDraft() {
		try {
			const payload = commonPayload()
			const saved = editor.id
				? await updateItem.mutateAsync({ id: editor.id, ...payload })
				: await createItem.mutateAsync({ ...payload, status: "draft" })
			applyLoadedEditor(saved)
			toast.success("Transparency draft saved.")
		} catch (error) {
			toast.error(error instanceof Error ? error.message : "Transparency draft could not be saved.")
		}
	}

	async function publish() {
		try {
			const payload = commonPayload()
			const saved = editor.id
				? await updateItem.mutateAsync({ id: editor.id, ...payload })
				: await createItem.mutateAsync({ ...payload, status: "draft" })
			const published = await publishItem.mutateAsync({
				id: saved.id,
				notifySubscribers: editor.notifySubscribers,
				publishAt: editor.scheduledAt || undefined,
			})
			applyLoadedEditor(published)
			toast.success(
				editor.scheduledAt ? "Transparency item scheduled." : "Transparency item published."
			)
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Transparency item could not be published."
			)
		}
	}

	async function archiveById(id: number) {
		try {
			const archived = await archiveItem.mutateAsync({ id })
			if (editor.id === id) {
				applyLoadedEditor(archived)
			}
			toast.success("Transparency item archived.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Transparency item could not be archived."
			)
		}
	}

	async function permanentlyDeleteById(id: number, title: string) {
		if (!canUseAdminActions) return
		if (!window.confirm(`Permanently delete "${title}"? This cannot be undone.`)) return
		try {
			await deleteItem.mutateAsync({ id, permanent: true })
			if (editor.id === id) resetEditor()
			toast.success("Transparency item permanently deleted.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Transparency item could not be deleted."
			)
		}
	}

	async function exportCsv() {
		try {
			const result = await queryClient.fetchQuery(
				orpc.igubat.admin.transparency.exportCsv.queryOptions({ input: filterInput })
			)
			const blob = new Blob([result.content], { type: "text/csv;charset=utf-8" })
			const url = URL.createObjectURL(blob)
			const anchor = document.createElement("a")
			anchor.href = url
			anchor.download = result.fileName
			anchor.click()
			URL.revokeObjectURL(url)
			toast.success("Transparency CSV exported.")
		} catch (error) {
			toast.error(
				error instanceof Error ? error.message : "Transparency CSV could not be exported."
			)
		}
	}

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
				<div>
					<p className="text-muted-foreground text-xs">Content &amp; Emergency / Transparency</p>
					<h1 className="text-primary text-3xl font-bold tracking-tight">
						Transparency &amp; Good Governance
					</h1>
					<p className="text-muted-foreground mt-2">
						Publish Full Disclosure Policy records: programs, bids, finances, budgets, ordinances,
						and executive orders.
					</p>
				</div>
				<div className="flex gap-2">
					{canUseAdminActions && (
						<Button variant="outline" onClick={exportCsv}>
							<Download className="size-4" /> Export CSV
						</Button>
					)}
					<Button onClick={resetEditor}>
						<Plus className="size-4" /> New Item
					</Button>
				</div>
			</div>

			<div className="grid gap-6 lg:grid-cols-5">
				<Card className="lg:col-span-3">
					<CardHeader className="pb-3">
						<CardTitle>Transparency Items</CardTitle>
						<CardDescription>
							Filter, then edit a row in the panel beside the table.
						</CardDescription>
						<div className="flex flex-wrap gap-2 pt-3">
							<Select
								value={typeFilter}
								onValueChange={value => {
									setTypeFilter(value ?? "all")
									setPage(1)
								}}
							>
								<SelectTrigger className="w-[180px]">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									<SelectItem value="all">All Types</SelectItem>
									{TRANSPARENCY_TYPES.map(type => (
										<SelectItem key={type.value} value={type.value}>
											{type.label}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
							<Select
								value={statusFilter}
								onValueChange={value => {
									setStatusFilter(value ?? "all")
									setPage(1)
								}}
							>
								<SelectTrigger className="w-[150px]">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									<SelectItem value="all">All Statuses</SelectItem>
									{TRANSPARENCY_STATUSES.map(status => (
										<SelectItem key={status} value={status}>
											{status}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
							<Input
								className="w-[120px]"
								placeholder="Fiscal year"
								value={fiscalYear}
								onChange={event => {
									setFiscalYear(event.target.value.replace(/\D/g, ""))
									setPage(1)
								}}
							/>
							<div className="relative min-w-[180px] flex-1">
								<Search className="text-muted-foreground absolute top-2.5 left-2.5 size-4" />
								<Input
									className="pl-8"
									placeholder="Search title or ref. number"
									value={search}
									onChange={event => {
										setSearch(event.target.value)
										setPage(1)
									}}
								/>
							</div>
						</div>
					</CardHeader>
					<CardContent>
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
										isLoading={items.isLoading}
										isError={items.isError}
										isEmpty={itemRows.length === 0}
										onRetry={() => void items.refetch()}
										loadingText="Loading transparency items..."
										errorText="Items could not be loaded."
										emptyText="No transparency items found."
									/>
									{itemRows.map(item => (
										<TableRow
											key={item.id}
											className={cn("cursor-pointer", editor.id === item.id && "bg-muted/60")}
											onClick={() => selectItem(item)}
										>
											<TableCell className="text-xs font-medium">
												{item.referenceNumber ?? "-"}
											</TableCell>
											<TableCell className="max-w-[260px]">
												<div className="truncate font-medium">{item.title}</div>
											</TableCell>
											<TableCell className="text-xs">{transparencyTypeLabel(item.type)}</TableCell>
											<TableCell>{item.fiscalYear ?? "-"}</TableCell>
											<TableCell>
												<Badge variant={transparencyStatusBadgeVariant(item.status)}>
													{item.status}
												</Badge>
											</TableCell>
											<TableCell className="text-xs">{formatDate(item.publishedAt)}</TableCell>
											<TableCell className="text-xs">{item.authorName ?? "-"}</TableCell>
											<TableCell className="text-right">
												<div
													className="flex justify-end gap-1"
													onClick={event => event.stopPropagation()}
												>
													<Button
														variant="ghost"
														size="icon"
														title="Archive"
														disabled={archiveItem.isPending || item.status === "archived"}
														onClick={() => void archiveById(item.id)}
													>
														<Archive className="size-4" />
													</Button>
													{canUseAdminActions && (
														<Button
															variant="ghost"
															size="icon"
															title="Permanently delete"
															className="text-destructive"
															disabled={deleteItem.isPending}
															onClick={() => void permanentlyDeleteById(item.id, item.title)}
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
						<TablePagination
							page={page}
							pageSize={PAGE_SIZE}
							rowCount={fetchedItems.length}
							onPageChange={setPage}
						/>
					</CardContent>
				</Card>

				<Card className="lg:col-span-2">
					<CardHeader>
						<div className="flex items-start justify-between gap-3">
							<div>
								<CardTitle>{editor.id ? "Edit Item" : "New Transparency Item"}</CardTitle>
								<CardDescription>
									{isDetailLoading
										? "Loading the full item before edits are enabled."
										: "Choose a type, fill the fields, then save a draft or publish."}
								</CardDescription>
							</div>
							{editor.status && (
								<Badge variant={transparencyStatusBadgeVariant(editor.status)}>
									{editor.status}
								</Badge>
							)}
						</div>
					</CardHeader>
					<CardContent className="space-y-4">
						<div className="space-y-2">
							<Label>Type</Label>
							<Select
								value={editor.type}
								disabled={isDetailLoading}
								onValueChange={value =>
									setEditor(current => ({
										...current,
										type: value as TransparencyType,
										metadata: {},
									}))
								}
							>
								<SelectTrigger className="w-full">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{TRANSPARENCY_TYPES.map(type => (
										<SelectItem key={type.value} value={type.value}>
											{type.label}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</div>

						<div className="grid gap-4 md:grid-cols-2">
							<div className="space-y-2">
								<Label htmlFor="reference">Reference Number</Label>
								<Input
									id="reference"
									value={editor.referenceNumber}
									disabled={isDetailLoading}
									onChange={event =>
										setEditor(current => ({ ...current, referenceNumber: event.target.value }))
									}
								/>
							</div>
							<div className="space-y-2">
								<Label htmlFor="fiscal">Fiscal Year</Label>
								<Input
									id="fiscal"
									value={editor.fiscalYear}
									disabled={isDetailLoading}
									onChange={event =>
										setEditor(current => ({
											...current,
											fiscalYear: event.target.value.replace(/\D/g, ""),
										}))
									}
								/>
							</div>
						</div>

						<div className="space-y-2">
							<Label htmlFor="title">Title</Label>
							<Input
								id="title"
								value={editor.title}
								disabled={isDetailLoading}
								onChange={event =>
									setEditor(current => ({ ...current, title: event.target.value }))
								}
							/>
						</div>

						<div className="grid gap-4 md:grid-cols-2">
							<div className="space-y-2">
								<Label htmlFor="barangay">Barangay</Label>
								<Input
									id="barangay"
									value={editor.barangay}
									disabled={isDetailLoading}
									onChange={event =>
										setEditor(current => ({ ...current, barangay: event.target.value }))
									}
								/>
							</div>
							<div className="space-y-2">
								<Label htmlFor="effective">Effective Date</Label>
								<Input
									id="effective"
									type="date"
									value={editor.effectiveDate}
									disabled={isDetailLoading}
									onChange={event =>
										setEditor(current => ({ ...current, effectiveDate: event.target.value }))
									}
								/>
							</div>
						</div>

						<div className="space-y-2">
							<Label htmlFor="cover">Cover Image URL</Label>
							<Input
								id="cover"
								value={editor.coverImageUrl}
								disabled={isDetailLoading}
								onChange={event =>
									setEditor(current => ({ ...current, coverImageUrl: event.target.value }))
								}
							/>
						</div>

						<div className="space-y-2">
							<Label htmlFor="summary">Summary</Label>
							<Textarea
								id="summary"
								rows={3}
								value={editor.summary}
								disabled={isDetailLoading}
								onChange={event =>
									setEditor(current => ({ ...current, summary: event.target.value }))
								}
							/>
						</div>

						<div className="space-y-2">
							<Label htmlFor="body">Body (Markdown)</Label>
							<Textarea
								id="body"
								rows={6}
								value={editor.body}
								disabled={isDetailLoading}
								onChange={event => setEditor(current => ({ ...current, body: event.target.value }))}
							/>
						</div>

						<TransparencyTypeFields
							type={editor.type}
							values={editor.metadata}
							onChange={(key, value) =>
								setEditor(current => ({
									...current,
									metadata: { ...current.metadata, [key]: value },
								}))
							}
						/>

						<TransparencyAttachmentsUploader
							attachments={editor.attachments}
							disabled={isDetailLoading}
							onChange={attachments => setEditor(current => ({ ...current, attachments }))}
						/>

						<div className="space-y-2 rounded-md border p-3">
							<Label className="text-xs font-semibold uppercase">Publish Controls</Label>
							<label className="flex items-center gap-2 text-sm">
								<Checkbox
									checked={editor.notifySubscribers}
									disabled={isDetailLoading}
									onCheckedChange={checked =>
										setEditor(current => ({ ...current, notifySubscribers: checked === true }))
									}
								/>
								Notify subscribers on publish
							</label>
							<div className="space-y-1">
								<Label htmlFor="schedule" className="text-xs">
									Schedule Publish At (blank = publish now)
								</Label>
								<Input
									id="schedule"
									type="datetime-local"
									value={editor.scheduledAt}
									disabled={isDetailLoading}
									onChange={event =>
										setEditor(current => ({ ...current, scheduledAt: event.target.value }))
									}
								/>
							</div>
						</div>

						{showPreview && (
							<div className="space-y-3 rounded-md border p-4">
								<div className="flex items-center justify-between gap-3">
									<div>
										<p className="text-muted-foreground text-xs">Citizen-view preview</p>
										<h2 className="text-lg font-semibold">{editor.title || "Untitled item"}</h2>
									</div>
									<Badge variant={transparencyStatusBadgeVariant(editor.status ?? "draft")}>
										{editor.status ?? "draft"}
									</Badge>
								</div>
								{editor.coverImageUrl && (
									// eslint-disable-next-line @next/next/no-img-element
									<img
										src={editor.coverImageUrl}
										alt=""
										className="aspect-video w-full rounded-md object-cover"
									/>
								)}
								<div className="text-muted-foreground flex flex-wrap gap-2 text-xs">
									<span>{transparencyTypeLabel(editor.type)}</span>
									<span>FY {editor.fiscalYear || "-"}</span>
									<span>Effective {editor.effectiveDate || "-"}</span>
								</div>
								{editor.summary && <p className="text-sm">{editor.summary}</p>}
								{editor.body && (
									<div className="prose prose-sm max-w-none text-sm whitespace-pre-wrap">
										{editor.body}
									</div>
								)}
								{editor.attachments.length > 0 && (
									<div className="space-y-2">
										<p className="text-xs font-semibold uppercase">Attachments</p>
										{editor.attachments.map((attachment, index) => (
											<a
												key={attachment.id ?? index}
												href={attachment.fileUrl || "#"}
												target="_blank"
												rel="noreferrer"
												className="text-primary flex items-center gap-2 text-sm hover:underline"
											>
												<FileText className="size-4" />
												<span>{attachment.fileName || `Attachment ${index + 1}`}</span>
											</a>
										))}
									</div>
								)}
							</div>
						)}

						{!hasRequiredMetadata(editor) && (
							<p className="text-muted-foreground text-xs">
								Complete the required type-specific fields before saving.
							</p>
						)}
						{!hasValidAttachments(editor.attachments) && (
							<p className="text-destructive text-xs">
								Complete attachment name, URL, and a valid size for each file reference.
							</p>
						)}

						<div className="flex flex-wrap justify-end gap-2">
							{canUseAdminActions && editor.id && (
								<Button
									variant="outline"
									className="text-destructive"
									disabled={deleteItem.isPending}
									onClick={() => void permanentlyDeleteById(editor.id!, editor.title)}
								>
									<Trash2 className="size-4" /> Delete
								</Button>
							)}
							<Button
								variant="outline"
								disabled={!editor.id || archiveItem.isPending || editor.status === "archived"}
								onClick={() => editor.id && void archiveById(editor.id)}
							>
								<Archive className="size-4" /> Archive
							</Button>
							<Button variant="outline" onClick={() => setShowPreview(current => !current)}>
								<Eye className="size-4" /> {showPreview ? "Hide Preview" : "Preview"}
							</Button>
							<Button
								variant="outline"
								disabled={publishItem.isPending || !canSubmit}
								loading={isSaving && !publishItem.isPending}
								loadingText="Saving..."
								onClick={saveDraft}
							>
								<Save className="size-4" /> Save Draft
							</Button>
							<Button
								disabled={isSaving || !canSubmit}
								loading={publishItem.isPending}
								loadingText={editor.scheduledAt ? "Scheduling..." : "Publishing..."}
								onClick={publish}
							>
								<Send className="size-4" />
								{editor.scheduledAt ? "Schedule" : "Publish Now"}
							</Button>
						</div>

						{editor.id && (
							<p className="text-muted-foreground text-xs">
								Last loaded as {editor.status ?? "draft"}; published{" "}
								{formatDateTime(editor.publishedAt ?? null)}.
							</p>
						)}
					</CardContent>
				</Card>
			</div>
		</div>
	)
}
