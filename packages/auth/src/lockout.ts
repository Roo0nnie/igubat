import { APIError, createAuthMiddleware } from "better-auth/api"

/**
 * Login lockout policy.
 *
 * After `LOCKOUT_MAX_ATTEMPTS` consecutive failed email/password sign-ins the
 * account is locked for `LOCKOUT_DURATION_MS`. A successful sign-in, or an
 * expired lock, resets the counter. State is persisted on the `users` row
 * (`failed_login_attempts`, `locked_until`).
 */
export const LOCKOUT_MAX_ATTEMPTS = 5
export const LOCKOUT_DURATION_MS = 15 * 60 * 1000
export const LOCKOUT_MESSAGE =
	"Too many failed sign-in attempts. Please try again in a few minutes."

const SIGN_IN_EMAIL_PATH = "/sign-in/email"

export interface LockoutState {
	failedLoginAttempts: number
	lockedUntil: Date | null
}

export function isLocked(state: LockoutState, now: Date): boolean {
	return state.lockedUntil !== null && state.lockedUntil.getTime() > now.getTime()
}

export function registerFailedAttempt(state: LockoutState, now: Date): LockoutState {
	// A lock that has already expired starts a fresh counting window.
	const lockExpired = state.lockedUntil !== null && !isLocked(state, now)
	const attempts = (lockExpired ? 0 : state.failedLoginAttempts) + 1

	if (attempts >= LOCKOUT_MAX_ATTEMPTS) {
		return {
			failedLoginAttempts: attempts,
			lockedUntil: new Date(now.getTime() + LOCKOUT_DURATION_MS),
		}
	}
	return { failedLoginAttempts: attempts, lockedUntil: null }
}

export function registerSuccessfulLogin(): LockoutState {
	return { failedLoginAttempts: 0, lockedUntil: null }
}

/** Persistence port so the hooks can be tested without a database. */
export interface LockoutStore {
	findByEmail(email: string): Promise<({ id: string } & LockoutState) | null>
	save(userId: string, state: LockoutState): Promise<void>
}

function readEmail(body: unknown): string | null {
	if (body && typeof body === "object" && "email" in body) {
		const email = (body as { email: unknown }).email
		if (typeof email === "string" && email.length > 0) return email.trim().toLowerCase()
	}
	return null
}

/**
 * Builds Better Auth `hooks.before` / `hooks.after` middleware that enforce
 * the lockout policy on `/sign-in/email`.
 *
 * Only wrong-credential failures (HTTP 401) count toward the lock; other
 * errors such as "email not verified" (403) do not.
 */
export function createLockoutHooks(store: LockoutStore, clock: () => Date = () => new Date()) {
	const before = createAuthMiddleware(async ctx => {
		if (ctx.path !== SIGN_IN_EMAIL_PATH) return
		const email = readEmail(ctx.body)
		if (!email) return

		const user = await store.findByEmail(email)
		if (user && isLocked(user, clock())) {
			throw new APIError("TOO_MANY_REQUESTS", { message: LOCKOUT_MESSAGE })
		}
	})

	const after = createAuthMiddleware(async ctx => {
		if (ctx.path !== SIGN_IN_EMAIL_PATH) return
		const email = readEmail(ctx.body)
		if (!email) return

		const returned = ctx.context.returned
		const failedCredentials = returned instanceof APIError && returned.statusCode === 401
		const succeeded = !(returned instanceof APIError) && ctx.context.newSession !== null

		if (!failedCredentials && !succeeded) return

		const user = await store.findByEmail(email)
		if (!user) return

		if (failedCredentials) {
			await store.save(user.id, registerFailedAttempt(user, clock()))
		} else if (user.failedLoginAttempts > 0 || user.lockedUntil !== null) {
			await store.save(user.id, registerSuccessfulLogin())
		}
	})

	return { before, after }
}
