import { SidebarProvider } from "@/core/components/ui/sidebar"
import { AdminSidebar } from "@/features/admin-layout/components/admin-sidebar"
import { AdminHeader } from "@/features/admin-layout/components/admin-header"

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <SidebarProvider>
      <div className="flex min-h-screen w-full bg-background font-sans antialiased text-foreground">
        <AdminSidebar />
        <div className="flex flex-1 flex-col overflow-hidden">
          <AdminHeader />
          <main className="flex-1 overflow-y-auto bg-muted/20">
            {children}
          </main>
        </div>
      </div>
    </SidebarProvider>
  )
}
