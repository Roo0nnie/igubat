import { expect, test } from "@playwright/test"

/**
 * Staff sign-in against a real backend.
 *
 * Requires a running backend + seeded database and a staff account supplied
 * through the environment (never hard-code credentials here):
 *
 *   E2E_STAFF_EMAIL=<staff email> E2E_STAFF_PASSWORD=<password> pnpm test:e2e:web
 *
 * Skipped automatically when either variable is missing (e.g. in CI, which
 * runs the web app without a backend).
 *
 * Deliberately does not submit wrong passwords: repeated failures would count
 * toward the account lockout on the shared staff account.
 */
const staffEmail = process.env.E2E_STAFF_EMAIL
const staffPassword = process.env.E2E_STAFF_PASSWORD

test.describe("staff login", () => {
	test.skip(!staffEmail || !staffPassword, "Set E2E_STAFF_EMAIL and E2E_STAFF_PASSWORD")

	test("signs a staff member in and lands on the dashboard", async ({ page }) => {
		await page.goto("/login")

		await page.getByLabel(/email/i).fill(staffEmail!)
		await page.getByLabel("Password", { exact: true }).fill(staffPassword!)
		await page.getByRole("button", { name: /^sign in$/i }).click()

		await expect(page).toHaveURL(/\/dashboard/, { timeout: 15_000 })
	})
})
