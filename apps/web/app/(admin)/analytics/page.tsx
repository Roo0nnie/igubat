import { forbidden } from "next/navigation"

import { requireStaff } from "@/core/lib/admin-guard"
import { AnalyticsContent } from "@/features/admin-analytics/components/analytics-content"

export const metadata = {
  title: "Analytics - iGubat",
}

export default async function AnalyticsPage() {
  // Admin-only surface (spec Step 7). Moderators reaching this URL directly get
  // a real HTTP 403 via the App Router forbidden boundary.
  const user = await requireStaff()
  if (user.portalRole !== "admin") {
    forbidden()
  }
  return <AnalyticsContent />
}
