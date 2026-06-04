import { NotImplemented } from "@/core/components/not-implemented"

/**
 * Admin-only global system configuration (IG-045).
 *
 * Loading and persisting system settings (maintenance mode, automatic request
 * assignment, email notifications) is not wired to the backend yet. The
 * previous version rendered switches that only flipped local state and never
 * loaded or saved anything — which reads as working configuration. This
 * surface now states its status explicitly until the settings load/persist
 * endpoints exist.
 *
 * Self-service profile and password management live in `ProfileContent`
 * (/profile) so Moderators keep access to their own account without exposing
 * system-wide settings.
 */
export function SettingsContent() {
  return (
    <div className="p-6 md:p-8 space-y-6 max-w-5xl mx-auto">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-primary">System Settings</h1>
        <p className="text-muted-foreground mt-2">Configure global application preferences.</p>
      </div>

      <NotImplemented description="System settings are not connected to the backend yet. Maintenance mode, automatic request assignment and email-notification preferences will be loaded and persisted here once the settings endpoints are implemented." />
    </div>
  )
}
