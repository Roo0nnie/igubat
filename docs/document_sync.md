# Documentation Sync — Add Module 13 across all iGubat docs

**Purpose:** Keep the seven canonical iGubat documents in sync after introducing **Module 13 — Transparency and Good Governance** (see `spec:0e00a677-d287-4d0a-b9cc-3ecbf980756f` *Module 13 — Transparency and Good Governance*). This spec lists every edit that must be applied so the doc set remains a coherent whole.

---

## 1. file:docs/igubat_tor.md (v3.1 → v3.2)


| Section                                     | Change                                                                                                                                                                                                                                                                                                                          |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Header / version note                       | Bump version `v3.1` → `v3.2`; add release note: *"Added Module 13 — Transparency and Good Governance."*                                                                                                                                                                                                                         |
| §3.2 Platform B — Web Administration Portal | Add Transparency Content Management to the bullet list.                                                                                                                                                                                                                                                                         |
| §4.1 Core Functional Modules table          | Add row **13 — Transparency and Good Governance Module — "Public disclosure of programs/projects, procurement bids, financial reports, annual budget, legislative ordinances, and executive orders per DILG Full Disclosure Policy."** Update the previous module-count wording to **"thirteen (13) core functional modules"**. |
| §5.1 Guest — "Can" list                     | Add bullet: *"Browse Transparency &amp; Good Governance: Program and Projects, Bids and Projects, Financial Reports, Annual Budget, Legislative Ordinances, Executive Orders (read-only, public)."*                                                                                                                             |
| §5.2 Authenticated User — "Can" list        | Add: *"Subscribe to push notifications for new transparency items."*                                                                                                                                                                                                                                                            |
| §5.3 Moderator — "Can" list                 | Add new section **Transparency CMS**: *"Create, edit, publish, schedule, and archive transparency items of any of the six types."*                                                                                                                                                                                              |
| §5.4 Admin — "Can" list                     | Add: *"Permanently delete any transparency item; export the transparency item list to CSV."*                                                                                                                                                                                                                                    |
| §6.1 Track 1 scope                          | (Optional) Add Module 13 — Transparency to Phase 1 scope (the surface is read-only public information).                                                                                                                                                                                                                         |
| New §7.13                                   | Add full Module 13 functional-requirements section (mirrors the breakdown in `spec:0e00a677-d287-4d0a-b9cc-3ecbf980756f` *Module 13 — Transparency and Good Governance*).                                                                                                                                                       |
| §11 File &amp; Media                        | Note that Transparency attachments share the signed-URL + virus-scan + soft-delete pipeline.                                                                                                                                                                                                                                    |


---

## 2. file:docs/igubat_overall_system.md


| Section                                 | Change                                                                                                                                                       |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| §1 Overview                             | Mention Transparency surface alongside Discover Gubat.                                                                                                       |
| §4 Mobile App Navigation Tree           | Add a new tree node: `├── Transparency &amp; Good Governance (Guest                                                                                          |
| §5 Web Administration Portal Navigation | Add `├── Transparency (Moderator                                                                                                                             |
| §6.1 Mobile App Screens table           | Add rows: **M-31 Transparency Section (Home)**, **M-32 Transparency Category List**, **M-33 Transparency Item Detail** — all Guest+Auth, Module 13, Phase 1. |
| §6.2 Web Portal Screens table           | Add rows: **W-26 Transparency Manager List**, **W-27 Transparency Item Editor** — Moderator+Admin, Module 13, Phase 1.                                       |
| §7.1 MVP scope                          | Include M-31, M-32, M-33, W-26, W-27.                                                                                                                        |


---

## 3. file:docs/igubat_user_stories.md

Add a new **Section 16 — Transparency &amp; Good Governance** *(Focused Development)* with these stories:

- **16.1** *Guest sees a Transparency section on Home with six tiles* — AC: 2×3 grid, subtitle "Know where your taxes go".
- **16.2** *Guest opens a category and sees published items most-recent first* — AC: pagination, fiscal-year filter chip.
- **16.3** *Guest opens an item and sees type-specific metadata + downloads attachments via signed URL.*
- **16.4** *Authenticated User subscribes to "New transparency item" pushes in preferences.*
- **16.5** *Authenticated User taps a push and is deep-linked into the item detail.*
- **16.6** *Moderator creates a transparency item of any of the six types* — AC: type selector, type-specific fields, attachments, Save Draft / Schedule / Publish Now.
- **16.7** *Moderator schedules an item and it auto-publishes at the scheduled time.*
- **16.8** *Moderator archives an item and it disappears from the public list.*
- **16.9** *Admin permanently deletes an item* — AC: confirmation modal; audit record written.
- **16.10** *Admin exports the transparency list to CSV.*
- **16.11** *Citizens view cached transparency items while offline* — AC: list visible; attachment requires network.

---

## 4. file:docs/igubat_proposal.md


| Section                   | Change                                                                                                                                                     |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| §1 Executive Summary      | Add Module 13 to the list of modules.                                                                                                                      |
| §2 Platform Understanding | Mention transparency disclosures per DILG FDPP, RA 9184, RA 7160.                                                                                          |
| §3.3 Module Map (mermaid) | Add `M13[Transparency & Good Governance]` node connected to both Mobile App (citizen-facing) and Web Admin Portal (CMS), with edge to `M8[Notifications]`. |
| §4 Track 1 Build Scope    | Add a new sub-block **"Transparency and Good Governance Module"** under Track 1, listing the six content types and lifecycle.                              |
| §5 Phase 1 Outcome        | Add: *"Residents can see what the LGU is doing, what it is buying, how it spends, and what it has enacted — fulfilling the Full Disclosure Policy."*       |


---

## 5. file:docs/igubat_mobile_app.md


| Section                      | Change                                                                                                                                                  |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| §1 Overview                  | Add Transparency to public surfaces.                                                                                                                    |
| §4 Step 1 — Home description | Add bullet to quick-action grid intro: a new Transparency &amp; Good Governance section is rendered as a 2×3 tile grid above the news feed.             |
| §4 Step 3 — Public Browsing  | Add **Transparency:** *"Open the Transparency section to browse six categories of LGU disclosures; tap an item to read it and download attached PDFs."* |
| §4 Step 4d — Notifications   | Note the new `transparency` category.                                                                                                                   |
| §6 End States                | Add: cached transparency items remain visible offline.                                                                                                  |
| §7 Key System Behaviors      | Add: *"Transparency disclosures are public; attachments served via signed URLs."*                                                                       |
| §8 Mobile Workflow Diagram   | Add `Transparency` node off Home → Detail.                                                                                                              |


---

## 6. file:docs/igubat_admin_portal.md


| Section                          | Change                                                                                                                                                                                                                                      |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| §1 Overview                      | Add Transparency CMS.                                                                                                                                                                                                                       |
| §4 Step 4 — Content Management   | Add new sub-step **4e — Transparency (Programs, Bids, Finances, Budget, Ordinances, Executive Orders):** documents the wizard, type-specific fields, lifecycle, notify-subscribers, preview, archive, permanent-delete-Admin-only behavior. |
| §5 Decision Points Summary table | Add row **Transparency publish path — Save Draft, Schedule, or Publish (with notify-subscribers)**.                                                                                                                                         |
| §7 Key System Behaviors          | Note Transparency reuses the canonical lifecycle.                                                                                                                                                                                           |
| §8 Permission Matrix table       | Add rows: *Transparency: create/edit/schedule/publish/archive* (✓/✓), *Transparency: notify subscribers* (✓/✓), *Transparency: permanently delete* (—/✓), *Transparency: export CSV* (—/✓).                                                 |
| §9 Workflow Diagram              | Add `D1 --> TR[Transparency]` and `TR --> X6[Publish / Schedule / Archive + Audit]`.                                                                                                                                                        |


---

## 7. file:docs/igubat_manual_test_plan.md


| Section              | Change                                                                                                                                                                                                                                                                                                                     |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Test Prerequisites   | Add sample data: at least 2 items per transparency type (one Draft, one Published).                                                                                                                                                                                                                                        |
| Mobile test cases    | Add **IG-057 — Home shows Transparency section with six tiles**, **IG-058 — Open each category list as Guest**, **IG-059 — Open item detail and download attachment**, **IG-060 — Authenticated User toggles transparency notification preference**, **IG-061 — Offline shows cached items, attachment requires network**. |
| Web admin test cases | Add **IG-062 — Moderator creates+publishes a Program/Project**, **IG-063 — Moderator schedules a Bid item; verify auto-publish**, **IG-064 — Admin permanently deletes an EO; verify audit entry**, **IG-065 — Admin exports transparency list CSV**, **IG-066 — RBAC: Moderator cannot reach permanent-delete control**.  |
| Smoke Test Checklist | Add: *"Transparency section visible on mobile Home; six tiles tappable; item detail loads."*                                                                                                                                                                                                                               |


