import React from "react"
import { cn } from "@/core/lib/utils"

interface IgubatLogoProps extends React.SVGProps<SVGSVGElement> {
	darkText?: boolean
}

export function IgubatLogo({ className, darkText = false, ...props }: IgubatLogoProps) {
	return (
		<div className={cn("flex items-center gap-3", className)}>
			{/* The "iG" Icon */}
			<div className="bg-white rounded-lg shadow-sm px-3 py-1.5 flex items-baseline relative overflow-hidden">
				<span className="text-[#7DB343] font-bold text-2xl tracking-tighter relative z-10">i</span>
				<span className="text-igubat-primary font-black text-4xl tracking-tighter leading-none relative z-10 -ml-1">G</span>
				{/* Simple circuit line / wave decorative element */}
				<svg className="absolute bottom-0 left-0 w-full h-1/3 opacity-20 text-igubat-primary" viewBox="0 0 100 20" preserveAspectRatio="none">
					<path d="M0,10 Q25,20 50,10 T100,10" fill="none" stroke="currentColor" strokeWidth="2" />
				</svg>
			</div>
			{/* The "iGubat 4710" Text */}
			<div className="flex flex-col justify-center">
				<span className={cn("font-bold text-2xl leading-none tracking-tight", darkText ? "text-igubat-primary" : "text-white")}>
					iGubat
				</span>
				<span className={cn("font-semibold text-sm tracking-[0.1em]", darkText ? "text-igubat-accent" : "text-white/80")}>
					4710
				</span>
			</div>
		</div>
	)
}
