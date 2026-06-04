# iGubat Manual Test Plan

**Document Version:** 1.0  
**Prepared from:** `igubat_tor.md` v3.1, `igubat_proposal.md`, `igubat_user_stories.md`, `igubat_overall_system.md`, `igubat_mobile_app.md`, `igubat_admin_portal.md`  
**Audience:** LGU ICT Office QA staff, development team QA, UAT participants

---

## 1. Review Summary

This manual test plan covers the iGubat application end-to-end across both platforms — the **Citizen Mobile Application** and the **Web Administration Portal** — and across all four canonical roles: **Guest, Authenticated User, Moderator, Admin**.

The in-scope core for testing is:

- **Mobile (Guest):** public Home, time-of-day greetings, news browsing, full article view, emergency screen with 911 slide-to-call, COMCEN hotlines, directory browsing, citizen guide (cached), offline behavior on public surfaces.
- **Mobile (Auth):** registration with DPA consent, OTP verification, login, lockout, password reset, profile and preferences, service request submission and lifecycle, issue report submission with GPS, in-app notification inbox, push delivery and preferences, cancel pending requests, offline submission queueing.
- **Web (Moderator):** login, dashboard, service request queue and lifecycle transitions, issue report queue and map view, lifecycle transitions, article authoring/scheduling/archival, carousel and banner manager, media library (soft-delete), emergency directory management, broadcast composition/scheduling/send, broadcast history, change own password.
- **Web (Admin):** all Moderator capabilities plus User Management (citizens and staff), Analytics dashboard with filters and export, Audit Log with filters and export (read-only), System Settings (application, service types, report categories, notifications, storage, health).
- **Role boundary enforcement:** Moderator denied access to User Management, Analytics, Audit, Settings (sidebar hidden + 403 on direct URL).
- **NFRs:** Android 8+, iOS 14+, 500 concurrent users capacity, HTTPS/TLS, 99% uptime business hours, 3-second response, daily backups, DPA 2012 compliance.

---

## 2. Test Prerequisites

Use a **staging environment** with SMS gateway, email provider, FCM/APNs, file upload, push notifications, map provider, and reporting/export services configured (or stubbed where unavailable).

### 2.1 Required Test Accounts


| ID                       | Role               | Notes                                                                   |
| ------------------------ | ------------------ | ----------------------------------------------------------------------- |
| `guest_mobile`           | Guest              | No account; fresh app install                                           |
| `auth_unverified`        | Authenticated User | Registered but OTP not yet verified                                     |
| `auth_verified_juan`     | Authenticated User | Verified citizen in barangay Poblacion                                  |
| `auth_verified_maria`    | Authenticated User | Verified citizen in a different barangay; used for cross-user isolation |
| `auth_pending_request`   | Authenticated User | Has a Service Request in `Pending`                                      |
| `auth_in_review_request` | Authenticated User | Has a Service Request in `In Review` (cancel must be blocked)           |
| `auth_open_report`       | Authenticated User | Has an Issue Report in `Received`                                       |
| `auth_locked`            | Authenticated User | Account locked after 5 failed logins                                    |
| `auth_deactivated`       | Authenticated User | Account deactivated by Admin                                            |
| `moderator_ops`          | Moderator          | Web portal credentials                                                  |
| `moderator_content`      | Moderator          | Second Moderator for content authoring scenarios                        |
| `admin_super`            | Admin              | Web portal credentials with full access                                 |
| `admin_secondary`        | Admin              | Used for testing audit segregation of duties                            |


### 2.2 Recommended Sample Data

- **Barangays:** at least 3 (e.g., Poblacion, San Isidro, San Roque).
- **Service Types:** Facility Use, Medical Assistance, Transportation Assistance (canonical).
- **Report Categories:** Road Damage, Flooding, Waste Management, Street Lighting, Public Safety, Others (canonical).
- **Articles:** 5 Draft, 10 Published (mixed categories), 2 Archived.
- **Carousel:** 5 featured items.
- **Banners:** 3 active banners.
- **Emergency Directory:** COMCEN entries (Smart, TNT, Landline), at least 2 hospitals, 1 BFP, 1 PNP, 1 disaster response unit.
- **Documents for upload tests:** valid JPEG (≤5 MB), valid PNG (≤5 MB), valid PDF (≤5 MB), oversized image (&gt;5 MB), unsupported file (e.g., `.exe`, `.zip`).
- **Time-of-day windows:** ability to test morning, afternoon, evening greetings (or override device time).

### 2.3 Devices and Browsers

- **Android:** Android 8.0 (API 26) and one recent version (e.g., Android 14).
- **iOS:** iOS 14 and one recent version (e.g., iOS 17).
- **Web:** latest stable Chrome, Firefox, Edge, Safari on a standard 13–15" desktop resolution.

---

## 3. Manual Test Cases

> Each test case follows the format: **ID | Title | Priority | Role | Module | Preconditions | Steps | Expected**

---

### IG-001 — Guest sees public Home with time-of-day greeting

- **Priority:** High
- **Role:** Guest
- **Module:** Home and Navigation
- **Preconditions:** Fresh install, device language set; no account exists; device online.
- **Steps:**
  1. Launch the iGubat app.
  2. Observe the Splash, then arrive at Home.
  3. Note the greeting banner content.
  4. Inspect the quick-action grid (Services, Citizen Guide, E-Services, Emergency, Utilities, Transport, Business, View More).
  5. Tap the "Help us improve our city" banner.
  6. Tap the notification bell.
- **Expected:**
  - Greeting matches the time of day in Filipino/Visayan (e.g., "Maayong Buntag, Igubat!").
  - All 8 quick-action tiles render.
  - The improve-city banner routes to the Sign-In screen.
  - The bell routes to the Sign-In screen.

---

### IG-002 — Guest browses News and reads a full article

- **Priority:** High
- **Role:** Guest
- **Module:** News and Announcements
- **Preconditions:** Published articles seeded.
- **Steps:**
  1. Open News from the home tile.
  2. Swipe the featured carousel.
  3. Scroll the Latest News feed; tap a category filter (e.g., Announcements).
  4. Tap an article.
  5. Use search; type a known title keyword.
  6. Tap a result.
- **Expected:**
  - Carousel scrolls horizontally and renders images and titles.
  - Category filter limits the feed correctly.
  - Article detail shows title, body, images, and publication date.
  - Search returns relevant matches with snippet.

---

### IG-003 — Guest uses the Emergency screen and 911 slide-to-call

- **Priority:** Critical
- **Role:** Guest
- **Module:** Emergency Hotline and Directory
- **Preconditions:** Device has dialer; device online or offline (both runs).
- **Steps:**
  1. Open Emergency from the quick-action grid.
  2. Slide the 911 card slider to the end.
  3. Cancel the call when the dialer opens.
  4. Tap one of the COMCEN hotlines (Smart).
  5. Long-press / use "Copy" on a hotline number.
  6. Tap a category shortcut (e.g., Hospitals); browse entries.
  7. Toggle device offline and repeat steps 1–5.
- **Expected:**
  - Slide-to-call invokes the dialer with the 911 number.
  - Tap-to-call invokes the dialer with the correct COMCEN number.
  - Copy shows a confirmation toast and pastes the number in another app.
  - Category browsing shows name, address, contact, hours.
  - Offline behavior preserves access to hotlines (cached) and tap-to-call works.

---

### IG-004 — Citizen Guide content is cached for offline

- **Priority:** Medium
- **Role:** Guest
- **Module:** Connectivity and Offline Support
- **Preconditions:** Online for first load.
- **Steps:**
  1. Open Citizen Guide; load each top-level page online.
  2. Switch the device to airplane mode.
  3. Re-open Citizen Guide pages.
- **Expected:**
  - Pages render from cache with a visible "Last updated" timestamp.

---

### IG-005 — Registration form validates and captures DPA consent

- **Priority:** Critical
- **Role:** Guest → Authenticated User
- **Module:** Authentication; Security and Compliance
- **Preconditions:** None.
- **Steps:**
  1. Open Registration.
  2. Submit empty form; observe required-field errors.
  3. Enter weak password (&lt;8 chars); observe error.
  4. Enter valid data **without** ticking DPA consent; attempt submit.
  5. Tick DPA consent; submit.
  6. Attempt to register again with the same mobile number.
- **Expected:**
  - Required fields: name, barangay, address, mobile, password.
  - Password complexity is enforced inline.
  - Submission is blocked until DPA consent is checked.
  - Successful submission creates an unverified account and routes to OTP screen.
  - Duplicate mobile shows a clear inline error and preserves entered data.

---

### IG-006 — OTP verification and resend rate limit

- **Priority:** Critical
- **Role:** Guest
- **Module:** Authentication
- **Preconditions:** Registered but unverified account.
- **Steps:**
  1. Enter an invalid 6-digit code.
  2. Enter an expired code (use a code from &gt;10 min ago if available).
  3. Tap Resend; observe countdown.
  4. Attempt to tap Resend during countdown.
  5. Enter the valid code.
- **Expected:**
  - Invalid/expired codes show clear errors.
  - Resend invokes once and is then locked behind the countdown.
  - Valid code activates the account and routes to Login or Home.

---

### IG-007 — Login and account lockout after 5 failed attempts

- **Priority:** Critical
- **Role:** Guest → Authenticated User
- **Module:** Authentication; Security
- **Preconditions:** Verified account exists.
- **Steps:**
  1. Enter mobile + wrong password; submit. Repeat 5 times.
  2. On the 6th attempt, use the correct password.
  3. Log in as Admin in the web portal and inspect login activity for the citizen account.
- **Expected:**
  - 5th failure surfaces a lockout notice with cool-down.
  - 6th attempt is rejected while locked.
  - Audit log shows the lockout event with timestamp and IP.

---

### IG-008 — Forgot Password via OTP invalidates all sessions

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Authentication
- **Preconditions:** Verified account currently signed in on a second device.
- **Steps:**
  1. From Login, tap Forgot Password; enter mobile.
  2. Enter the OTP received.
  3. Set a new password.
  4. On the second device, attempt to use any authenticated feature.
- **Expected:**
  - Password reset succeeds.
  - Second device's session is invalidated and a re-login prompt appears.

---

### IG-009 — Authenticated Home shows personalized greeting and unread badge

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Home and Navigation
- **Preconditions:** Signed-in user with at least one unread notification.
- **Steps:**
  1. Open the app.
  2. Note the greeting text.
  3. Check the bell icon.
  4. Tap the bell.
- **Expected:**
  - Greeting includes the user's first name.
  - Bell shows the unread count.
  - Tapping opens the in-app notification inbox.

---

### IG-010 — Profile update and avatar upload

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Citizen Profile
- **Preconditions:** Signed in.
- **Steps:**
  1. Open Profile.
  2. Edit name and address; save.
  3. Change barangay (canonical list).
  4. Change contact number (expect OTP re-verification).
  5. Upload a JPEG profile photo (≤5 MB).
  6. Attempt to upload a 10 MB image.
  7. Attempt to upload a `.exe` file.
- **Expected:**
  - Profile fields persist; greeting reflects updated first name.
  - Barangay selection is constrained to canonical values.
  - Contact change triggers OTP re-verification.
  - Valid image uploads succeed and the avatar updates.
  - Oversized or unsupported files are rejected with clear errors.

---

### IG-011 — Change password requires current password

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Citizen Profile / Authentication
- **Preconditions:** Signed in.
- **Steps:**
  1. Open Change Password.
  2. Enter wrong current password; submit.
  3. Enter correct current password; mismatched new and confirm; submit.
  4. Enter weak new password; submit.
  5. Enter valid new password and matching confirm; submit.
  6. Verify other devices are signed out.
- **Expected:**
  - Wrong current password is rejected.
  - Mismatched/weak passwords are rejected.
  - Successful change invalidates other sessions.

---

### IG-012 — Notification preferences honored at delivery

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Notifications
- **Preconditions:** Signed in; Moderator available for content actions.
- **Steps:**
  1. Open Profile → Notification Preferences.
  2. Disable News notifications.
  3. Have a Moderator publish a new article with Notify Subscribers enabled.
  4. Re-enable News notifications.
  5. Have a Moderator publish another article.
  6. Attempt to disable Emergency Broadcasts.
- **Expected:**
  - With News disabled, no push is delivered for the first article; the article appears in the inbox feed but no push.
  - With News re-enabled, push is delivered for the second article.
  - Disabling Emergency Broadcasts requires an explicit confirmation dialog.

---

### IG-013 — Appearance toggle (Light/Dark)

- **Priority:** Medium
- **Role:** Authenticated User
- **Module:** Citizen Profile
- **Preconditions:** Signed in.
- **Steps:**
  1. Toggle to Dark mode.
  2. Close and reopen the app.
- **Expected:**
  - Theme applies on next render and persists across sessions.

---

### IG-014 — Submit a Service Request and receive tracking number

- **Priority:** Critical
- **Role:** Authenticated User
- **Module:** Service Requests
- **Preconditions:** Signed in; online.
- **Steps:**
  1. Open Services.
  2. Choose **Facility Use**.
  3. Enter description and preferred date/time.
  4. Attach 3 files (JPEG, PNG, PDF); each ≤5 MB.
  5. Attempt a 4th attachment (expect rejection).
  6. Submit.
- **Expected:**
  - Submission succeeds; a tracking number is displayed.
  - Status is **Pending**.
  - Contact info is auto-populated from profile.
  - Attachment count is capped at 3.

---

### IG-015 — Service Request attachment validation (type and size)

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Service Requests / File and Media Management
- **Preconditions:** Submitting a request.
- **Steps:**
  1. Try to attach a `.exe` file.
  2. Try to attach an oversized 10 MB image.
  3. Try to attach a corrupted PDF (if available).
  4. Attach a valid PDF.
- **Expected:**
  - Unsupported types are rejected with a clear error.
  - Oversized files are rejected.
  - Server-side validation matches client-side validation.

---

### IG-016 — Cancel a Pending request; cannot cancel after In Review

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Service Requests
- **Preconditions:** Use `auth_pending_request` and `auth_in_review_request`.
- **Steps:**
  1. Sign in as `auth_pending_request`; open the request detail.
  2. Cancel the request; confirm.
  3. Sign in as `auth_in_review_request`; open the request detail.
  4. Look for the Cancel control.
- **Expected:**
  - Cancel succeeds for `Pending` and is recorded in status history.
  - Cancel control is hidden once status has moved past `Pending`.

---

### IG-017 — Receive push on every status change

- **Priority:** Critical
- **Role:** Authenticated User; Moderator
- **Module:** Service Requests / Notifications
- **Preconditions:** A submitted request belonging to the citizen account.
- **Steps:**
  1. As Moderator, transition status `Pending → In Review`.
  2. As citizen, observe push and inbox entry.
  3. Repeat for `In Review → Approved`, `Approved → For Pickup`, `For Pickup → Completed`.
- **Expected:**
  - Push is received on each transition.
  - Inbox shows entries with timestamps.
  - Deep link opens the request detail.

---

### IG-018 — File an Issue Report with GPS auto-detect and manual pin

- **Priority:** Critical
- **Role:** Authenticated User
- **Module:** Issue and Concern Reports / Geolocation
- **Preconditions:** Signed in; on a device that can grant Location.
- **Steps:**
  1. Open "Report an Issue."
  2. Choose category **Road Damage**.
  3. Enter description; attach 2 photos.
  4. Grant Location permission when prompted.
  5. Verify auto-detected pin is on a map.
  6. Drag the pin to a nearby intersection.
  7. Submit.
- **Expected:**
  - Permission prompt appears only here, not at app launch.
  - The map shows the pin; coordinates persist with the report.
  - Initial status is **Received**.

---

### IG-019 — Issue Report category constraints

- **Priority:** Medium
- **Role:** Authenticated User
- **Module:** Issue and Concern Reports
- **Preconditions:** Filing a report.
- **Steps:**
  1. Open the category selector.
  2. Choose each of the 6 canonical categories in succession.
- **Expected:**
  - Exactly 6 categories appear: Road Damage, Flooding, Waste Management, Street Lighting, Public Safety, Others.
  - No additional or missing categories.

---

### IG-020 — Track issue report and receive public remarks

- **Priority:** High
- **Role:** Authenticated User; Moderator
- **Module:** Issue and Concern Reports / Notifications
- **Preconditions:** Submitted report owned by the citizen account.
- **Steps:**
  1. As Moderator, transition `Received → In Progress` with a public remark "Crew dispatched."
  2. As citizen, open the report.
  3. Continue lifecycle to `Resolved` (with remark) and then `Closed`.
- **Expected:**
  - Each transition produces a push to the citizen.
  - Public remarks appear in the citizen's view.
  - Internal notes added by Moderator are not visible to the citizen.

---

### IG-021 — Notification inbox: mark read, mark all read, deep link

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Notifications
- **Preconditions:** Multiple unread notifications.
- **Steps:**
  1. Open the inbox.
  2. Tap a notification to deep-link.
  3. Return to inbox.
  4. Mark one as read manually.
  5. Use "Mark all as read."
- **Expected:**
  - Deep link opens the correct detail screen.
  - Read state updates immediately and badge count decrements.

---

### IG-022 — Offline submission queues and auto-retries

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Connectivity and Offline Support
- **Preconditions:** Signed in.
- **Steps:**
  1. Enable airplane mode.
  2. Fill out a Service Request and submit.
  3. Observe the offline notice and queued state.
  4. Disable airplane mode.
  5. Wait for auto-retry.
- **Expected:**
  - Submission is not lost.
  - On reconnect, the System auto-retries and the request appears in `Pending` with the original timestamp preserved.

---

### IG-023 — Offline cache covers last 20 articles, hotlines, guide

- **Priority:** Medium
- **Role:** Guest or Authenticated User
- **Module:** Connectivity and Offline Support
- **Preconditions:** Online first to populate cache.
- **Steps:**
  1. Scroll News to load 20+ articles online.
  2. Open Emergency; load Hospitals/BFP/PNP entries.
  3. Open Citizen Guide pages.
  4. Switch to airplane mode.
  5. Re-open News, Emergency, Citizen Guide.
- **Expected:**
  - Articles, hotlines, directory, and guide all display from cache with "Last updated" timestamps.

---

### IG-024 — Sign out invalidates session

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Authentication
- **Preconditions:** Signed in.
- **Steps:**
  1. Open Profile; sign out.
  2. From the system back navigation, attempt to return to a protected screen.
  3. Try to open a previously fetched detail.
- **Expected:**
  - Session token is invalidated server-side.
  - Protected screens redirect to Home/Sign-In.

---

### IG-025 — Deactivated and locked accounts handled clearly

- **Priority:** High
- **Role:** Authenticated User
- **Module:** Authentication / User Management
- **Preconditions:** Use `auth_locked` and `auth_deactivated`.
- **Steps:**
  1. Attempt to log in as `auth_locked`.
  2. Attempt to log in as `auth_deactivated`.
- **Expected:**
  - Locked account shows lockout notice with guidance.
  - Deactivated account shows a clear message to contact LGU staff; no service request or report features accessible.

---

### IG-026 — Web portal login and 30-minute idle timeout

- **Priority:** High
- **Role:** Moderator or Admin
- **Module:** Authentication / Security
- **Preconditions:** Working portal credentials.
- **Steps:**
  1. Log in to the web portal.
  2. Open a protected page; do nothing for 30+ minutes.
  3. Attempt an action.
  4. Re-authenticate; confirm audit log entries for login/timeout.
- **Expected:**
  - Idle session is terminated and the user is returned to `/login`.
  - Audit log records login, idle-timeout (where supported), and subsequent re-login.

---

### IG-027 — Moderator processes Service Request through full lifecycle

- **Priority:** Critical
- **Role:** Moderator
- **Module:** Service Requests
- **Preconditions:** A Pending request from a known citizen.
- **Steps:**
  1. Open Service Requests; filter by Pending.
  2. Open the request detail.
  3. Add an internal remark; transition to `In Review`.
  4. Continue: `In Review → Approved → For Pickup → Completed`.
  5. Verify each transition fires a citizen-facing push notification (cross-check on the citizen device).
- **Expected:**
  - Only canonical transitions are allowed; attempts to skip statuses are blocked.
  - Citizen receives push on every transition.
  - Audit log records each transition with actor, role, timestamp.

---

### IG-028 — Moderator rejects a Service Request

- **Priority:** High
- **Role:** Moderator
- **Module:** Service Requests
- **Preconditions:** A Pending request.
- **Steps:**
  1. Open the request.
  2. Transition `Pending → In Review`.
  3. Transition `In Review → Rejected` with a public remark explaining the reason.
- **Expected:**
  - Request now shows `Rejected` to the citizen.
  - Public remark is visible to the citizen.
  - Citizen receives push; cannot resubmit on the same record (must create a new one).

---

### IG-029 — Moderator handles Issue Report through map view

- **Priority:** High
- **Role:** Moderator
- **Module:** Issue and Concern Reports / Geolocation
- **Preconditions:** Open report with GPS.
- **Steps:**
  1. Open Issue Reports; switch to Map View.
  2. Filter by category Road Damage and barangay Poblacion.
  3. Click a pin; open the report detail.
  4. Transition `Received → In Progress → Resolved → Closed`, adding public remarks at each step.
- **Expected:**
  - Map filters apply correctly.
  - Pin click opens the right report.
  - Citizen sees status and public remarks updated.

---

### IG-030 — Moderator authors, schedules, and previews an article

- **Priority:** High
- **Role:** Moderator
- **Module:** News and Announcements
- **Preconditions:** Logged in to the portal.
- **Steps:**
  1. Open Articles; click Create.
  2. Use the rich text editor (headings, list, inline image).
  3. Assign category, tags, featured image.
  4. Click Preview.
  5. Save as Draft.
  6. Edit and schedule for a future time (e.g., 5 minutes ahead).
  7. Wait for the scheduled time.
- **Expected:**
  - Preview renders as the citizen view.
  - Draft appears in Articles list under Draft filter.
  - Scheduled article transitions to Published at the scheduled time; appears in mobile News feed.

---

### IG-031 — Moderator archives an article and verifies removal from public

- **Priority:** Medium
- **Role:** Moderator
- **Module:** News and Announcements
- **Preconditions:** A Published article.
- **Steps:**
  1. Open the article; click Archive.
  2. Confirm.
  3. On the mobile app, check the Latest News feed and the carousel.
- **Expected:**
  - Article disappears from public surfaces immediately (or on next cache refresh).
  - Article still appears in Articles list under Archived filter.

---

### IG-032 — Moderator manages Carousel and Banner order

- **Priority:** Medium
- **Role:** Moderator
- **Module:** News and Announcements
- **Preconditions:** Existing carousel/banners.
- **Steps:**
  1. Open Carousel Manager; drag a card to a new position.
  2. Toggle one item to Inactive.
  3. Save.
  4. Repeat in Banner Manager.
  5. Verify the order/activation reflects on the mobile Home.
- **Expected:**
  - Reorder and activation persist.
  - Mobile reflects changes within minutes (cache invalidation).

---

### IG-033 — Moderator manages the emergency directory

- **Priority:** High
- **Role:** Moderator
- **Module:** Emergency Hotline and Directory
- **Preconditions:** Logged in.
- **Steps:**
  1. Add a new hospital entry with name/address/contact/hours.
  2. Edit an existing BFP entry.
  3. Deactivate a PNP entry.
  4. On mobile, refresh Emergency.
- **Expected:**
  - New entry appears in Hospitals.
  - Edits persist and are reflected.
  - Deactivated entries are hidden from citizens.

---

### IG-034 — Moderator composes and sends an emergency broadcast

- **Priority:** Critical
- **Role:** Moderator
- **Module:** Emergency / Notifications
- **Preconditions:** At least one Authenticated User opted in.
- **Steps:**
  1. Open Compose Broadcast.
  2. Type a message; preview.
  3. Click Send; confirm the explicit warning.
  4. Note the delivery summary (recipient count, failures).
  5. On a citizen device, observe the high-priority push.
  6. Open Broadcast History; verify the entry.
- **Expected:**
  - Send requires explicit confirmation.
  - Citizen receives push as high priority (even if non-emergency categories are muted, unless the user has explicitly opted out of Emergency Broadcasts).
  - History row shows message, sender, timestamp, count.

---

### IG-035 — Moderator schedules a future broadcast

- **Priority:** Medium
- **Role:** Moderator
- **Module:** Emergency / Notifications
- **Preconditions:** Logged in.
- **Steps:**
  1. Compose a broadcast; choose a future time (e.g., 10 minutes ahead).
  2. Save.
  3. Open Scheduled Broadcasts; edit time.
  4. Wait until the scheduled time.
- **Expected:**
  - Pending broadcast appears in the schedule list.
  - Edits persist before send time.
  - At scheduled time, broadcast is dispatched and moves to History.

---

### IG-036 — Moderator denied access to User Management

- **Priority:** Critical
- **Role:** Moderator
- **Module:** RBAC / User and Staff Account Management
- **Preconditions:** Logged in as Moderator.
- **Steps:**
  1. Inspect the sidebar; look for Users.
  2. Navigate manually to `/users` (or the equivalent admin URL).
- **Expected:**
  - Users item is not in the sidebar.
  - Direct URL returns 403 / redirects to the Moderator Dashboard.

---

### IG-037 — Moderator denied access to Analytics

- **Priority:** Critical
- **Role:** Moderator
- **Module:** RBAC / Analytics and Reports
- **Preconditions:** Logged in as Moderator.
- **Steps:**
  1. Sidebar inspection.
  2. Direct URL navigation to the Analytics route.
- **Expected:**
  - Sidebar hides Analytics.
  - Direct URL returns 403 / redirect.

---

### IG-038 — Moderator denied access to Audit Log

- **Priority:** Critical
- **Role:** Moderator
- **Module:** RBAC / Audit and Activity Logging
- **Preconditions:** Logged in as Moderator.
- **Steps:**
  1. Sidebar inspection.
  2. Direct URL navigation.
- **Expected:**
  - Audit Log is not accessible.
  - 403 or redirect on direct URL attempt.

---

### IG-039 — Moderator denied access to Settings

- **Priority:** Critical
- **Role:** Moderator
- **Module:** RBAC / System Settings
- **Preconditions:** Logged in as Moderator.
- **Steps:**
  1. Sidebar inspection.
  2. Direct URL navigation.
- **Expected:**
  - Settings is not in the sidebar.
  - Direct URL returns 403 / redirect.

---

### IG-040 — Admin creates a Moderator and forces first-login password change

- **Priority:** High
- **Role:** Admin
- **Module:** User and Staff Account Management
- **Preconditions:** Logged in as Admin.
- **Steps:**
  1. Open Users → Staff.
  2. Create a Moderator with name, email, temporary password.
  3. Log out and log in with the new credentials.
- **Expected:**
  - Account is created.
  - First login forces a password change.
  - Audit log records the staff creation.

---

### IG-041 — Admin deactivates and reactivates a citizen account

- **Priority:** High
- **Role:** Admin
- **Module:** User and Staff Account Management
- **Preconditions:** Verified citizen exists.
- **Steps:**
  1. Open Users → Citizens; search; open detail.
  2. Deactivate; confirm.
  3. From the citizen's mobile, attempt to log in.
  4. Reactivate.
  5. Retry login.
- **Expected:**
  - Deactivation immediately invalidates sessions.
  - Citizen sees the deactivated-account message.
  - Reactivation restores access.
  - Both actions are in the audit log.

---

### IG-042 — Admin exports citizen list to CSV honoring filters

- **Priority:** Medium
- **Role:** Admin
- **Module:** User and Staff Account Management
- **Preconditions:** Multiple citizens across barangays.
- **Steps:**
  1. Open Citizens; filter by barangay Poblacion.
  2. Click Export CSV.
  3. Open the CSV.
- **Expected:**
  - Export only includes filtered rows.
  - Sensitive fields are redacted per LGU policy.
  - The export action is logged.

---

### IG-043 — Admin views Analytics dashboard and applies filters

- **Priority:** High
- **Role:** Admin
- **Module:** Analytics and Reports
- **Preconditions:** Sufficient data in staging.
- **Steps:**
  1. Open Analytics.
  2. Verify widgets render (DAU/MAU, registrations, requests by type/status, reports by category/barangay, notification delivery).
  3. Apply filters: date range last 30 days, barangay Poblacion, service type Medical Assistance.
  4. Export to PDF and CSV.
- **Expected:**
  - All widgets render or show empty states.
  - Filters refetch all widgets.
  - PDF and CSV exports reflect the current filters.

---

### IG-044 — Admin views Audit Log with filters and export

- **Priority:** High
- **Role:** Admin
- **Module:** Audit and Activity Logging
- **Preconditions:** Significant actions have occurred (logins, status changes, deletes).
- **Steps:**
  1. Open Audit Log.
  2. Filter by actor `moderator_ops`, action type "status change", date today.
  3. Open an entry's detail.
  4. Export filtered results to CSV.
  5. Attempt any edit or delete on an entry (e.g., via API).
- **Expected:**
  - Filters return expected rows.
  - Detail view shows full metadata.
  - CSV reflects filters.
  - Edit/delete is impossible — append-only.

---

### IG-045 — Admin manages System Settings safely

- **Priority:** Medium
- **Role:** Admin
- **Module:** System Settings
- **Preconditions:** Logged in.
- **Steps:**
  1. Update application name and logo; save.
  2. Add a new service type (then disable it).
  3. Edit the report categories list (only the canonical six are recognized; attempt to add a 7th).
  4. Open System Health.
- **Expected:**
  - Branding updates reflect across the portal.
  - Service types can be added/disabled.
  - The 6 canonical report categories are protected; new categories require explicit override with a warning.
  - System Health renders recent errors and uptime.

---

### IG-046 — File and Media: signed URLs and soft-delete

- **Priority:** High
- **Role:** Moderator; Admin
- **Module:** File and Media Management
- **Preconditions:** A media asset exists.
- **Steps:**
  1. Open Media Library; copy a file's URL.
  2. Open the URL in a different browser/incognito.
  3. Wait beyond the signed-URL expiration; retry.
  4. As Moderator, delete a media asset (soft-delete).
  5. As Admin, permanently delete an asset with confirmation.
- **Expected:**
  - Signed URL works while valid; fails after expiration.
  - Soft-deleted assets are recoverable within 30 days.
  - Admin's permanent delete is logged and irreversible.

---

### IG-047 — RBAC enforcement on the API layer (negative cases)

- **Priority:** Critical
- **Role:** Moderator
- **Module:** Security / RBAC
- **Preconditions:** Moderator token in hand (e.g., via developer tools).
- **Steps:**
  1. With a Moderator token, call admin-only endpoints (User Management list, Analytics, Audit Log, Settings).
  2. Repeat with an expired Moderator token.
- **Expected:**
  - All admin-only endpoints return 403 for Moderator.
  - Expired tokens return 401 and require re-login.

---

### IG-048 — Bilingual greetings render correctly across time-of-day

- **Priority:** Medium
- **Role:** Guest; Authenticated User
- **Module:** Home and Navigation
- **Preconditions:** Ability to override device time.
- **Steps:**
  1. Set device time to 7:00 AM; open Home.
  2. Set to 1:00 PM; open Home.
  3. Set to 7:00 PM; open Home.
- **Expected:**
  - Greetings change appropriately (e.g., "Maayong Buntag/Hapon/Gabii, Igubat!" or the Tagalog equivalent).

---

### IG-049 — Cross-user data isolation

- **Priority:** Critical
- **Role:** Authenticated User
- **Module:** Service Requests / Issue Reports / Security
- **Preconditions:** Two citizen accounts (`auth_verified_juan`, `auth_verified_maria`) with their own requests/reports.
- **Steps:**
  1. As Juan, copy the URL/path or ID of one of his requests.
  2. Sign in as Maria; attempt to open Juan's request via the same ID (UI or API).
- **Expected:**
  - Maria cannot view Juan's request or report.
  - API returns 403/404.

---

### IG-050 — Performance smoke: response time and concurrent baseline

- **Priority:** Medium
- **Role:** All
- **Module:** NFR-3, NFR-6
- **Preconditions:** Staging mirrors production capacity.
- **Steps:**
  1. Time the following operations: open News list, open article detail, submit Service Request, open Moderator queue, transition status, send broadcast.
  2. Use a basic load tool to simulate 100 then 500 concurrent sessions performing the same operations.
- **Expected:**
  - Standard operations complete in **≤ 3 seconds** under normal load.
  - Under 500 concurrent sessions, response time remains within an acceptable degradation envelope agreed with the LGU ICT Office (no errors, request handling stable).

---

## 4. Smoke Test Checklist

Run this checklist on every deploy to staging or production. Each item must pass before promoting.

### 4.1 Mobile App Smoke (Guest)

- [ ] App launches without crash; arrives at Home.
- [ ] Time-of-day greeting renders.
- [ ] News list and at least one article render.
- [ ] Emergency screen renders; 911 slide-to-call opens dialer.
- [ ] COMCEN tap-to-call and copy-to-clipboard work.
- [ ] Citizen Guide pages render.
- [ ] Tapping notification bell routes to Sign-In.

### 4.2 Mobile App Smoke (Authenticated User)

- [ ] Registration succeeds with DPA consent.
- [ ] OTP received and accepted.
- [ ] Login succeeds; personalized greeting renders.
- [ ] Submit a Service Request; tracking number is returned.
- [ ] File an Issue Report with GPS; status is `Received`.
- [ ] Notification inbox opens; unread count is correct.
- [ ] Change password works; other sessions invalidated.
- [ ] Sign out invalidates session.

### 4.3 Web Portal Smoke (Moderator)

- [ ] Login succeeds; arrives at Moderator dashboard.
- [ ] Service Requests queue opens; filter by Pending.
- [ ] Service Request detail opens; canonical status transition works.
- [ ] Issue Reports list and map render.
- [ ] Issue Report status transitions work.
- [ ] Article create, save Draft, schedule, publish, archive all work.
- [ ] Carousel and banners render and reorder.
- [ ] Media library upload + soft-delete work.
- [ ] Emergency directory add/edit/deactivate work.
- [ ] Broadcast composer sends after confirmation; History records it.
- [ ] Users, Analytics, Audit, Settings are HIDDEN from sidebar.
- [ ] Direct URL access to those returns 403.

### 4.4 Web Portal Smoke (Admin)

- [ ] Login succeeds; arrives at Admin dashboard.
- [ ] All Moderator smoke items pass for Admin too.
- [ ] Users → Citizens list loads; search works.
- [ ] Users → Staff creation works; new Moderator is forced to reset password on first login.
- [ ] Analytics dashboard renders; filters refetch widgets; PDF/CSV export work.
- [ ] Audit Log renders; filters work; export to CSV works; no edit/delete API exists.
- [ ] Settings: branding edit reflects; System Health renders.

### 4.5 Cross-Cutting Smoke

- [ ] Push notifications received on Android and iOS test devices.
- [ ] OTP SMS delivered.
- [ ] Transactional email delivered (verification, reset).
- [ ] Daily backup ran in the last 24 hours (verify with infrastructure runbook).
- [ ] All endpoints serve over HTTPS only; HTTP requests redirect.
- [ ] Sessions expire after 30 min idle on portal; 7-day idle on mobile.

---

## 5. Defect Severity Definitions


| Severity          | Definition                                                                        | Example                                                                           |
| ----------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| **S1 – Critical** | Blocks usage of a critical surface or violates a security/compliance requirement. | 911 slide-to-call fails; Moderator can reach Analytics; DPA consent not captured. |
| **S2 – High**     | Major function broken or workaround is unacceptable.                              | Status transitions fail; push notifications not delivered.                        |
| **S3 – Medium**   | Function works with minor degradation.                                            | Filters slow but not failing; inconsistent timestamp formatting.                  |
| **S4 – Low**      | Cosmetic or trivial.                                                              | Typography spacing; non-blocking copy issues.                                     |


---

## 6. Exit Criteria

iGubat manual testing can be accepted when:

- **All Critical (S1) and High (S2) tests pass** or have approved defects with documented workarounds.
- **No Moderator can access** User Management, Analytics, Audit Log, or Settings via UI or direct URL.
- **Onboarding (Registration + OTP)** succeeds reliably with DPA consent captured and audit-logged.
- **Service Request lifecycle** works end-to-end with canonical transitions and notifications on each step.
- **Issue Report lifecycle** works end-to-end with GPS capture, map view, and notifications.
- **Emergency surfaces** (911, COMCEN, directory) work online and offline; broadcasts are delivered.
- **Content management** (articles, carousel, banners, media) functions correctly with scheduling and archival.
- **User and Staff Management** functions correctly with audit logging on every change.
- **Audit Log** is append-only, read-only, exportable.
- **Analytics** renders with filters and exports.
- **NFRs verified**: HTTPS-only transport, 3-second response on standard operations, 500-concurrent baseline, daily backups present.
- **Mobile compatibility** verified on **Android 8.0** and **iOS 14** baseline devices in addition to current versions.
- **Bilingual greetings** render correctly.

---

*Document version 1.0 — aligned to `igubat_tor.md` v3.1. Roles in scope: Guest, Authenticated User, Moderator, Admin, System. Canonical statuses and lifecycles per TOR §7.*