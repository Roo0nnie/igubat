import type { V1Inputs, V1Outputs } from "@/services/orpc/contract-types"

export type DiscoverGubatListInput = V1Inputs["igubat"]["admin"]["discoverGubat"]["list"]

type ContractDiscoverGubatListRow = V1Outputs["igubat"]["admin"]["discoverGubat"]["list"][number]

type ClientDate = string | Date

export type DiscoverGubatListRow = Omit<
	ContractDiscoverGubatListRow,
	"eventDate" | "scheduledAt" | "publishedAt" | "archivedAt" | "createdAt" | "updatedAt"
> & {
	eventDate: ClientDate | null
	scheduledAt: ClientDate | null
	publishedAt: ClientDate | null
	archivedAt: ClientDate | null
	createdAt: ClientDate
	updatedAt: ClientDate
}

export type DiscoverGubatType = V1Inputs["igubat"]["admin"]["discoverGubat"]["create"]["type"]

export type DiscoverGubatStatus = "draft" | "scheduled" | "published" | "archived"

export const DISCOVER_GUBAT_TYPES: { value: DiscoverGubatType; label: string }[] = [
	{ value: "tourist_spot", label: "Tourist Spot" },
	{ value: "festival_culture", label: "Festivals & Culture" },
	{ value: "local_product", label: "Local Delicacies & Products" },
]

export const DISCOVER_GUBAT_STATUSES: DiscoverGubatStatus[] = [
	"draft",
	"scheduled",
	"published",
	"archived",
]

export function discoverGubatTypeLabel(type: string): string {
	return DISCOVER_GUBAT_TYPES.find(item => item.value === type)?.label ?? type
}

export function discoverGubatStatusLabel(status: string): string {
	return status
		.split("_")
		.map(part => part.charAt(0).toUpperCase() + part.slice(1))
		.join(" ")
}

export function discoverGubatStatusBadgeVariant(
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
