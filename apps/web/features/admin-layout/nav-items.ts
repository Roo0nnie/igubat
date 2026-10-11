import {
	BarChart3,
	BellRing,
	BookOpenText,
	ClipboardList,
	HelpCircle,
	History,
	LayoutDashboard,
	LockKeyhole,
	Newspaper,
	Scale,
	Settings,
	Siren,
	TriangleAlert,
	UserCog,
	Users,
	type LucideIcon,
} from "lucide-react"

import type { RequiredAccess } from "@/core/lib/roles"

/** Admin dashboard counters that can be surfaced as a nav item badge. */
export type NavBadgeKey = "pendingRequests" | "newReports"

export type NavItem = {
	title: string
	url: string
	icon: LucideIcon
	/** Minimum access level required to see and open this surface. */
	access: RequiredAccess
	badge?: { key: NavBadgeKey; label: string }
}

export type NavGroup = {
	label: string
	items: NavItem[]
	/** Pin the group to the bottom of the sidebar, below the main navigation. */
	pinBottom?: boolean
}

/**
 * Portal navigation, grouped to match the Web Administration Portal Workflow
 * (`igubat_admin_portal.md`). Each item declares the access level the spec's
 * permission matrix (Section 8) requires. Admin-only items are hidden from
 * Moderators and refused on direct URL access (403) by the route guards.
 *
 * Every icon must be unique: when the sidebar collapses to an icon rail the
 * icon is the only thing identifying the destination.
 */
export const NAV_GROUPS: NavGroup[] = [
	{
		label: "Operations",
		items: [
			{ title: "Dashboard", url: "/dashboard", icon: LayoutDashboard, access: "staff" },
			{
				title: "Service Requests",
				url: "/requests",
				icon: ClipboardList,
				access: "staff",
				badge: { key: "pendingRequests", label: "pending" },
			},
			{
				title: "Issue Reports",
				url: "/reports",
				icon: TriangleAlert,
				access: "staff",
				badge: { key: "newReports", label: "new" },
			},
		],
	},
	{
		label: "Content & Emergency",
		items: [
			{ title: "Content", url: "/content", icon: Newspaper, access: "staff" },
			{ title: "Emergency", url: "/emergency", icon: Siren, access: "staff" },
			{ title: "Transparency", url: "/transparency", icon: Scale, access: "staff" },
			{ title: "Notifications", url: "/notifications", icon: BellRing, access: "staff" },
		],
	},
	{
		label: "Administration",
		items: [
			{ title: "User Management", url: "/citizens", icon: Users, access: "admin" },
			{ title: "Staff Management", url: "/staff", icon: UserCog, access: "admin" },
			{ title: "Analytics", url: "/analytics", icon: BarChart3, access: "admin" },
			{ title: "Audit Log", url: "/audit-logs", icon: History, access: "admin" },
			{ title: "Settings", url: "/settings", icon: Settings, access: "admin" },
		],
	},
	{
		label: "Support",
		pinBottom: true,
		items: [
			{ title: "Help & Support", url: "/help-support", icon: HelpCircle, access: "staff" },
			{ title: "Privacy Policy", url: "/privacy-policy", icon: LockKeyhole, access: "staff" },
			{ title: "Terms of Use", url: "/terms-of-use", icon: BookOpenText, access: "staff" },
		],
	},
]
