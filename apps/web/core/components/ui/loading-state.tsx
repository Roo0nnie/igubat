"use client"

import { useEffect, useState } from "react"
import { CloudOff, Inbox, RefreshCw, WifiOff } from "lucide-react"

import { Button } from "@/core/components/ui/button"
import { IgubatLogo } from "@/core/components/ui/igubat-logo"
import { Skeleton } from "@/core/components/ui/skeleton"
import { TableCell, TableRow } from "@/core/components/ui/table"
import { cn } from "@/core/lib/utils"

export const SLOW_LOADING_MS = 8000

/** True once `isLoading` has stayed on for `delay` ms; changing `resetKey` restarts the wait. */
export function useSlowLoading(isLoading: boolean, delay = SLOW_LOADING_MS, resetKey: unknown = 0) {
	const [slow, setSlow] = useState(false)

	useEffect(() => {
		if (!isLoading) return
		const timer = setTimeout(() => setSlow(true), delay)
		return () => {
			clearTimeout(timer)
			setSlow(false)
		}
	}, [isLoading, delay, resetKey])

	return isLoading && slow
}

type LoadingStatusProps = {
	message?: string
	onRetry?: () => void
	className?: string
}

/** Caption announced to screen readers; turns into a connection hint when loading drags on. */
export function LoadingStatus({ message = "Loading...", onRetry, className }: LoadingStatusProps) {
	const [attempt, setAttempt] = useState(0)
	const slow = useSlowLoading(true, SLOW_LOADING_MS, attempt)
	const retry = onRetry
		? () => {
				setAttempt(value => value + 1)
				onRetry()
			}
		: undefined

	return (
		<div role="status" aria-live="polite" className={cn("text-sm", className)}>
			{slow ? (
				<div className="flex flex-wrap items-center justify-center gap-x-3 gap-y-2 rounded-lg border border-amber-300/60 bg-amber-50 px-3 py-2 text-amber-900 dark:border-amber-500/30 dark:bg-amber-500/10 dark:text-amber-200">
					<WifiOff className="size-4 shrink-0" aria-hidden="true" />
					<span>Still loading. Please check your internet connection.</span>
					{retry && (
						<Button size="sm" variant="outline" onClick={retry}>
							<RefreshCw className="size-3.5" aria-hidden="true" /> Retry
						</Button>
					)}
				</div>
			) : (
				<div className="text-muted-foreground flex items-center justify-center gap-2">
					<span className="relative flex size-2" aria-hidden="true">
						<span className="bg-primary/60 absolute inline-flex size-full rounded-full motion-safe:animate-ping" />
						<span className="bg-primary relative inline-flex size-2 rounded-full" />
					</span>
					<span>{message}</span>
				</div>
			)}
		</div>
	)
}

type TableStateRowsProps = {
	colSpan: number
	isLoading: boolean
	isError: boolean
	isEmpty: boolean
	onRetry?: () => void
	loadingText?: string
	errorText?: string
	emptyText?: string
	emptyHint?: string
	rows?: number
	/** Set false when a page-level `LoadingStatus` already describes the wait. */
	showStatus?: boolean
}

/** Loading / error / empty rows for a `<TableBody>`. Renders nothing once data is ready. */
export function TableStateRows({
	colSpan,
	isLoading,
	isError,
	isEmpty,
	onRetry,
	loadingText = "Loading records...",
	errorText = "We couldn't load these records.",
	emptyText = "No records found.",
	emptyHint,
	rows = 5,
	showStatus = true,
}: TableStateRowsProps) {
	if (isLoading) {
		return (
			<>
				{showStatus && (
					<TableRow className="hover:bg-transparent">
						<TableCell colSpan={colSpan} className="py-3">
							<LoadingStatus message={loadingText} onRetry={onRetry} />
						</TableCell>
					</TableRow>
				)}
				{Array.from({ length: rows }).map((_, rowIndex) => (
					<TableRow key={rowIndex} className="hover:bg-transparent" aria-hidden="true">
						{Array.from({ length: colSpan }).map((__, cellIndex) => (
							<TableCell key={cellIndex}>
								<Skeleton
									className={cn(
										"h-4",
										cellIndex === 0
											? "w-24"
											: cellIndex === colSpan - 1
												? "ml-auto w-14"
												: "w-full max-w-40"
									)}
								/>
							</TableCell>
						))}
					</TableRow>
				))}
			</>
		)
	}

	if (isError) {
		return (
			<TableRow className="hover:bg-transparent">
				<TableCell colSpan={colSpan}>
					<ErrorState title={errorText} onRetry={onRetry} compact />
				</TableCell>
			</TableRow>
		)
	}

	if (isEmpty) {
		return (
			<TableRow className="hover:bg-transparent">
				<TableCell colSpan={colSpan}>
					<EmptyState title={emptyText} description={emptyHint} compact />
				</TableCell>
			</TableRow>
		)
	}

	return null
}

type StateBlockProps = {
	title: string
	description?: string
	compact?: boolean
	className?: string
}

export function ErrorState({
	title = "Something went wrong",
	description = "Please check your connection and try again.",
	onRetry,
	compact,
	className,
}: Partial<StateBlockProps> & { onRetry?: () => void }) {
	return (
		<div
			role="alert"
			className={cn(
				"flex flex-col items-center justify-center gap-3 text-center",
				compact ? "py-6" : "py-12",
				className
			)}
		>
			<div className="bg-destructive/10 text-destructive flex size-11 items-center justify-center rounded-full">
				<CloudOff className="size-5" aria-hidden="true" />
			</div>
			<div className="space-y-1">
				<p className="text-foreground text-sm font-semibold">{title}</p>
				<p className="text-muted-foreground max-w-sm text-sm">{description}</p>
			</div>
			{onRetry && (
				<Button size="sm" variant="outline" onClick={onRetry}>
					<RefreshCw className="size-3.5" aria-hidden="true" /> Try again
				</Button>
			)}
		</div>
	)
}

export function EmptyState({
	title,
	description,
	icon: Icon = Inbox,
	action,
	compact,
	className,
}: StateBlockProps & {
	icon?: React.ComponentType<{ className?: string }>
	action?: React.ReactNode
}) {
	return (
		<div
			className={cn(
				"flex flex-col items-center justify-center gap-3 text-center",
				compact ? "py-6" : "py-12",
				className
			)}
		>
			<div className="bg-primary/10 text-primary flex size-11 items-center justify-center rounded-full">
				<Icon className="size-5" aria-hidden="true" />
			</div>
			<div className="space-y-1">
				<p className="text-foreground text-sm font-semibold">{title}</p>
				{description && <p className="text-muted-foreground max-w-sm text-sm">{description}</p>}
			</div>
			{action}
		</div>
	)
}

export function StatCardsSkeleton({
	count = 4,
	className,
}: {
	count?: number
	className?: string
}) {
	return (
		<div className={cn("grid gap-4 sm:grid-cols-2 lg:grid-cols-4", className)} aria-hidden="true">
			{Array.from({ length: count }).map((_, index) => (
				<div key={index} className="bg-card space-y-3 rounded-xl border p-5">
					<div className="flex items-center justify-between">
						<Skeleton className="h-4 w-24" />
						<Skeleton className="size-8 rounded-lg" />
					</div>
					<Skeleton className="h-7 w-16" />
					<Skeleton className="h-3 w-32" />
				</div>
			))}
		</div>
	)
}

export function CardGridSkeleton({ count = 6, className }: { count?: number; className?: string }) {
	return (
		<div className={cn("grid gap-4 sm:grid-cols-2 lg:grid-cols-3", className)} aria-hidden="true">
			{Array.from({ length: count }).map((_, index) => (
				<div key={index} className="bg-card overflow-hidden rounded-xl border">
					<Skeleton className="h-40 w-full rounded-none" />
					<div className="space-y-2 p-4">
						<Skeleton className="h-3 w-20" />
						<Skeleton className="h-5 w-3/4" />
						<Skeleton className="h-3 w-full" />
						<Skeleton className="h-3 w-2/3" />
					</div>
				</div>
			))}
		</div>
	)
}

export function ListSkeleton({ count = 4, className }: { count?: number; className?: string }) {
	return (
		<div className={cn("space-y-3", className)} aria-hidden="true">
			{Array.from({ length: count }).map((_, index) => (
				<div key={index} className="flex items-center gap-3 rounded-lg border p-3">
					<Skeleton className="size-10 shrink-0 rounded-full" />
					<div className="flex-1 space-y-2">
						<Skeleton className="h-4 w-1/3" />
						<Skeleton className="h-3 w-1/2" />
					</div>
				</div>
			))}
		</div>
	)
}

export function DetailPageSkeleton({
	showHero = false,
	className,
}: {
	showHero?: boolean
	className?: string
}) {
	return (
		<div className={cn("space-y-6", className)} aria-hidden="true">
			<div className="space-y-3">
				<Skeleton className="h-4 w-28" />
				<Skeleton className="h-8 w-2/3" />
				<Skeleton className="h-4 w-1/3" />
			</div>
			{showHero && <Skeleton className="aspect-16/7 w-full rounded-xl" />}
			<div className="grid gap-6 lg:grid-cols-3">
				<div className="bg-card space-y-3 rounded-xl border p-6 lg:col-span-2">
					{Array.from({ length: 7 }).map((_, index) => (
						<Skeleton key={index} className={cn("h-4", index === 6 ? "w-1/2" : "w-full")} />
					))}
				</div>
				<div className="bg-card space-y-4 rounded-xl border p-6">
					{Array.from({ length: 4 }).map((_, index) => (
						<div key={index} className="space-y-2">
							<Skeleton className="h-3 w-20" />
							<Skeleton className="h-4 w-32" />
						</div>
					))}
				</div>
			</div>
		</div>
	)
}

export function FormSkeleton({ fields = 4, className }: { fields?: number; className?: string }) {
	return (
		<div className={cn("space-y-5", className)} aria-hidden="true">
			{Array.from({ length: fields }).map((_, index) => (
				<div key={index} className="space-y-2">
					<Skeleton className="h-4 w-28" />
					<Skeleton className="h-9 w-full" />
				</div>
			))}
			<Skeleton className="h-9 w-32" />
		</div>
	)
}

export function PageSkeleton({
	message,
	children,
	className,
}: {
	message: string
	children: React.ReactNode
	className?: string
}) {
	return (
		<div className={cn("mx-auto max-w-7xl space-y-6 p-6 md:p-8", className)}>
			<div className="space-y-2" aria-hidden="true">
				<Skeleton className="h-8 w-64" />
				<Skeleton className="h-4 w-96 max-w-full" />
			</div>
			<LoadingStatus message={message} className="[&>div]:justify-start" />
			{children}
		</div>
	)
}

/** Full-page branded wait used for route transitions and session bootstrap. */
export function BrandedPageLoader({
	message = "Getting things ready...",
	className,
}: {
	message?: string
	className?: string
}) {
	return (
		<div
			role="status"
			aria-live="polite"
			className={cn(
				"flex min-h-[60vh] w-full flex-col items-center justify-center gap-6 p-6",
				className
			)}
		>
			<div className="motion-safe:animate-[igubat-breathe_1.6s_ease-in-out_infinite]">
				<IgubatLogo />
			</div>
			<div
				className="bg-primary/15 relative h-1 w-40 overflow-hidden rounded-full motion-reduce:hidden"
				aria-hidden="true"
			>
				<div className="bg-primary absolute inset-y-0 left-0 w-1/3 rounded-full motion-safe:animate-[igubat-progress_1.2s_ease-in-out_infinite]" />
			</div>
			<p className="text-muted-foreground text-sm font-medium">{message}</p>
		</div>
	)
}
