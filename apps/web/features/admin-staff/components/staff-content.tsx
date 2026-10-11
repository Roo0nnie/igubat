"use client"

import { useState } from "react"
import { Plus, Save, Search } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
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
import { getRoleLabel } from "@/core/lib/roles"
import { useAdminStaffQuery, useCreateStaffMutation } from "@/features/admin-staff/api/staff.hooks"

const STAFF_ROLES = [
	"frontline_officer",
	"department_supervisor",
	"content_editor",
	"emergency_operator",
	"ict_admin",
] as const

export function StaffContent() {
	const staff = useAdminStaffQuery()
	const createStaff = useCreateStaffMutation()
	const [search, setSearch] = useState("")
	const [name, setName] = useState("")
	const [email, setEmail] = useState("")
	const [role, setRole] = useState<(typeof STAFF_ROLES)[number]>("frontline_officer")

	const rows = (staff.data ?? []).filter(user => {
		const term = search.trim().toLowerCase()
		return (
			term.length === 0 ||
			user.name.toLowerCase().includes(term) ||
			user.email.toLowerCase().includes(term) ||
			user.role.toLowerCase().includes(term)
		)
	})

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div>
				<h1 className="text-primary text-3xl font-bold tracking-tight">Staff Management</h1>
				<p className="text-muted-foreground mt-2">
					Create and review LGU portal accounts. New staff use password123 until reset.
				</p>
			</div>

			<div className="grid gap-6 lg:grid-cols-3">
				<Card className="lg:col-span-2">
					<CardHeader className="pb-3">
						<div className="flex flex-col justify-between gap-4 sm:flex-row">
							<div>
								<CardTitle>Staff Accounts</CardTitle>
								<CardDescription>Seeded and newly created portal users.</CardDescription>
							</div>
							<div className="relative w-full max-w-sm">
								<Search className="text-muted-foreground absolute top-2.5 left-2.5 size-4" />
								<Input
									value={search}
									onChange={event => setSearch(event.target.value)}
									placeholder="Search staff..."
									className="pl-8"
								/>
							</div>
						</div>
					</CardHeader>
					<CardContent>
						<div className="rounded-md border">
							<Table>
								<TableHeader>
									<TableRow>
										<TableHead>Name</TableHead>
										<TableHead>Email</TableHead>
										<TableHead>Role</TableHead>
										<TableHead>Status</TableHead>
										<TableHead>Password Reset</TableHead>
									</TableRow>
								</TableHeader>
								<TableBody>
									<TableStateRows
										colSpan={5}
										isLoading={staff.isLoading}
										isError={staff.isError}
										isEmpty={rows.length === 0}
										onRetry={() => void staff.refetch()}
										loadingText="Loading staff accounts..."
										errorText="Staff accounts could not be loaded."
										emptyText="No staff found."
										emptyHint="Create a staff account using the form."
									/>
									{rows.map(user => (
										<TableRow key={user.id}>
											<TableCell className="font-medium">{user.name}</TableCell>
											<TableCell>{user.email}</TableCell>
											<TableCell>{getRoleLabel(user.role)}</TableCell>
											<TableCell>
												<Badge variant={user.status === "active" ? "default" : "secondary"}>
													{user.status ?? "active"}
												</Badge>
											</TableCell>
											<TableCell>{user.forcePasswordReset ? "Required" : "Not required"}</TableCell>
										</TableRow>
									))}
								</TableBody>
							</Table>
						</div>
					</CardContent>
				</Card>

				<Card>
					<CardHeader>
						<CardTitle className="flex items-center gap-2">
							<Plus className="size-4" /> Create Staff
						</CardTitle>
						<CardDescription>The development password is password123.</CardDescription>
					</CardHeader>
					<CardContent className="space-y-4">
						<div className="space-y-2">
							<Label htmlFor="staff-name">Name</Label>
							<Input id="staff-name" value={name} onChange={event => setName(event.target.value)} />
						</div>
						<div className="space-y-2">
							<Label htmlFor="staff-email">Email</Label>
							<Input
								id="staff-email"
								type="email"
								value={email}
								onChange={event => setEmail(event.target.value)}
							/>
						</div>
						<div className="space-y-2">
							<Label>Role</Label>
							<Select
								value={role}
								onValueChange={value => setRole(value as (typeof STAFF_ROLES)[number])}
							>
								<SelectTrigger className="w-full">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{STAFF_ROLES.map(option => (
										<SelectItem key={option} value={option}>
											{getRoleLabel(option)}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</div>
						<Button
							disabled={!name || !email}
							loading={createStaff.isPending}
							loadingText="Creating account..."
							onClick={() => createStaff.mutate({ name, email, role })}
						>
							<Save className="size-4" /> Create account
						</Button>
					</CardContent>
				</Card>
			</div>
		</div>
	)
}
