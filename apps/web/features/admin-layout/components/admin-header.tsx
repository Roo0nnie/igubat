"use client"

import { useRouter } from "next/navigation"
import { Bell, Search, User, UserCircle } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuItem,
	DropdownMenuLabel,
	DropdownMenuSeparator,
	DropdownMenuTrigger,
} from "@/core/components/ui/dropdown-menu"
import { Input } from "@/core/components/ui/input"
import { SidebarTrigger } from "@/core/components/ui/sidebar"
import { useRole } from "@/core/context/role-provider"
import { getRoleLabel } from "@/core/lib/roles"
import { useSignOutMutation } from "@/features/auth/api/session.hooks"

export function AdminHeader() {
	const { name, email, role, isAdmin } = useRole()
	const signOut = useSignOutMutation()
	const router = useRouter()

	return (
		<header className="bg-background flex h-16 shrink-0 items-center gap-4 border-b px-4 md:px-6">
			<SidebarTrigger className="text-muted-foreground hover:text-foreground -ml-1" />
			<div className="w-full flex-1">
				<form>
					<div className="relative">
						<Search className="text-muted-foreground absolute top-2.5 left-2.5 h-4 w-4" />
						<Input
							type="search"
							placeholder="Search..."
							className="bg-background w-full appearance-none pl-8 shadow-none md:w-2/3 lg:w-1/3"
						/>
					</div>
				</form>
			</div>
			<div className="flex items-center gap-4">
				<Badge variant={isAdmin ? "default" : "secondary"} className={isAdmin ? "bg-primary" : ""}>
					{getRoleLabel(role)}
				</Badge>
				<Button
					variant="ghost"
					size="icon"
					className="text-muted-foreground hover:text-foreground relative"
				>
					<Bell className="h-5 w-5" />
					<span className="bg-primary absolute top-2 right-2 h-2 w-2 rounded-full" />
					<span className="sr-only">Toggle notifications</span>
				</Button>
				<DropdownMenu>
					<DropdownMenuTrigger
						render={
							<Button
								variant="ghost"
								size="icon"
								className="bg-muted hover:bg-muted/80 rounded-full border"
							>
								<User className="text-muted-foreground h-5 w-5" />
								<span className="sr-only">Toggle user menu</span>
							</Button>
						}
					/>
					<DropdownMenuContent align="end" className="w-56">
						<DropdownMenuLabel>
							<div className="flex flex-col">
								<span className="font-medium">{name}</span>
								<span className="text-muted-foreground text-xs font-normal">{email}</span>
							</div>
						</DropdownMenuLabel>
						<DropdownMenuSeparator />
						{/* Self-service account surface — available to all staff (spec
                permission matrix: both Moderator and Admin). */}
						<DropdownMenuItem
							onSelect={e => {
								e.preventDefault()
								router.push("/profile")
							}}
						>
							<UserCircle className="mr-2 h-4 w-4" />
							My Profile
						</DropdownMenuItem>
						<DropdownMenuSeparator />
						<DropdownMenuItem
							disabled={signOut.isPending}
							onSelect={e => {
								e.preventDefault()
								signOut.mutate()
							}}
						>
							{signOut.isPending ? "Logging out..." : "Logout"}
						</DropdownMenuItem>
					</DropdownMenuContent>
				</DropdownMenu>
			</div>
		</header>
	)
}
