# iGubat Manual Test Run Report

**Test Plan:** `docs/igubat_manual_test_plan.md` v1.0 (aligned to TOR v3.1)
**Ticket:** `6b564f04-5f62-41a7-9782-b07a52a9d847` — QA: Execute iGubat Manual Test Plan v1.0 on Staging
**Build / commit:** `13eb692` (`13eb6920b02b2cdc862d20cb030ad72e6daf4fa0`), authored 2026-05-31T19:24:30+08:00
**Run date:** 2026-06-05
**Tester:** Automated execution agent (Claude Code), on behalf of QA — pending QA-lead sign-off
**Target environment:** Staging (per ticket §Preconditions)

---

## 0. Run Verdict — BLOCKED

> **This run is BLOCKED at the precondition gate.** Per the test plan §2 and the ticket's quoted instruction:
> *"If any precondition is missing, this ticket is blocked. Capture the missing items in the test-run report and do not mark Exit Criteria as met."*

The execution environment is a developer workstation. It has **no reachable staging deployment, no seeded test accounts, no SMS/email/push/map/export services, and no Android 8.0 / iOS 14 / desktop-browser device matrix**. None of the 50 manual cases (IG-001 … IG-050) nor the 5 smoke checklists (§4.1–§4.5) can be exercised against a live system from here. They are therefore recorded as **Blocked**, not Pass and not Fail. No results are fabricated.

The §6 Exit Criteria are evaluated below and **every line is marked Not Met** with justification, as required.

This report is the artifact the ticket asks for in the missing-precondition path. To convert it into a real, signed-off run, a QA tester with the §2 environment must re-execute against staging and replace the Blocked rows with observed results + evidence.

---

## 1. Precondition Checklist (§2) — gating gate

| # | Precondition (plan §2) | Status | Notes |
| --- | --- | --- | --- |
| 1 | Staging env reachable with SMS gateway, email, FCM/APNs, file upload, push, map provider, reporting/export configured | ❌ Not Met | No staging URL/credentials available in this environment; external integrations not provisioned/reachable. |
| 2 | 16 test accounts seeded (§2.1: `guest_mobile`, `auth_unverified`, `auth_verified_juan`, `auth_verified_maria`, `auth_pending_request`, `auth_in_review_request`, `auth_open_report`, `auth_locked`, `auth_deactivated`, `moderator_ops`, `moderator_content`, `admin_super`, `admin_secondary`) | ❌ Not Met | No seeded staging accounts available. (Plan §2.1 lists 13 named IDs under a "16 accounts" header — discrepancy to confirm with QA lead during a real run.) |
| 3 | Sample data seeded (§2.2: ≥3 barangays, 3 service types, 6 report categories, 5 Draft/10 Published/2 Archived articles, 5 carousel items, 3 banners, full emergency directory, upload corpus) | ❌ Not Met | No seeded staging data; file-upload corpus (valid JPEG/PNG/PDF ≤5 MB, oversized >5 MB, `.exe`/`.zip`) not provisioned. |
| 4 | Device & browser matrix (§2.3: Android 8.0 + recent, iOS 14 + recent, latest Chrome/Firefox/Edge/Safari at 13–15") | ❌ Not Met | No physical/emulated devices or desktop browsers attached to this run. |
| 5 | Ability to override device time (IG-001, IG-048) | ❌ Not Met | No device under control. |
| 6 | Audit-log access via `admin_super` (IG-007, IG-026, IG-040–IG-044) | ❌ Not Met | No portal/admin access. |

**Owner for unblocking:** LGU ICT Office QA / DevOps (staging provisioning + seed) — _assign in tracker_.
**Gate result:** preconditions not satisfied → execution does not proceed past the §4 smoke gate.

---

## 2. Smoke Checklist Results (§4)

All smoke items require the live staging build and device matrix from §2 (not met). All recorded **Blocked**. Per the execution workflow, an S1/S2 smoke failure blocks the run; here the smoke stage cannot start.

### 4.1 Mobile App Smoke (Guest) — 7 items — **Blocked** (env)
### 4.2 Mobile App Smoke (Authenticated User) — 8 items — **Blocked** (env)
### 4.3 Web Portal Smoke (Moderator) — 12 items — **Blocked** (env)
### 4.4 Web Portal Smoke (Admin) — 7 items — **Blocked** (env)
### 4.5 Cross-Cutting Smoke — 6 items — **Blocked** (env)

> §4.5 specifically requires: push on **Android + iOS**, OTP SMS, transactional email, daily-backup evidence, HTTPS-only redirect, session timeouts (30 min portal / 7 day mobile). None verifiable without staging + devices + infra runbook access.

---

## 3. Manual Case Results (§3) — IG-001 … IG-050

Report fields per ticket format: Case ID · Build · Tester · Environment · Account · Result · Severity · Defect link · Evidence · Notes.

- **Build / commit** for every row: `13eb692` (2026-05-31T19:24:30+08:00)
- **Tester** for every row: Automated execution agent (pending QA-lead re-run)
- **Environment / Account / Evidence** for every row: _Not available — no staging, no devices, no seeded accounts_
- **Result** for every row below: **Blocked**
- **Severity:** n/a (Blocked, not Failed — no defect filed; blocker is environmental)

| Case ID | Title (abbrev.) | Result | Blocking precondition(s) |
| --- | --- | --- | --- |
| IG-001 | Guest Home + time-of-day greeting | Blocked | §2.1, §2.3, §2.5 (time override) |
| IG-002 | Guest browses News + reads article | Blocked | §2.1, §2.2 (articles), §2.3 |
| IG-003 | Emergency screen + 911 slide-to-call (online & offline) | Blocked | §2.1, §2.2 (directory), §2.3 (dialer device) |
| IG-004 | Citizen Guide cached offline | Blocked | §2.1, §2.3 |
| IG-005 | Registration validation + DPA consent | Blocked | §2.1, §2.3 |
| IG-006 | OTP verification + resend rate limit | Blocked | §2.1, SMS gateway (§2.1 env) |
| IG-007 | Login lockout after 5 fails | Blocked | §2.1, **audit-log access (§2.6)** — mark Blocked if audit not in staging |
| IG-008 | Forgot Password via OTP invalidates sessions | Blocked | §2.1, two-device setup, SMS |
| IG-009 | Auth Home greeting + unread badge | Blocked | §2.1 (verified acct + unread notif) |
| IG-010 | Profile update + avatar upload | Blocked | §2.1, upload corpus (§2.2), OTP |
| IG-011 | Change password requires current pw | Blocked | §2.1, multi-device |
| IG-012 | Notification preferences honored at delivery | Blocked | §2.1, push (FCM/APNs), moderator acct |
| IG-013 | Appearance toggle Light/Dark | Blocked | §2.1, §2.3 |
| IG-014 | Submit Service Request + tracking number | Blocked | §2.1, upload corpus, service types (§2.2) |
| IG-015 | SR attachment validation (type/size) | Blocked | §2.1, upload corpus (incl. corrupted PDF) |
| IG-016 | Cancel Pending; blocked after In Review | Blocked | §2.1 accts `auth_pending_request`, `auth_in_review_request` |
| IG-017 | Push on every SR status change (Android + iOS) | Blocked | §2.1, push, **both devices (§4.5)** |
| IG-018 | Issue Report + GPS auto-detect + manual pin | Blocked | §2.1, §2.3 (location-capable device), map provider |
| IG-019 | Issue Report category constraints (6 canonical) | Blocked | §2.1, report categories (§2.2) |
| IG-020 | Track report + public remarks (Android + iOS) | Blocked | §2.1, push, both devices, moderator |
| IG-021 | Notification inbox: mark read / all / deep link | Blocked | §2.1 (multiple unread) |
| IG-022 | Offline submission queues + auto-retry; **original timestamp preserved** | Blocked | §2.1, §2.3 (airplane mode). Must verify original client timestamp on sync. |
| IG-023 | Offline cache: last 20 articles, hotlines, guide | Blocked | §2.1, §2.2, §2.3 |
| IG-024 | Sign out invalidates session | Blocked | §2.1 |
| IG-025 | Deactivated & locked accounts handled | Blocked | §2.1 accts `auth_locked`, `auth_deactivated` |
| IG-026 | Web login + 30-min idle timeout | Blocked | §2.1 portal creds, **audit-log (§2.6)** |
| IG-027 | Moderator full SR lifecycle + push per step | Blocked | §2.1, push, audit-log, citizen device |
| IG-028 | Moderator rejects SR | Blocked | §2.1, push |
| IG-029 | Moderator handles Issue Report via map | Blocked | §2.1, map provider, GPS report seed |
| IG-030 | Moderator authors/schedules/previews article | Blocked | §2.1, scheduler |
| IG-031 | Moderator archives article; removed from public | Blocked | §2.1, §2.2, mobile device |
| IG-032 | Moderator manages carousel + banner order | Blocked | §2.1, §2.2, cache invalidation |
| IG-033 | Moderator manages emergency directory | Blocked | §2.1, §2.2, mobile refresh |
| IG-034 | Moderator composes/sends broadcast (Android + iOS) | Blocked | §2.1, push, both devices, opted-in user |
| IG-035 | Moderator schedules future broadcast | Blocked | §2.1, scheduler |
| IG-036 | Moderator denied User Management (UI **and** URL) | Blocked | §2.1 moderator creds; RBAC requires UI + direct-URL + API check |
| IG-037 | Moderator denied Analytics (UI **and** URL) | Blocked | §2.1, RBAC dual check |
| IG-038 | Moderator denied Audit Log (UI **and** URL) | Blocked | §2.1, RBAC dual check |
| IG-039 | Moderator denied Settings (UI **and** URL) | Blocked | §2.1, RBAC dual check |
| IG-040 | Admin creates Moderator + forced first-login pw change | Blocked | §2.1, **audit-log (§2.6)**, email |
| IG-041 | Admin deactivate/reactivate citizen | Blocked | §2.1, mobile device, audit-log |
| IG-042 | Admin export citizens CSV honoring filters | Blocked | §2.1, §2.2, export service, audit-log |
| IG-043 | Admin Analytics dashboard + filters + PDF/CSV | Blocked | §2.1, sufficient data, export service |
| IG-044 | Admin Audit Log filters + export + append-only | Blocked | §2.1, **audit-log (§2.6)**, API access |
| IG-045 | Admin System Settings (canonical 6 categories protected) | Blocked | §2.1, §2.2 |
| IG-046 | Media: signed URLs + soft-delete (30-day window) | Blocked | §2.1, media asset, **live signed-URL expiry must be observed** |
| IG-047 | RBAC enforcement on API (403 admin endpoints, 401 expired) | Blocked | §2.1, moderator token via dev tools |
| IG-048 | Bilingual greetings across time-of-day (Cebuano/Visayan + Tagalog) | Blocked | §2.1, §2.5 (time override). Record exact rendered strings. |
| IG-049 | Cross-user data isolation (Juan vs Maria) | Blocked | §2.1 accts `auth_verified_juan`, `auth_verified_maria` |
| IG-050 | Performance smoke: ≤3 s ops + 500-concurrent baseline | Blocked | §2 staging mirrors prod; load tooling. **Must be measured, not estimated.** If load tooling absent: single-user timings + 500-concurrent Blocked w/ follow-up. |

**Totals:** 50 cases — Pass 0 · Fail 0 · **Blocked 50** · N/A 0. Defects filed: 0 (blocker is environmental, not a product defect).

---

## 4. Special Coverage Notes (ticket §Special Coverage) — disposition

- **IG-007 / IG-026 / IG-040–IG-044 (audit log):** If the audit-log feature is not yet in staging, these stay **Blocked** (do not silently pass). Not verifiable here.
- **IG-036–IG-039, IG-047 (RBAC):** Pass requires **both** UI (sidebar hidden + in-app nav) **and** direct-URL + raw API call with a Moderator token. Neither path exercised → Blocked.
- **IG-022 (offline):** Must confirm the **original client-side submission timestamp** is preserved after sync (verify on reconnect, not mere eventual appearance). Blocked.
- **IG-046 (media):** Soft-delete recoverability within the 30-day window with a freshly soft-deleted asset; signed-URL expiry observed **live**. Blocked.
- **IG-050 (performance):** Numbers must be **measured**. No load tooling/staging here → Blocked (single-user timings also unavailable without staging).
- **IG-017, IG-020, IG-027, IG-034 (push):** Delivery must be confirmed on **both** Android and iOS (§4.5). Blocked.
- **IG-048 (bilingual greetings):** Verify Cebuano/Visayan ("Maayong Buntag/Hapon/Gabii") and Tagalog variants; record exact rendered strings. Blocked.

---

## 5. Exit Criteria Evaluation (§6) — each line Met / Not Met

| # | Exit Criterion (§6) | Verdict | Justification |
| --- | --- | --- | --- |
| 1 | All S1 & S2 tests pass (or approved defect + workaround) | **Not Met** | No S1/S2 case executed; all Blocked. |
| 2 | No Moderator reaches User Mgmt / Analytics / Audit / Settings via UI **or** URL | **Not Met** | RBAC (IG-036–039, IG-047) not exercised. |
| 3 | Registration + OTP reliable, DPA consent captured + audit-logged | **Not Met** | IG-005/006 Blocked; no SMS/audit. |
| 4 | Service Request lifecycle end-to-end + push per step | **Not Met** | IG-014/017/027/028 Blocked. |
| 5 | Issue Report lifecycle + GPS + map + notifications | **Not Met** | IG-018/020/029 Blocked. |
| 6 | Emergency surfaces (911, COMCEN, directory) online + offline; broadcasts delivered | **Not Met** | IG-003/033/034/035 Blocked. |
| 7 | Content mgmt (articles, carousel, banners, media) with scheduling + archival | **Not Met** | IG-030–032/046 Blocked. |
| 8 | User & Staff Management with audit logging on every change | **Not Met** | IG-040–042 Blocked; no audit-log. |
| 9 | Audit Log append-only, read-only, exportable | **Not Met** | IG-044 Blocked. |
| 10 | Analytics renders with filters + exports (PDF + CSV) | **Not Met** | IG-043 Blocked. |
| 11 | NFRs: HTTPS-only, ≤3 s response, 500-concurrent baseline, daily backups | **Not Met** | IG-050 + §4.5 Blocked. |
| 12 | Mobile compatibility on Android 8.0 **and** iOS 14 baseline + one current each | **Not Met** | No device matrix. |
| 13 | Bilingual greetings render across morning/afternoon/evening | **Not Met** | IG-048 Blocked. |

**Exit Criteria overall: NOT MET (0/13).** Release is **not** certifiable on this run.

---

## 6. Sign-off

| Role | Name | Verdict | Date |
| --- | --- | --- | --- |
| Executing agent | Claude Code (automated) | Blocked — preconditions unmet | 2026-06-05 |
| QA Lead | _pending_ | _pending re-run on provisioned staging_ | — |

**Next action:** Provision staging per §2 (env + integrations + 16 accounts + sample data + device matrix + audit-log access), assign blocker owner in the issue tracker, then re-execute and replace the Blocked rows in this report (or a dated successor `manual-test-run-<YYYY-MM-DD>-<buildSha>.md`) with observed results and evidence before evaluating Exit Criteria again.

---

_Report generated for ticket 6b564f04-5f62-41a7-9782-b07a52a9d847. Source plan unchanged (out of scope to edit). No defects filed — sole blocker is the absence of a staging environment and device matrix in this execution context._
