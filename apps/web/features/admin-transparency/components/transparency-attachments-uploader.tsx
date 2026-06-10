"use client"

import { FileText, Plus, Trash2 } from "lucide-react"

import { Button } from "@/core/components/ui/button"
import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/core/components/ui/select"

const MAX_ATTACHMENTS = 10

const MIME_OPTIONS = [
	{ value: "application/pdf", label: "PDF" },
	{ value: "image/jpeg", label: "JPEG" },
	{ value: "image/png", label: "PNG" },
] as const

export type TransparencyAttachmentDraft = {
	id?: number
	fileName: string
	fileUrl: string
	mimeType: (typeof MIME_OPTIONS)[number]["value"]
	sizeBytes: string
	sortOrder: string
}

const emptyAttachment = (sortOrder: number): TransparencyAttachmentDraft => ({
	fileName: "",
	fileUrl: "",
	mimeType: "application/pdf",
	sizeBytes: "0",
	sortOrder: String(sortOrder),
})

export function TransparencyAttachmentsUploader({
	attachments,
	disabled,
	onChange,
}: {
	attachments: TransparencyAttachmentDraft[]
	disabled?: boolean
	onChange: (attachments: TransparencyAttachmentDraft[]) => void
}) {
	function updateAttachment(index: number, patch: Partial<TransparencyAttachmentDraft>) {
		onChange(
			attachments.map((attachment, attachmentIndex) =>
				attachmentIndex === index ? { ...attachment, ...patch } : attachment
			)
		)
	}

	function removeAttachment(index: number) {
		onChange(attachments.filter((_, attachmentIndex) => attachmentIndex !== index))
	}

	return (
		<fieldset className="space-y-3 rounded-md border p-3">
			<legend className="text-primary px-1 text-xs font-semibold uppercase">Attachments</legend>
			<div className="flex justify-end">
				<Button
					type="button"
					variant="outline"
					size="sm"
					disabled={disabled || attachments.length >= MAX_ATTACHMENTS}
					onClick={() => onChange([...attachments, emptyAttachment(attachments.length)])}
				>
					<Plus className="size-4" /> Add file
				</Button>
			</div>
			<p className="text-muted-foreground text-xs">
				Add up to 10 public file references. Accepted types: PDF, JPG, PNG; each file must be 10 MB
				or smaller.
			</p>
			{attachments.length === 0 && (
				<div className="text-muted-foreground rounded-md border border-dashed p-4 text-sm">
					No attachments added.
				</div>
			)}
			{attachments.map((attachment, index) => (
				<div key={attachment.id ?? index} className="space-y-3 rounded-md border p-3">
					<div className="flex items-center justify-between gap-3">
						<div className="flex min-w-0 items-center gap-2 text-sm font-medium">
							<FileText className="text-primary size-4 shrink-0" />
							<span className="truncate">{attachment.fileName || `Attachment ${index + 1}`}</span>
						</div>
						<Button
							type="button"
							variant="ghost"
							size="icon"
							aria-label="Remove attachment"
							disabled={disabled}
							onClick={() => removeAttachment(index)}
						>
							<Trash2 className="size-4" />
						</Button>
					</div>
					<div className="grid gap-3 md:grid-cols-2">
						<div className="space-y-1">
							<Label htmlFor={`attachment-name-${index}`} className="text-xs">
								File Name
							</Label>
							<Input
								id={`attachment-name-${index}`}
								value={attachment.fileName}
								disabled={disabled}
								onChange={event => updateAttachment(index, { fileName: event.target.value })}
							/>
						</div>
						<div className="space-y-1">
							<Label htmlFor={`attachment-url-${index}`} className="text-xs">
								File URL
							</Label>
							<Input
								id={`attachment-url-${index}`}
								value={attachment.fileUrl}
								disabled={disabled}
								onChange={event => updateAttachment(index, { fileUrl: event.target.value })}
							/>
						</div>
						<div className="space-y-1">
							<Label htmlFor={`attachment-mime-${index}`} className="text-xs">
								File Type
							</Label>
							<Select
								value={attachment.mimeType}
								disabled={disabled}
								onValueChange={value =>
									updateAttachment(index, {
										mimeType: value as TransparencyAttachmentDraft["mimeType"],
									})
								}
							>
								<SelectTrigger id={`attachment-mime-${index}`} className="w-full">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{MIME_OPTIONS.map(option => (
										<SelectItem key={option.value} value={option.value}>
											{option.label}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</div>
						<div className="grid gap-3 sm:grid-cols-2">
							<div className="space-y-1">
								<Label htmlFor={`attachment-size-${index}`} className="text-xs">
									Size Bytes
								</Label>
								<Input
									id={`attachment-size-${index}`}
									type="number"
									min={0}
									max={10 * 1024 * 1024}
									value={attachment.sizeBytes}
									disabled={disabled}
									onChange={event =>
										updateAttachment(index, {
											sizeBytes: event.target.value.replace(/\D/g, ""),
										})
									}
								/>
							</div>
							<div className="space-y-1">
								<Label htmlFor={`attachment-sort-${index}`} className="text-xs">
									Sort
								</Label>
								<Input
									id={`attachment-sort-${index}`}
									type="number"
									min={0}
									value={attachment.sortOrder}
									disabled={disabled}
									onChange={event =>
										updateAttachment(index, {
											sortOrder: event.target.value.replace(/\D/g, ""),
										})
									}
								/>
							</div>
						</div>
					</div>
				</div>
			))}
		</fieldset>
	)
}
