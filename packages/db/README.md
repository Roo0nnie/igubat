# @repo/db

Drizzle ORM database package with schema definitions and client.

## Structure

```
packages/db/
├── src/
│   ├── client.ts         # Database client factory
│   ├── schema.ts         # Schema exports
│   └── utils/            # Database utilities
├── drizzle.config.ts     # Drizzle configuration
└── package.json
```

## Usage

```typescript
import { db } from "@repo/db"
import { todos, users } from "@repo/db/schema"

// Query examples
const allTodos = await db.select().from(todos)
const user = await db.query.users.findFirst({ where: eq(users.id, "123") })
```

## Environment Variables

| Variable       | Description                  |
| -------------- | ---------------------------- |
| `DATABASE_URL` | PostgreSQL connection string |

## Scripts

| Command            | Description             |
| ------------------ | ----------------------- |
| `pnpm db:push`     | Push schema to database |
| `pnpm db:studio`   | Open Drizzle Studio     |
| `pnpm db:generate` | Generate migrations     |
| `pnpm db:migrate`  | Run migrations          |
| `pnpm db:seed`     | Push schema, then seed users and mock data |

## Seed Data

Run `pnpm db:seed` from the repo root (requires `DATABASE_URL`). Safe to re-run — seed-owned rows are replaced on each run.

**Default password for all accounts:** `password123`

### Citizens (mobile app)

| Email | Role | Notes |
| ----- | ---- | ----- |
| `juan@example.com` | `registered_citizen` | Primary demo user (Barangay Cogon) |
| `maria@example.com` | `registered_citizen` | Barangay Bagacay |
| `pedro@example.com` | `registered_citizen` | Barangay Panganiban (Poblacion) |
| `ana@igubat.local` | `registered_citizen` | Barangay Manook |
| `unverified@igubat.local` | `registered_citizen` | OTP testing only — cannot sign in until verified |

### Staff (web portal)

| Email | Role | Portal |
| ----- | ---- | ------ |
| `admin@igubat.local` | `super_admin` | Admin |
| `ict@igubat.local` | `ict_admin` | Admin |
| `supervisor@igubat.local` | `department_supervisor` | Moderator |
| `officer@igubat.local` | `frontline_officer` | Moderator |
| `officer2@igubat.local` | `frontline_officer` | Moderator |
| `editor@igubat.local` | `content_editor` | Moderator |
| `emergency@igubat.local` | `emergency_operator` | Moderator |

### Seeded domain tables

Departments, workflow templates, news articles (published/draft/archived), emergency directory, service requests with attachments, citizen reports, notifications, audit logs, and support tickets.

## Adding Tables

1. Create schema in `src/schema/`:

```typescript
// src/schema/posts.ts
import { pgTable, text, timestamp } from "drizzle-orm/pg-core"

export const posts = pgTable("posts", {
	id: text("id").primaryKey(),
	title: text("title").notNull(),
	createdAt: timestamp("created_at").defaultNow(),
})
```

2. Export from `src/schema/index.ts`
3. Run `pnpm db:push` to sync with database
