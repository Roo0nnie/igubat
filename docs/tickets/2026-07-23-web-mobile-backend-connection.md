# Web And Mobile Backend Connection Audit

## Goal

Verify and complete the remaining connections from `apps/web` and `apps/mobile` to `apps/backend`, using `packages/contracts` for web/oRPC contracts and `packages/db/src/schema.ts` as the backend-owned persistence source.

## Current Audit

| Area | Schema | Backend | Web | Mobile | Status |
| --- | --- | --- | --- | --- | --- |
| Auth/profile | `users`, `sessions`, `accounts`, `verifications`, `notification_preferences` | Better Auth and iGubat `/me/*` handlers | Better Auth and oRPC hooks | Dio auth/profile/preferences data sources | Connected |
| News/events | `news_articles`, `events`, `content_placements` | `/igubat/public/news`, `/events`, `/placements`; admin article upsert | News hooks exist | News/events Dio data sources exist | Connected |
| Service requests | `service_categories`, `service_types`, `service_requests`, request attachments/history | Public services and `/me/requests`; admin request processing | Citizen/admin hooks exist | Fixed live service cards to pass `serviceTypeId` into request submission | Connected after this ticket |
| Citizen reports | `citizen_reports`, report attachments/history | `/me/reports`; admin report processing | Citizen/admin hooks exist | Fixed category values to match backend enum | Connected after this ticket |
| Emergency | `emergency_directory`, `emergency_broadcasts` | Public directory and admin broadcast/directory endpoints | Admin/public hooks exist | Emergency directory Dio data source exists | Connected |
| Transparency | `transparency_items`, `transparency_attachments` | Dedicated public/admin transparency controller/service | Admin transparency UI and hooks exist | Public transparency data sources, cache, list/detail screens exist | Connected |
| Discover Gubat | `discover_gubat_items`, `discover_gubat_media` | Added public/admin Discover Gubat endpoints | Added public hooks/pages and admin hooks | Added Dio data/domain/presentation modules and routes | Connected after this ticket |
| Support tickets | `tickets` | Existing `/v1/tickets` contract/controller/service | Fixed submit ticket page to call `orpc.ticket.submit` | Not a mobile flow | Connected after this ticket |
| Analytics/audit/settings/staff | `audit_logs`, `system_settings`, `analytics_exports`, `users` | Admin endpoints exist | Admin hooks/pages exist | Not a citizen mobile flow | Connected for web |

## Implementation Notes

- Web business features use `@repo/contracts` through `apps/web/services/orpc/client.ts`.
- Mobile uses Dio and direct `/api/v1/*` URLs from `apps/mobile/lib/core/constants/api_constants.dart`.
- Neither frontend imports `@repo/db/schema`; schema remains backend-owned.
- `packages/db/src/schema.ts` already contains staged TOR-aligned schema expansion. Preserve it and generate/review the Drizzle migration before any database deployment.
- Remaining file upload work is intentionally limited to metadata payloads until storage credentials and signed upload URLs are configured.

## Acceptance Criteria

- Public Discover Gubat list/detail works from web and mobile against backend data.
- Admin Discover Gubat contract routes exist for list/detail/create/update/publish/archive/delete.
- Web support ticket form persists through the existing backend tickets module.
- Mobile service request submission sends a real `serviceTypeId` when launched from live service cards.
- Mobile issue reports send only backend-valid category values.
- Focused contracts, web, backend, db, and mobile checks pass or have clearly documented environment blockers.
