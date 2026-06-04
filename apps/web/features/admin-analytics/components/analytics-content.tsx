import { NotImplemented } from "@/core/components/not-implemented"

/**
 * Analytics & Reports (IG-043).
 *
 * The analytics pipeline — KPI aggregation, request-volume charts and the
 * PDF/CSV export endpoints — is not wired to the backend yet. Rather than
 * render placeholder KPIs ("—") and export buttons that do nothing (which
 * would read as production-ready while remaining untestable), this surface
 * states its status explicitly until the data and export endpoints exist.
 */
export function AnalyticsContent() {
  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-primary">Analytics & Reports</h1>
        <p className="text-muted-foreground mt-2">
          Usage, request volume, report distribution and notification delivery.
        </p>
      </div>

      <NotImplemented description="Analytics aggregation and PDF/CSV exports are not connected to the backend yet. KPIs, charts and report exports will appear here once the analytics endpoints are implemented." />
    </div>
  )
}
