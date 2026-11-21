# @repo/db

Shared database package for **iGubat** — the Local Government Unit (LGU) digital services application for the Municipality of Gubat, Province of Sorsogon.

This package defines how iGubat data is stored in **PostgreSQL**: table schemas, relationships, migrations, a typed database client, and local demo seed data. The NestJS API (`apps/backend`), Next.js staff portal (`apps/web`), and Flutter citizen app (`apps/mobile`) all rely on this model.

---

## Purpose (for stakeholders and engineers)

iGubat modernizes municipal service delivery with one shared data platform:

| Who | How they use iGubat | What this database supports |
| --- | ------------------- | --------------------------- |
| **Citizens** | Flutter mobile app | Accounts, service requests, issue reports, news/events, Discover Gubat, transparency disclosures, emergency contacts, notifications |
| **LGU staff (Moderator / Admin)** | Next.js web portal | Role-based work queues, CMS, workflows, emergency broadcasts, audits, analytics |
| **ICT / platform** | NestJS API + Better Auth | Secure sessions, shared domain data, append-only audit trail |

The database is the **system of record** for citizen transactions, published LGU content, and operational history. Application screens and APIs read and write through this schema; they do not invent separate table definitions.

---

## What the system stores today

- **Identity & access** — citizen and staff accounts, roles, session/device state, Data Privacy Act (RA 10173) consent, login lockout
- **Barangay master data** — Gubat barangays used on profiles and reports
- **Municipal services** — service catalog, form versions, workflow templates, tracked requests, attachments, status history
- **Citizen issue reports** — categories (e.g. road damage, flooding), location, attachments, status history
- **Public information** — news, events, home placements (carousel/banner), help articles, policy documents
- **Discover Gubat** — tourist spots, festival/culture, local products and photo galleries
- **Transparency & Good Governance** — Full Disclosure Policy items (programs, procurement, financial reports, budget, ordinances, executive orders) and PDF attachments
- **Emergency readiness** — directory (hospital, BFP, police, COMCEN, disaster response) and broadcast messages
- **Notifications** — preferences, push device registrations, delivery logs
- **Operations & compliance** — departments, support tickets, media assets, system settings, login activity, checksummed audit logs, analytics export jobs

---

## High-level data model

Conceptual view of how major domains relate (not every column or join table):

```mermaid
erDiagram
  users ||--o{ sessions : has
  users ||--o{ accounts : has
  users }o--o| departments : belongs_to
  users ||--o{ service_requests : submits
  users ||--o{ citizen_reports : submits
  users ||--o{ notifications : receives

  departments ||--o{ service_requests : handles
  departments ||--o{ workflow_templates : owns

  service_categories ||--o{ service_types : contains
  service_types ||--o{ service_type_form_versions : versions
  service_types ||--o{ service_requests : requested_as
  service_requests ||--o{ service_request_attachments : has
  service_requests ||--o{ service_request_status_history : tracks

  citizen_reports ||--o{ citizen_report_attachments : has
  citizen_reports ||--o{ citizen_report_status_history : tracks

  news_articles }o--o| users : authored_by
  events }o--o| users : authored_by
  transparency_items ||--o{ transparency_attachments : has
  discover_gubat_entries ||--o{ discover_gubat_photos : has

  users ||--o{ audit_logs : actor
  users ||--o{ device_registrations : registers
  notifications ||--o{ notification_delivery_logs : delivered_as
```

**Reading the diagram:** citizens and staff share the `users` table (distinguished by role). Service requests and citizen reports hang off users and departments. CMS/transparency/Discover Gubat content is authored by staff users. Notifications and audit logs provide delivery and accountability trails.

---

## Tech currently in use

| Concern | Technology | Notes |
| ------- | ---------- | ----- |
| ORM | [Drizzle ORM](https://orm.drizzle.team/) `1.0.0-beta.9-e89174b` | Typed schema and queries (workspace catalog version) |
| Migrations / tooling | [Drizzle Kit](https://orm.drizzle.team/docs/kit-overview) (same beta channel) | `push`, `generate`, `migrate`, `studio` |
| Database | **PostgreSQL** | Dialect fixed in `drizzle.config.ts`; local DB name `igubat` |
| Driver | [`pg`](https://node-postgres.com/) (`node-postgres`) | Via `drizzle-orm/node-postgres` |
| Runtime | Node.js + TypeScript (ESM) | Package `"type": "module"`; built with `tsc` |
| Config / env | `dotenv` | Loads `DATABASE_URL` for Kit and seed |
| Seed runner | `tsx` | Runs `src/seed.ts` after a schema push |
| Auth tables | Better Auth–compatible | `users`, `sessions`, `accounts`, `verifications` (+ iGubat profile/role fields) |
| Monorepo | pnpm + Turborepo | Root scripts: `pnpm db:*` |

This package does **not** contain business rules, HTTP APIs, or UI. Those live under `apps/*` and consume `@repo/db/schema` and `@repo/db/client`.

---

## System requirements

| Requirement | Expected |
| ----------- | -------- |
| Node.js | Compatible with the monorepo toolchain (see root `package.json` / CI); ESM required |
| Package manager | **pnpm** (workspace) |
| PostgreSQL | Any instance reachable via `DATABASE_URL` (no major version pinned in this package today) |
| Network | Localhost for local development; staging/production URLs from deploy secrets |
| Build | Package built (`pnpm build` / `tsc`) before consumers or Kit scripts that need `dist/` |

Optional for schema work: browser access for **Drizzle Studio**, and write credentials for `push` / `migrate` / `seed`.

Local default connection (developers only):

```text
postgres://postgres:password@localhost:5432/igubat
```

---

## Structure

```
packages/db/
├── src/
│   ├── client.ts              # createDBClient() factory (cached per connection string)
│   ├── schema.ts              # Tables, relations, shared domain types
│   ├── seed.ts                # Idempotent local demo users + mock domain data
│   ├── migrations/            # Generated SQL migrations + snapshots
│   └── utils/
│       └── table.ts           # pgTableCreator helper
├── drizzle.config.ts          # PostgreSQL dialect, public schema filter
├── .env.example               # DATABASE_URL template
└── package.json
```

---

## Environment variables

| Variable | Required | Description |
| -------- | -------- | ----------- |
| `DATABASE_URL` | Yes | PostgreSQL connection string |

```bash
cp packages/db/.env.example packages/db/.env
```

The same `DATABASE_URL` is required by `apps/backend` at runtime. Staging and production values are managed as deploy secrets — never commit real credentials.

---

## Scripts

Run from the **monorepo root**:

| Command | Description |
| ------- | ----------- |
| `pnpm db:push` | Build package, then sync schema directly to the database (**local development**) |
| `pnpm db:studio` | Open Drizzle Studio |
| `pnpm db:generate` | Generate SQL migration files from schema changes |
| `pnpm db:migrate` | Apply pending migrations (**staging / production**) |
| `pnpm db:seed` | Push schema, then load local demo data (development only) |

Package-local equivalents: `pnpm --filter @repo/db push|studio|generate|migrate|seed`.

---

## Migration conventions

Use the right command for the environment:

| Environment | Workflow | Why |
| ----------- | -------- | --- |
| **Local development** | Edit `src/schema.ts` → `pnpm db:push` | Fast iteration; schema and DB stay in sync without committing SQL every tweak |
| **Staging / production** | Edit schema → `pnpm db:generate` → review SQL under `src/migrations/` → `pnpm db:migrate` | Versioned, reviewable changes that can be applied safely across environments |

### Conventions

1. **Schema is source of truth** — define tables and relations in `src/schema.ts`, then sync.
2. **Never use `db:push` against staging or production** — it can drop or alter objects without a reviewable migration file.
3. **Commit generated migrations** — SQL + snapshots under `src/migrations/` travel with the PR that changes the schema.
4. **Review destructive changes** — renames, drops, and type changes need an explicit migration plan (data backfill or multi-step deploy if needed).
5. **Better Auth core columns** — keep `users` / `sessions` / `accounts` / `verifications` compatible with Better Auth; extend with iGubat fields carefully and regenerate auth helpers when the team process requires it.
6. **Rebuild after schema changes** — consumers need a fresh `@repo/db` build (`pnpm build` or package `dev` watch).
7. **Contracts stay aligned** — when a table change affects API shapes, update `@repo/contracts` in the same change set.

### Adding a table (checklist)

1. Define the table with `createTable` in `src/schema.ts`.
2. Register it in `defineRelations()` and the exported `schema` object.
3. Local: `pnpm db:push`. Shared environments: `pnpm db:generate` then `pnpm db:migrate`.
4. Update Zod/DTOs in `@repo/contracts` when the API exposes the new fields.
5. Rebuild dependents.

```typescript
export const exampleRecords = createTable("example_records", t => ({
	id: t.text("id").primaryKey(),
	title: t.text("title").notNull(),
	createdAt: t.timestamp("created_at").defaultNow(),
}))
```

---

## Backup and restore (ops expectations)

Per iGubat TOR non-functional requirements, production data should have **automated daily database backups** with at least **30-day retention**. This package does not run backups itself — hosting/ops owns the schedule.

### Practical guidance

| Topic | Guidance |
| ----- | -------- |
| **What to back up** | Full PostgreSQL database pointed to by production `DATABASE_URL` (all public schema tables) |
| **When** | At least daily; before risky migrations or large data fixes |
| **Retention** | Minimum 30 days (TOR NFR-7) |
| **Verify** | Periodically restore a backup into a non-production instance and smoke-test login + one service request / report flow |
| **Restore** | Use the provider’s restore tooling (or `pg_restore` / SQL dump restore). Point a staging app at the restored DB only after secrets and network rules are correct |
| **Seed vs backup** | `pnpm db:seed` is for **local demo data only**. It replaces seed-owned rows and must never be run against production |

If your host already provides snapshots (e.g. managed PostgreSQL), document the restore runbook in the infrastructure repo and keep this package focused on schema + migrations.

---

## Usage (engineers)

```typescript
import { createDBClient } from "@repo/db/client"
import { serviceRequests } from "@repo/db/schema"

const db = createDBClient() // or createDBClient(process.env.DATABASE_URL)

const rows = await db.select().from(serviceRequests)
```

Package exports:

- `@repo/db/schema` — tables, relations, role/status types
- `@repo/db/client` — `createDBClient`, `DBClient`

---

## Local demo seed (development only)

`pnpm db:seed` loads sample citizens, staff, and domain records so demos and QA can exercise flows without manual setup. It is **safe to re-run locally** (seed-owned rows are replaced). Do **not** use these accounts or this command in production.

Demo credentials and account lists are maintained for engineering/QA demos only; treat them as non-production secrets and rotate or disable them if a shared demo environment is exposed beyond the team.

### Example citizen accounts (mobile)

| Email | Role | Notes |
| ----- | ---- | ----- |
| `juan@example.com` | `registered_citizen` | Primary demo user (Barangay Cogon) |
| `maria@example.com` | `registered_citizen` | Barangay Bagacay |
| `pedro@example.com` | `registered_citizen` | Barangay Panganiban (Poblacion) |
| `ana@igubat.local` | `registered_citizen` | Barangay Manook |
| `unverified@igubat.local` | `registered_citizen` | OTP testing — cannot sign in until verified |

### Example staff accounts (web portal)

| Email | Role | Portal |
| ----- | ---- | ------ |
| `admin@igubat.local` | `super_admin` | Admin |
| `ict@igubat.local` | `ict_admin` | Admin |
| `supervisor@igubat.local` | `department_supervisor` | Moderator |
| `officer@igubat.local` | `frontline_officer` | Moderator |
| `officer2@igubat.local` | `frontline_officer` | Moderator |
| `editor@igubat.local` | `content_editor` | Moderator |
| `emergency@igubat.local` | `emergency_operator` | Moderator |

**Shared local demo password for all seeded accounts:** `password123`

Local/demo only — never reuse this password in staging or production, and do not expose a seeded demo environment beyond the team without rotating credentials.

### Domains covered by seed

Departments, service catalog/types, workflow templates, news/events/placements, Discover Gubat, transparency items, emergency directory/broadcasts, service requests with attachments, citizen reports, notifications, audit logs, help/policy docs, system settings, and support tickets.

---

## Consumers

| Package / app | How it uses `@repo/db` |
| ------------- | ---------------------- |
| `apps/backend` | Runtime queries via Nest database module + Better Auth tables |
| `apps/web` | Through the API (staff portal) |
| `apps/mobile` | Through the API (citizen app) |
| `packages/auth` | Aligns with Better Auth user/session/account shapes defined here |

---

## Related docs

- Project TOR: [`docs/igubat_tor.md`](../../docs/igubat_tor.md)
- Root monorepo setup: [`README.md`](../../README.md)
- Backend API: [`apps/backend/README.md`](../../apps/backend/README.md)
- Auth package: [`packages/auth/README.md`](../auth/README.md)
