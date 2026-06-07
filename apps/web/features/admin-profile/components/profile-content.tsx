"use client"

import { useState } from "react"

import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/core/components/ui/tabs"
import { useRole } from "@/core/context/role-provider"
import { getRoleLabel } from "@/core/lib/roles"
import {
	useStaffProfileQuery,
	useUpdateStaffProfileMutation,
} from "@/features/admin-profile/api/profile.hooks"

export function ProfileContent() {
	const { name: fallbackName, email: fallbackEmail, role } = useRole()
	const profile = useStaffProfileQuery()
	const updateProfile = useUpdateStaffProfileMutation()
	const [nameOverride, setNameOverride] = useState<string | null>(null)
	const [mobileNumberOverride, setMobileNumberOverride] = useState<string | null>(null)
	const [barangayOverride, setBarangayOverride] = useState<string | null>(null)
	const [addressOverride, setAddressOverride] = useState<string | null>(null)
	const name = nameOverride ?? profile.data?.name ?? fallbackName
	const mobileNumber = mobileNumberOverride ?? profile.data?.mobileNumber ?? ""
	const barangay = barangayOverride ?? profile.data?.barangay ?? ""
	const address = addressOverride ?? profile.data?.address ?? ""

	return (
		<div className="mx-auto max-w-5xl space-y-6 p-6 md:p-8">
			<div>
				<h1 className="text-primary text-3xl font-bold tracking-tight">My Profile</h1>
				<p className="text-muted-foreground mt-2">
					Manage your account details and password guidance.
				</p>
			</div>

			<Tabs defaultValue="profile" className="w-full">
				<TabsList className="mb-4">
					<TabsTrigger value="profile">Profile</TabsTrigger>
					<TabsTrigger value="security">Security</TabsTrigger>
				</TabsList>

				<TabsContent value="profile">
					<Card>
						<CardHeader>
							<CardTitle>Profile Information</CardTitle>
							<CardDescription>
								Update contact details shared with service workflows and audit context.
							</CardDescription>
						</CardHeader>
						<CardContent className="space-y-4">
							<div className="grid gap-4 md:grid-cols-2">
								<div className="space-y-2">
									<Label htmlFor="name">Name</Label>
									<Input
										id="name"
										value={name}
										onChange={event => setNameOverride(event.target.value)}
									/>
								</div>
								<div className="space-y-2">
									<Label htmlFor="email">Email</Label>
									<Input
										id="email"
										type="email"
										value={profile.data?.email ?? fallbackEmail}
										disabled
									/>
								</div>
								<div className="space-y-2">
									<Label htmlFor="role">Role</Label>
									<Input id="role" value={getRoleLabel(profile.data?.role ?? role)} disabled />
								</div>
								<div className="space-y-2">
									<Label htmlFor="mobile">Mobile Number</Label>
									<Input
										id="mobile"
										value={mobileNumber}
										onChange={event => setMobileNumberOverride(event.target.value)}
									/>
								</div>
								<div className="space-y-2">
									<Label htmlFor="barangay">Barangay</Label>
									<Input
										id="barangay"
										value={barangay}
										onChange={event => setBarangayOverride(event.target.value)}
									/>
								</div>
								<div className="space-y-2">
									<Label htmlFor="address">Address</Label>
									<Input
										id="address"
										value={address}
										onChange={event => setAddressOverride(event.target.value)}
									/>
								</div>
							</div>
						</CardContent>
						<CardFooter className="border-t px-6 py-4">
							<Button
								disabled={updateProfile.isPending || !name}
								onClick={() =>
									updateProfile.mutate({
										name,
										mobileNumber: mobileNumber || undefined,
										barangay: barangay || undefined,
										address: address || undefined,
									})
								}
							>
								{updateProfile.isPending ? "Saving..." : "Save changes"}
							</Button>
						</CardFooter>
					</Card>
				</TabsContent>

				<TabsContent value="security">
					<Card>
						<CardHeader>
							<CardTitle>Change Password</CardTitle>
							<CardDescription>
								Development staff credentials are seeded with password123 and flagged for reset on
								newly created accounts.
							</CardDescription>
						</CardHeader>
						<CardContent className="space-y-4">
							<div className="space-y-2">
								<Label htmlFor="current">Current Password</Label>
								<Input id="current" type="password" placeholder="password123" />
							</div>
							<div className="space-y-2">
								<Label htmlFor="new">New Password</Label>
								<Input id="new" type="password" />
							</div>
							<div className="space-y-2">
								<Label htmlFor="confirm">Confirm Password</Label>
								<Input id="confirm" type="password" />
							</div>
						</CardContent>
						<CardFooter className="border-t px-6 py-4">
							<Button variant="outline" disabled>
								Password update requires Better Auth change-password wiring
							</Button>
						</CardFooter>
					</Card>
				</TabsContent>
			</Tabs>
		</div>
	)
}
