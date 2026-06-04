# User Stories

## iGubat — LGU Digital Services Application

> Derived from `igubat_tor.md` v3.1. Roles map to the four canonical platform identities: **Guest**, **Authenticated User**, **Moderator**, **Admin**. The role **System** is used where the application itself is the actor (background notifications, audit logging, retries).

Sections marked *(Focused Development)* are the highest-priority delivery areas per TOR v3.1 §6 and must reach production-ready state before secondary modules ship.

Story format:

- **As a** [role]
- **I want to** [capability]
- **So that** [outcome]
- **Acceptance Criteria:** bullet list of testable conditions.

---

## 1. Authentication *(Focused Development)*

### Story 1.1 — Guest Views Sign-In Prompt

**As a** Guest  
**I want to** see a "Create Account" call-to-action on the home screen  
**So that** I know how to register if I want to access citizen-only features.

**Acceptance Criteria:**

- The home screen displays a visible "Sign in / Create Account" entry point.
- Tapping the entry point routes to the registration screen.
- The CTA does not block access to public surfaces (News, Emergency, Citizen Guide).

---

### Story 1.2 — Authenticated User Registers an Account

**As a** Guest  
**I want to** create an account by providing my full name, barangay, complete address, mobile number, optional email, and password  
**So that** I can submit service requests and file reports as an Authenticated User.

**Acceptance Criteria:**

- Required fields: full name, barangay (from canonical list), complete address, mobile number, password.
- Password enforces minimum 8 characters, alphanumeric.
- Privacy Notice is displayed; explicit consent checkbox is required before submission per Data Privacy Act of 2012.
- Submission produces an unverified account and triggers OTP delivery.
- Duplicate mobile or email returns a clear inline error without losing entered data.

---

### Story 1.3 — Authenticated User Verifies via OTP

**As a** newly registered Guest  
**I want to** receive and enter an OTP via SMS or email  
**So that** my account is activated.

**Acceptance Criteria:**

- OTP is delivered via the channel chosen at registration (SMS default).
- OTP screen accepts 6-digit numeric code.
- Invalid or expired OTP shows a clear error and allows resend after rate-limit cool-down.
- Successful verification activates the account and routes to login or directly to the authenticated Home.

---

### Story 1.4 — Resend OTP

**As an** unverified user  
**I want to** request a fresh OTP if I did not receive the first one  
**So that** I can complete activation without contacting support.

**Acceptance Criteria:**

- Resend action is rate-limited (e.g., 60-second cool-down) with a visible countdown.
- A new OTP invalidates the previous code.

---

### Story 1.5 — Login with Mobile or Email

**As an** Authenticated User  
**I want to** sign in using my mobile number or email and password  
**So that** I can access my account.

**Acceptance Criteria:**

- Both mobile number and email are accepted as identifiers.
- Invalid credentials show a generic error (no disclosure of which field is wrong).
- Successful login routes to the authenticated Home with personalized greeting.

---

### Story 1.6 — Account Lockout After 5 Failed Attempts

**As the** System  
**I want to** lock an account after 5 consecutive failed login attempts  
**So that** brute-force attacks are mitigated.

**Acceptance Criteria:**

- The fifth consecutive failure displays a lockout notice with cooling-off period.
- The lockout state is logged in the audit log.
- Admin may unlock the account via User Management.

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

### Story 2.6 — Moderator Views Citizen Profile (Read-Only)

**As a** Moderator  
**I want to** view a citizen's basic profile when processing their submission  
**So that** I have the context to act on the request.

**Acceptance Criteria:**

- Visible fields: name, barangay, contact number.
- No edit controls are available to the Moderator.

---

### Story 2.7 — Admin Manages Citizen Accounts (Without Direct Edit)

**As an** Admin  
**I want to** search citizen accounts and change account status (verify, deactivate, reactivate)  
**So that** I can administer the user base while respecting DPA-driven self-edit rules.

**Acceptance Criteria:**

- Admin cannot directly edit personal data fields.
- Status transitions are logged in the audit log.
- A citizen may request data correction through a documented support channel.

---

## 3. Home and Navigation

### Story 3.1 — Guest Sees Time-of-Day Greeting and Quick Actions

**As a** Guest  
**I want to** see a Filipino/Visayan time-of-day greeting and a grid of quick-action tiles  
**So that** I can reach what I need in one tap.

**Acceptance Criteria:**

- Greeting varies by time-of-day (e.g., "Maayong Buntag, Igubat!" in the morning).
- Quick-action tiles: Services, Citizen Guide, E-Services, Emergency, Utilities, Transport, Business, View More.
- A "Help us improve our city" banner is visible with a sign-in CTA.

---

### Story 3.2 — Notification Bell Routes Guest to Sign-In

**As a** Guest  
**I want to** be guided to sign in when I tap the notification bell  
**So that** I understand that notifications require an account.

**Acceptance Criteria:**

- The bell is visible but tapping it opens the sign-in flow.

---

### Story 3.3 — Authenticated User Sees Personalized Home

**As an** Authenticated User  
**I want to** see a greeting using my first name and an unread-count badge on the bell  
**So that** the app feels personal and I can see new notifications at a glance.

**Acceptance Criteria:**

- Greeting renders the user's first name.
- Badge shows unread notification count; tapping opens the in-app notification inbox.

---

## 4. News and Announcements

### Story 4.1 — Guest Browses Latest News

**As a** Guest  
**I want to** browse the Latest News feed with category labels  
**So that** I stay informed about LGU activity.

**Acceptance Criteria:**

- Categories include Community, Events, Procurement, Announcements.
- Article cards show title, category, publication date, and featured image.

---

### Story 4.2 — Guest Browses Featured Stories Carousel

**As a** Guest  
**I want to** swipe through the featured stories carousel  
**So that** I can quickly see the LGU's top stories.

**Acceptance Criteria:**

- Carousel is horizontally scrollable.
- Tapping a card opens the full article view.

---

### Story 4.3 — Guest Reads Full Article

**As a** Guest  
**I want to** read the full article with title, body, images, and publication date  
**So that** I have the complete information.

**Acceptance Criteria:**

- Inline images render at appropriate resolution.
- Long-form content scrolls smoothly.

---

### Story 4.4 — Guest Searches News by Keyword

**As a** Guest  
**I want to** search articles by keyword  
**So that** I can find a specific story.

**Acceptance Criteria:**

- Search matches title and body.
- Results show category, date, and snippet.

---

### Story 4.5 — Authenticated User Receives Push on New Article

**As an** Authenticated User with news notifications enabled  
**I want to** receive a push notification when a new article is published  
**So that** I do not miss timely civic news.

**Acceptance Criteria:**

- Push is sent within 1 minute of publication.
- The notification deep-links to the article view.

---

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

### Story 4.11 — Admin Permanently Deletes Content

**As an** Admin  
**I want to** permanently delete an article, banner, or media asset  
**So that** I can remove content that should not be retained.

**Acceptance Criteria:**

- Deletion requires explicit confirmation.
- Action is logged in the audit log.

---

## 5. Service Requests *(Focused Development)*

### Story 5.1 — Guest Sees Sign-In Prompt on Submit

**As a** Guest  
**I want to** see a clear sign-in prompt when I try to submit a service request  
**So that** I know I need an account.

**Acceptance Criteria:**

- Tapping "Submit" from a service routes to the registration/login screen.
- After successful authentication, the user is returned to the same service.

---

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

### Story 5.10 — Admin Configures Service Types

**As an** Admin  
**I want to** configure service types, categories, and request form fields  
**So that** the catalogue matches LGU operations.

**Acceptance Criteria:**

- Admin can add/edit/disable service types.
- Form field changes are versioned to avoid breaking historical records.

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

### Story 6.8 — Admin Views Reports on an Interactive Map

**As an** Admin  
**I want to** view all reports on an interactive map with filters and a heatmap  
**So that** I can spot patterns across barangays.

**Acceptance Criteria:**

- Heatmap toggle.
- Filters: category, status, barangay, date range.
- Clicking a pin opens the report detail.

---

## 7. Emergency Hotline and Directory *(Focused Development)*

### Story 7.1 — Guest Calls 911 from the Slide-to-Call Card

**As a** Guest  
**I want to** slide-to-call 911 from the Emergency screen  
**So that** I can reach emergency services in one motion.

**Acceptance Criteria:**

- The slide gesture initiates a tel: action to 911.
- The card is visible at the top of the Emergency screen.

---

### Story 7.2 — Guest Uses COMCEN Hotlines

**As a** Guest  
**I want to** one-tap call or copy-to-clipboard the COMCEN hotlines (Smart, TNT, Landline)  
**So that** I can reach the Community Emergency Communications Center regardless of my carrier.

**Acceptance Criteria:**

- Each hotline shows label, number, and tap/copy controls.
- Copy action shows a brief confirmation toast.

---

### Story 7.3 — Guest Browses Hospitals, BFP, PNP, Disaster Response

**As a** Guest  
**I want to** browse directory listings by category  
**So that** I can find nearby help.

**Acceptance Criteria:**

- Categories: Hospitals, Fire Protection (BFP), Police (PNP), Disaster Response.
- Each entry shows name, address, contact number, hours.
- Tap-to-call works on each entry.

---

### Story 7.4 — Authenticated User Receives Emergency Broadcast

**As an** Authenticated User  
**I want to** receive emergency broadcast alerts as high-priority push notifications  
**So that** I am warned about critical events.

**Acceptance Criteria:**

- Emergency broadcasts bypass the default notification mute unless the user has explicitly opted out with confirmation.
- The notification is marked high priority by the OS.

---

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

### Story 7.9 — Admin Manages Broadcast and Directory at Full Scope

**As an** Admin  
**I want to** permanently delete directory entries and manage the full broadcast history  
**So that** I can correct mistakes and maintain governance.

**Acceptance Criteria:**

- Hard-delete action is restricted to Admin and requires confirmation.
- All hard-delete actions are written to the audit log.

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

### Story 8.3 — Moderator Triggers Optional Push on Article Publish

**As a** Moderator  
**I want to** optionally push a notification when publishing an article  
**So that** important news reaches subscribers immediately.

**Acceptance Criteria:**

- A "Notify subscribers" checkbox appears on the publish action.
- The check is logged with the article record.

---

### Story 8.4 — Admin Views Notification Delivery Logs

**As an** Admin  
**I want to** view notification delivery logs (sent/delivered/failed)  
**So that** I can diagnose delivery issues.

**Acceptance Criteria:**

- Logs filterable by channel (push, email, in-app) and date range.
- Failed deliveries surface the failure reason.

---

### Story 8.5 — System Sends Push on Citizen-Visible Events

**As the** System  
**I want to** dispatch a push notification on every citizen-visible status change  
**So that** the citizen experience is consistent and timely.

**Acceptance Criteria:**

- Triggers cover service request status changes, issue report status changes, new articles (opt-in), and emergency broadcasts.
- Retries failed deliveries with exponential backoff and a maximum attempt cap.

---

### Story 8.6 — System Notifies Moderators of New Submissions

**As the** System  
**I want to** notify Moderators when a new request or report is submitted  
**So that** new work is visible immediately.

**Acceptance Criteria:**

- Web portal dashboards reflect new items in near real-time.
- Optional email digest to assigned Moderators on a configurable cadence.

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

### Story 9.7 — Moderator Cannot Access User Management

**As a** Moderator  
**I want to** be blocked from User Management surfaces  
**So that** the role boundary is enforced.

**Acceptance Criteria:**

- Sidebar/navigation hides User Management for Moderator.
- Direct URL navigation returns 403/redirects to the dashboard.

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

### Story 10.4 — Moderator Cannot Access Analytics

**As a** Moderator  
**I want to** be blocked from the Analytics surfaces  
**So that** the role boundary is enforced.

**Acceptance Criteria:**

- Analytics is hidden from the Moderator sidebar.
- Direct URL navigation returns 403.

---

## 11. Audit and Activity Logging

### Story 11.1 — System Logs Significant Events

**As the** System  
**I want to** log significant events with actor, role, timestamp, IP, and action  
**So that** the LGU has an immutable audit trail.

**Acceptance Criteria:**

- Logged events include logins, account changes, request and report status changes, content actions, broadcasts, settings changes.
- Storage is append-only.

---

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

### Story 11.4 — Audit Log Is Read-Only for All Roles

**As the** System  
**I want to** prevent any role from modifying or deleting audit entries  
**So that** the trail remains tamper-evident.

**Acceptance Criteria:**

- No API exposes update/delete for audit entries.
- Database-level protections prevent direct manipulation.

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

### Story 12.2 — System Scans Uploads for Malicious Content

**As the** System  
**I want to** virus-scan uploaded files before storage  
**So that** the platform stays safe.

**Acceptance Criteria:**

- Detected threats are rejected with a generic error.
- Quarantine and Admin notification on detected threats.

---

### Story 12.3 — System Compresses Images Automatically

**As the** System  
**I want to** auto-compress uploaded images  
**So that** storage and bandwidth are conserved.

**Acceptance Criteria:**

- Image quality remains readable.
- Original is retained only as needed.

---

### Story 12.4 — Moderator Uses the Media Asset Manager

**As a** Moderator  
**I want to** browse, upload, and delete media in the admin portal  
**So that** I can manage article and banner assets.

**Acceptance Criteria:**

- Delete defaults to soft-delete (30-day retention).
- Search/filter by name, type, upload date.

---

### Story 12.5 — Admin Force-Deletes Files

**As an** Admin  
**I want to** permanently delete files immediately  
**So that** I can comply with content takedown obligations.

**Acceptance Criteria:**

- Confirmation dialog with explicit warning.
- Action is logged.

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

### Story 13.3 — Moderator Sees a Single Report on a Map

**As a** Moderator  
**I want to** open a report and see its location on a map  
**So that** I can plan dispatch.

**Acceptance Criteria:**

- Map shows the pin and address (reverse-geocoded where available).

---

### Story 13.4 — Admin Sees All Reports as a Heatmap

**As an** Admin  
**I want to** toggle a heatmap of all reports  
**So that** I can identify hot spots.

**Acceptance Criteria:**

- Heatmap supports the same filters as the list view.

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

### Story 14.4 — System Retries Failed Submissions on Reconnect

**As the** System  
**I want to** automatically retry failed submissions when connectivity is restored  
**So that** the citizen experience is resilient.

**Acceptance Criteria:**

- Retry is transparent to the user.
- A maximum retry window with user-visible final-failure state.

---

*Document version 1.0 — aligned to `igubat_tor.md` v3.1. Roles: Guest, Authenticated User, Moderator, Admin, System. 14 sections, 80+ user stories.*