import React from "react"

import { cn } from "@/core/lib/utils"

interface IgubatLogoProps extends React.SVGProps<SVGSVGElement> {
	darkText?: boolean
}

export function IgubatLogo({ className, darkText = false, ...props }: IgubatLogoProps) {
	return (
		<div className={cn("flex items-center gap-3", className)}>
			{/* The "iG" Icon */}
			<div className="relative flex items-baseline overflow-hidden rounded-lg bg-white px-3 py-1.5 shadow-sm">
				<span className="relative z-10 text-2xl font-bold tracking-tighter text-[#7DB343]">i</span>
				<span className="text-igubat-primary relative z-10 -ml-1 text-4xl leading-none font-black tracking-tighter">
					G
				</span>
				{/* Simple circuit line / wave decorative element */}
				<svg
					className="text-igubat-primary absolute bottom-0 left-0 h-1/3 w-full opacity-20"
					viewBox="0 0 100 20"
					preserveAspectRatio="none"
				>
					<path d="M0,10 Q25,20 50,10 T100,10" fill="none" stroke="currentColor" strokeWidth="2" />
				</svg>
			</div>
			{/* The "iGubat 4710" Text */}
			<div className="flex flex-col justify-center">
				<span
					className={cn(
						"text-2xl leading-none font-bold tracking-tight",
						darkText ? "text-igubat-primary" : "text-white"
					)}
				>
					iGubat
				</span>
				<span
					className={cn(
						"text-sm font-semibold tracking-[0.1em]",
						darkText ? "text-igubat-accent" : "text-white/80"
					)}
				>
					4710
				</span>
			</div>
		</div>
	)
}
