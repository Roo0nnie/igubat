"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"

import {
	Sidebar,
	SidebarContent,
	SidebarGroup,
	SidebarGroupContent,
	SidebarGroupLabel,
	SidebarHeader,
	SidebarMenu,
	SidebarMenuBadge,
	SidebarMenuButton,
	SidebarMenuItem,
	SidebarRail,
	SidebarSeparator,
} from "@/core/components/ui/sidebar"
import { useRole } from "@/core/context/role-provider"
import { canAccess } from "@/core/lib/roles"
import { cn } from "@/core/lib/utils"
import { useAdminDashboardQuery } from "@/features/admin-dashboard/api/dashboard.hooks"
import { NAV_GROUPS, type NavBadgeKey, type NavItem } from "@/features/admin-layout/nav-items"

export function AdminSidebar() {
	const pathname = usePathname()
	const { portalRole } = useRole()
	const dashboard = useAdminDashboardQuery()

	// Hide groups/items the current role can't access. Admin-only items simply
	// disappear for Moderators (spec Section 8 permission matrix).
	const groups = NAV_GROUPS.map(group => ({
		...group,
		items: group.items.filter(item => canAccess(portalRole, item.access)),
	})).filter(group => group.items.length > 0)

	const badgeCount = (key: NavBadgeKey) => dashboard.data?.[key] ?? 0

	return (
		<Sidebar collapsible="icon" className="bg-sidebar border-r">
			<SidebarHeader className="h-16 justify-center border-b px-3 group-data-[collapsible=icon]:px-2">
				<Link
					href="/dashboard"
					aria-label="iGubat Admin Portal home"
					className="flex items-center gap-2.5 overflow-hidden rounded-md"
				>
					<span className="flex size-8 shrink-0 items-baseline justify-center rounded-lg border bg-white shadow-sm">
						<span className="text-sm font-bold tracking-tighter text-[#7DB343]">i</span>
						<span className="text-igubat-primary -ml-px text-xl leading-7 font-black tracking-tighter">
							G
						</span>
					</span>
					<span className="flex min-w-0 flex-col leading-tight group-data-[collapsible=icon]:hidden">
						<span className="text-primary truncate text-base font-bold tracking-tight">iGubat</span>
						<span className="text-muted-foreground truncate text-xs font-medium">Admin Portal</span>
					</span>
				</Link>
			</SidebarHeader>
			<SidebarContent className="[scrollbar-width:thin] group-data-[collapsible=icon]:overflow-auto group-data-[collapsible=icon]:overflow-x-hidden group-data-[collapsible=icon]:[scrollbar-width:none]">
				{groups.map((group, index) => (
					<SidebarGroup key={group.label} className={cn(group.pinBottom && "mt-auto")}>
						{index > 0 && (
							<SidebarSeparator
								className={cn(
									"mx-0 mb-2",
									!group.pinBottom && "hidden group-data-[collapsible=icon]:block"
								)}
							/>
						)}
						<SidebarGroupLabel>{group.label}</SidebarGroupLabel>
						<SidebarGroupContent>
							<SidebarMenu>
								{group.items.map(item => (
									<NavLink
										key={item.title}
										item={item}
										isActive={pathname === item.url || pathname.startsWith(`${item.url}/`)}
										count={item.badge ? badgeCount(item.badge.key) : 0}
									/>
								))}
							</SidebarMenu>
						</SidebarGroupContent>
					</SidebarGroup>
				))}
			</SidebarContent>
			<SidebarRail />
		</Sidebar>
	)
}

function NavLink({ item, isActive, count }: { item: NavItem; isActive: boolean; count: number }) {
	const showBadge = item.badge && count > 0
	const displayCount = count > 99 ? "99+" : String(count)

	return (
		<SidebarMenuItem>
			<SidebarMenuButton
				tooltip={showBadge ? `${item.title} (${count} ${item.badge?.label})` : item.title}
				isActive={isActive}
				aria-current={isActive ? "page" : undefined}
				render={<Link href={item.url} />}
			>
				<item.icon className="text-muted-foreground group-data-active/menu-button:text-sidebar-accent-foreground" />
				<span>{item.title}</span>
			</SidebarMenuButton>
			{showBadge && (
				<>
					<SidebarMenuBadge
						aria-label={`${count} ${item.badge?.label}`}
						className="bg-primary text-primary-foreground peer-hover/menu-button:text-primary-foreground peer-data-active/menu-button:text-primary-foreground rounded-full"
					>
						{displayCount}
					</SidebarMenuBadge>
					<span
						aria-hidden
						className="bg-destructive ring-sidebar pointer-events-none absolute top-1 right-1 hidden size-2 rounded-full ring-2 group-data-[collapsible=icon]:block"
					/>
				</>
			)}
		</SidebarMenuItem>
	)
}
