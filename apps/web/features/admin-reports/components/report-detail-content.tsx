"use client"

import { useState } from "react"
import type { Route } from "next"
import Link from "next/link"
import { ArrowLeft, CheckCircle2, Clock, FileText, MapPin, Save } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { Label } from "@/core/components/ui/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/core/components/ui/select"
import { Textarea } from "@/core/components/ui/textarea"
import {
	useAdminReportQuery,
	useUpdateReportStatusMutation,
} from "@/features/admin-reports/api/reports.hooks"

const STATUS_OPTIONS = ["received", "in_progress", "resolved", "closed"] as const

function formatStatus(status: string) {
	return status.replace(/_/g, " ").replace(/\b\w/g, char => char.toUpperCase())
}

function statusVariant(status: string) {
	if (status === "resolved") return "default" as const
	if (status === "closed") return "destructive" as const
	if (status === "received") return "outline" as const
	return "secondary" as const
}

function formatDate(value: string | Date) {
	return new Date(value).toLocaleString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
		hour: "numeric",
		minute: "2-digit",
	})
}

export function ReportDetailContent({ id }: { id: number }) {
	const report = useAdminReportQuery(id)
	const updateStatus = useUpdateReportStatusMutation()
	const [statusOverride, setStatusOverride] = useState<(typeof STATUS_OPTIONS)[number] | null>(null)
	const [remarksOverride, setRemarksOverride] = useState<string | null>(null)
	const [internalNotesOverride, setInternalNotesOverride] = useState<string | null>(null)
	const status = statusOverride ?? report.data?.status ?? "received"
	const remarks = remarksOverride ?? report.data?.publicRemarks ?? ""
	const internalNotes = internalNotesOverride ?? report.data?.internalNotes ?? ""

	if (report.isLoading) {
		return (
			<div className="text-muted-foreground mx-auto max-w-5xl p-6 text-sm md:p-8">
				Loading report...
			</div>
		)
	}

	if (report.isError || !report.data) {
		return (
			<div className="mx-auto max-w-5xl space-y-4 p-6 md:p-8">
				<Button variant="outline" render={<Link href={"/reports" as Route} />}>
					<ArrowLeft className="size-4" /> Back
				</Button>
				<Card className="border-destructive/40">
					<CardContent className="text-destructive py-6 text-sm">
						Report could not be loaded.
					</CardContent>
				</Card>
			</div>
		)
	}

	const data = report.data

	return (
		<div className="mx-auto max-w-6xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
				<div className="space-y-2">
					<Button variant="outline" size="sm" render={<Link href={"/reports" as Route} />}>
						<ArrowLeft className="size-4" /> Back to reports
					</Button>
					<div>
						<h1 className="text-primary text-3xl font-bold tracking-tight">
							IR-{String(data.id).padStart(5, "0")}
						</h1>
						<p className="text-muted-foreground mt-2">
							{data.category} report from {data.citizenName ?? "Citizen"}
						</p>
					</div>
				</div>
				<Badge variant={statusVariant(data.status)} className="w-fit">
					{formatStatus(data.status)}
				</Badge>
			</div>

			<div className="grid gap-6 lg:grid-cols-3">
				<Card className="lg:col-span-2">
					<CardHeader>
						<CardTitle>Report Details</CardTitle>
						<CardDescription>
							Community report content, location, and submitter context.
						</CardDescription>
					</CardHeader>
					<CardContent className="grid gap-4 md:grid-cols-2">
						<div>
							<p className="text-sm font-medium">Citizen</p>
							<p className="text-muted-foreground text-sm">{data.citizenName ?? "Not available"}</p>
						</div>
						<div>
							<p className="text-sm font-medium">Barangay</p>
							<p className="text-muted-foreground text-sm">{data.barangay ?? "Not set"}</p>
						</div>
						<div className="md:col-span-2">
							<p className="flex items-center gap-1 text-sm font-medium">
								<MapPin className="text-primary size-4" /> Location
							</p>
							<p className="text-muted-foreground text-sm">{data.locationAddress ?? "Not set"}</p>
						</div>
						<div className="md:col-span-2">
							<p className="text-sm font-medium">Description</p>
							<p className="text-muted-foreground mt-1 text-sm whitespace-pre-wrap">
								{data.description}
							</p>
						</div>
					</CardContent>
				</Card>

				<Card>
					<CardHeader>
						<CardTitle>Update Status</CardTitle>
						<CardDescription>
							Status changes notify the citizen and write audit history.
						</CardDescription>
					</CardHeader>
					<CardContent className="space-y-4">
						<div className="space-y-2">
							<Label>Status</Label>
							<Select
								value={status}
								onValueChange={value => setStatusOverride(value as (typeof STATUS_OPTIONS)[number])}
							>
								<SelectTrigger className="w-full">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{STATUS_OPTIONS.map(option => (
										<SelectItem key={option} value={option}>
											{formatStatus(option)}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</div>
						<div className="space-y-2">
							<Label htmlFor="remarks">Citizen remarks</Label>
							<Textarea
								id="remarks"
								value={remarks}
								onChange={event => setRemarksOverride(event.target.value)}
								rows={4}
							/>
						</div>
						<div className="space-y-2">
							<Label htmlFor="internal-notes">Internal notes</Label>
							<Textarea
								id="internal-notes"
								value={internalNotes}
								onChange={event => setInternalNotesOverride(event.target.value)}
								rows={4}
							/>
						</div>
						<Button
							disabled={updateStatus.isPending}
							onClick={() =>
								updateStatus.mutate({
									id,
									status,
									remarks: remarks || undefined,
									internalNotes: internalNotes || undefined,
								})
							}
						>
							<Save className="size-4" /> {updateStatus.isPending ? "Saving..." : "Save status"}
						</Button>
					</CardContent>
				</Card>
			</div>

			<div className="grid gap-6 lg:grid-cols-2">
				<Card>
					<CardHeader>
						<CardTitle>Attachments</CardTitle>
					</CardHeader>
					<CardContent className="space-y-3">
						{data.attachments.length === 0 && (
							<p className="text-muted-foreground text-sm">No attachments uploaded.</p>
						)}
						{data.attachments.map(file => (
							<a
								key={file.id}
								href={file.fileUrl}
								className="hover:bg-muted flex items-center gap-3 rounded-md border p-3 text-sm"
								target="_blank"
								rel="noreferrer"
							>
								<FileText className="text-primary size-4" />
								<span>{file.fileName}</span>
							</a>
						))}
					</CardContent>
				</Card>

				<Card>
					<CardHeader>
						<CardTitle>Lifecycle History</CardTitle>
					</CardHeader>
					<CardContent className="space-y-4">
						{data.history.map(item => (
							<div key={item.id} className="flex gap-3">
								{item.status === "resolved" ? (
									<CheckCircle2 className="text-primary mt-0.5 size-4" />
								) : (
									<Clock className="text-muted-foreground mt-0.5 size-4" />
								)}
								<div>
									<p className="text-sm font-medium">{formatStatus(item.status)}</p>
									<p className="text-muted-foreground text-xs">{formatDate(item.createdAt)}</p>
									{item.remarks && (
										<p className="text-muted-foreground mt-1 text-sm">{item.remarks}</p>
									)}
								</div>
							</div>
						))}
					</CardContent>
				</Card>
			</div>
		</div>
	)
}
