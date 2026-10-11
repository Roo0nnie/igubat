# User Stories — Admin

## iGubat — LGU Digital Services Application

> **Role:** Admin  
> **Description:** LGU administrators with full oversight of the web administration portal — user and staff account management, analytics, audit logs, system settings, permanent deletion, and CSV/PDF exports.  
> **Derived from:** `igubat_user_stories.md` v1.1 (aligned to `igubat_tor.md` v3.2)  
> **Story count:** 24

Story format:

- **As an** Admin
- **I want to** [capability]
- **So that** [outcome]
- **Acceptance Criteria:** bullet list of testable conditions.

Stories retain their original numbering (Section.Story) from the master `igubat_user_stories.md` for cross-reference. Stories shared with another role (e.g., Guest/Authenticated User offline access, Moderator/Admin staff login) appear in both role files.

---

## 1. Authentication *(Focused Development)*

### Story 1.9 — Staff Login to Web Administration Portal

**As a** Moderator or Admin  
**I want to** sign in to the web administration portal with my staff email and password  
**So that** I can perform my operational duties.

**Acceptance Criteria:**

- Login URL is distinct from the citizen-facing app.
- Successful login routes to the role-appropriate dashboard.
- Session expires after 30 minutes of inactivity (default, configurable by Admin).
- Login and logout events are written to the audit log with timestamp and IP address.

---

### Story 1.10 — Admin Forces Password Reset

**As an** Admin  
**I want to** force a password reset for any staff or citizen account  
**So that** I can respond to credential compromise or staff offboarding.

**Acceptance Criteria:**

- Admin can initiate a forced reset from the user detail page.
- The targeted account's existing sessions are invalidated immediately.
- The reset action is logged.

---

---

## 2. Citizen Profile Management

### Story 2.7 — Admin Manages Citizen Accounts (Without Direct Edit)

**As an** Admin  
**I want to** search citizen accounts and change account status (verify, deactivate, reactivate)  
**So that** I can administer the user base while respecting DPA-driven self-edit rules.

**Acceptance Criteria:**

- Admin cannot directly edit personal data fields.
- Status transitions are logged in the audit log.
- A citizen may request data correction through a documented support channel.

---

---

## 4. News and Announcements

### Story 4.11 — Admin Permanently Deletes Content

**As an** Admin  
**I want to** permanently delete an article, banner, or media asset  
**So that** I can remove content that should not be retained.

**Acceptance Criteria:**

- Deletion requires explicit confirmation.
- Action is logged in the audit log.

---

---

## 5. Service Requests *(Focused Development)*

### Story 5.10 — Admin Configures Service Types

**As an** Admin  
**I want to** configure service types, categories, and request form fields  
**So that** the catalogue matches LGU operations.

**Acceptance Criteria:**

- Admin can add/edit/disable service types.
- Form field changes are versioned to avoid breaking historical records.

---

---

## 6. Issue and Concern Reports *(Focused Development)*

### Story 6.8 — Admin Views Reports on an Interactive Map

**As an** Admin  
**I want to** view all reports on an interactive map with filters and a heatmap  
**So that** I can spot patterns across barangays.

**Acceptance Criteria:**

- Heatmap toggle.
- Filters: category, status, barangay, date range.
- Clicking a pin opens the report detail.

---

---

## 7. Emergency Hotline and Directory *(Focused Development)*

### Story 7.9 — Admin Manages Broadcast and Directory at Full Scope

**As an** Admin  
**I want to** permanently delete directory entries and manage the full broadcast history  
**So that** I can correct mistakes and maintain governance.

**Acceptance Criteria:**

- Hard-delete action is restricted to Admin and requires confirmation.
- All hard-delete actions are written to the audit log.

---

---

## 8. Notifications

### Story 8.4 — Admin Views Notification Delivery Logs

**As an** Admin  
**I want to** view notification delivery logs (sent/delivered/failed)  
**So that** I can diagnose delivery issues.

**Acceptance Criteria:**

- Logs filterable by channel (push, email, in-app) and date range.
- Failed deliveries surface the failure reason.

---

---

## 9. User and Staff Account Management

### Story 9.1 — Admin Creates a Moderator Account

**As an** Admin  
**I want to** create a new Moderator account with name, email, and temporary password  
**So that** LGU staff can sign in to the web portal.

**Acceptance Criteria:**

- Email uniqueness enforced.
- Temporary password is delivered via secure channel.
- New Moderator is required to change password on first login.

---

### Story 9.2 — Admin Edits, Deactivates, or Reactivates Staff

**As an** Admin  
**I want to** edit, deactivate, or reactivate any staff account  
**So that** the staff roster reflects current personnel.

**Acceptance Criteria:**

- Deactivated accounts cannot sign in; existing sessions are invalidated.
- All actions are logged.

---

### Story 9.3 — Admin Resets Any Staff Password

**As an** Admin  
**I want to** reset the password for any staff account  
**So that** I can unblock staff members.

**Acceptance Criteria:**

- Reset triggers a notification to the staff member with a single-use temporary password.
- The targeted account's sessions are invalidated.

---

### Story 9.4 — Admin Manages Citizen Accounts

**As an** Admin  
**I want to** view, search, verify, deactivate, reactivate, or delete citizen accounts  
**So that** the citizen base is maintained.

**Acceptance Criteria:**

- Search by name, mobile, email, barangay.
- Deletion is hard-delete with confirmation; soft-deactivate is preferred.
- Actions are logged.

---

### Story 9.5 — Admin Exports Citizen List to CSV

**As an** Admin  
**I want to** export the citizen account list to CSV  
**So that** I can integrate with other LGU systems and audits.

**Acceptance Criteria:**

- Export respects current search/filter context.
- Sensitive fields are redacted per LGU policy.

---

### Story 9.6 — Admin Views Login Activity

**As an** Admin  
**I want to** view login activity for any account  
**So that** I can investigate suspicious access.

**Acceptance Criteria:**

- Activity shows timestamp, IP, user agent, success/failure.
- Filterable by date range.

---

---

## 10. Analytics and Reports

### Story 10.1 — Admin Views Analytics Dashboard

**As an** Admin  
**I want to** see DAU/MAU, new registrations, request volume, report categories, and notification stats  
**So that** I have operational visibility.

**Acceptance Criteria:**

- Widgets render summary numbers and charts.
- Skeletons display while data loads.

---

### Story 10.2 — Admin Filters Analytics

**As an** Admin  
**I want to** filter analytics by date range, barangay, and service type  
**So that** I can analyze specific cohorts and time windows.

**Acceptance Criteria:**

- Filter changes refetch all widgets.
- Active filters are visible as chips with clear-all action.

---

### Story 10.3 — Admin Exports Reports

**As an** Admin  
**I want to** export reports to PDF or CSV  
**So that** I can share with LGU leadership.

**Acceptance Criteria:**

- Export reflects current filters.
- Large exports show progress and are emailed when ready (optional).

---

---

## 11. Audit and Activity Logging

### Story 11.2 — Admin Views the Audit Log

**As an** Admin  
**I want to** view the audit log with search and filter by actor, role, action type, and date range  
**So that** I can investigate incidents.

**Acceptance Criteria:**

- Pagination supports large logs.
- Drill-down view shows full event details.

---

### Story 11.3 — Admin Exports the Audit Log

**As an** Admin  
**I want to** export the audit log to CSV  
**So that** I can submit it for external audit.

**Acceptance Criteria:**

- Export honors current filters.
- The export action itself is logged.

---

---

## 12. File and Media Management

### Story 12.5 — Admin Force-Deletes Files

**As an** Admin  
**I want to** permanently delete files immediately  
**So that** I can comply with content takedown obligations.

**Acceptance Criteria:**

- Confirmation dialog with explicit warning.
- Action is logged.

---

---

## 13. Geolocation and Mapping

### Story 13.4 — Admin Sees All Reports as a Heatmap

**As an** Admin  
**I want to** toggle a heatmap of all reports  
**So that** I can identify hot spots.

**Acceptance Criteria:**

- Heatmap supports the same filters as the list view.

---

---

## 15. Tourism, Culture &amp; Local Products (Discover Gubat)

### Story 15.6 — Admin Permanently Deletes a Discover Gubat Entry

**As an** Admin  
**I want to** permanently delete a tourist spot, culture article, or local product entry  
**So that** I can remove content that should not be retained.

**Acceptance Criteria:**

- Delete defaults to soft-delete (30-day retention); permanent delete is Admin-only and requires explicit confirmation.
- The action is logged in the audit log.

---

---

## 16. Transparency &amp; Good Governance *(Focused Development)*

### Story 16.9 — Admin Permanently Deletes an Item

**As an** Admin **I want to** permanently delete an item **so that** content that should not be retained is removed.

**Acceptance Criteria:** soft-delete (30-day retention) is the default; permanent delete is Admin-only, requires a confirmation modal, and writes an audit record.

---

### Story 16.10 — Admin Exports the Transparency List to CSV

**As an** Admin **I want to** export the transparency item list to CSV **so that** I can report on disclosures.

**Acceptance Criteria:** Export CSV is Admin-only; a direct API call without admin returns 403.

---

---

*Admin user stories — 24 stories across 14 feature sections. Extracted from `igubat_user_stories.md` v1.1. Companion files: igubat_user_stories_guest.md, igubat_user_stories_authenticated_user.md, igubat_user_stories_moderator.md, igubat_user_stories_admin.md. System-actor stories (background jobs, audit logging, retries) remain documented only in the master file.*