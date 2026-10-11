import { expect, test } from "@playwright/test"

test.describe("home page", () => {
	test("redirects unauthenticated visitors from / to /login", async ({ page }) => {
		await page.goto("/")
		await expect(page).toHaveURL(/\/login/)
	})

	test("shows the iGubat header", async ({ page }) => {
		await page.goto("/")
		await expect(page.getByRole("banner")).toContainText(/igubat/i)
	})

	test("shows a Login CTA button linking to /login when logged out", async ({ page }) => {
		await page.goto("/")
		const cta = page.getByRole("link", { name: /login/i })
		await expect(cta).toBeVisible()
		await expect(cta).toHaveAttribute("href", "/login")
	})
})
