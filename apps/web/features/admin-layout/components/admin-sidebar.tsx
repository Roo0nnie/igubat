"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"

import { IgubatLogo } from "@/core/components/ui/igubat-logo"
import {
	Sidebar,
	SidebarContent,
	SidebarGroup,
	SidebarGroupContent,
	SidebarGroupLabel,
	SidebarHeader,
	SidebarMenu,
	SidebarMenuButton,
	SidebarMenuItem,
} from "@/core/components/ui/sidebar"
import { useRole } from "@/core/context/role-provider"
import { canAccess } from "@/core/lib/roles"
import { NAV_GROUPS } from "@/features/admin-layout/nav-items"

export function AdminSidebar() {
	const pathname = usePathname()
	const { portalRole } = useRole()

	// Hide groups/items the current role can't access. Admin-only items simply
	// disappear for Moderators (spec Section 8 permission matrix).
	const groups = NAV_GROUPS.map(group => ({
		...group,
		items: group.items.filter(item => canAccess(portalRole, item.access)),
	})).filter(group => group.items.length > 0)

	return (
		<Sidebar className="bg-sidebar border-r">
			<SidebarHeader className="border-b p-4">
				<div className="flex items-center gap-2">
					<IgubatLogo className="text-primary h-8 w-auto" />
					<span className="text-primary text-lg font-bold tracking-tight">Admin Portal</span>
				</div>
			</SidebarHeader>
			<SidebarContent>
				{groups.map(group => (
					<SidebarGroup key={group.label}>
						<SidebarGroupLabel>{group.label}</SidebarGroupLabel>
						<SidebarGroupContent>
							<SidebarMenu>
								{group.items.map(item => {
									const isActive = pathname === item.url || pathname.startsWith(`${item.url}/`)
									return (
										<SidebarMenuItem key={item.title}>
											<SidebarMenuButton
												tooltip={item.title}
												isActive={isActive}
												render={<Link href={item.url} />}
											>
												<item.icon className="text-muted-foreground" />
												<span>{item.title}</span>
											</SidebarMenuButton>
										</SidebarMenuItem>
									)
								})}
							</SidebarMenu>
						</SidebarGroupContent>
					</SidebarGroup>
				))}
			</SidebarContent>
		</Sidebar>
	)
}
