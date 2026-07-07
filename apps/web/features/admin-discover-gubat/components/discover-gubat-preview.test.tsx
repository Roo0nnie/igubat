import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { DiscoverGubatPreview } from "@/features/admin-discover-gubat/components/discover-gubat-preview"

describe("DiscoverGubatPreview", () => {
	it("renders citizen-facing content, metadata, and photos", () => {
		render(
			<DiscoverGubatPreview
				entry={{
					type: "tourist_spot",
					title: "Buenavista Beach",
					category: "Beach",
					summary: "Beginner-friendly surf and beach destination.",
					body: "Full guide body for citizen readers.",
					coverImageUrl: "https://files.gubat.gov.ph/buenavista-cover.jpg",
					mapLocation: "Buenavista, Gubat, Sorsogon",
					whereToBuy: "",
					eventDate: "",
					status: "draft",
					photos: [
						{
							id: "photo-1",
							imageUrl: "https://files.gubat.gov.ph/buenavista-surf.jpg",
							altText: "Buenavista surf break",
						},
					],
				}}
			/>
		)

		expect(screen.getByText("Citizen-view preview")).toBeInTheDocument()
		expect(screen.getByText("Buenavista Beach")).toBeInTheDocument()
		expect(screen.getByText("Tourist Spot")).toBeInTheDocument()
		expect(screen.getByText("Beach")).toBeInTheDocument()
		expect(screen.getByText("Full guide body for citizen readers.")).toBeInTheDocument()
		expect(screen.getByText("Map location")).toBeInTheDocument()
		expect(screen.getByText("Buenavista, Gubat, Sorsogon")).toBeInTheDocument()
		expect(screen.getByRole("img", { name: "Buenavista Beach" })).toHaveAttribute(
			"src",
			"https://files.gubat.gov.ph/buenavista-cover.jpg"
		)
		expect(screen.getByRole("img", { name: "Buenavista surf break" })).toHaveAttribute(
			"src",
			"https://files.gubat.gov.ph/buenavista-surf.jpg"
		)
	})
})
