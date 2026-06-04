# TERMS OF REFERENCE (TOR)

## iGubat — LGU Digital Services Application

### Citizen Mobile Application and Web Administration Portal

### Version 3.1 — Aligned to iGubat Proposal

> **Project Title:** iGubat — Local Government Unit Digital Services Application  
> **Prepared for:** Municipality of Igubat, Information and Communications Technology (ICT) Office  
> **Document Type:** Terms of Reference (TOR)  
> **Document Version:** 3.1  
> **Source:** `igubat_proposal.md`  
> **Governing Workflow Documents:**
>
> - `igubat_overall_system.md` — Overall System Structure
> - `igubat_mobile_app.md` — Citizen Mobile App Workflow
> - `igubat_admin_portal.md` — Web Administration Portal Workflow
> - `igubat_user_stories.md` — User Stories
> - `igubat_manual_test_plan.md` — Manual Test Plan

This TOR supersedes v3.0. It removes upstream transcript content, aligns the structure to the project template, and adds explicit Deliverables, Assumptions &amp; Dependencies, and Out of Scope sections. The four-role model (Guest, Authenticated User, Moderator, Admin) and the eleven (11) functional modules are preserved in full.

---

## Table of Contents

1. Project Background
2. Project Objectives
3. System Platforms Overview
4. System Architecture and Modules
5. User Roles and Access
6. Focused Development Areas
7. Functional Requirements by Module
8. Non-Functional Requirements
9. Security and Compliance Requirements
10. Notification System Requirements
11. File and Media Management Requirements
12. Geolocation and Mapping Requirements
13. Connectivity and Offline Support Requirements
14. Deliverables
15. Assumptions and Dependencies
16. Out of Scope

---

## 1. PROJECT BACKGROUND

The Municipality of Igubat seeks to develop a comprehensive digital platform — the **iGubat Application** — to modernize the delivery of local government services to its constituents. The platform makes LGU services accessible through a citizen-facing mobile application and manageable through a web-based administration portal for LGU staff.

The iGubat application aims to:

- Reduce the need for in-person transactions at the Municipal Hall and barangay offices.
- Improve information dissemination across all barangays of the municipality.
- Establish a direct, two-way communication channel between the LGU and residents.
- Support data-driven decision-making within the LGU through aggregated reports and analytics.
- Provide always-on access to emergency hotlines including the COMCEN (Community Emergency Communications Center), Philippine National Police (PNP), Bureau of Fire Protection (BFP), and partner hospitals.

The system shall be built and operated by the LGU ICT Office and consumed by residents of all barangays of the Municipality of Igubat.

---

## 2. PROJECT OBJECTIVES

### 2.1

Provide constituents of the Municipality of Igubat with a single, convenient digital access point for LGU services, official news, and emergency information.

### 2.2

Enable LGU staff (Moderator role) to receive, process, and respond to citizen service requests and issue reports efficiently from a unified web administration portal.

### 2.3

Provide LGU administrators (Admin role) with consolidated tools to manage all application content, citizen and staff accounts, system settings, analytics, and audit logs.

### 2.4

Establish a secure, scalable, and maintainable technical foundation that complies with the **Data Privacy Act of 2012 (Republic Act No. 10173)** and supports future LGU digital initiatives.

### 2.5

Ensure emergency-information continuity by guaranteeing offline access to COMCEN hotlines, partner directories, and recently published civic content even when connectivity is intermittent.

### 2.6

Promote inclusive service delivery by reaching residents across all barangays of the municipality through both Android and iOS devices.

---

## 3. SYSTEM PLATFORMS OVERVIEW

The iGubat system shall be composed of two integrated platforms sharing one backend, one database, and one notification fabric.


| #   | Platform                                           | Audience                  | Primary Purpose                                                                                         |
| --- | -------------------------------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------- |
| A   | **Citizen Mobile Application** (iOS &amp; Android) | Guest, Authenticated User | Public information, account services, request submission, issue reporting, emergency access             |
| B   | **Web Administration Portal** (desktop browsers)   | Moderator, Admin          | Queue processing, content management, emergency broadcasts, user management, analytics, audit, settings |


### 3.1 Platform A — Citizen Mobile Application

A cross-platform mobile application (iOS and Android) for use by constituents of the Municipality of Igubat.

- Allow citizens to access LGU services without an in-person visit to the Municipal Hall.
- Submit and track service requests (Facility Use, Medical Assistance, Transportation Assistance) and local issue/concern reports.
- Receive official LGU announcements and emergency broadcast alerts.
- Access emergency hotlines (911, COMCEN Smart/TNT/Landline, PNP, BFP, partner hospitals) at any time, online or offline.

### 3.2 Platform B — Web Administration Portal

A web-based portal accessible by LGU staff on current desktop browsers (Chrome, Firefox, Edge, Safari).

- Process and manage citizen service requests and issue/concern reports.
- Manage all application content: news articles, announcements, homepage carousel, banners, emergency directory.
- Monitor and manage citizen and staff user accounts.
- Configure system settings, view analytics, and review the audit log.

---

## 4. SYSTEM ARCHITECTURE AND MODULES

The system shall follow a **modular architecture** designed for maintainability and scalability. The system shall be composed of the following eleven (11) core functional modules and three (3) cross-cutting capability layers.

### 4.1 Core Functional Modules


| #   | Module                                       | Description                                                                                                                        |
| --- | -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Authentication Module**                    | Registration, OTP verification, login, password reset, session management                                                          |
| 2   | **Citizen Profile Module**                   | Personal information, barangay, contact details, appearance and notification preferences                                           |
| 3   | **Home and Navigation Module**               | Mobile app entry point, quick-action grid, greeting banner, notification bell                                                      |
| 4   | **News and Announcements Module**            | Article authoring, publication, archival, carousel, banners                                                                        |
| 5   | **Service Request Module**                   | Submission, queue routing, status tracking, completion of Facility Use, Medical Assistance, and Transportation Assistance requests |
| 6   | **Issue and Concern Reports Module**         | Citizen reports of Road Damage, Flooding, Waste Management, Street Lighting, Public Safety, Others                                 |
| 7   | **Emergency Hotline and Directory Module**   | COMCEN hotlines, hospital/BFP/PNP directories, broadcast alerts                                                                    |
| 8   | **Notification Module**                      | Push (FCM/APNs), in-app, email; broadcast and per-event delivery                                                                   |
| 9   | **User and Staff Account Management Module** | Citizen account oversight, staff account lifecycle, role assignment                                                                |
| 10  | **Analytics and Reports Module**             | Operational metrics, charts, exports                                                                                               |
| 11  | **Audit and Activity Logging Module**        | Tamper-evident log of significant system actions                                                                                   |


### 4.2 Cross-Cutting Capability Layers


| Layer                                | Description                                                                                |
| ------------------------------------ | ------------------------------------------------------------------------------------------ |
| **File and Media Management**        | Secure upload, validation, signed-URL retrieval, compression, soft-delete (Section 11)     |
| **Geolocation and Mapping**          | GPS capture, manual map pin adjustment, map display, location-based filtering (Section 12) |
| **Connectivity and Offline Support** | Cached content, retry queue, offline notices (Section 13)                                  |


---

## 5. USER ROLES AND ACCESS

The system shall support exactly **four (4)** canonical user roles across both platforms. Role names below are the source-of-truth identifiers and must be used verbatim in all artifacts.


| Role                   | Platform                     | Description                                                                    |
| ---------------------- | ---------------------------- | ------------------------------------------------------------------------------ |
| **Guest**              | Mobile App (unauthenticated) | Any person opening the mobile app without registering or signing in            |
| **Authenticated User** | Mobile App (signed in)       | A resident who has created and verified a personal account                     |
| **Moderator**          | Web Administration Portal    | LGU operational staff who process requests, handle reports, and manage content |
| **Admin**              | Web Administration Portal    | Highest-level administrator with full portal access                            |


### 5.1 Guest (Unauthenticated Mobile App User)

**Platform:** Mobile Application (unauthenticated)  
**Description:** Any person who accesses the mobile application without registering or signing in.

**Can:**

- View the public home screen with the time-of-day greeting banner (e.g., "Maayong Buntag, Igubat!") and the quick-action grid.
- Browse and read all published news articles and announcements.
- View the emergency screen: 911 slide-to-call, COMCEN hotlines (Smart, TNT, Landline), PNP, BFP, partner hospitals.
- Use one-tap call and copy-to-clipboard on any hotline number.
- Browse the LGU services directory and citizen guide (read-only).
- Browse the emergency directory (hospitals, fire stations, police stations).

**Cannot:**

- Submit service requests.
- File issue or concern reports.
- Receive personalized push notifications.
- Track any request or report status.

### 5.2 Authenticated User (Registered Citizen)

**Platform:** Mobile Application (signed in)  
**Description:** A resident who has created and verified a personal account in the mobile application.

**Can (all Guest access, plus):**

- **Registration and Profile**
  - Create an account with full name, address, barangay, contact number, and password.
  - Update personal profile information and upload a profile photo.
  - Change account password and manage notification preferences.
  - Set appearance preference (light mode or dark mode).
- **Service Requests**
  - Browse available services organized by category.
  - Submit service requests (Facility Use, Medical Assistance, Transportation Assistance) with description, preferred schedule, and up to 3 photo or document attachments.
  - Receive a system-generated tracking number upon successful submission.
  - View the full list and status history of all personally submitted requests.
  - Receive push notification on every status change.
  - Cancel a request that is still in **Pending** status.
- **Issue and Concern Reports**
  - Submit a local issue or concern report with category (Road Damage, Flooding, Waste Management, Street Lighting, Public Safety, Others), description, up to 3 photo attachments, and GPS location (auto-detected with option to adjust the pin).
  - View status and LGU remarks on all personally submitted reports.
  - Receive push notification on every status change.
- **Notifications**
  - Receive official LGU announcements and emergency broadcast alerts via push.
  - View complete in-app notification history.

### 5.3 Moderator

**Platform:** Web Administration Portal  
**Description:** LGU frontline staff assigned to process citizen service requests, respond to issue reports, and manage application content. This role consolidates operational and content management responsibilities.

**Can:**

- **Service Request Processing**
  - View, filter, and open all citizen service requests in the queue.
  - Update request status along the canonical lifecycle: **Pending → In Review → Approved | Rejected | For Pickup → Completed**.
  - Add internal remarks and notes on each request (staff-only).
  - Attach supplementary documents to a request record.
- **Issue Report Handling**
  - View all submitted citizen issue and concern reports on a list and a map.
  - Update report status: **Received → In Progress → Resolved → Closed**.
  - Add internal remarks and notify the reporting citizen of updates.
- **Content Management**
  - Create, edit, publish, archive, and schedule news articles (canonical Article statuses: **Draft | Published | Archived**).
  - Upload and manage images and media assets for articles.
  - Assign categories and tags to articles; set featured images.
  - Manage the homepage featured stories carousel and banners (upload, reorder, activate/deactivate).
  - Preview articles before publishing.
- **Emergency Directory**
  - Add, edit, and deactivate entries in the COMCEN hotlines list and hospital/BFP/PNP directory.
  - Compose and send emergency broadcast push notifications to all app users.
  - View history of all sent broadcast alerts.

**Cannot:**

- Create, edit, or delete staff or citizen accounts.
- Access the analytics dashboard.
- Access system settings.
- Permanently delete content or user records.
- Change role assignments or system configuration.
- View or export audit logs.

### 5.4 Admin (Super Administrator)

**Platform:** Web Administration Portal  
**Description:** The highest-level administrator of the iGubat system. The Admin has full access to all features of the web administration portal and is responsible for user management, analytics, audit, and system configuration.

**Can (all Moderator access, plus):**

- **User Management**
  - View, search, verify, deactivate, and permanently delete citizen accounts.
  - Create, edit, assign roles to, and deactivate LGU staff (Moderator) accounts.
  - Reset passwords for any staff or citizen account.
  - View complete login activity history for all accounts.
  - Export citizen account lists to CSV.
- **Content Oversight**
  - Permanently delete any article, banner, or media asset.
  - Override or unpublish any content item.
- **Emergency Management**
  - Permanently delete any emergency directory entry.
  - View and manage the full broadcast alert history.
- **Analytics and Reports**
  - View the full system analytics dashboard.
  - Filter analytics by date range, barangay, and service type.
  - Export reports to PDF or CSV.
- **Audit Logs**
  - View the full audit log of all staff and system actions.
  - Filter audit logs by actor, action type, and date range.
  - Export audit logs to CSV.
  - Audit logs remain read-only and cannot be modified or deleted by any role.
- **System Settings**
  - Configure system-wide settings: application name, logo, color theme, contact details.
  - Manage service types, report categories, and available request forms.
  - Configure notification settings and file storage settings.
  - View system health and error logs.

---

## 6. FOCUSED DEVELOPMENT AREAS

Two clusters are designated **Focused Development** because they represent the highest-priority delivery surfaces for opening the citizen funnel and unlocking LGU operations on day one.

### 6.1 Citizen Onboarding and Public Access *(Track 1)*

**Why priority:** opens the citizen funnel and surfaces emergency content publicly. Even before authenticated features ship, the Municipality of Igubat must be able to publish news and reach residents with emergency information.

**Scope:**

- Module 1 — Registration and Authentication (Section 7.1)
- Module 2 — Citizen Profile (Section 7.2)
- Module 3 — Home and Navigation (Section 7.3)
- Module 4 — News and Announcements (Section 7.4)
- Module 7 — Emergency Hotline and Directory (Section 7.7)

### 6.2 LGU Service Operations *(Track 2)*

**Why priority:** the core operational value of the platform. Service requests, issue reports, and emergency broadcasts are the day-to-day work of LGU staff.

**Scope:**

- Module 5 — Service Requests (Section 7.5)
- Module 6 — Issue and Concern Reports (Section 7.6)
- Module 8 — Notifications (Section 7.8)
- Module 9 — User and Staff Account Management (Section 7.9, Admin only)

---

## 7. FUNCTIONAL REQUIREMENTS BY MODULE

Each module defines its purpose and the specific functional requirements per applicable role.

---

### 7.1 Module 1 — Registration and Authentication

**Purpose:** Manage how users access the system securely across both platforms.

**Guest:**

- View the registration prompt with a "Create Account" call-to-action.
- Access the sign-in screen without being redirected away from public content (news, emergency).

**Authenticated User (self-registration via mobile app):**

- Register an account by providing: full name, barangay, complete address, mobile number, email (optional), and password.
- Accept the Privacy Notice and provide explicit consent to data collection per the Data Privacy Act of 2012.
- Receive an OTP (One-Time Password) via SMS or email for account verification.
- Sign in using mobile number or email and password.
- Use "Forgot Password" to reset password via OTP.
- Sign out from the mobile application.
- The system shall enforce strong password requirements (minimum 8 characters, alphanumeric).
- The system shall lock the account after **5 consecutive failed login attempts**.
- Mobile sessions shall expire after a configurable period of inactivity (default 7 days for the mobile app).

**Moderator and Admin (staff login via web portal):**

- Sign in to the web administration portal using a staff-issued email and password.
- Staff accounts are created by the Admin only; no self-registration for staff.
- Sessions shall expire after **30 minutes of inactivity** (admin portal default).
- The system shall log all login and logout events with timestamps and IP address.

**Admin:**

- Force password reset for any staff or citizen account.
- Deactivate any account to revoke access immediately.
- View login activity history for all accounts.

---

### 7.2 Module 2 — Citizen Profile Management

**Purpose:** Allow citizens to manage their personal information and account settings.

**Authenticated User:**

- View and update personal profile: name, address, barangay, contact number.
- Upload or change a profile photo.
- Change account password (requires current password verification).
- Set notification preferences: enable or disable specific push notification types (news, service requests, issue reports, emergency broadcasts).
- Set appearance preference: light mode or dark mode.
- View account registration date and account status.

**Moderator:**

- View basic citizen profile information (name, barangay, contact number) when processing a service request or report submitted by that citizen.
- Cannot edit citizen profile data.

**Admin:**

- Search and view all citizen accounts and profile details.
- Verify, deactivate, or reactivate citizen accounts.
- Cannot directly edit citizen personal data (Data Privacy compliance — citizens edit their own data).

---

### 7.3 Module 3 — Home and Navigation

**Purpose:** Provide the entry point and navigation hub of the mobile application.

**Guest:**

- View a time-of-day greeting banner using Filipino/Visayan salutations (e.g., "Maayong Buntag, Igubat!" / "Magandang Umaga, Igubat!").
- View a quick-action grid with navigation tiles: **Services, Citizen Guide, E-Services, Emergency, Utilities, Transport, Business, View More**.
- View a "Help us improve our city" banner with a sign-in call-to-action.
- Notification bell icon redirects to sign-in when tapped.

**Authenticated User:**

- View a personalized greeting using the citizen's first name (e.g., "Maayong Buntag, Juan!").
- All Guest navigation access.
- Notification bell displays unread notification count; tapping opens the in-app notification inbox.

---

### 7.4 Module 4 — News and Announcements

**Purpose:** Publish and display official LGU news, announcements, and updates.

**Guest:**

- View all published news articles and announcements.
- Browse the featured stories carousel (horizontally scrollable photo cards).
- Browse the Latest News feed with category labels (Community, Events, Procurement, Announcements).
- Open and read the full article view with title, body text, images, and publication date.
- Search articles by keyword.

**Authenticated User:**

- All Guest access.
- Receive push notification when a new article is published (if notifications are enabled).
- View unread article indicators in the notification inbox.

**Moderator:**

- Create new news articles using a rich text editor (headings, paragraphs, lists, inline images).
- Upload and attach images to articles; assign categories, tags, and a featured image.
- Set publication date and time (immediate or scheduled).
- Save articles as **Draft** before publishing.
- Edit and update **Published** articles; **Archive** any article.
- Manage the featured stories carousel: add, reorder, and remove items.
- Manage homepage banners: upload, reorder, activate, and deactivate.
- Preview an article before publishing.
- View the list of all articles with status filter: **Draft | Published | Archived**.

**Admin:**

- All Moderator content access.
- Permanently delete any article or media asset.

---

### 7.5 Module 5 — Service Requests

**Purpose:** Allow citizens to submit service requests and enable LGU staff to receive, process, and resolve them.

**Service Types (canonical):** Facility Use, Medical Assistance, Transportation Assistance.

**Status Lifecycle (canonical):** `Pending → In Review → Approved | Rejected | For Pickup → Completed`.

**Guest:**

- View the list of available services and read their descriptions (read-only).
- View a sign-in prompt when attempting to submit a request.

**Authenticated User:**

- Browse available services organized by category (e-Services, Popular Services).
- Submit a service request with: service type, description, preferred date/time, up to 3 file attachments, and auto-populated contact information from profile.
- Receive a system-generated tracking number upon submission.
- View the full list and status history of all personally submitted requests.
- Receive push notification when request status is updated.
- Cancel a request that is still in **Pending** status.

**Moderator:**

- View and filter the full queue of service requests by service type, status, barangay, and date range.
- Open a request to view full details: requestor info, description, attachments, status history.
- Update request status through the canonical lifecycle.
- Add internal remarks (visible to staff only) and attach supplementary documents.

**Admin:**

- All Moderator service request access.
- Configure service types, categories, and form fields per service type.
- View request volume and processing time analytics (cross-reference Module 10).

---

### 7.6 Module 6 — Issue and Concern Reports

**Purpose:** Allow citizens to report local issues and enable LGU staff to respond.

**Report Categories (canonical):** Road Damage, Flooding, Waste Management, Street Lighting, Public Safety, Others.

**Status Lifecycle (canonical):** `Received → In Progress → Resolved → Closed`.

**Guest:**

- View a sign-in prompt when attempting to file a report.

**Authenticated User:**

- Submit a report with: category, description, up to 3 photo attachments, and GPS location (auto-detected; option to manually adjust map pin).
- View all personally submitted reports with current status and LGU remarks.
- Receive push notification when report status is updated.

**Moderator:**

- View all citizen issue and concern reports in a queue with category, status, barangay, and date filters.
- View report details including category, description, photos, and GPS location on a map.
- Update report status through the canonical lifecycle.
- Add internal remarks and notify the reporting citizen of updates via the system.

**Admin:**

- All Moderator report access.
- View all reports on an interactive map (clustered by barangay) with category and status filters.
- View report volume summaries and location heatmap data (cross-reference Module 10).

---

### 7.7 Module 7 — Emergency Hotline and Directory

**Purpose:** Provide citizens with always-accessible emergency contact information.

**Guest:**

- View the emergency screen containing:
  - **"For Emergencies, Call 911"** card with a slide-to-call button.
  - **COMCEN hotlines** (Smart, TNT, Landline) with one-tap call and copy-to-clipboard.
  - Category shortcuts: **Hospitals, Fire Protection (BFP), Police (PNP), Disaster Response**.
  - Directory listings for each category: name, address, contact number, hours.

**Authenticated User:**

- All Guest emergency access.
- Receive emergency broadcast alerts as high-priority push notifications.

**Moderator:**

- Add, edit, and deactivate entries in the COMCEN hotlines list and the hospital/BFP/PNP directory.
- Compose and send emergency broadcast push notification alerts to all app users.
- Schedule emergency announcements for a future date and time.
- View the history of all broadcast alerts sent: message, sender, timestamp, recipient count.

**Admin:**

- All Moderator emergency access.
- Permanently delete any emergency directory entry.
- View and manage the complete broadcast alert history.

---

### 7.8 Module 8 — Notification System

**Purpose:** Deliver timely and relevant information to citizens through push, in-app, and email channels.

**Authenticated User:**

- Receive push notifications for: new articles, emergency broadcasts, service request status updates, and issue report status updates.
- View all received notifications in the in-app notification inbox.
- Mark notifications as read or dismiss them.
- Configure which notification types to receive in account settings.

**Moderator:**

- Optionally trigger push notification to all app users when publishing a new article.
- Compose and send emergency broadcast push notification alerts.

**Admin:**

- All Moderator notification access.
- View notification delivery logs (sent, delivered, failed).

**System (automated):**

- Send push notification to the citizen at every status change on their service request or issue report.
- Send push notification to Moderators when a new request or report is submitted.
- Send transactional emails for OTP, account verification, and password reset.
- Retry failed notification deliveries automatically.

---

### 7.9 Module 9 — User and Staff Account Management

**Purpose:** Manage all citizen accounts and LGU staff accounts; control system access.

**Authenticated User:**

- Manage their own account (see Module 2).

**Moderator:**

- View their own staff profile in the admin portal.
- Update their own password.
- **Cannot** create, edit, or delete any staff or citizen account.

**Admin:**

- Create new LGU staff (Moderator) accounts with: name, email address, and temporary password.
- Edit staff account details and deactivate or reactivate staff accounts.
- Reset passwords for any staff account.
- View and manage all citizen accounts: search, view details, verify, deactivate, reactivate.
- View login activity history for all accounts.
- Export the citizen account list to CSV.

---

### 7.10 Module 10 — Analytics and Reports

**Purpose:** Provide the Admin with data for operational monitoring and decision-making. **Not accessible to Moderator.**

**Admin:**

- View the analytics dashboard:
  - Total and daily active mobile app users.
  - New citizen registrations over time (line chart).
  - Service request volume by type and status (bar chart).
  - Citizen reports by category and barangay (pie chart and map view).
  - Top reported issues by location.
  - Notification delivery statistics.
- Filter all analytics by **date range**, **barangay**, and **service type**.
- Export reports to PDF or CSV.

---

### 7.11 Module 11 — Audit and Activity Logging

**Purpose:** Maintain a complete, tamper-evident record of all significant actions taken in the system for accountability.

**System (automated):**

- Log all significant events with: actor identity, role, timestamp, IP address, and action description, including:
  - User login and logout events.
  - Account creation, modification, and deactivation.
  - Service request status changes.
  - Issue report status changes.
  - Content publication, editing, and deletion.
  - Emergency alert broadcasts sent.
  - System settings changes.

**Admin:**

- View the full audit log with search and filter by actor, role, action type, and date range.
- Export audit log to CSV.
- Audit logs are read-only and cannot be modified or deleted by any role, including Admin.

**Moderator:**

- **No access** to the audit log.

---

## 8. NON-FUNCTIONAL REQUIREMENTS


| #      | Category             | Requirement                                                                                           |
| ------ | -------------------- | ----------------------------------------------------------------------------------------------------- |
| NFR-1  | Mobile compatibility | Android API level 26 (Android 8.0) and above; iOS 14 and above                                        |
| NFR-2  | Web compatibility    | Latest two stable versions of Chrome, Firefox, Edge, and Safari                                       |
| NFR-3  | Concurrent users     | Minimum **500 concurrent users** at launch; scalable to 2,000                                         |
| NFR-4  | Transport security   | All transmissions over **HTTPS/TLS 1.2 or higher**                                                    |
| NFR-5  | Availability         | **99% uptime** during LGU business hours (8:00 AM – 5:00 PM, Mon–Fri)                                 |
| NFR-6  | Response time        | Standard operations complete in **≤ 3 seconds** under normal load                                     |
| NFR-7  | Backups              | **Automated daily database backups** with minimum **30-day retention**                                |
| NFR-8  | Localization         | Bilingual support (English and Filipino/Visayan) for greetings and core labels                        |
| NFR-9  | Accessibility        | Reasonable accessibility for elderly users: large tap targets, readable typography, light/dark themes |
| NFR-10 | Maintainability      | Modular architecture; documented APIs; reproducible deployments                                       |


---

## 9. SECURITY AND COMPLIANCE REQUIREMENTS

- **Role-Based Access Control (RBAC).** Each role (Guest, Authenticated User, Moderator, Admin) can only access functions and data within its defined scope. Moderators cannot reach analytics, settings, audit logs, or user-management actions.
- **Password storage.** All passwords stored using a modern hashing algorithm (e.g., bcrypt with appropriate cost).
- **Account lockout.** Trigger after **5 consecutive failed login attempts**, with administrator override.
- **Session expiration.** Mobile sessions default to 7 days idle; admin portal sessions default to 30 minutes idle. Both configurable by Admin.
- **Data Privacy Act of 2012 (RA 10173) compliance.**
  - Privacy Notice displayed and explicit consent captured at registration.
  - Personal data collected limited to what is necessary for service delivery.
  - Citizens may update their own personal data; Admin cannot directly edit it.
  - Account deactivation honored; right-to-erasure handled administratively by Admin.
- **File upload validation.** All uploaded files validated by MIME type and scanned for malicious content before storage.
- **API authentication.** All API endpoints protected by token-based authentication (JWT or equivalent).
- **Audit logging.** Tamper-evident log of all significant system actions; immutable, append-only.
- **Encrypted secrets.** API keys, OTP secrets, FCM/APNs credentials stored in a secure secrets store.
- **Rate limiting.** Login, OTP request, and broadcast send endpoints rate-limited to prevent abuse.

---

## 10. NOTIFICATION SYSTEM REQUIREMENTS

The system shall support the following notification channels:

- **Push Notifications** — delivered to the citizen's mobile device via **FCM (Firebase Cloud Messaging)** for Android and **APNs (Apple Push Notification service)** for iOS.
- **In-App Notifications** — displayed within the mobile application notification inbox.
- **Email Notifications** — transactional emails for account verification, OTP delivery, password reset, and (where the citizen prefers) status updates.
- **Emergency Broadcast Alerts** — high-priority push notifications sent to all registered citizens; deliverable regardless of individual mute preferences for the emergency-broadcast category by default (with explicit citizen-controlled override).
- **Scheduled Notifications** — Moderators and Admin may schedule notifications for future delivery.
- The notification system shall log all sent notifications with delivery status and timestamps.

---

## 11. FILE AND MEDIA MANAGEMENT REQUIREMENTS

- Supported upload types: **JPEG, PNG, GIF (images)** and **PDF (documents)**.
- Uploaded images shall be automatically compressed to reduce storage footprint while preserving readability.
- Maximum file size: **5 MB per file**, maximum **3 files per submission** (applies to both Service Requests and Issue Reports).
- All uploaded files shall be validated for MIME type and scanned for malicious content.
- Uploaded files shall be accessible only through authenticated, **time-limited signed URLs**.
- The admin portal shall include a media asset manager allowing Moderators to browse, upload, and delete media (with delete being soft).
- File deletion shall default to **soft-delete (files retained for 30 days before permanent removal)**; Admin may force permanent delete.

---

## 12. GEOLOCATION AND MAPPING REQUIREMENTS

- The mobile application shall request GPS location permission when a citizen files an issue report.
- The citizen shall have the option to **auto-detect GPS coordinates** or **manually adjust a location pin** on an interactive map.
- Submitted GPS coordinates shall be stored as latitude and longitude values in the database.
- The web administration portal shall display citizen reports on an interactive map, filterable by **category, status, and barangay**.
- A heatmap view shall be available to the Admin for visualizing the density of reports.
- Map tiles and basemap shall be sourced from an open or licensed provider acceptable to the LGU ICT Office.

---

## 13. CONNECTIVITY AND OFFLINE SUPPORT REQUIREMENTS

- The mobile application shall cache the following for offline viewing:
  - The most recently loaded **20 news articles**.
  - The **emergency hotline numbers** and directory listings (COMCEN, hospitals, BFP, PNP).
  - The **citizen guide pages**.
- Cached content shall display a **"Last updated"** timestamp.
- If a citizen attempts to submit a request or report without internet connection, the system shall display an offline notice and prompt retry when connectivity is restored.
- The application shall automatically retry failed submissions when internet connection is detected, preserving the original submission timestamp.

---

## 14. DELIVERABLES

Aligned to the four-phase sequence defined in `igubat_proposal.md` §5.

### 14.1 Phase 1 — Citizen Foundation and Public Access

- Module 1 — Registration and Authentication (Section 7.1)
- Module 2 — Citizen Profile (Section 7.2)
- Module 3 — Home and Navigation (Section 7.3)
- Module 4 — News and Announcements (Section 7.4)
- Module 7 — Emergency Hotline and Directory (Section 7.7)
- Cross-cutting: File and Media Management foundational scope (Section 11), Connectivity and Offline Support (Section 13).
- Initial deployment, environments, and hosting setup.

> **Outcome:** The Municipality of Igubat can publish official content and reach residents with emergency information from day one. The citizen registration funnel is open.

### 14.2 Phase 2 — Service Operations

- Module 5 — Service Requests (Section 7.5)
- Module 6 — Issue and Concern Reports (Section 7.6)
- Module 8 — Notification System (Section 7.8)
- Cross-cutting: Geolocation and Mapping (Section 12).

> **Outcome:** Citizens can submit requests and reports; LGU staff can process them end-to-end with the Moderator portal.

### 14.3 Phase 3 — Administration and Oversight

- Module 9 — User and Staff Account Management (Section 7.9)
- Module 11 — Audit and Activity Logging (Section 7.11)
- Web administration portal hardening (Moderator and Admin role boundaries).

> **Outcome:** The Admin has full control over user lifecycle and accountability through immutable audit trails.

### 14.4 Phase 4 — Analytics and System Maturity

- Module 10 — Analytics and Reports (Section 7.10)
- System Settings and configuration management.
- Performance tuning, capacity testing, and operational handover.

> **Outcome:** The LGU has data-driven operational visibility and the system is fully configurable by the Admin.

### 14.5 Cross-Cutting Deliverables

- User manuals for each role (Guest, Authenticated User, Moderator, Admin).
- Staff training sessions for Moderators and the Admin.
- Manual test plan execution and sign-off (`igubat_manual_test_plan.md`).
- Post-launch warranty for defect resolution and stabilization.

---

## 15. ASSUMPTIONS AND DEPENDENCIES

### 15.1

The LGU ICT Office will provide an **SMS gateway account** (e.g., Semaphore, Movider, or equivalent Philippine SMS provider) for OTP delivery and emergency SMS where required.

### 15.2

The LGU ICT Office will provide an **email service provider** account (e.g., SendGrid, Postmark, Amazon SES) for transactional and notification emails.

### 15.3

The LGU ICT Office will provide **Firebase Cloud Messaging (FCM)** and **Apple Push Notification service (APNs)** credentials for mobile push notifications, including an Apple Developer Program enrollment for iOS distribution.

### 15.4

The LGU ICT Office will provide **cloud hosting** (or on-premises capacity) sized for the 500-concurrent-user NFR with a documented scaling path to 2,000.

### 15.5

The LGU ICT Office will provide **content for launch**: COMCEN hotlines, partner directory (hospitals, BFP, PNP), seed news articles, and the Privacy Notice text reviewed by the Data Protection Officer.

### 15.6

The Municipality of Igubat will designate at least **one Admin** before user-management features go live, and at least **one Moderator per operational module** before service operations features go live.

### 15.7

The basemap and map tile provider (e.g., OpenStreetMap, Mapbox, Google Maps) will be selected by the LGU ICT Office prior to Phase 2 development.

### 15.8

The Municipality of Igubat will publish the application on the Google Play Store and Apple App Store under its own developer accounts; the LGU ICT Office will manage publication and store listings.

### 15.9

Barangay names and the canonical barangay master list will be supplied by the LGU prior to Phase 1 cutover and maintained through System Settings (Module 9/Admin).

---

## 16. OUT OF SCOPE

The following are **explicitly out of scope** for the current build. They remain available for reactivation in future phases.


| Item                                                                                | Reason                                                              |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Online payment of fees, taxes, or permits                                           | Platform does not handle payments in this release                   |
| Civil registration (birth/marriage/death certificate issuance integration with PSA) | Requires PSA partnership and separate compliance review             |
| Tax declaration and Real Property Tax (RPT) computation                             | Future LGU revenue track                                            |
| Two-Factor Authentication (TOTP/Authenticator app) for citizens                     | Mobile-app OTP is sufficient in v1                                  |
| Multi-language UI beyond bilingual greetings and core labels                        | Localization framework included but full translation deferred       |
| Public-facing API for third-party integrations                                      | Internal API only in v1                                             |
| Field-officer mobile companion app                                                  | Moderators operate from the web portal only                         |
| Chatbot or AI assistant inside the mobile app                                       | Not in current proposal                                             |
| Door-to-door barangay verification workflow                                         | Manual verification by Admin in v1                                  |
| SMS-based two-way reporting                                                         | Push-based notifications only in v1                                 |
| In-app live video streaming of LGU sessions                                         | Out of scope; links to external streams may be embedded in articles |
| Integration with national LGU systems (DICT eGov platforms)                         | Deferred pending DICT coordination                                  |


---

*Document version 3.1 — aligned to `igubat_proposal.md`. Canonical roles: Guest, Authenticated User, Moderator, Admin. Canonical service statuses: Pending → In Review → Approved | Rejected | For Pickup → Completed. Canonical report statuses: Received → In Progress → Resolved → Closed. Canonical article statuses: Draft | Published | Archived.*

*Prepared for the Municipality of Igubat, ICT Office.*