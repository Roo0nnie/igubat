/* eslint-disable @next/next/no-img-element */

import { Badge } from "@/core/components/ui/badge"
import {
	discoverGubatStatusBadgeVariant,
	discoverGubatTypeLabel,
	type DiscoverGubatStatus,
	type DiscoverGubatType,
} from "@/features/admin-discover-gubat/lib/discover-gubat-types"

export type DiscoverGubatPreviewPhoto = {
	id: string
	imageUrl: string
	altText?: string
}

export type DiscoverGubatPreviewEntry = {
	type: DiscoverGubatType
	title: string
	category: string
	summary: string
	body: string
	coverImageUrl: string
	mapLocation: string
	whereToBuy: string
	eventDate: string
	status?: DiscoverGubatStatus
	photos: DiscoverGubatPreviewPhoto[]
}

type DiscoverGubatPreviewProps = {
	entry: DiscoverGubatPreviewEntry
}

function detailLabel(type: DiscoverGubatType) {
	switch (type) {
		case "tourist_spot":
			return "Map location"
		case "festival_culture":
			return "Culture note"
		case "local_product":
			return "Where to buy"
	}
}

function detailValue(entry: DiscoverGubatPreviewEntry) {
	switch (entry.type) {
		case "tourist_spot":
			return entry.mapLocation
		case "festival_culture":
			return entry.eventDate ? `Observed around ${entry.eventDate}.` : entry.summary
		case "local_product":
			return entry.whereToBuy
	}
}

export function DiscoverGubatPreview({ entry }: DiscoverGubatPreviewProps) {
	const title = entry.title.trim() || "Untitled entry"
	const status = entry.status ?? "draft"
	const detail = detailValue(entry).trim()
	const photos = entry.photos.filter(photo => photo.imageUrl.trim())
	const body = entry.body.trim()

	return (
		<section className="flex flex-col gap-3 rounded-lg border p-4">
			<div className="flex items-start justify-between gap-3">
				<div>
					<p className="text-muted-foreground text-xs">Citizen-view preview</p>
					<h2 className="text-lg font-semibold">{title}</h2>
				</div>
				<Badge variant={discoverGubatStatusBadgeVariant(status)}>{status}</Badge>
			</div>

			{entry.coverImageUrl.trim() && (
				<img
					src={entry.coverImageUrl.trim()}
					alt={title}
					className="aspect-video w-full rounded-lg object-cover"
				/>
			)}

			<div className="text-muted-foreground flex flex-wrap gap-2 text-xs">
				<span>{discoverGubatTypeLabel(entry.type)}</span>
				{entry.category.trim() && <span>{entry.category.trim()}</span>}
			</div>

			{entry.summary.trim() && <p className="text-sm">{entry.summary}</p>}
			{body && <div className="text-sm leading-6 whitespace-pre-wrap">{body}</div>}

			{detail && (
				<div className="rounded-md border p-3 text-sm">
					<p className="text-muted-foreground text-xs font-semibold uppercase">
						{detailLabel(entry.type)}
					</p>
					<p className="mt-1">{detail}</p>
				</div>
			)}

			{photos.length > 0 && (
				<div className="grid gap-3 sm:grid-cols-2">
					{photos.map((photo, index) => (
						<img
							key={photo.id}
							src={photo.imageUrl.trim()}
							alt={photo.altText?.trim() || `${title} photo ${index + 1}`}
							className="aspect-video w-full rounded-lg object-cover"
						/>
					))}
				</div>
			)}
		</section>
	)
}
