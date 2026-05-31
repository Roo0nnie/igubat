import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/core/components/ui/sidebar"
import { Home, FileText, Users, Newspaper, AlertTriangle, Bell, Settings } from "lucide-react"
import Link from "next/link"
import { IgubatLogo } from "@/core/components/ui/igubat-logo"

const items = [
  {
    title: "Dashboard",
    url: "/dashboard",
    icon: Home,
  },
  {
    title: "Requests",
    url: "/requests",
    icon: FileText,
  },
  {
    title: "Citizens",
    url: "/citizens",
    icon: Users,
  },
  {
    title: "Content",
    url: "/content",
    icon: Newspaper,
  },
  {
    title: "Reports",
    url: "/reports",
    icon: AlertTriangle,
  },
  {
    title: "Notifications",
    url: "/notifications",
    icon: Bell,
  },
]

export function AdminSidebar() {
  return (
    <Sidebar className="border-r bg-sidebar">
      <SidebarHeader className="p-4 border-b">
        <div className="flex items-center gap-2">
          <IgubatLogo className="h-8 w-auto text-primary" />
          <span className="font-bold text-lg text-primary tracking-tight">Admin Portal</span>
        </div>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Menu</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {items.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild tooltip={item.title}>
                    <Link href={item.url}>
                      <item.icon className="text-muted-foreground" />
                      <span>{item.title}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter className="border-t p-4">
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton asChild tooltip="Settings">
              <Link href="/settings">
                <Settings className="text-muted-foreground" />
                <span>Settings</span>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  )
}
