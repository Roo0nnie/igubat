import "dotenv/config"

import type { NextConfig } from "next"
import path from "node:path"

import "./env"

/** @type {import("next").NextConfig} */
const config: NextConfig = {
	typedRoutes: true,
	output: "standalone",
	outputFileTracingRoot: path.resolve(import.meta.dirname, "../../"),

	/** Enables hot reloading for local packages without a build step */
	transpilePackages: [
		"@repo/auth",
		"@repo/backend",
		"@repo/contracts",
		"@repo/db",
		"@t3-oss/env-core",
		"@t3-oss/env-nextjs",
	],

	typescript: { ignoreBuildErrors: true },
	reactCompiler: true,

	/**
	 * Enables `forbidden()`/`unauthorized()` from `next/navigation` so admin-only
	 * route guards can return a real HTTP 403 (rendered via `forbidden.tsx`)
	 * instead of a 200 page that merely looks forbidden.
	 */
	experimental: {
		authInterrupts: true,
	},

	devIndicators: {
		position: "bottom-right",
	},
}

export default config
