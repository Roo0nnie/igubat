import { useState } from "react"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import {
	DiscoverGubatPhotoFields,
	type DiscoverGubatPhotoDraft,
} from "@/features/admin-discover-gubat/components/discover-gubat-photo-fields"

describe("DiscoverGubatPhotoFields", () => {
	it("adds, edits, and removes multiple photo rows", async () => {
		const user = userEvent.setup()
		const onChange = vi.fn()

		function Harness() {
			const [photos, setPhotos] = useState<DiscoverGubatPhotoDraft[]>([
				{
					id: "photo-1",
					imageUrl: "https://files.gubat.gov.ph/buenavista-1.jpg",
					altText: "Beach shoreline",
				},
			])

			return (
				<DiscoverGubatPhotoFields
					photos={photos}
					disabled={false}
					onChange={nextPhotos => {
						onChange(nextPhotos)
						setPhotos(nextPhotos)
					}}
				/>
			)
		}

		render(<Harness />)

		await user.click(screen.getByRole("button", { name: /add photo/i }))
		expect(onChange).toHaveBeenLastCalledWith([
			{
				id: "photo-1",
				imageUrl: "https://files.gubat.gov.ph/buenavista-1.jpg",
				altText: "Beach shoreline",
			},
			expect.objectContaining({ imageUrl: "", altText: "" }),
		])

		await user.clear(screen.getByLabelText("Photo 1 URL"))
		await user.type(screen.getByLabelText("Photo 1 URL"), "https://files.gubat.gov.ph/updated.jpg")
		expect(onChange).toHaveBeenLastCalledWith([
			{
				id: "photo-1",
				imageUrl: "https://files.gubat.gov.ph/updated.jpg",
				altText: "Beach shoreline",
			},
			expect.objectContaining({ imageUrl: "", altText: "" }),
		])

		await user.click(screen.getByRole("button", { name: /remove photo 1/i }))
		expect(onChange).toHaveBeenLastCalledWith([
			expect.objectContaining({ imageUrl: "", altText: "" }),
		])
	})
})
