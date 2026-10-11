import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { render, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import SubmitTicketPage from "./page"

const submitTicket = vi.fn()

vi.mock("@/services/orpc/client", () => ({
	orpc: {
		ticket: {
			submit: {
				mutationOptions: (options?: unknown) => ({
					mutationFn: submitTicket,
					...(typeof options === "object" && options ? options : {}),
				}),
			},
		},
	},
}))

describe("SubmitTicketPage", () => {
	it("submits support tickets through the backend contract", async () => {
		const user = userEvent.setup()
		const queryClient = new QueryClient()
		submitTicket.mockResolvedValueOnce({ id: 101 })

		render(
			<QueryClientProvider client={queryClient}>
				<SubmitTicketPage />
			</QueryClientProvider>
		)

		await user.type(screen.getByLabelText("Name"), "Jane Doe")
		await user.type(screen.getByLabelText("Email"), "jane@example.com")
		await user.type(screen.getByLabelText("Subject"), "Road concern")
		await user.selectOptions(screen.getByLabelText("Priority"), "high")
		await user.type(screen.getByLabelText("Concern"), "Street light is out.")
		await user.click(screen.getByRole("button", { name: "Submit Ticket" }))

		await waitFor(() =>
			expect(submitTicket).toHaveBeenCalledWith(
				{
					name: "Jane Doe",
					email: "jane@example.com",
					subject: "Road concern",
					priority: "high",
					concern: "Street light is out.",
				},
				expect.anything()
			)
		)
		expect(await screen.findByText("Ticket submitted and saved.")).toBeInTheDocument()
	})
})
