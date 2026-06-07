import Link from "next/link"
import { redirect } from "next/navigation"

import { IgubatLogo } from "@/core/components/ui/igubat-logo"
import { getSession } from "@/services/better-auth/auth-server"

export default async function SiteLayout({
	children,
}: Readonly<{
	children: React.ReactNode
}>) {
	const session = await getSession()

	if (!session) {
		redirect("/login")
	}

	return (
		<div className="flex h-screen w-full overflow-hidden bg-[#F9FAFB]">
			{/* Sidebar (Deep Green) */}
			<aside className="bg-igubat-primary relative z-20 flex w-[280px] flex-col text-white shadow-xl">
				{/* Brand Header */}
				<div className="flex h-[88px] shrink-0 items-center border-b border-white/10 px-6">
					<IgubatLogo className="origin-left scale-90" />
				</div>

				{/* Nav Links */}
				<nav className="scrollbar-none flex-1 space-y-1.5 overflow-y-auto px-4 py-6">
					<Link
						href="/dashboard"
						className="flex items-center gap-3 rounded-lg border border-white/5 bg-white/10 px-3 py-2.5 text-sm font-medium text-white transition-colors"
					>
						<svg
							className="text-igubat-accent size-5"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							strokeWidth="2"
							strokeLinecap="round"
							strokeLinejoin="round"
						>
							<path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
							<polyline points="9 22 9 12 15 12 15 22" />
						</svg>
						Dashboard
					</Link>
					<Link
						href="/submit-ticket"
						className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-white/70 transition-colors hover:bg-white/5 hover:text-white"
					>
						<svg
							className="size-5"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							strokeWidth="2"
							strokeLinecap="round"
							strokeLinejoin="round"
						>
							<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
							<polyline points="14 2 14 8 20 8" />
							<line x1="16" y1="13" x2="8" y2="13" />
							<line x1="16" y1="17" x2="8" y2="17" />
							<polyline points="10 9 9 9 8 9" />
						</svg>
						Service Requests
					</Link>
					<Link
						href="#"
						className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-white/70 transition-colors hover:bg-white/5 hover:text-white"
					>
						<svg
							className="size-5"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							strokeWidth="2"
							strokeLinecap="round"
							strokeLinejoin="round"
						>
							<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
						</svg>
						Citizen Reports
					</Link>
					<Link
						href="#"
						className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-white/70 transition-colors hover:bg-white/5 hover:text-white"
					>
						<svg
							className="size-5"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							strokeWidth="2"
							strokeLinecap="round"
							strokeLinejoin="round"
						>
							<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
							<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
						</svg>
						News & Content
					</Link>
				</nav>

				{/* User Profile (Glassmorphism) */}
				<div className="border-t border-white/10 bg-black/10 p-4 backdrop-blur-md">
					<div className="flex items-center gap-3">
						<div className="bg-igubat-accent/20 border-igubat-accent flex size-10 items-center justify-center rounded-full border font-semibold">
							{session.user?.name?.charAt(0) || "U"}
						</div>
						<div className="min-w-0 flex-1">
							<div className="truncate text-sm font-medium">{session.user?.name}</div>
							<div className="truncate text-xs text-white/60">{session.user?.email}</div>
						</div>
					</div>
				</div>
			</aside>

			{/* Main Content Area */}
			<div className="flex h-full flex-1 flex-col overflow-hidden bg-[#F9FAFB]">
				{/* Top Header */}
				<header className="z-10 flex h-[72px] shrink-0 items-center justify-between border-b border-slate-200 bg-white/70 px-8 shadow-[0_1px_3px_0_rgba(0,0,0,0.02)] backdrop-blur-xl">
					<div className="flex items-center gap-4">
						<h1 className="text-xl font-bold text-slate-800">Command Center</h1>
					</div>
					<div className="flex items-center gap-4">
						<div className="flex size-10 cursor-pointer items-center justify-center rounded-full border border-slate-200 bg-white shadow-sm transition-colors hover:bg-slate-50">
							<svg
								className="size-5 text-slate-600"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								strokeWidth="2"
								strokeLinecap="round"
								strokeLinejoin="round"
							>
								<path d="M12 22a2 2 0 0 0 2-2H10a2 2 0 0 0 2 2z" />
								<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9z" />
							</svg>
						</div>
						<div className="flex size-10 cursor-pointer items-center justify-center rounded-full border border-slate-200 bg-white shadow-sm transition-colors hover:bg-slate-50">
							<svg
								className="size-5 text-slate-600"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								strokeWidth="2"
								strokeLinecap="round"
								strokeLinejoin="round"
							>
								<circle cx="12" cy="12" r="3" />
								<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" />
							</svg>
						</div>
					</div>
				</header>

				<main className="relative flex-1 overflow-auto p-8">{children}</main>
			</div>
		</div>
	)
}
