import { useSyncExternalStore } from "react"

const subscribe = () => () => {}

/**
 * Returns `false` during SSR and the initial hydration pass, `true` once React
 * has taken over the DOM. Use it to keep JS-only controls inert until their
 * handlers are attached.
 */
export function useHydrated() {
	return useSyncExternalStore(
		subscribe,
		() => true,
		() => false
	)
}
