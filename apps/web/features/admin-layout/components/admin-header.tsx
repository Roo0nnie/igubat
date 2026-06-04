"use client"

import { useRouter } from "next/navigation"
import { Bell, Search, User, UserCircle } from "lucide-react"

import { Button } from "@/core/components/ui/button"
import { Input } from "@/core/components/ui/input"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/core/components/ui/dropdown-menu"
import { SidebarTrigger } from "@/core/components/ui/sidebar"
import { Badge } from "@/core/components/ui/badge"
import { useRole } from "@/core/context/role-provider"
import { getRoleLabel } from "@/core/lib/roles"
import { useSignOutMutation } from "@/features/auth/api/session.hooks"

export function AdminHeader() {
  const { name, email, role, isAdmin } = useRole()
  const signOut = useSignOutMutation()
  const router = useRouter()

  return (
    <header className="flex h-16 shrink-0 items-center gap-4 border-b bg-background px-4 md:px-6">
      <SidebarTrigger className="-ml-1 text-muted-foreground hover:text-foreground" />
      <div className="w-full flex-1">
        <form>
          <div className="relative">
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder="Search..."
              className="w-full appearance-none bg-background pl-8 shadow-none md:w-2/3 lg:w-1/3"
            />
          </div>
        </form>
      </div>
      <div className="flex items-center gap-4">
        <Badge variant={isAdmin ? "default" : "secondary"} className={isAdmin ? "bg-primary" : ""}>
          {getRoleLabel(role)}
        </Badge>
        <Button variant="ghost" size="icon" className="relative text-muted-foreground hover:text-foreground">
          <Bell className="h-5 w-5" />
          <span className="absolute top-2 right-2 h-2 w-2 rounded-full bg-primary" />
          <span className="sr-only">Toggle notifications</span>
        </Button>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="rounded-full bg-muted border hover:bg-muted/80">
              <User className="h-5 w-5 text-muted-foreground" />
              <span className="sr-only">Toggle user menu</span>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel>
              <div className="flex flex-col">
                <span className="font-medium">{name}</span>
                <span className="text-xs font-normal text-muted-foreground">{email}</span>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            {/* Self-service account surface — available to all staff (spec
                permission matrix: both Moderator and Admin). */}
            <DropdownMenuItem
              onSelect={(e) => {
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
              onSelect={(e) => {
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
