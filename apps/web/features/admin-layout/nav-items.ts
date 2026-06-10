import {
	AlertTriangle,
	BarChart3,
	Bell,
	FileText,
	HelpCircle,
	Home,
	Newspaper,
	ScrollText,
	Settings,
	ShieldCheck,
	Siren,
	UserCog,
	Users,
	type LucideIcon,
} from "lucide-react"

import type { RequiredAccess } from "@/core/lib/roles"

export type NavItem = {
	title: string
	url: string
	icon: LucideIcon
	/** Minimum access level required to see and open this surface. */
	access: RequiredAccess
}

export type NavGroup = {
	label: string
	items: NavItem[]
}

/**
 * Portal navigation, grouped to match the Web Administration Portal Workflow
 * (`igubat_admin_portal.md`). Each item declares the access level the spec's
 * permission matrix (Section 8) requires. Admin-only items are hidden from
 * Moderators and refused on direct URL access (403) by the route guards.
 */
export const NAV_GROUPS: NavGroup[] = [
	{
		label: "Operations",
		items: [
			{ title: "Dashboard", url: "/dashboard", icon: Home, access: "staff" },
			{ title: "Service Requests", url: "/requests", icon: FileText, access: "staff" },
			{ title: "Issue Reports", url: "/reports", icon: AlertTriangle, access: "staff" },
		],
	},
	{
		label: "Content & Emergency",
		items: [
			{ title: "Content", url: "/content", icon: Newspaper, access: "staff" },
			{ title: "Emergency", url: "/emergency", icon: Siren, access: "staff" },
			{ title: "Transparency", url: "/transparency", icon: ShieldCheck, access: "staff" },
			{ title: "Notifications", url: "/notifications", icon: Bell, access: "staff" },
		],
	},
	{
		label: "Administration",
		items: [
			{ title: "User Management", url: "/citizens", icon: Users, access: "admin" },
			{ title: "Staff Management", url: "/staff", icon: UserCog, access: "admin" },
			{ title: "Analytics", url: "/analytics", icon: BarChart3, access: "admin" },
			{ title: "Audit Log", url: "/audit-logs", icon: ScrollText, access: "admin" },
			{ title: "Settings", url: "/settings", icon: Settings, access: "admin" },
		],
	},
	{
		label: "Support",
		items: [
			{ title: "Help & Support", url: "/help-support", icon: HelpCircle, access: "staff" },
			{ title: "Privacy Policy", url: "/privacy-policy", icon: ShieldCheck, access: "staff" },
			{ title: "Terms of Use", url: "/terms-of-use", icon: ScrollText, access: "staff" },
		],
	},
]
