"use client"

import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/core/components/ui/select"
import type { TransparencyType } from "@/features/admin-transparency/lib/transparency-types"

type Field =
	| { key: string; label: string; kind: "text" | "number" | "date" }
	| { key: string; label: string; kind: "select"; options: { value: string; label: string }[] }

const FIELDS_BY_TYPE: Record<TransparencyType, Field[]> = {
	program_project: [
		{
			key: "projectStatus",
			label: "Project Status",
			kind: "select",
			options: [
				{ value: "planned", label: "Planned" },
				{ value: "ongoing", label: "Ongoing" },
				{ value: "completed", label: "Completed" },
				{ value: "suspended", label: "Suspended" },
			],
		},
		{ key: "startDate", label: "Start Date", kind: "date" },
		{ key: "endDate", label: "End Date", kind: "date" },
		{ key: "costPhp", label: "Cost (PHP)", kind: "number" },
		{ key: "implementingOffice", label: "Implementing Office", kind: "text" },
		{ key: "beneficiaries", label: "Beneficiaries", kind: "text" },
		{ key: "locationAddress", label: "Location Address", kind: "text" },
	],
	bid_procurement: [
		{ key: "approvedBudgetForContractPhp", label: "ABC (PHP)", kind: "number" },
		{
			key: "procurementMode",
			label: "Procurement Mode",
			kind: "select",
			options: [
				{ value: "public_bidding", label: "Public Bidding" },
				{ value: "small_value", label: "Small Value" },
				{ value: "shopping", label: "Shopping" },
				{ value: "negotiated", label: "Negotiated" },
			],
		},
		{ key: "closingDate", label: "Closing Date", kind: "date" },
		{
			key: "bidStatus",
			label: "Bid Status",
			kind: "select",
			options: [
				{ value: "posted", label: "Posted" },
				{ value: "pre_bid", label: "Pre-Bid" },
				{ value: "open", label: "Open" },
				{ value: "awarded", label: "Awarded" },
				{ value: "cancelled", label: "Cancelled" },
			],
		},
		{ key: "awardedTo", label: "Awarded To", kind: "text" },
		{ key: "awardedAmountPhp", label: "Awarded Amount (PHP)", kind: "number" },
	],
	financial_report: [
		{
			key: "reportType",
			label: "Report Type",
			kind: "select",
			options: [
				{ value: "saob", label: "SAOB" },
				{ value: "sre", label: "SRE" },
				{ value: "coa_annual", label: "COA Annual" },
				{ value: "quarterly_financial_statement", label: "Quarterly Financial Statement" },
				{ value: "other", label: "Other" },
			],
		},
		{ key: "fiscalPeriod", label: "Fiscal Period (e.g. Q1 2026)", kind: "text" },
		{ key: "preparedBy", label: "Prepared By", kind: "text" },
	],
	annual_budget: [
		{
			key: "budgetType",
			label: "Budget Type",
			kind: "select",
			options: [
				{ value: "annual", label: "Annual" },
				{ value: "supplemental", label: "Supplemental" },
				{ value: "executive_budget", label: "Executive Budget" },
			],
		},
		{ key: "totalAmountPhp", label: "Total Amount (PHP)", kind: "number" },
		{ key: "endorsedBy", label: "Endorsed By", kind: "text" },
	],
	legislative_ordinance: [
		{ key: "dateApproved", label: "Date Approved", kind: "date" },
		{ key: "principalAuthor", label: "Principal Author", kind: "text" },
		{ key: "sponsors", label: "Sponsors", kind: "text" },
		{ key: "sbSessionDate", label: "SB Session Date", kind: "date" },
	],
	executive_order: [
		{ key: "dateIssued", label: "Date Issued", kind: "date" },
		{ key: "issuedBy", label: "Issued By", kind: "text" },
		{ key: "revokes", label: "Revokes (EO refs)", kind: "text" },
	],
}

export function TransparencyTypeFields({
	type,
	values,
	onChange,
}: {
	type: TransparencyType
	values: Record<string, string>
	onChange: (key: string, value: string) => void
}) {
	const fields = FIELDS_BY_TYPE[type]
	return (
		<fieldset className="space-y-3 rounded-md border p-3">
			<legend className="text-primary px-1 text-xs font-semibold uppercase">
				Type-Specific Fields
			</legend>
			<div className="grid gap-3 md:grid-cols-2">
				{fields.map(field => (
					<div key={field.key} className="space-y-1">
						<Label htmlFor={`meta-${field.key}`} className="text-xs">
							{field.label}
						</Label>
						{field.kind === "select" ? (
							<Select
								value={values[field.key] ?? ""}
								onValueChange={value => onChange(field.key, value ?? "")}
							>
								<SelectTrigger id={`meta-${field.key}`} className="w-full">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{field.options.map(option => (
										<SelectItem key={option.value} value={option.value}>
											{option.label}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						) : (
							<Input
								id={`meta-${field.key}`}
								type={field.kind === "number" ? "number" : field.kind === "date" ? "date" : "text"}
								value={values[field.key] ?? ""}
								onChange={event => onChange(field.key, event.target.value)}
							/>
						)}
					</div>
				))}
			</div>
		</fieldset>
	)
}
