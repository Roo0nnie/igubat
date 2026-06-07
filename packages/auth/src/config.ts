import { createEnv } from "@t3-oss/env-core"
import { betterAuth } from "better-auth"
import { drizzleAdapter } from "better-auth/adapters/drizzle"
import { emailOTP, openAPI } from "better-auth/plugins"
import { z } from "zod"

import { createDBClient } from "@repo/db/client"
import { accounts, sessions, users, verifications } from "@repo/db/schema"

/**
 * Type-safe environment variable validation for Auth package
 *
 * Validates auth-related environment variables at module load time.
 * This ensures all required auth configuration is present before initialization.
 */
export const authEnv = createEnv({
	server: {
		// Authentication
		BETTER_AUTH_SECRET: z.string(),
		BETTER_AUTH_TRUSTED_ORIGINS: z.string(),
		BETTER_AUTH_COOKIE_DOMAIN: z.string().optional(),

		// OAuth Providers (Google)
		GOOGLE_CLIENT_ID: z.string().optional(),
		GOOGLE_CLIENT_SECRET: z.string().optional(),
	},
	runtimeEnv: process.env,
	skipValidation: !!process.env.CI || process.env.npm_lifecycle_event === "lint",
})

/**
 * Internal basePath used by Better Auth.
 * All versioned API requests (/api/v1/auth/*, /api/v2/auth/*, etc.) are
 * normalized to this path before being handled by Better Auth.
 */
export const AUTH_BASE_PATH = "/auth"

/**
 * Creates a Better Auth instance configured with Drizzle adapter.
 *
 * The auth instance uses database connection from @repo/db and is
 * configured to work across multiple apps (backend, web, mobile via API).
 *
 * Uses a neutral basePath ("/auth") - the backend normalizes versioned
 * paths (/api/v1/auth/*, /api/v2/auth/*) to this basePath before handling.
 *
 * @returns Better Auth instance
 */
export function createAuth(): ReturnType<typeof betterAuth> {
	const db = createDBClient()

	return betterAuth({
		database: drizzleAdapter(db, {
			provider: "pg",
			schema: {
				users,
				sessions,
				accounts,
				verifications,
			},
			usePlural: true,
		}),
		basePath: AUTH_BASE_PATH,
		secret: authEnv.BETTER_AUTH_SECRET,
		emailAndPassword: {
			enabled: true,
			// A citizen account is NOT a usable session until the email/OTP
			// challenge succeeds. With this on, sign-up creates the user in an
			// unverified state (no session token) and the emailOTP plugin below
			// dispatches the verification code; only `/email-otp/verify-email`
			// establishes an authenticated session.
			requireEmailVerification: true,
		},
		emailVerification: {
			// Mobile registration routes directly to OTP. A valid verification
			// must create the first usable session so the app can enter the
			// authenticated shell without sending the user back through login.
			autoSignInAfterVerification: true,
		},
		user: {
			// Surface the citizen/staff role and department on the session so the
			// web portal can enforce role-based access control (Moderator vs Admin).
			// `input: false` prevents clients from assigning their own role at signup;
			// roles are managed exclusively through staff/admin tooling.
			//
			// The citizen profile fields collected during registration
			// (mobile number, barangay, address and DPA consent) are persisted as
			// `input: true` additional fields so the mobile sign-up payload is
			// stored on the `users` row instead of being silently dropped.
			additionalFields: {
				role: {
					type: "string",
					required: false,
					defaultValue: "registered_citizen",
					input: false,
				},
				departmentId: {
					type: "number",
					required: false,
					input: false,
				},
				mobileNumber: {
					type: "string",
					required: false,
					input: true,
				},
				barangay: {
					type: "string",
					required: false,
					input: true,
				},
				address: {
					type: "string",
					required: false,
					input: true,
				},
				dpaConsent: {
					type: "boolean",
					required: false,
					defaultValue: false,
					input: true,
				},
			},
		},
		socialProviders: {
			google: {
				prompt: "select_account",
				clientId: authEnv.GOOGLE_CLIENT_ID as string,
				clientSecret: authEnv.GOOGLE_CLIENT_SECRET as string,
			},
		},
		trustedOrigins: authEnv.BETTER_AUTH_TRUSTED_ORIGINS?.split(",") ?? [],
		advanced: {
			...(authEnv.BETTER_AUTH_COOKIE_DOMAIN && {
				crossSubDomainCookies: {
					enabled: true,
					domain: authEnv.BETTER_AUTH_COOKIE_DOMAIN,
				},
			}),
		},
		plugins: [
			openAPI({
				path: "/reference",
			}),
			// Server-side 6-digit OTP email verification. `sendVerificationOnSignUp`
			// dispatches the code as part of `/sign-up/email`, and the citizen only
			// becomes authenticated once `/email-otp/verify-email` validates it.
			emailOTP({
				otpLength: 6,
				expiresIn: 60 * 10, // 10 minutes
				sendVerificationOnSignUp: true,
				async sendVerificationOTP({ email, otp, type }) {
					// Dispatch the OTP through the configured delivery channel.
					// Until a production SMS/SMTP provider is wired, the code is
					// surfaced via the server log so the verification handshake is
					// fully exercisable end-to-end in development. Swapping in a real
					// transport here requires no client change.
					// eslint-disable-next-line no-console
					console.info(`[email-otp] type=${type} email=${email} otp=${otp}`)
				},
			}),
		],
	})
}

/**
 * Default Better Auth instance.
 * This is the shared instance used across all apps.
 *
 * Lazy initialization to ensure environment variables are loaded before creating the instance.
 */
let _auth: ReturnType<typeof betterAuth> | null = null

/**
 * Clear the cached auth instance. Call this when configuration changes.
 */
export function clearAuthCache(): void {
	_auth = null
}

export function getAuth(): ReturnType<typeof betterAuth> {
	if (!_auth) {
		_auth = createAuth()
	}
	return _auth!
}

/**
 * Inferred Session type from Better Auth.
 * Export this so web app can use the correct types matching backend config.
 */
export type Session = ReturnType<typeof getAuth>["$Infer"]["Session"]
