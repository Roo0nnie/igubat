# Data Model &amp; Backend Contracts — Transparency Module

**Scope:** Concrete additions to file:packages/db/src/schema.ts, file:packages/db/src/seed.ts, file:packages/contracts/src/modules/v1/igubat/igubat.schema.ts, file:packages/contracts/src/modules/v1/igubat/igubat.contract.ts, and file:apps/backend/src/modules/v1/igubat/ to back **Module 13 — Transparency and Good Governance**.

---

## 1. Schema Additions — file:packages/db/src/schema.ts

Two new tables and one enum-category extension. Both follow the existing `createTable` + Drizzle pattern.

### 1.1 `transparency_items`


| Column                    | Drizzle type                                                                                            | Notes                                           |
| ------------------------- | ------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| `id`                      | `t.serial("id").primaryKey()`                                                                           |                                                 |
| `type`                    | `t.text("type").notNull().$type<TransparencyType>()`                                                    | one of the six content-type strings             |
| `referenceNumber`         | `t.text("reference_number")`                                                                            |                                                 |
| `title`                   | `t.text("title").notNull()`                                                                             |                                                 |
| `slug`                    | `t.text("slug").unique()`                                                                               | derived from referenceNumber + title            |
| `summary`                 | `t.text("summary")`                                                                                     |                                                 |
| `body`                    | `t.text("body").notNull().default("")`                                                                  |                                                 |
| `fiscalYear`              | `t.integer("fiscal_year")`                                                                              |                                                 |
| `effectiveDate`           | `t.timestamp("effective_date")`                                                                         |                                                 |
| `barangay`                | `t.text("barangay")`                                                                                    |                                                 |
| `status`                  | `t.text("status").notNull().default("draft").$type<"draft" | "scheduled" | "published" | "archived">()` |                                                 |
| `metadata`                | `t.json("metadata")`                                                                                    | type-specific fields (see §6 of canonical spec) |
| `coverImageUrl`           | `t.text("cover_image_url")`                                                                             |                                                 |
| `authorId`                | `t.text("author_id").references(() => users.id, { onDelete: "set null" })`                              |                                                 |
| `notifyOnPublish`         | `t.boolean("notify_on_publish").notNull().default(false)`                                               | UX checkbox snapshot                            |
| `scheduledAt`             | `t.timestamp("scheduled_at")`                                                                           |                                                 |
| `publishedAt`             | `t.timestamp("published_at")`                                                                           |                                                 |
| `archivedAt`              | `t.timestamp("archived_at")`                                                                            |                                                 |
| `deletedAt`               | `t.timestamp("deleted_at")`                                                                             | soft-delete                                     |
| `createdAt` / `updatedAt` | `t.timestamp(...).defaultNow()`                                                                         |                                                 |


Indices: `(type, status, published_at DESC)` for the public list query, `(fiscal_year)`, `(slug)` unique.

### 1.2 `transparency_attachments`

Mirrors `citizen_report_attachments`:

- `id`, `transparencyItemId` (FK with `onDelete: "cascade"`), `fileUrl`, `fileName`, `mimeType`, `sizeBytes`, `sortOrder`, `createdAt`.

### 1.3 Notification category extension

Extend the existing `notifications.category` enum and `notification_preferences` row to include the new `transparency` channel:

- `notifications.category` `$type<...>()` adds `"transparency"`.
- `notification_preferences` gains `transparency: t.boolean("transparency").notNull().default(true)`.

### 1.4 Relations

Add to `defineRelations(...)`:

- `transparencyItems.author → users`
- `transparencyItems.attachments → many transparencyAttachments`
- `transparencyAttachments.transparencyItem → one transparencyItems`

Both tables added to the final `schema = Object.assign(...)` exported object.

---

## 2. Seed Additions — file:packages/db/src/seed.ts

Insert representative records (at least one Draft, two Published per type — twelve+ items total). Examples:


| Type                    | Sample referenceNumber | Title                                                         | fiscalYear |
| ----------------------- | ---------------------- | ------------------------------------------------------------- | ---------- |
| `program_project`       | `PRJ-2026-014`         | "Buenavista Beach Mangrove Rehabilitation"                    | 2026       |
| `bid_procurement`       | `IB-2026-007`          | "Invitation to Bid — Concreting of Brgy. Rizal Road"          | 2026       |
| `financial_report`      | `SAOB-Q1-2026`         | "Statement of Allotments, Obligations and Balances — Q1 2026" | 2026       |
| `annual_budget`         | `AB-2026`              | "Annual Budget FY 2026"                                       | 2026       |
| `legislative_ordinance` | `Ord. No. 2026-018`    | "Single-Use Plastic Reduction Ordinance"                      | 2026       |
| `executive_order`       | `EO No. 2026-05`       | "Implementation of Pacific Coast Cleanliness Drive"           | 2026       |


Each record gets 1–3 representative attachments (`mediaAssets` rows referencing the seed PDFs/JPEGs already in file:packages/db/src/seed.ts, or new entries; URLs are placeholder paths). One `notifications` row per published item with `category: "transparency"` for the seeded citizen account.

Also extend `notificationPreferences` seeded rows to set `transparency: true`.

---

## 3. Contract Additions — file:packages/contracts/src/modules/v1/igubat/igubat.schema.ts

Add Zod schemas:

- `TransparencyTypeSchema` — `z.enum(["program_project", "bid_procurement", "financial_report", "annual_budget", "legislative_ordinance", "executive_order"])`.
- `TransparencyStatusSchema` — `z.enum(["draft", "scheduled", "published", "archived"])`.
- `TransparencyMetadataSchema` — discriminated union on `type` with the per-type required fields from §6 of the canonical spec.
- `TransparencyAttachmentSchema` — `id`, `fileName`, `fileUrl`, `mimeType`, `sizeBytes`, `sortOrder`.
- `TransparencyItemSummarySchema` — list-row shape (no `body`, includes `coverImageUrl`, `referenceNumber`, `publishedAt`, `fiscalYear`, `status`).
- `TransparencyItemDetailSchema` — extends summary with `body`, `metadata`, `attachments`.
- `CreateTransparencyItemSchema` / `UpdateTransparencyItemSchema` — for admin POST/PATCH.
- `TransparencyListQuerySchema` — `type?`, `status?`, `fiscalYear?`, `barangay?`, `search?`, `limit?`, `cursor?`.

Also extend `NotificationPreferenceSchema` with `transparency: z.boolean()`.

---

## 4. Contract Additions — file:packages/contracts/src/modules/v1/igubat/igubat.contract.ts

Add new procedures under the existing sub-routers:

### Under `public:` (no auth)

- `GET /transparency` — `TransparencyListQuerySchema` → `z.array(TransparencyItemSummarySchema)`
- `GET /transparency/{slug}` — `SlugParamSchema` → `TransparencyItemDetailSchema`

### Under `me:` (Authenticated User)

- The existing `notificationPreferences` / `updateNotificationPreferences` endpoints inherit the new `transparency` field via the extended schema (no new endpoints needed).

### Under `admin:` (Moderator / Admin)

- `GET /transparency` — `TransparencyListQuerySchema` → `z.array(TransparencyItemSummarySchema)` (includes drafts/scheduled/archived)
- `GET /transparency/{id}` — `IdParamSchema` → `TransparencyItemDetailSchema`
- `POST /transparency` — `CreateTransparencyItemSchema` → `TransparencyItemDetailSchema`
- `PATCH /transparency/{id}` — `UpdateTransparencyItemSchema` → `TransparencyItemDetailSchema`
- `POST /transparency/{id}/publish` — `IdParamSchema` + `{ notifySubscribers: boolean, publishAt?: string }` → `TransparencyItemDetailSchema`
- `POST /transparency/{id}/archive` — `IdParamSchema` → `TransparencyItemDetailSchema`
- `DELETE /transparency/{id}` — `IdParamSchema` (soft-delete; Admin-only permanent delete via `?permanent=true`)
- `GET /transparency/export` — Admin only — returns CSV stream.

Tag the new procedures with `["iGubat Transparency"]` for the OpenAPI grouping.

---

## 5. Backend Module — file:apps/backend/src/modules/v1/igubat/

Add a `transparency/` sub-folder mirroring how todos are sub-foldered under examples:

```
modules/v1/igubat/
├── igubat.module.ts          (existing — register TransparencyService/Controller here)
├── igubat.controller.ts      (existing — leaves transparency to its own controller)
├── igubat.service.ts         (existing)
└── transparency/
    ├── transparency.controller.ts
    ├── transparency.service.ts
    └── transparency.service.spec.ts
```

Responsibilities of `TransparencyService`:

- CRUD against `transparency_items` + `transparency_attachments`.
- Lifecycle helpers (`publish`, `schedule`, `archive`, `softDelete`, `permanentDelete`).
- On `publish`: if `notifyOnPublish`, enqueue notifications via the existing Notification module.
- Every state-changing operation appends to `audit_logs` (action types like `transparency.create`, `transparency.publish`, `transparency.delete`).
- Admin-only enforcement on permanent delete + CSV export via the existing role guards / `RequiredAccess` machinery used by other admin endpoints.

A cron job (`@Cron` in NestJS) checks for `status = "scheduled" AND scheduledAt <= now()` every minute and promotes them to `published`.

---

## 6. Cross-Cutting Behavior


| Concern                     | How it's satisfied                                                                                                       |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Soft-delete                 | `deletedAt` timestamp; public/admin lists filter where `deletedAt IS NULL`.                                              |
| Signed URLs for attachments | Service injects existing signed-URL helper used by `citizen_report_attachments`.                                         |
| Virus scan                  | Reuses existing upload-pipeline (out of scope of this spec).                                                             |
| RBAC                        | `transparency.create/edit/publish/archive` → staff; `transparency.permanentDelete/export` → admin.                       |
| Audit                       | Every write writes an `audit_logs` row with before/after diff.                                                           |
| Offline mobile cache        | Mobile app caches the last 20 published items per type into local storage (Hive/secure storage), with a `lastUpdatedAt`. |


&lt;/TRAYCER_SPEC&gt;