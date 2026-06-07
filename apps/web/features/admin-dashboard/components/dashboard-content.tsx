"use client"

import type { Route } from "next"
import Link from "next/link"
import { Activity, AlertTriangle, CalendarDays, FileText, Newspaper, Users } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { useAdminDashboardQuery } from "@/features/admin-dashboard/api/dashboard.hooks"

function formatStatus(status: string) {
	return status.replace(/_/g, " ").replace(/\b\w/g, char => char.toUpperCase())
}

function statusVariant(status: string) {
	if (["approved", "resolved", "completed"].includes(status)) return "default" as const
	if (["rejected", "closed"].includes(status)) return "destructive" as const
	if (["pending", "received"].includes(status)) return "outline" as const
	return "secondary" as const
}

function formatDate(value: string | Date) {
	return new Date(value).toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
	})
}

export function DashboardContent() {
	const dashboard = useAdminDashboardQuery()
	const data = dashboard.data

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div>
				<h1 className="text-primary text-3xl font-bold tracking-tight">Dashboard</h1>
				<p className="text-muted-foreground mt-2">
					Live LGU service activity, content, and emergency overview.
				</p>
			</div>

			{dashboard.isError && (
				<Card className="border-destructive/40">
					<CardContent className="text-destructive py-4 text-sm">
						Dashboard data could not be loaded.
					</CardContent>
				</Card>
			)}

			<div className="grid gap-4 md:grid-cols-2 lg:grid-cols-5">
				{[
					{ label: "Total Users", value: data?.totalUsers ?? 0, icon: Users, href: "/citizens" },
					{
						label: "Pending Requests",
						value: data?.pendingRequests ?? 0,
						icon: FileText,
						href: "/requests",
					},
					{
						label: "Active Services",
						value: data?.activeServices ?? 0,
						icon: Activity,
						href: "/content",
					},
					{
						label: "New Reports",
						value: data?.newReports ?? 0,
						icon: AlertTriangle,
						href: "/reports",
					},
					{
						label: "Announcements",
						value: data?.publishedAnnouncements ?? 0,
						icon: Newspaper,
						href: "/content",
					},
				].map(stat => (
					<Card key={stat.label}>
						<CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
							<CardTitle className="text-sm font-medium">{stat.label}</CardTitle>
							<stat.icon className="text-primary size-4" />
						</CardHeader>
						<CardContent>
							<div className="text-2xl font-bold">{dashboard.isLoading ? "..." : stat.value}</div>
							<Button
								variant="link"
								className="h-auto p-0 text-xs"
								render={<Link href={stat.href as Route} />}
							>
								View details
							</Button>
						</CardContent>
					</Card>
				))}
			</div>

			<div className="grid gap-4 lg:grid-cols-7">
				<Card className="lg:col-span-4">
					<CardHeader>
						<CardTitle>Recent Transactions</CardTitle>
						<CardDescription>Latest service requests submitted by citizens.</CardDescription>
					</CardHeader>
					<CardContent>
						<div className="space-y-4">
							{(data?.recentRequests ?? []).length === 0 && (
								<p className="text-muted-foreground text-sm">No recent service requests yet.</p>
							)}
							{data?.recentRequests.map(request => (
								<Link
									key={request.id}
									href={`/requests/${request.id}` as Route}
									className="hover:bg-muted flex items-center gap-4 rounded-md border p-3 transition-colors"
								>
									<div className="min-w-0 flex-1 space-y-1">
										<p className="truncate text-sm font-medium">
											{request.citizenName ?? "Citizen"}
										</p>
										<p className="text-muted-foreground truncate text-sm">
											{request.trackingNumber} - {request.serviceType}
										</p>
									</div>
									<Badge variant={statusVariant(request.status)}>
										{formatStatus(request.status)}
									</Badge>
								</Link>
							))}
						</div>
					</CardContent>
				</Card>

				<Card className="lg:col-span-3">
					<CardHeader>
						<CardTitle>Upcoming Events</CardTitle>
						<CardDescription>Public calendar items visible to citizens.</CardDescription>
					</CardHeader>
					<CardContent>
						<div className="space-y-4">
							{(data?.upcomingEvents ?? []).length === 0 && (
								<p className="text-muted-foreground text-sm">No upcoming events yet.</p>
							)}
							{data?.upcomingEvents.map(event => (
								<Link
									key={event.id}
									href={`/content?event=${event.slug}` as Route}
									className="hover:bg-muted flex gap-3 rounded-md border p-3 transition-colors"
								>
									<CalendarDays className="text-primary mt-0.5 size-4" />
									<div className="min-w-0 space-y-1">
										<p className="truncate text-sm font-medium">{event.title}</p>
										<p className="text-muted-foreground text-xs">{formatDate(event.startsAt)}</p>
									</div>
								</Link>
							))}
						</div>
					</CardContent>
				</Card>
			</div>

			<Card>
				<CardHeader>
					<CardTitle>Quick Actions</CardTitle>
					<CardDescription>Common staff workflows.</CardDescription>
				</CardHeader>
				<CardContent className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
					<Button
						variant="outline"
						className="justify-start"
						render={<Link href={"/content" as Route} />}
					>
						<Newspaper className="size-4" /> Post update
					</Button>
					<Button
						variant="outline"
						className="justify-start"
						render={<Link href={"/emergency" as Route} />}
					>
						<AlertTriangle className="size-4" /> Broadcast alert
					</Button>
					<Button
						variant="outline"
						className="justify-start"
						render={<Link href={"/requests" as Route} />}
					>
						<FileText className="size-4" /> Process request
					</Button>
					<Button
						variant="outline"
						className="justify-start"
						render={<Link href={"/reports" as Route} />}
					>
						<Activity className="size-4" /> Review report
					</Button>
				</CardContent>
			</Card>
		</div>
	)
}
