import { cookies } from "next/headers"

import { SidebarProvider } from "@/core/components/ui/sidebar"
import { RoleProvider } from "@/core/context/role-provider"
import { requireStaff } from "@/core/lib/admin-guard"
import { AdminHeader } from "@/features/admin-layout/components/admin-header"
import { AdminSidebar } from "@/features/admin-layout/components/admin-sidebar"

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
	// Strict RBAC: unauthenticated and non-staff visitors are redirected away
	// before any admin surface renders (spec Section 7).
	const user = await requireStaff()
	const sidebarOpen = (await cookies()).get("sidebar_state")?.value !== "false"

	return (
		<RoleProvider user={user}>
			<SidebarProvider defaultOpen={sidebarOpen}>
				<div className="bg-background text-foreground flex min-h-screen w-full font-sans antialiased">
					<AdminSidebar />
					<div className="flex flex-1 flex-col overflow-hidden">
						<AdminHeader />
						<main className="bg-muted/20 flex-1 overflow-y-auto">{children}</main>
					</div>
				</div>
			</SidebarProvider>
		</RoleProvider>
	)
}
