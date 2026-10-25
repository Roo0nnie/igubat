"use client"

import { useEffect, useRef } from "react"
import { usePathname, useRouter, useSearchParams } from "next/navigation"
import { Search } from "lucide-react"

import { Input } from "@/core/components/ui/input"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/core/components/ui/select"
import {
	TRANSPARENCY_STATUSES,
	TRANSPARENCY_TYPES,
	type TransparencyStatus,
	type TransparencyType,
} from "@/features/admin-transparency/lib/transparency-types"

function statusLabel(status: TransparencyStatus) {
	return status.charAt(0).toUpperCase() + status.slice(1)
}

export function TransparencyFiltersBar() {
	const router = useRouter()
	const pathname = usePathname()
	const searchParams = useSearchParams()

	const rawType = searchParams.get("type")
	const rawStatus = searchParams.get("status")
	const type =
		rawType && TRANSPARENCY_TYPES.some(option => option.value === rawType) ? rawType : "all"
	const status =
		rawStatus && TRANSPARENCY_STATUSES.includes(rawStatus as TransparencyStatus) ? rawStatus : "all"
	const fiscalYear = searchParams.get("fiscalYear") ?? ""
	const search = searchParams.get("search") ?? ""
	const searchInputRef = useRef<HTMLInputElement>(null)
	const searchTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null)

	useEffect(
		() => () => {
			if (searchTimerRef.current) clearTimeout(searchTimerRef.current)
		},
		[]
	)

	function setParam(name: string, value: string) {
		if (searchTimerRef.current) clearTimeout(searchTimerRef.current)
		searchTimerRef.current = null
		const next = new URLSearchParams(searchParams.toString())
		if (name !== "search") {
			const draftSearch = searchInputRef.current?.value.trim() ?? ""
			if (draftSearch) next.set("search", draftSearch)
			else next.delete("search")
		}
		const normalized = value.trim()

		if (!normalized || normalized === "all") {
			next.delete(name)
		} else {
			next.set(name, normalized)
		}

		next.delete("cursor")
		const query = next.toString()
		router.replace(query ? `${pathname}?${query}` : pathname, { scroll: false })
	}

	return (
		<div className="grid gap-2 md:grid-cols-[minmax(160px,200px)_minmax(140px,170px)_minmax(120px,150px)_minmax(220px,1fr)]">
			<Select value={type} onValueChange={value => setParam("type", value ?? "all")}>
				<SelectTrigger className="w-full" aria-label="Transparency type">
					<SelectValue />
				</SelectTrigger>
				<SelectContent>
					<SelectItem value="all">All types</SelectItem>
					{TRANSPARENCY_TYPES.map(option => (
						<SelectItem key={option.value} value={option.value}>
							{option.label}
						</SelectItem>
					))}
				</SelectContent>
			</Select>

			<Select value={status} onValueChange={value => setParam("status", value ?? "all")}>
				<SelectTrigger className="w-full" aria-label="Publication status">
					<SelectValue />
				</SelectTrigger>
				<SelectContent>
					<SelectItem value="all">All statuses</SelectItem>
					{TRANSPARENCY_STATUSES.map(option => (
						<SelectItem key={option} value={option}>
							{statusLabel(option)}
						</SelectItem>
					))}
				</SelectContent>
			</Select>

			<Input
				aria-label="Fiscal year"
				inputMode="numeric"
				maxLength={4}
				placeholder="Fiscal year"
				value={fiscalYear}
				onChange={event => setParam("fiscalYear", event.target.value.replace(/\D/g, ""))}
			/>

			<div className="relative">
				<Search className="text-muted-foreground pointer-events-none absolute top-2 left-2.5 size-4" />
				<Input
					aria-label="Search transparency items"
					className="pl-8"
					placeholder="Search title or ref. number"
					key={search}
					defaultValue={search}
					ref={searchInputRef}
					onChange={event => {
						if (searchTimerRef.current) clearTimeout(searchTimerRef.current)
						const value = event.target.value
						searchTimerRef.current = setTimeout(() => setParam("search", value), 250)
					}}
				/>
			</div>
		</div>
	)
}

export function parseTransparencyFilters(searchParams: URLSearchParams): NonNullable<{
	type?: TransparencyType
	status?: TransparencyStatus
	fiscalYear?: number
	search?: string
}> {
	const type = searchParams.get("type")
	const status = searchParams.get("status")
	const fiscalYear = searchParams.get("fiscalYear")
	const search = searchParams.get("search")?.trim()
	const parsedFiscalYear = fiscalYear ? Number(fiscalYear) : undefined

	return {
		type: TRANSPARENCY_TYPES.some(option => option.value === type)
			? (type as TransparencyType)
			: undefined,
		status: TRANSPARENCY_STATUSES.includes(status as TransparencyStatus)
			? (status as TransparencyStatus)
			: undefined,
		fiscalYear: Number.isInteger(parsedFiscalYear) ? parsedFiscalYear : undefined,
		search: search || undefined,
	}
}
