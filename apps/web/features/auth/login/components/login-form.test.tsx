import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { fireEvent, render, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { STAFF_ONLY_MESSAGE } from "../api/login.hooks"
import { LoginForm } from "./login-form"

const { push, signInEmail, signOut } = vi.hoisted(() => ({
	push: vi.fn(),
	signInEmail: vi.fn(),
	signOut: vi.fn(),
}))

vi.mock("next/navigation", () => ({
	useRouter: () => ({ push, replace: vi.fn(), refresh: vi.fn() }),
}))

vi.mock("next/image", () => ({
	// eslint-disable-next-line @next/next/no-img-element
	default: ({ alt }: { alt: string }) => <img alt={alt} />,
}))

vi.mock("@/services/better-auth/auth-client", () => ({
	authClient: {
		signIn: { email: signInEmail },
		signOut,
	},
}))

function renderForm() {
	const queryClient = new QueryClient({
		defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
	})
	render(
		<QueryClientProvider client={queryClient}>
			<LoginForm />
		</QueryClientProvider>
	)
}

async function submit(email: string, password: string) {
	const user = userEvent.setup()
	if (email) await user.type(screen.getByLabelText("Email"), email)
	if (password) await user.type(screen.getByLabelText("Password"), password)
	await user.click(screen.getByRole("button", { name: "Sign In" }))
}

describe("LoginForm (staff portal)", () => {
	beforeEach(() => {
		vi.clearAllMocks()
	})

	it("sends staff to the dashboard after a successful sign-in", async () => {
		signInEmail.mockResolvedValue({
			data: { user: { id: "staff-1", role: "frontline_officer" } },
			error: null,
		})
		renderForm()

		await submit("officer@example.com", "a-strong-password")

		await waitFor(() => expect(push).toHaveBeenCalledWith("/dashboard"))
		expect(signInEmail).toHaveBeenCalledWith({
			email: "officer@example.com",
			password: "a-strong-password",
		})
		expect(signOut).not.toHaveBeenCalled()
	})

	it("signs a citizen back out and shows the staff-only message", async () => {
		signInEmail.mockResolvedValue({
			data: { user: { id: "citizen-1", role: "registered_citizen" } },
			error: null,
		})
		renderForm()

		await submit("citizen@example.com", "a-strong-password")

		expect(await screen.findByText(STAFF_ONLY_MESSAGE)).toBeInTheDocument()
		expect(signOut).toHaveBeenCalledTimes(1)
		expect(push).not.toHaveBeenCalled()
	})

	it("shows the error returned by the auth server, such as an account lockout", async () => {
		signInEmail.mockResolvedValue({
			data: null,
			error: {
				status: 429,
				message: "Too many failed sign-in attempts. Please try again in a few minutes.",
			},
		})
		renderForm()

		await submit("officer@example.com", "wrong-password")

		expect(await screen.findByText(/too many failed sign-in attempts/i)).toBeInTheDocument()
		expect(push).not.toHaveBeenCalled()
	})

	it("validates the form with the login schema before calling the auth server", async () => {
		renderForm()

		// Dispatch submit directly so the app's Zod validation runs even though
		// the browser's native `required` check would normally block first.
		fireEvent.submit(screen.getByRole("button", { name: "Sign In" }).closest("form")!)

		expect(await screen.findByText("Please enter a valid email address")).toBeInTheDocument()
		expect(screen.getByText("Password is required")).toBeInTheDocument()
		expect(signInEmail).not.toHaveBeenCalled()
	})
})
