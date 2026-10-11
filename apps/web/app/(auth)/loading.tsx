import { BrandedPageLoader } from "@/core/components/ui/loading-state"

export default function AuthLoading() {
	return <BrandedPageLoader message="Preparing secure sign-in..." className="min-h-[40vh]" />
}
