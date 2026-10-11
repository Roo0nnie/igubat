"use client"

import { useRouter } from "next/navigation"
import {
	Bell,
	ChevronDown,
	LogOut,
	PanelLeftClose,
	PanelLeftOpen,
	Search,
	UserCircle,
} from "lucide-react"

import { Button } from "@/core/components/ui/button"
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuGroup,
	DropdownMenuItem,
	DropdownMenuLabel,
	DropdownMenuSeparator,
	DropdownMenuTrigger,
} from "@/core/components/ui/dropdown-menu"
import { Input } from "@/core/components/ui/input"
import { useSidebar } from "@/core/components/ui/sidebar"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/core/components/ui/tooltip"
import { useRole } from "@/core/context/role-provider"
import { getRoleLabel } from "@/core/lib/roles"
import { cn } from "@/core/lib/utils"
import { useSignOutMutation } from "@/features/auth/api/session.hooks"

export function AdminHeader() {
	const { name, email, role, isAdmin } = useRole()
	const signOut = useSignOutMutation()
	const router = useRouter()
	const initials =
		name
			.split(/\s+/)
			.filter(Boolean)
			.slice(0, 2)
			.map(part => part[0]?.toUpperCase())
			.join("") || "?"

	return (
		<header className="bg-background flex h-16 shrink-0 items-center gap-4 border-b px-4 md:px-6">
			<SidebarToggle />
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
			<div className="flex items-center gap-2 sm:gap-3">
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
								aria-label={`Account menu for ${name}`}
								className="data-popup-open:bg-muted h-10 gap-2 rounded-full px-1 sm:pr-3"
							/>
						}
					>
						<span className="bg-primary text-primary-foreground flex size-8 shrink-0 items-center justify-center rounded-full text-xs font-semibold">
							{initials}
						</span>
						<span className="hidden max-w-40 flex-col items-start leading-tight sm:flex">
							<span className="truncate text-sm font-medium">{name}</span>
							<span
								className={cn(
									"truncate text-xs font-normal",
									isAdmin ? "text-primary" : "text-muted-foreground"
								)}
							>
								{getRoleLabel(role)}
							</span>
						</span>
						<ChevronDown className="text-muted-foreground hidden size-4 sm:block" />
					</DropdownMenuTrigger>
					<DropdownMenuContent align="end" sideOffset={8} className="w-56">
						<DropdownMenuGroup>
							<DropdownMenuLabel>
								<div className="flex flex-col">
									<span className="text-foreground font-medium">{name}</span>
									<span className="text-muted-foreground text-xs font-normal">{email}</span>
								</div>
							</DropdownMenuLabel>
						</DropdownMenuGroup>
						<DropdownMenuSeparator />
						{/* Self-service account surface — available to all staff (spec
                permission matrix: both Moderator and Admin). */}
						<DropdownMenuItem onClick={() => router.push("/profile")}>
							<UserCircle className="mr-2 h-4 w-4" />
							My Profile
						</DropdownMenuItem>
						<DropdownMenuSeparator />
						<DropdownMenuItem
							disabled={signOut.isPending}
							closeOnClick={false}
							onClick={() => signOut.mutate()}
						>
							<LogOut className="mr-2 h-4 w-4" />
							{signOut.isPending ? "Logging out..." : "Logout"}
						</DropdownMenuItem>
					</DropdownMenuContent>
				</DropdownMenu>
			</div>
		</header>
	)
}

function SidebarToggle() {
	const { state, isMobile, openMobile, toggleSidebar } = useSidebar()
	const isOpen = isMobile ? openMobile : state === "expanded"
	const label = isMobile
		? isOpen
			? "Close menu"
			: "Open menu"
		: isOpen
			? "Collapse sidebar"
			: "Expand sidebar"
	const Icon = isOpen ? PanelLeftClose : PanelLeftOpen

	return (
		<Tooltip>
			<TooltipTrigger
				render={
					<Button
						variant="ghost"
						size="icon-sm"
						aria-label={label}
						aria-expanded={isOpen}
						onClick={toggleSidebar}
						className="text-muted-foreground hover:text-foreground -ml-1"
					/>
				}
			>
				<Icon className="h-5 w-5" />
			</TooltipTrigger>
			<TooltipContent side="bottom">
				{label}
				{!isMobile && <span className="text-background/70 ml-2">Ctrl+B</span>}
			</TooltipContent>
		</Tooltip>
	)
}
