import type { V1Inputs, V1Outputs } from "@/services/orpc/contract-types"

export type TransparencyListInput = V1Inputs["igubat"]["admin"]["transparency"]["list"]

type ContractTransparencyListRow = V1Outputs["igubat"]["admin"]["transparency"]["list"][number]

type ClientDate = string | Date

export type TransparencyListRow = Omit<
	ContractTransparencyListRow,
	"effectiveDate" | "scheduledAt" | "publishedAt" | "archivedAt" | "createdAt" | "updatedAt"
> & {
	effectiveDate: ClientDate | null
	scheduledAt: ClientDate | null
	publishedAt: ClientDate | null
	archivedAt: ClientDate | null
	createdAt: ClientDate
	updatedAt: ClientDate
}

export type TransparencyType = NonNullable<
	V1Inputs["igubat"]["admin"]["transparency"]["create"]
>["type"]

export type TransparencyStatus = "draft" | "scheduled" | "published" | "archived"

export const TRANSPARENCY_TYPES: { value: TransparencyType; label: string; routeSlug: string }[] = [
	{ value: "program_project", label: "Program and Projects", routeSlug: "program-projects" },
	{ value: "bid_procurement", label: "Bids and Projects", routeSlug: "bids-projects" },
	{ value: "financial_report", label: "Financial Reports", routeSlug: "financial-reports" },
	{ value: "annual_budget", label: "Annual Budget", routeSlug: "annual-budget" },
	{
		value: "legislative_ordinance",
		label: "Legislative Ordinances",
		routeSlug: "legislative-ordinances",
	},
	{ value: "executive_order", label: "Executive Orders", routeSlug: "executive-orders" },
]

export const TRANSPARENCY_STATUSES: TransparencyStatus[] = [
	"draft",
	"scheduled",
	"published",
	"archived",
]

export function transparencyTypeLabel(type: string): string {
	return TRANSPARENCY_TYPES.find(item => item.value === type)?.label ?? type
}

export function transparencyStatusBadgeVariant(
	status: string
): "default" | "secondary" | "outline" {
	switch (status) {
		case "published":
			return "default"
		case "archived":
			return "secondary"
		default:
			return "outline"
	}
}
