# User Stories — Authenticated User

## iGubat — LGU Digital Services Application

> **Role:** Authenticated User  
> **Description:** A registered, verified citizen signed in to the mobile app. Authenticated Users can submit and track service requests and issue reports, manage their profile, and control notification preferences.  
> **Derived from:** `igubat_user_stories.md` v1.1 (aligned to `igubat_tor.md` v3.2)  
> **Story count:** 33

Story format:

- **As an** Authenticated User
- **I want to** [capability]
- **So that** [outcome]
- **Acceptance Criteria:** bullet list of testable conditions.

Stories retain their original numbering (Section.Story) from the master `igubat_user_stories.md` for cross-reference. Stories shared with another role (e.g., Guest/Authenticated User offline access, Moderator/Admin staff login) appear in both role files.

---

## 1. Authentication *(Focused Development)*

### Story 1.5 — Login with Mobile or Email

**As an** Authenticated User  
**I want to** sign in using my mobile number or email and password  
**So that** I can access my account.

**Acceptance Criteria:**

- Both mobile number and email are accepted as identifiers.
- Invalid credentials show a generic error (no disclosure of which field is wrong).
- Successful login routes to the authenticated Home with personalized greeting.

---

### Story 1.7 — Forgot Password / Reset via OTP

**As an** Authenticated User who forgot my password  
**I want to** reset my password via an OTP sent to my registered mobile or email  
**So that** I can regain access without staff intervention.

**Acceptance Criteria:**

- Reset request accepts mobile or email.
- A single-use, time-bound OTP is delivered.
- New password is subject to the same complexity rules as registration.
- Successful reset invalidates all existing sessions.

---

### Story 1.8 — Logout from Mobile App

**As an** Authenticated User  
**I want to** sign out from the mobile app  
**So that** my account is no longer accessible from the device.

**Acceptance Criteria:**

- Logout invalidates the current session token server-side.
- App returns to the Guest home screen with the sign-in prompt visible.

---

---

## 2. Citizen Profile Management

### Story 2.1 — View and Update Profile

**As an** Authenticated User  
**I want to** view and update my profile (name, address, barangay, contact)  
**So that** my information stays accurate for service delivery.

**Acceptance Criteria:**

- Edits persist on save.
- Barangay change is restricted to the canonical list.
- Contact number change triggers re-verification via OTP.

---

### Story 2.2 — Upload or Change Profile Photo

**As an** Authenticated User  
**I want to** upload or change my profile photo  
**So that** my account has a personal identifier.

**Acceptance Criteria:**

- Accepted formats: JPEG, PNG, GIF; max 5 MB.
- Uploaded image is auto-compressed.
- Photo updates everywhere it appears (greeting avatar, request author).

---

### Story 2.3 — Change Password

**As an** Authenticated User  
**I want to** change my password after verifying my current password  
**So that** I can maintain account security.

**Acceptance Criteria:**

- Current password verification is required.
- New password complies with complexity rules.
- All other active sessions are signed out.

---

### Story 2.4 — Manage Notification Preferences

**As an** Authenticated User  
**I want to** enable or disable specific push notification types  
**So that** I control what I am notified about.

**Acceptance Criteria:**

- Categories: News, Service Request status, Issue Report status, Emergency Broadcasts.
- Emergency Broadcasts may be muted only with an explicit confirmation dialog (high-risk opt-out).

---

### Story 2.5 — Set Appearance (Light/Dark)

**As an** Authenticated User  
**I want to** choose between light and dark mode  
**So that** the app is comfortable for me to use at any time of day.

**Acceptance Criteria:**

- Preference persists across sessions.
- The chosen theme applies on next render.

---

---

## 3. Home and Navigation

### Story 3.3 — Authenticated User Sees Personalized Home

**As an** Authenticated User  
**I want to** see a greeting using my first name and an unread-count badge on the bell  
**So that** the app feels personal and I can see new notifications at a glance.

**Acceptance Criteria:**

- Greeting renders the user's first name.
- Badge shows unread notification count; tapping opens the in-app notification inbox.

---

---

## 4. News and Announcements

### Story 4.5 — Authenticated User Receives Push on New Article

**As an** Authenticated User with news notifications enabled  
**I want to** receive a push notification when a new article is published  
**So that** I do not miss timely civic news.

**Acceptance Criteria:**

- Push is sent within 1 minute of publication.
- The notification deep-links to the article view.

---

---

## 5. Service Requests *(Focused Development)*

### Story 5.2 — Authenticated User Browses Services

**As an** Authenticated User  
**I want to** browse available services organized by category  
**So that** I can find the service I need.

**Acceptance Criteria:**

- Categories include e-Services and Popular Services.
- The three canonical service types (Facility Use, Medical Assistance, Transportation Assistance) are visible.

---

### Story 5.3 — Authenticated User Submits a Service Request

**As an** Authenticated User  
**I want to** submit a service request with service type, description, preferred date/time, and up to 3 attachments  
**So that** the LGU can act on it.

**Acceptance Criteria:**

- Contact information is auto-populated from the profile.
- Attachments enforce: JPEG/PNG/GIF/PDF, max 5 MB each, max 3 files.
- On success, a tracking number is generated and shown.
- Initial status is **Pending**.

---

### Story 5.4 — Authenticated User Views Request History

**As an** Authenticated User  
**I want to** see the full list and status history of all my submitted requests  
**So that** I can track progress.

**Acceptance Criteria:**

- List sortable by submission date.
- Status badge per item.
- Detail view shows full timeline of status changes with timestamps.

---

### Story 5.5 — Authenticated User Cancels a Pending Request

**As an** Authenticated User  
**I want to** cancel a request that is still in **Pending** status  
**So that** I can withdraw a submission I no longer need.

**Acceptance Criteria:**

- Cancel control is visible only while status is **Pending**.
- Cancellation is recorded in the status history.

---

### Story 5.6 — Authenticated User Receives Push on Status Change

**As an** Authenticated User  
**I want to** receive a push notification when my request status changes  
**So that** I am informed without re-opening the app.

**Acceptance Criteria:**

- Push fires on every status transition.
- The notification deep-links to the request detail view.

---

---

## 6. Issue and Concern Reports *(Focused Development)*

### Story 6.1 — Authenticated User Files an Issue Report

**As an** Authenticated User  
**I want to** submit a report with category, description, up to 3 photos, and GPS location  
**So that** the LGU can address the issue.

**Acceptance Criteria:**

- Category selectable from canonical list: Road Damage, Flooding, Waste Management, Street Lighting, Public Safety, Others.
- GPS is auto-detected with a manually adjustable pin on a map.
- Initial status is **Received**.

---

### Story 6.2 — Authenticated User Adjusts the Map Pin

**As an** Authenticated User  
**I want to** adjust the GPS pin manually before submitting  
**So that** the location is accurate even if my device GPS is off.

**Acceptance Criteria:**

- Pin is draggable on an interactive map.
- Selected latitude/longitude are stored with the report.

---

### Story 6.3 — Authenticated User Tracks Submitted Reports

**As an** Authenticated User  
**I want to** see status and LGU remarks on all reports I submitted  
**So that** I know how my concerns are being handled.

**Acceptance Criteria:**

- Status reflects canonical lifecycle: `Received → In Progress → Resolved → Closed`.
- Public-facing remarks (added by Moderator) are visible to the citizen.

---

### Story 6.4 — Authenticated User Receives Push on Report Status Change

**As an** Authenticated User  
**I want to** receive push notifications on every status change of my report  
**So that** I stay informed.

**Acceptance Criteria:**

- Push fires for every transition.
- Push deep-links to the report detail.

---

---

## 7. Emergency Hotline and Directory *(Focused Development)*

### Story 7.4 — Authenticated User Receives Emergency Broadcast

**As an** Authenticated User  
**I want to** receive emergency broadcast alerts as high-priority push notifications  
**So that** I am warned about critical events.

**Acceptance Criteria:**

- Emergency broadcasts bypass the default notification mute unless the user has explicitly opted out with confirmation.
- The notification is marked high priority by the OS.

---

---

## 8. Notifications

### Story 8.1 — Authenticated User Sees In-App Notification Inbox

**As an** Authenticated User  
**I want to** see all received notifications in an in-app inbox  
**So that** I can review platform events without leaving the app.

**Acceptance Criteria:**

- Inbox is reachable from the notification bell.
- Mark-as-read and bulk mark-all-as-read are supported.
- Deep links route to the relevant detail screen.

---

### Story 8.2 — Authenticated User Honors Channel Preferences

**As an** Authenticated User  
**I want to** the system to honor the notification preferences I set  
**So that** I am not notified about things I opted out of.

**Acceptance Criteria:**

- Preferences are honored at delivery time per category.
- Emergency Broadcasts override mute unless explicit opt-out confirmation has been provided.

---

---

## 12. File and Media Management

### Story 12.1 — Authenticated User Uploads Attachments

**As an** Authenticated User  
**I want to** attach up to 3 files (JPEG/PNG/GIF/PDF, ≤5 MB each) to a request or report  
**So that** I can supply evidence.

**Acceptance Criteria:**

- Server validates MIME and size.
- Uploaded files are accessible only via signed, time-limited URLs.

---

---

## 13. Geolocation and Mapping

### Story 13.1 — Authenticated User Grants Location Permission

**As an** Authenticated User  
**I want to** be asked for location permission only when filing an issue report  
**So that** I understand why my location is needed.

**Acceptance Criteria:**

- Permission prompt is contextual to the report flow.
- Denial leaves the manual pin selection available.

---

### Story 13.2 — Authenticated User Adjusts Pin on Interactive Map

**As an** Authenticated User  
**I want to** drag the pin on a map to adjust the location  
**So that** the location is accurate.

**Acceptance Criteria:**

- Map supports zoom and pan.
- Selected coordinates persist with the report.

---

---

## 14. Connectivity and Offline Support

### Story 14.1 — Mobile App Caches Recent News for Offline Viewing

**As an** Authenticated User or Guest  
**I want to** read recently loaded news articles when offline  
**So that** I am informed even without connectivity.

**Acceptance Criteria:**

- Cache holds the last 20 articles.
- Cached articles display a "Last updated" timestamp.

---

### Story 14.2 — Mobile App Caches Emergency Hotlines and Directory

**As a** Guest or Authenticated User  
**I want to** access emergency hotlines and the partner directory when offline  
**So that** I can call for help without connectivity.

**Acceptance Criteria:**

- COMCEN, hospitals, BFP, PNP entries are cached on first load.
- Tap-to-call works using device dialer regardless of connectivity.

---

### Story 14.3 — Mobile App Shows Offline Notice on Submit

**As an** Authenticated User attempting to submit while offline  
**I want to** see an offline notice and have the submission queued  
**So that** I do not lose my work.

**Acceptance Criteria:**

- Notice explains the offline state.
- The submission is auto-retried when connectivity returns and the original submission timestamp is preserved.

---

---

## 15. Tourism, Culture &amp; Local Products (Discover Gubat)

### Story 15.4 — Authenticated User Receives Push on New Discover Gubat Item

**As an** Authenticated User with Discover Gubat notifications enabled  
**I want to** receive a push notification when a new tourist spot, culture article, or local product is published  
**So that** I learn about new things to explore.

**Acceptance Criteria:**

- Push is sent on publish only when the Moderator enabled "Notify subscribers" and the user has the category enabled.
- The notification deep-links to the relevant Discover Gubat detail.

---

### Story 15.7 — Discover Gubat Is Available Offline

**As a** Guest or Authenticated User  
**I want to** access recently loaded Discover Gubat content when offline  
**So that** I can still explore tourism, culture, and product information without connectivity.

**Acceptance Criteria:**

- Tourist spots, culture articles, and local products loaded online are cached and render offline.
- Cached Discover Gubat content shows a "Last updated" timestamp.

---

---

## 16. Transparency &amp; Good Governance *(Focused Development)*

### Story 16.4 — Authenticated User Subscribes to Transparency Notifications

**As an** Authenticated User **I want to** toggle the `transparency` notification category **so that** I am alerted when a new transparency item is published.

**Acceptance Criteria:** preference appears in notification settings; when enabled, in-app + push + email are dispatched on publish.

---

### Story 16.5 — Authenticated User Deep-Links from a Push

**As an** Authenticated User **I want to** tap a transparency push **so that** I land directly on the item detail.

**Acceptance Criteria:** push `metadata.type = "transparency"` + `metadata.slug` deep-links to `/transparency/:type/:slug`.

---

### Story 16.11 — Citizens View Cached Transparency Items Offline

**As a** Guest or Authenticated User **I want to** view recently loaded transparency items offline **so that** I can read disclosures without connectivity.

**Acceptance Criteria:** previously loaded list items render offline with a "Last updated · cached" banner; attachments require network unless previously opened.

---

*Document version 1.1 — aligned to `igubat_tor.md` v3.2. Roles: Guest, Authenticated User, Moderator, Admin, System. 16 sections, 95+ user stories.*

---

*Authenticated User user stories — 33 stories across 13 feature sections. Extracted from `igubat_user_stories.md` v1.1. Companion files: igubat_user_stories_guest.md, igubat_user_stories_authenticated_user.md, igubat_user_stories_moderator.md, igubat_user_stories_admin.md. System-actor stories (background jobs, audit logging, retries) remain documented only in the master file.*