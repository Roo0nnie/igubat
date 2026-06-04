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
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/core/components/ui/sidebar"
import { IgubatLogo } from "@/core/components/ui/igubat-logo"
import { useRole } from "@/core/context/role-provider"
import { canAccess } from "@/core/lib/roles"
import { NAV_GROUPS } from "@/features/admin-layout/nav-items"

export function AdminSidebar() {
  const pathname = usePathname()
  const { portalRole } = useRole()

  // Hide groups/items the current role can't access. Admin-only items simply
  // disappear for Moderators (spec Section 8 permission matrix).
  const groups = NAV_GROUPS.map((group) => ({
    ...group,
    items: group.items.filter((item) => canAccess(portalRole, item.access)),
  })).filter((group) => group.items.length > 0)

  return (
    <Sidebar className="border-r bg-sidebar">
      <SidebarHeader className="p-4 border-b">
        <div className="flex items-center gap-2">
          <IgubatLogo className="h-8 w-auto text-primary" />
          <span className="font-bold text-lg text-primary tracking-tight">Admin Portal</span>
        </div>
      </SidebarHeader>
      <SidebarContent>
        {groups.map((group) => (
          <SidebarGroup key={group.label}>
            <SidebarGroupLabel>{group.label}</SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu>
                {group.items.map((item) => {
                  const isActive =
                    pathname === item.url || pathname.startsWith(`${item.url}/`)
                  return (
                    <SidebarMenuItem key={item.title}>
                      <SidebarMenuButton asChild tooltip={item.title} isActive={isActive}>
                        <Link href={item.url}>
                          <item.icon className="text-muted-foreground" />
                          <span>{item.title}</span>
                        </Link>
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
