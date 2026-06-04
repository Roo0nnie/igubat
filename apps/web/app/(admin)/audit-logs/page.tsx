import { forbidden } from "next/navigation"

import { requireStaff } from "@/core/lib/admin-guard"
import { AuditContent } from "@/features/admin-audit/components/audit-content"

export const metadata = {
  title: "Audit Log - iGubat",
}

export default async function AuditLogsPage() {
  // Admin-only, read-only surface (spec Step 8). Moderators reaching this URL
  // directly get a real HTTP 403 via the App Router forbidden boundary.
  const user = await requireStaff()
  if (user.portalRole !== "admin") {
    forbidden()
  }
  return <AuditContent />
}
