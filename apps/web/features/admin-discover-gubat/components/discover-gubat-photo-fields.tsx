"use client"

import { Plus, Trash2 } from "lucide-react"

import { Button } from "@/core/components/ui/button"
import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"

export type DiscoverGubatPhotoDraft = {
	id: string
	imageUrl: string
	altText: string
}

type DiscoverGubatPhotoFieldsProps = {
	photos: DiscoverGubatPhotoDraft[]
	disabled?: boolean
	onChange: (photos: DiscoverGubatPhotoDraft[]) => void
}

function createPhotoDraft(): DiscoverGubatPhotoDraft {
	return {
		id: `photo-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
		imageUrl: "",
		altText: "",
	}
}

export function DiscoverGubatPhotoFields({
	photos,
	disabled = false,
	onChange,
}: DiscoverGubatPhotoFieldsProps) {
	function updatePhoto(index: number, changes: Partial<DiscoverGubatPhotoDraft>) {
		onChange(
			photos.map((photo, photoIndex) => (photoIndex === index ? { ...photo, ...changes } : photo))
		)
	}

	return (
		<div className="flex flex-col gap-3 rounded-lg border p-3">
			<div className="flex items-center justify-between gap-3">
				<div>
					<Label className="text-xs font-semibold uppercase">Photos</Label>
					<p className="text-muted-foreground mt-1 text-xs">
						Add gallery images shown after the cover image.
					</p>
				</div>
				<Button
					type="button"
					variant="outline"
					size="sm"
					disabled={disabled}
					onClick={() => onChange([...photos, createPhotoDraft()])}
				>
					<Plus data-icon="inline-start" /> Add Photo
				</Button>
			</div>

			{photos.length === 0 ? (
				<p className="text-muted-foreground text-sm">No gallery photos added.</p>
			) : (
				<div className="flex flex-col gap-3">
					{photos.map((photo, index) => {
						const photoNumber = index + 1
						const urlId = `discover-photo-${photo.id}-url`
						const altId = `discover-photo-${photo.id}-alt`

						return (
							<div
								key={photo.id}
								className="grid gap-3 rounded-md border p-3 md:grid-cols-[1fr_1fr_auto]"
							>
								<div className="flex flex-col gap-2">
									<Label htmlFor={urlId}>Photo {photoNumber} URL</Label>
									<Input
										id={urlId}
										value={photo.imageUrl}
										disabled={disabled}
										onChange={event => updatePhoto(index, { imageUrl: event.target.value })}
									/>
								</div>
								<div className="flex flex-col gap-2">
									<Label htmlFor={altId}>Photo {photoNumber} Alt text</Label>
									<Input
										id={altId}
										value={photo.altText}
										disabled={disabled}
										onChange={event => updatePhoto(index, { altText: event.target.value })}
									/>
								</div>
								<div className="flex items-end">
									<Button
										type="button"
										variant="outline"
										size="icon"
										disabled={disabled}
										aria-label={`Remove photo ${photoNumber}`}
										onClick={() => onChange(photos.filter((_, photoIndex) => photoIndex !== index))}
									>
										<Trash2 />
									</Button>
								</div>
							</div>
						)
					})}
				</div>
			)}
		</div>
	)
}
