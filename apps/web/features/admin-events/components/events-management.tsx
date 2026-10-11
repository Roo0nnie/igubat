"use client"

import { useMemo, useState } from "react"
import {
	Archive,
	CalendarDays,
	Edit,
	Eye,
	EyeOff,
	MapPin,
	Plus,
	Save,
	Search,
	Trash2,
} from "lucide-react"
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
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/core/components/ui/dialog"
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
import { Textarea } from "@/core/components/ui/textarea"
import type { ArrayItem, V1Inputs } from "@/services/orpc/contract-types"
import {
	useAdminEventsQuery,
	useDeleteEventMutation,
	useUpsertEventMutation,
} from "@/features/admin-events/api/events.hooks"

type EventRow = ArrayItem<NonNullable<ReturnType<typeof useAdminEventsQuery>["data"]>>
type EventStatus = V1Inputs["igubat"]["admin"]["upsertEvent"]["status"]

const STATUS_FILTERS = ["all", "published", "draft", "archived"] as const
const CATEGORY_SUGGESTIONS = [
	"Community",
	"Health",
	"Business",
	"Environment",
	"Safety",
	"Culture",
	"Education",
]
const TIME_ZONE = "Asia/Manila"

type EventForm = {
	id?: number
	title: string
	slug: string
	category: string
	location: string
	description: string
	imageUrl: string
	startsAt: string
	endsAt: string
	status: EventStatus
}

const emptyForm: EventForm = {
	title: "",
	slug: "",
	category: "Community",
	location: "",
	description: "",
	imageUrl: "",
	startsAt: "",
	endsAt: "",
	status: "draft",
}

function slugify(value: string) {
	return value
		.toLowerCase()
		.replace(/[^a-z0-9]+/g, "-")
		.replace(/^-|-$/g, "")
}

/** Date -> value for `<input type="datetime-local">` in the admin's local time. */
function toLocalInput(value: string | Date | null | undefined) {
	if (!value) return ""
	const date = new Date(value)
	const offsetMs = date.getTimezoneOffset() * 60_000
	return new Date(date.getTime() - offsetMs).toISOString().slice(0, 16)
}

function formatRange(startsAt: string | Date, endsAt: string | Date | null) {
	const start = new Date(startsAt)
	const date = start.toLocaleDateString("en-PH", {
		timeZone: TIME_ZONE,
		month: "short",
		day: "numeric",
		year: "numeric",
	})
	const time = (value: Date) =>
		value.toLocaleTimeString("en-PH", { timeZone: TIME_ZONE, hour: "numeric", minute: "2-digit" })
	return endsAt ? `${date}, ${time(start)} – ${time(new Date(endsAt))}` : `${date}, ${time(start)}`
}

function hasEnded(event: EventRow) {
	return new Date(event.endsAt ?? event.startsAt).getTime() < Date.now()
}

function validate(form: EventForm) {
	const errors: Partial<Record<keyof EventForm, string>> = {}
	if (!form.title.trim()) errors.title = "Title is required."
	if (!form.slug) errors.slug = "Slug is required."
	else if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(form.slug))
		errors.slug = "Use lowercase letters, numbers and dashes."
	if (!form.category.trim()) errors.category = "Category is required."
	if (!form.location.trim()) errors.location = "Location is required."
	if (!form.description.trim()) errors.description = "Description is required."
	if (!form.startsAt) errors.startsAt = "Start date and time are required."
	if (form.startsAt && form.endsAt && new Date(form.endsAt) < new Date(form.startsAt))
		errors.endsAt = "End must be after the start."
	return errors
}

function toPayload(form: EventForm) {
	return {
		id: form.id,
		title: form.title.trim(),
		slug: form.slug,
		category: form.category.trim(),
		location: form.location.trim(),
		description: form.description.trim(),
		imageUrl: form.imageUrl.trim() || undefined,
		status: form.status,
		startsAt: new Date(form.startsAt).toISOString(),
		endsAt: form.endsAt ? new Date(form.endsAt).toISOString() : null,
	}
}

function rowToForm(event: EventRow): EventForm {
	return {
		id: event.id,
		title: event.title,
		slug: event.slug,
		category: event.category,
		location: event.location,
		description: event.description,
		imageUrl: event.imageUrl ?? "",
		startsAt: toLocalInput(event.startsAt),
		endsAt: toLocalInput(event.endsAt),
		status: event.status === "scheduled" ? "draft" : event.status,
	}
}

function errorMessage(error: unknown, fallback: string) {
	return error instanceof Error && error.message ? error.message : fallback
}

export function EventsManagement() {
	const [search, setSearch] = useState("")
	const [statusFilter, setStatusFilter] = useState<(typeof STATUS_FILTERS)[number]>("all")
	const [form, setForm] = useState<EventForm | null>(null)
	const [showErrors, setShowErrors] = useState(false)

	const events = useAdminEventsQuery({
		search: search.trim() || undefined,
		status: statusFilter === "all" ? undefined : statusFilter,
	})
	const upsertEvent = useUpsertEventMutation()
	const deleteEvent = useDeleteEventMutation()

	const errors = useMemo(() => (form ? validate(form) : {}), [form])
	const rows = events.data ?? []

	function openForm(next: EventForm) {
		setShowErrors(false)
		setForm(next)
	}

	async function save() {
		if (!form) return
		if (Object.keys(errors).length > 0) {
			setShowErrors(true)
			return
		}
		try {
			await upsertEvent.mutateAsync(toPayload(form))
			toast.success(form.id ? "Event updated." : "Event created.")
			setForm(null)
		} catch (error) {
			toast.error(errorMessage(error, "Event could not be saved."))
		}
	}

	async function changeStatus(event: EventRow, status: EventStatus, message: string) {
		try {
			await upsertEvent.mutateAsync(toPayload({ ...rowToForm(event), status }))
			toast.success(message)
		} catch (error) {
			toast.error(errorMessage(error, "Event status could not be changed."))
		}
	}

	async function remove(event: EventRow) {
		if (!window.confirm(`Delete "${event.title}"? It will be removed from the mobile app.`)) return
		try {
			await deleteEvent.mutateAsync({ id: event.id })
			toast.success("Event deleted.")
		} catch (error) {
			toast.error(errorMessage(error, "Event could not be deleted."))
		}
	}

	const fieldError = (key: keyof EventForm) =>
		showErrors && errors[key] ? (
			<p className="text-destructive text-xs" role="alert">
				{errors[key]}
			</p>
		) : null

	return (
		<Card>
			<CardHeader className="pb-3">
				<div className="flex flex-col justify-between gap-4 lg:flex-row lg:items-center">
					<div>
						<CardTitle>Events</CardTitle>
						<CardDescription>
							Published events appear in the mobile app under Upcoming Events until they end.
						</CardDescription>
					</div>
					<div className="flex flex-col gap-2 sm:flex-row">
						<div className="relative w-full sm:w-64">
							<Search className="text-muted-foreground absolute top-2.5 left-2.5 size-4" />
							<Input
								type="search"
								placeholder="Search events..."
								aria-label="Search events"
								className="pl-8"
								value={search}
								onChange={event => setSearch(event.target.value)}
							/>
						</div>
						<Select
							value={statusFilter}
							onValueChange={value => setStatusFilter(value as typeof statusFilter)}
						>
							<SelectTrigger className="w-full sm:w-36" aria-label="Filter by status">
								<SelectValue />
							</SelectTrigger>
							<SelectContent>
								{STATUS_FILTERS.map(option => (
									<SelectItem key={option} value={option} className="capitalize">
										{option === "all" ? "All statuses" : option}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
						<Button onClick={() => openForm(emptyForm)}>
							<Plus className="size-4" /> New event
						</Button>
					</div>
				</div>
			</CardHeader>
			<CardContent>
				<div className="rounded-md border">
					<Table>
						<TableHeader>
							<TableRow>
								<TableHead>Event</TableHead>
								<TableHead>Category</TableHead>
								<TableHead>Schedule</TableHead>
								<TableHead>Status</TableHead>
								<TableHead className="text-right">Actions</TableHead>
							</TableRow>
						</TableHeader>
						<TableBody>
							<TableStateRows
								colSpan={5}
								isLoading={events.isLoading}
								isError={events.isError}
								isEmpty={rows.length === 0}
								onRetry={() => void events.refetch()}
								loadingText="Loading events..."
								errorText="Events could not be loaded."
								emptyText="No events found."
								emptyHint="Create one to show it on the mobile Home screen."
							/>
							{rows.map(event => {
								const ended = hasEnded(event)
								return (
									<TableRow key={event.id}>
										<TableCell className="max-w-[280px]">
											<div className="truncate font-medium">{event.title}</div>
											<div className="text-muted-foreground flex items-center gap-1 truncate text-xs">
												<MapPin className="size-3 shrink-0" /> {event.location}
											</div>
										</TableCell>
										<TableCell>{event.category}</TableCell>
										<TableCell className="text-sm">
											<div className="flex items-center gap-1">
												<CalendarDays className="text-muted-foreground size-3.5 shrink-0" />
												{formatRange(event.startsAt, event.endsAt)}
											</div>
											<span
												className={
													ended ? "text-muted-foreground text-xs" : "text-xs text-emerald-600"
												}
											>
												{ended ? "Past" : "Upcoming"}
											</span>
										</TableCell>
										<TableCell>
											<Badge
												variant={
													event.status === "published"
														? "default"
														: event.status === "archived"
															? "secondary"
															: "outline"
												}
												className="capitalize"
											>
												{event.status}
											</Badge>
										</TableCell>
										<TableCell className="text-right">
											<div className="flex justify-end gap-1">
												<Button
													variant="outline"
													size="sm"
													onClick={() => openForm(rowToForm(event))}
												>
													<Edit className="size-4" /> Edit
												</Button>
												{event.status === "published" ? (
													<Button
														variant="ghost"
														size="icon"
														aria-label={`Unpublish ${event.title}`}
														title="Unpublish (move to draft)"
														onClick={() => changeStatus(event, "draft", "Event unpublished.")}
													>
														<EyeOff className="size-4" />
													</Button>
												) : (
													<Button
														variant="ghost"
														size="icon"
														aria-label={`Publish ${event.title}`}
														title="Publish"
														onClick={() => changeStatus(event, "published", "Event published.")}
													>
														<Eye className="size-4" />
													</Button>
												)}
												{event.status !== "archived" && (
													<Button
														variant="ghost"
														size="icon"
														aria-label={`Archive ${event.title}`}
														title="Archive"
														onClick={() => changeStatus(event, "archived", "Event archived.")}
													>
														<Archive className="size-4" />
													</Button>
												)}
												<Button
													variant="ghost"
													size="icon"
													aria-label={`Delete ${event.title}`}
													title="Delete"
													className="text-destructive hover:text-destructive"
													onClick={() => remove(event)}
												>
													<Trash2 className="size-4" />
												</Button>
											</div>
										</TableCell>
									</TableRow>
								)
							})}
						</TableBody>
					</Table>
				</div>
			</CardContent>

			<Dialog open={form !== null} onOpenChange={open => !open && setForm(null)}>
				<DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-2xl">
					<DialogHeader>
						<DialogTitle>{form?.id ? "Edit event" : "New event"}</DialogTitle>
						<DialogDescription>
							Times are in your local time zone. Only published events that have not ended are shown
							to citizens.
						</DialogDescription>
					</DialogHeader>
					{form && (
						<div className="space-y-4">
							<div className="space-y-2">
								<Label htmlFor="event-title">Title</Label>
								<Input
									id="event-title"
									value={form.title}
									onChange={event => {
										const title = event.target.value
										setForm(current =>
											current
												? {
														...current,
														title,
														slug:
															!current.id &&
															(!current.slug || current.slug === slugify(current.title))
																? slugify(title)
																: current.slug,
													}
												: current
										)
									}}
								/>
								{fieldError("title")}
							</div>
							<div className="grid gap-4 md:grid-cols-2">
								<div className="space-y-2">
									<Label htmlFor="event-slug">Slug</Label>
									<Input
										id="event-slug"
										value={form.slug}
										onChange={event =>
											setForm(current =>
												current ? { ...current, slug: slugify(event.target.value) } : current
											)
										}
									/>
									{fieldError("slug")}
								</div>
								<div className="space-y-2">
									<Label htmlFor="event-category">Category</Label>
									<Input
										id="event-category"
										list="event-category-options"
										value={form.category}
										onChange={event =>
											setForm(current =>
												current ? { ...current, category: event.target.value } : current
											)
										}
									/>
									<datalist id="event-category-options">
										{CATEGORY_SUGGESTIONS.map(option => (
											<option key={option} value={option} />
										))}
									</datalist>
									{fieldError("category")}
								</div>
							</div>
							<div className="space-y-2">
								<Label htmlFor="event-location">Location</Label>
								<Input
									id="event-location"
									placeholder="e.g. Municipal Plaza"
									value={form.location}
									onChange={event =>
										setForm(current =>
											current ? { ...current, location: event.target.value } : current
										)
									}
								/>
								{fieldError("location")}
							</div>
							<div className="grid gap-4 md:grid-cols-2">
								<div className="space-y-2">
									<Label htmlFor="event-starts">Starts</Label>
									<Input
										id="event-starts"
										type="datetime-local"
										value={form.startsAt}
										onChange={event =>
											setForm(current =>
												current ? { ...current, startsAt: event.target.value } : current
											)
										}
									/>
									{fieldError("startsAt")}
								</div>
								<div className="space-y-2">
									<Label htmlFor="event-ends">Ends (optional)</Label>
									<Input
										id="event-ends"
										type="datetime-local"
										value={form.endsAt}
										min={form.startsAt || undefined}
										onChange={event =>
											setForm(current =>
												current ? { ...current, endsAt: event.target.value } : current
											)
										}
									/>
									{fieldError("endsAt")}
								</div>
							</div>
							<div className="space-y-2">
								<Label htmlFor="event-description">Description</Label>
								<Textarea
									id="event-description"
									rows={4}
									value={form.description}
									onChange={event =>
										setForm(current =>
											current ? { ...current, description: event.target.value } : current
										)
									}
								/>
								{fieldError("description")}
							</div>
							<div className="grid gap-4 md:grid-cols-2">
								<div className="space-y-2">
									<Label htmlFor="event-image">Image URL (optional)</Label>
									<Input
										id="event-image"
										placeholder="https://..."
										value={form.imageUrl}
										onChange={event =>
											setForm(current =>
												current ? { ...current, imageUrl: event.target.value } : current
											)
										}
									/>
								</div>
								<div className="space-y-2">
									<Label htmlFor="event-status">Status</Label>
									<Select
										value={form.status}
										onValueChange={value =>
											setForm(current =>
												current ? { ...current, status: value as EventStatus } : current
											)
										}
									>
										<SelectTrigger id="event-status" className="w-full">
											<SelectValue />
										</SelectTrigger>
										<SelectContent>
											<SelectItem value="draft">Draft (hidden)</SelectItem>
											<SelectItem value="published">Published (visible)</SelectItem>
											<SelectItem value="archived">Archived</SelectItem>
										</SelectContent>
									</Select>
								</div>
							</div>
						</div>
					)}
					<DialogFooter>
						<Button variant="outline" onClick={() => setForm(null)}>
							Cancel
						</Button>
						<Button loading={upsertEvent.isPending} loadingText="Saving event..." onClick={save}>
							<Save className="size-4" /> Save event
						</Button>
					</DialogFooter>
				</DialogContent>
			</Dialog>
		</Card>
	)
}
