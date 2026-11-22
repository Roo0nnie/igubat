import { APIError } from "better-auth/api"
import { describe, expect, it, vi } from "vitest"

import {
	createLockoutHooks,
	isLocked,
	LOCKOUT_DURATION_MS,
	LOCKOUT_MAX_ATTEMPTS,
	LOCKOUT_MESSAGE,
	registerFailedAttempt,
	registerSuccessfulLogin,
	type LockoutState,
	type LockoutStore,
} from "./lockout"

const NOW = new Date("2026-01-01T08:00:00.000Z")
const fresh: LockoutState = { failedLoginAttempts: 0, lockedUntil: null }

function failTimes(times: number, start: LockoutState = fresh, now = NOW): LockoutState {
	let state = start
	for (let i = 0; i < times; i++) state = registerFailedAttempt(state, now)
	return state
}

describe("lockout policy", () => {
	it("does not lock before the maximum number of failures", () => {
		const state = failTimes(LOCKOUT_MAX_ATTEMPTS - 1)
		expect(state.failedLoginAttempts).toBe(LOCKOUT_MAX_ATTEMPTS - 1)
		expect(state.lockedUntil).toBeNull()
		expect(isLocked(state, NOW)).toBe(false)
	})

	it("locks for the configured duration on the fifth consecutive failure", () => {
		const state = failTimes(LOCKOUT_MAX_ATTEMPTS)
		expect(LOCKOUT_MAX_ATTEMPTS).toBe(5)
		expect(state.lockedUntil?.getTime()).toBe(NOW.getTime() + LOCKOUT_DURATION_MS)
		expect(isLocked(state, NOW)).toBe(true)
		expect(isLocked(state, new Date(NOW.getTime() + LOCKOUT_DURATION_MS - 1))).toBe(true)
	})

	it("unlocks once the lock expires and starts a fresh counting window", () => {
		const locked = failTimes(LOCKOUT_MAX_ATTEMPTS)
		const later = new Date(NOW.getTime() + LOCKOUT_DURATION_MS + 1)
		expect(isLocked(locked, later)).toBe(false)

		const next = registerFailedAttempt(locked, later)
		expect(next).toEqual({ failedLoginAttempts: 1, lockedUntil: null })
	})

	it("resets the counter after a successful login", () => {
		expect(registerSuccessfulLogin()).toEqual(fresh)
	})
})

/** In-memory store standing in for the `users` table. */
function memoryStore(initial: LockoutState = fresh) {
	const rows = new Map([["citizen@example.com", { id: "user-1", ...initial }]])
	const store: LockoutStore = {
		findByEmail: vi.fn(async (email: string) => rows.get(email) ?? null),
		save: vi.fn(async (_id: string, state: LockoutState) => {
			const row = rows.get("citizen@example.com")!
			rows.set("citizen@example.com", { ...row, ...state })
		}),
	}
	return { store, row: () => rows.get("citizen@example.com")! }
}

type Middleware = (ctx: unknown) => Promise<unknown>

function signInCtx(returned: unknown, newSession: unknown = null, path = "/sign-in/email") {
	return {
		path,
		body: { email: "Citizen@Example.com", password: "irrelevant" },
		context: { returned, newSession },
	}
}

const wrongPassword = () => new APIError("UNAUTHORIZED", { message: "Invalid email or password" })

describe("lockout hooks on /sign-in/email", () => {
	it("locks the account after repeated wrong passwords and blocks the next attempt", async () => {
		const { store, row } = memoryStore()
		const hooks = createLockoutHooks(store, () => NOW)
		const before = hooks.before as unknown as Middleware
		const after = hooks.after as unknown as Middleware

		for (let i = 0; i < LOCKOUT_MAX_ATTEMPTS; i++) {
			await before(signInCtx(undefined))
			await after(signInCtx(wrongPassword()))
		}

		expect(row().failedLoginAttempts).toBe(LOCKOUT_MAX_ATTEMPTS)
		expect(row().lockedUntil).not.toBeNull()

		await expect(before(signInCtx(undefined))).rejects.toMatchObject({
			statusCode: 429,
			message: LOCKOUT_MESSAGE,
		})
	})

	it("resets the counter on a successful sign-in", async () => {
		const { store, row } = memoryStore({ failedLoginAttempts: 3, lockedUntil: null })
		const after = createLockoutHooks(store, () => NOW).after as unknown as Middleware

		await after(signInCtx({ token: "t" }, { session: {}, user: {} }))

		expect(row()).toMatchObject({ failedLoginAttempts: 0, lockedUntil: null })
	})

	it("does not count non-credential errors such as unverified email (403)", async () => {
		const { store } = memoryStore()
		const after = createLockoutHooks(store, () => NOW).after as unknown as Middleware

		await after(signInCtx(new APIError("FORBIDDEN", { message: "Email not verified" })))

		expect(store.save).not.toHaveBeenCalled()
	})

	it("ignores other endpoints and unknown emails", async () => {
		const { store } = memoryStore()
		const hooks = createLockoutHooks(store, () => NOW)
		const after = hooks.after as unknown as Middleware

		await after(signInCtx(wrongPassword(), null, "/sign-up/email"))
		await after({
			path: "/sign-in/email",
			body: { email: "nobody@example.com" },
			context: { returned: wrongPassword(), newSession: null },
		})

		expect(store.save).not.toHaveBeenCalled()
	})
})
