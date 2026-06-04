import { SidebarProvider } from "@/core/components/ui/sidebar"
import { RoleProvider } from "@/core/context/role-provider"
import { requireStaff } from "@/core/lib/admin-guard"
import { AdminSidebar } from "@/features/admin-layout/components/admin-sidebar"
import { AdminHeader } from "@/features/admin-layout/components/admin-header"

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode
}) {
  // Strict RBAC: unauthenticated and non-staff visitors are redirected away
  // before any admin surface renders (spec Section 7).
  const user = await requireStaff()

  return (
    <RoleProvider user={user}>
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
    </RoleProvider>
  )
}
