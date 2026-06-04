import { Lock } from "lucide-react"

import { NotImplemented } from "@/core/components/not-implemented"

/**
 * Audit Log (IG-044).
 *
 * The audit-log service (queries against `audit_logs`) and CSV export are not
 * wired to the backend yet. Instead of rendering an empty mock table backed by
 * `MOCK_AUDIT = []` plus filters and a dead export button — which would read as
 * a working, append-only audit viewer — this surface states its status
 * explicitly until the audit query + export endpoints exist.
 */
export function AuditContent() {
  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-primary">Audit Log</h1>
        <p className="text-muted-foreground mt-2 flex items-center gap-2">
          <Lock className="h-4 w-4" /> Append-only. Entries cannot be edited or deleted by any role.
        </p>
      </div>

      <NotImplemented description="The audit-log viewer and CSV export are not connected to the backend yet. Filterable entries and export will appear here once the audit-log query and export endpoints are implemented." />
    </div>
  )
}
