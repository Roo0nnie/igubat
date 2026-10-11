# User Stories — Moderator

## iGubat — LGU Digital Services Application

> **Role:** Moderator  
> **Description:** LGU staff signed in to the web administration portal. Moderators process citizen submissions, author and publish content, and manage day-to-day operations, but are blocked from user management, analytics, and permanent-delete actions.  
> **Derived from:** `igubat_user_stories.md` v1.1 (aligned to `igubat_tor.md` v3.2)  
> **Story count:** 26

Story format:

- **As a** Moderator
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

---

## 2. Citizen Profile Management

### Story 2.6 — Moderator Views Citizen Profile (Read-Only)

**As a** Moderator  
**I want to** view a citizen's basic profile when processing their submission  
**So that** I have the context to act on the request.

**Acceptance Criteria:**

- Visible fields: name, barangay, contact number.
- No edit controls are available to the Moderator.

---

---

## 4. News and Announcements

### Story 4.6 — Moderator Authors a News Article

**As a** Moderator  
**I want to** create a new article using a rich text editor with headings, paragraphs, lists, and inline images  
**So that** I can communicate LGU news.

**Acceptance Criteria:**

- Editor supports headings, paragraphs, lists, links, and inline images.
- I can assign categories, tags, and a featured image.
- I can save as **Draft**, schedule a future publication, or publish immediately.

---

### Story 4.7 — Moderator Schedules Publication

**As a** Moderator  
**I want to** schedule an article for a future publication date and time  
**So that** announcements appear at the right moment.

**Acceptance Criteria:**

- Scheduled articles remain in **Draft** state until the scheduled time, then transition to **Published**.
- Cancelling a scheduled publication returns the article to **Draft**.

---

### Story 4.8 — Moderator Archives an Article

**As a** Moderator  
**I want to** archive a previously published article  
**So that** it is no longer visible to citizens but remains in the system.

**Acceptance Criteria:**

- Archived articles disappear from the public feed and carousel.
- Status filter shows **Draft | Published | Archived** options.

---

### Story 4.9 — Moderator Manages Carousel and Banners

**As a** Moderator  
**I want to** add, reorder, and remove items in the featured stories carousel and the homepage banners  
**So that** the home screen reflects current priorities.

**Acceptance Criteria:**

- Drag-and-drop reordering with autosave.
- Activate/deactivate toggle per banner.
- Preview changes before publishing.

---

### Story 4.10 — Moderator Previews Before Publishing

**As a** Moderator  
**I want to** preview an article as a Guest would see it before publishing  
**So that** I catch layout issues.

**Acceptance Criteria:**

- Preview mode opens in a separate route or modal.
- Preview reflects the latest unsaved edits.

---

---

## 5. Service Requests *(Focused Development)*

### Story 5.7 — Moderator Views Service Request Queue

**As a** Moderator  
**I want to** view and filter the full queue of service requests  
**So that** I can prioritize work.

**Acceptance Criteria:**

- Filters: service type, status, barangay, date range.
- Default sort is oldest-first by submission date.

---

### Story 5.8 — Moderator Opens and Updates a Request

**As a** Moderator  
**I want to** open a request to view full details and update its status  
**So that** I can drive the request to completion.

**Acceptance Criteria:**

- Allowed transitions follow the canonical lifecycle: `Pending → In Review → Approved | Rejected | For Pickup → Completed`.
- Each transition optionally accepts an internal remark.
- Each transition triggers a notification to the citizen.

---

### Story 5.9 — Moderator Adds Internal Remarks

**As a** Moderator  
**I want to** add staff-only remarks on a request  
**So that** colleagues understand the handling context.

**Acceptance Criteria:**

- Remarks are visible only to Moderator and Admin.
- Remarks are timestamped and authored.

---

---

## 6. Issue and Concern Reports *(Focused Development)*

### Story 6.5 — Moderator Views Reports Queue and Map

**As a** Moderator  
**I want to** view reports in a list and on a map  
**So that** I can prioritize by category, severity, and location.

**Acceptance Criteria:**

- List filters: category, status, barangay, date range.
- Map view plots pins by category color and supports zoom to barangay.

---

### Story 6.6 — Moderator Updates Report Status

**As a** Moderator  
**I want to** update report status through the canonical lifecycle  
**So that** the citizen is informed and the audit trail is accurate.

**Acceptance Criteria:**

- Allowed transitions: `Received → In Progress → Resolved → Closed`.
- Each transition triggers a notification to the reporting citizen.

---

### Story 6.7 — Moderator Adds Public Remarks and Internal Notes

**As a** Moderator  
**I want to** add public remarks visible to the citizen and internal notes visible only to staff  
**So that** I can communicate appropriately.

**Acceptance Criteria:**

- Two distinct fields: "Reply to citizen" and "Internal note".
- Public remarks appear in the citizen's report detail timeline.

---

---

## 7. Emergency Hotline and Directory *(Focused Development)*

### Story 7.5 — Moderator Manages Directory Entries

**As a** Moderator  
**I want to** add, edit, and deactivate entries in the COMCEN hotlines list and partner directory  
**So that** citizens always see accurate emergency contacts.

**Acceptance Criteria:**

- Fields per entry: name, category, address, contact number, hours, status (active/inactive).
- Changes are reflected in the mobile app within minutes (cache invalidation considered).

---

### Story 7.6 — Moderator Composes and Sends Broadcasts

**As a** Moderator  
**I want to** compose and send an emergency broadcast push notification to all app users  
**So that** I can warn citizens during an incident.

**Acceptance Criteria:**

- Composer shows character count and preview.
- Send action requires explicit confirmation.
- Delivery summary (recipient count, failures) is shown after dispatch.

---

### Story 7.7 — Moderator Schedules a Broadcast

**As a** Moderator  
**I want to** schedule a broadcast for a future date and time  
**So that** announcements arrive at the appropriate moment.

**Acceptance Criteria:**

- A pending broadcast appears in a schedule list with edit and cancel options before send time.

---

### Story 7.8 — Moderator Views Broadcast History

**As a** Moderator  
**I want to** see the history of all broadcasts sent  
**So that** I can audit our communication.

**Acceptance Criteria:**

- History shows message, sender, timestamp, and recipient count.
- Search by date range.

---

---

## 8. Notifications

### Story 8.3 — Moderator Triggers Optional Push on Article Publish

**As a** Moderator  
**I want to** optionally push a notification when publishing an article  
**So that** important news reaches subscribers immediately.

**Acceptance Criteria:**

- A "Notify subscribers" checkbox appears on the publish action.
- The check is logged with the article record.

---

---

## 9. User and Staff Account Management

### Story 9.7 — Moderator Cannot Access User Management

**As a** Moderator  
**I want to** be blocked from User Management surfaces  
**So that** the role boundary is enforced.

**Acceptance Criteria:**

- Sidebar/navigation hides User Management for Moderator.
- Direct URL navigation returns 403/redirects to the dashboard.

---

---

## 10. Analytics and Reports

### Story 10.4 — Moderator Cannot Access Analytics

**As a** Moderator  
**I want to** be blocked from the Analytics surfaces  
**So that** the role boundary is enforced.

**Acceptance Criteria:**

- Analytics is hidden from the Moderator sidebar.
- Direct URL navigation returns 403.

---

---

## 12. File and Media Management

### Story 12.4 — Moderator Uses the Media Asset Manager

**As a** Moderator  
**I want to** browse, upload, and delete media in the admin portal  
**So that** I can manage article and banner assets.

**Acceptance Criteria:**

- Delete defaults to soft-delete (30-day retention).
- Search/filter by name, type, upload date.

---

---

## 13. Geolocation and Mapping

### Story 13.3 — Moderator Sees a Single Report on a Map

**As a** Moderator  
**I want to** open a report and see its location on a map  
**So that** I can plan dispatch.

**Acceptance Criteria:**

- Map shows the pin and address (reverse-geocoded where available).

---

---

## 15. Tourism, Culture &amp; Local Products (Discover Gubat)

### Story 15.5 — Moderator Manages Discover Gubat Entries

**As a** Moderator  
**I want to** create, edit, publish, schedule, and archive tourist spots, culture articles, and local products  
**So that** the Discover Gubat surface stays accurate and current.

**Acceptance Criteria:**

- Entries follow the canonical lifecycle: **Draft | Published | Archived**.
- I can upload photos, assign a category, set a featured image, and set a map location for tourist spots.
- I can preview an entry as a citizen would see it before publishing.
- Archived entries disappear from the public surface but remain in the system.

---

---

## 16. Transparency &amp; Good Governance *(Focused Development)*

### Story 16.6 — Moderator Creates a Transparency Item

**As a** Moderator **I want to** create an item of any of the six types **so that** I can disclose LGU records.

**Acceptance Criteria:** type selector → type-specific fields → attachments (≤10, ≤10 MB each) → Save Draft / Schedule / Publish Now with "Notify subscribers" checkbox.

---

### Story 16.7 — Moderator Schedules an Item

**As a** Moderator **I want to** schedule an item **so that** it auto-publishes at the scheduled time.

**Acceptance Criteria:** item enters `Scheduled`; the cron sweep promotes it to `Published` at `publishedAt`; subscribers notified if opted in.

---

### Story 16.8 — Moderator Archives an Item

**As a** Moderator **I want to** archive an item **so that** it leaves the public list while the record is retained.

**Acceptance Criteria:** archived items disappear from public lists but remain in the CMS and can be re-published.

---

---

*Moderator user stories — 26 stories across 13 feature sections. Extracted from `igubat_user_stories.md` v1.1. Companion files: igubat_user_stories_guest.md, igubat_user_stories_authenticated_user.md, igubat_user_stories_moderator.md, igubat_user_stories_admin.md. System-actor stories (background jobs, audit logging, retries) remain documented only in the master file.*