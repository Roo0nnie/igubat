Claude finished the response

im planning to create an igubat application where the primary purpose is make the services in the LGU service make it digital, like this in the screenshot, but ii have no idea what is the limitation or scope of the application, can you help me create a plan and help me what are the modules to be included in the application and website to manage the application content. I have here a sample screenshot that provide the same purpose of this application
May 26

Looking at your screenshots, this is a city government mobile app (specifically for the City of Naga). Here's a comprehensive plan for your iGubat LGU Digital Services Application.

Here's the full breakdown for your iGubat app project:

What the app is

iGubat is a citizen-facing mobile app (iOS/Android) for the Municipality of Igubat, with a companion web admin panel for LGU staff to manage content and respond to requests. The primary goal is to digitize the front-end of LGU services — making information, requests, and emergency contacts accessible on citizens' phones.

Mobile App Modules

The five core tabs mirror what you saw in the Naga app screenshots:

Home — greeting banner, quick-action grid (Services, Citizen Guide, E-Services, Emergency, Utilities, Transport, Business), and a "Help us improve" sign-in prompt for issue reporting.

Services — two-tier layout: e-Services (Business Permit, Real Property Tax, Local Civil Registry) requiring login for the online portal, and Popular Services (facility booking, medical assistance, transportation assistance).

News & Updates — featured photo cards (like the Traslacion, Bar Exam coverage you saw), latest news feed with category tags (Community, Procurement, Events), and search.

Emergency — 911 quick-call with slide-to-call, COMCEN hotlines (Smart/TNT/Landline with copy buttons), and service category shortcuts (Hospitals, Fire Protection, Police, Disaster).

Account — unauthenticated view with sign-in CTA, plus Preferences (appearance/dark mode), Support links (Facebook, YouTube, website), and when signed in: request history and profile.

Citizen Reports (accessible when logged in) — form to submit local concerns (road damage, waste, flooding, etc.) with photo and GPS location, plus status tracking.

Web Admin Panel Modules

Dashboard — daily active users, pending requests count, unread reports, recent activity feed.

Content Manager — create/edit/delete news posts, set featured articles, upload images, schedule publication.

Service Request Processor — view incoming service requests (facility bookings, medical/transport requests), update status (Pending → In Review → Approved/Rejected), assign to staff.

Citizen Report Viewer — map or list view of submitted reports, update resolution status, internal notes, notify citizen.

User Management — citizen account list, staff accounts with role-based access (Admin, Editor, Officer), verification workflow.

Emergency Settings — CRUD for hotline numbers, hospital/BFP directory, push-broadcast alerts for emergencies.

Analytics — basic stats: most-used services, reports by category, user registration trends.

Scope Boundaries

Phase 1 (your initial scope) should focus on what the screenshots already show: information access, request submission forms, emergency hotlines, citizen reporting, and admin content management. Exclude full payment gateways, digital document issuance, real-time government API integrations (PhilSys, PSA, DICT), and biometric verification — those are realistic Phase 2 additions once the foundation is stable.

Suggested Tech Stack

For the mobile app, React Native or Flutter works well for a single codebase targeting both iOS and Android. For the web admin, a standard React/Next.js dashboard. For the backend, Node.js or Laravel (popular in PH government projects) with a PostgreSQL database, and Firebase or OneSignal for push notifications.

Want me to go deeper on any specific module — like the service request flow, the database schema, or the admin panel wireframe?

what are the user included here, the user local admin etc? can you help me define
May 26

Here are the user roles for your iGubat app. There are 5 distinct users across the mobile app and web admin panel.

Here's how each role is defined in detail:

Role 1 — Guest (unauthenticated) Anyone who downloads the app without registering. They can browse news, view emergency hotlines, use the quick-call feature, and read about available services. This is important because in an emergency, a citizen shouldn't need to log in first. No account required.

Role 2 — Registered Citizen A resident who creates an account using their name, address, and contact number. Once verified, they unlock the ability to submit service requests (facility booking, medical assistance, transport), file local issue/concern reports with photos and GPS location, and track the status of their submissions. This is the primary user of the mobile app.

Role 3 — LGU Officer / Frontline Staff Staff from specific offices — like the Municipal Social Services and Development office (MSSD), Business Permits and Licensing Office (BPLO), or the transport desk. They log in to the web admin panel to see requests assigned to their department, update statuses, and respond to citizen reports. They don't touch content or user settings — only their own queue.

Role 4 — Content Editor Typically the Public Information Officer (PIO) or municipal communications staff. They manage everything that appears in the News & Updates feed — writing posts, uploading photos, scheduling announcements, setting featured articles. They have no access to service requests or user management.

Role 5 — Super Admin The IT/MIS head or a designated system administrator. Full access to everything: user accounts, staff roles, hotline configuration, service settings, push notifications, and the analytics dashboard. There should ideally be only 1–2 people with this role, and all actions should be logged for accountability.

The key design principle here is least privilege — each role can only see and do what their job requires. An LGU officer can't accidentally publish news, and a content editor can't approve permit requests. This keeps the system clean and reduces errors. Want me to map out the registration and verification flow for citizens next?

now i want you to create for me a TOR to implement this modules for different users. the sample tor must formatted like sample below and format it in the .md file so i can copy and paste the TOR of this iGubat

Sample format tor:
1. User Roles and Access Requirements
The system shall support the following user roles:
1.1 Super Admin

    Full system access
    Manage admins and moderators
    View all system data

    Override decisions
    1.2 Admin
    Monitor system activity
    View users, tasks, and payments
    Generate reports

    Manage flagged or suspicious activities
    1.3 Moderator
    Review and verify user accounts
    Approve/reject ID submissions
    Handle reports and disputes

    Take actions:
     
        Warn users
        Suspend users (with defined duration)
        Deactivate users 1.4 Client
    Create and manage tasks
    Assign taskers
    Review submitted work
    Approve or reject task completion

    Report users and raise disputes
    1.5 Tasker
    Apply for tasks
    Accept/reject assigned tasks
    Complete tasks
    View earnings (in-app balance)
    Report users and raise disputes

May 26
Check available skills for .md file creation

Since this is a markdown file (not a Word doc), I'll create it directly.
Created a file, read a file

Here's your complete TOR for the iGubat application. It covers:

    Section 3 — All 5 user roles (Guest, Registered Citizen, LGU Officer, Content Editor, Super Admin) with their specific permissions, matching the format of your sample TOR
    Section 4 — Detailed functional requirements for every module in both the mobile app and admin panel
    Sections 5–10 — Non-functional requirements, deliverables table, indicative timeline (27 weeks), responsibilities, assumptions/constraints, and acceptance criteria

A few things worth noting before you submit this to anyone:

The timeline is indicative — you'll want to adjust it based on your actual team size and budget. The 27-week estimate assumes a small team of 2–3 developers working in parallel across mobile and backend.

The out-of-scope items in Section 9 (payments, document issuance, PSA/PhilSys integration) are important to keep explicit — these are common scope creep areas in LGU systems and having them written down protects both the LGU and the developer.

You may also want to add a Budget section if this TOR is being used for procurement (PhilGEPS posting), and a Penalties and Liquidated Damages clause if required by your local procurement guidelines under RA 9184.
Igubat tor
Document · MD 
12:24 PM
Read the current TOR file

Now I have the full picture. Let me build the comprehensive revised TOR.
Ran a command, created a file, read a file

Here's your fully revised TOR v2.0. Here's a summary of everything that was improved:

Structure changes:

    Expanded from 2 platforms to 3 platforms (Mobile App, Web Admin Portal, Backend Service Platform) — this is how professional government system TORs are structured
    Added a proper Table of Contents and expanded from 10 to 21 sections

User roles expanded from 5 to 8:

    Added Department Supervisor (office head who oversees Frontline Officers)
    Added Emergency Operator (dedicated role for hotline management and broadcast alerts)
    Added ICT Administrator (technical staff separate from Super Admin)
    Each role now has a clearly stated platform, description, and explicit list of what they can and cannot do

Modules restructured to be role-based (Section 6): Every module now lists each role separately with its exact permissions — exactly the format you requested. For example, Module 1 (Registration) tells you what a Guest can do, what a Registered Citizen can do, what LGU Staff can do, and what the Super Admin can do — all within the same module.

New sections added (all 14 recommended improvements): Workflow Engine, Security & Compliance, Notification System, File Management, Geolocation, Offline Support, Scalability, API & Integration, Future Expansion, Warranty & Support — all now included with specific, implementable requirements.
Igubat tor
Document · MD 
Want to be notified when Claude responds?


Claude is AI and can make mistakes. Please double-check responses.
Igubat tor · MD
# Terms of Reference (TOR)
## iGubat — LGU Digital Services Application
### Citizen Mobile Application, Web Administration Portal, and Backend Service Platform
 
---
 
**Project Title:** iGubat — Local Government Unit Digital Services Application
**Document Type:** Terms of Reference (TOR)
**Prepared for:** Municipality of Igubat, Information and Communications Technology Office
**Version:** 2.0
 
---
 
## Table of Contents
 
1. Project Background
2. Project Objectives
3. System Platforms Overview
4. System Architecture Requirements
5. User Roles and Access Requirements
6. Functional Requirements by Module
7. Non-Functional Requirements
8. Security and Compliance Requirements
9. Notification System Requirements
10. File and Media Management Requirements
11. Geolocation and Mapping Requirements
12. Connectivity and Offline Support Requirements
13. Scalability Requirements
14. API and Integration Requirements
15. Future Expansion Considerations
16. Deliverables
17. Project Timeline
18. Roles and Responsibilities
19. Assumptions and Constraints
20. Acceptance Criteria
21. Warranty and Post-Deployment Support
---
 
## 1. Project Background
 
The Municipality of Igubat seeks to develop a comprehensive digital platform — the **iGubat Application** — to modernize the delivery of local government services to its constituents. The platform shall make LGU services accessible through a citizen-facing mobile application, manageable through a web-based administration and operations portal for LGU staff, and powered by a centralized backend service platform.
 
The iGubat application aims to reduce the need for in-person transactions, improve information dissemination, establish a direct communication channel between the local government and citizens, and support data-driven decision-making within the LGU.
 
---
 
## 2. Project Objectives
 
The system shall achieve the following objectives:
 
* Provide citizens with a single, convenient digital access point for LGU services, news, and emergency information
* Enable LGU frontline staff to receive, process, and respond to service requests and citizen reports efficiently
* Provide the Public Information Office with tools to publish and manage public-facing content
* Enable LGU administrators to oversee users, workflows, and system activity
* Establish a secure, scalable, and maintainable technical foundation for future LGU digital initiatives
---
 
## 3. System Platforms Overview
 
The iGubat system shall be composed of three integrated platforms:
 
### Platform A — Citizen Mobile Application
 
A cross-platform mobile application (iOS and Android) for use by constituents of the Municipality of Igubat.
 
**Purpose:**
* Allow citizens to access LGU services without an in-person visit
* Submit and track service requests
* Receive official announcements and emergency alerts
* Report local issues and concerns
* Access emergency hotlines at any time
### Platform B — Web Administration and Operations Portal
 
A web-based portal accessible by LGU staff on desktop browsers.
 
**Purpose:**
* Process and manage citizen service requests
* Manage content (news, announcements, banners)
* Monitor and resolve citizen issue reports
* Manage user accounts and staff access
* Monitor system activity and generate operational reports
* Configure emergency directories and system settings
### Platform C — Backend Service Platform
 
A centralized backend system that powers both Platform A and Platform B.
 
**Purpose:**
* Expose secure RESTful APIs consumed by the mobile app and admin portal
* Handle authentication and session management
* Process and route push notifications, email, and future SMS alerts
* Manage file and media storage
* Maintain audit logs of all system activities
* Power the workflow and approval engine
* Process analytics data
---
 
## 4. System Architecture Requirements
 
The system shall follow a **modular, service-oriented architecture** designed for maintainability and future scalability. The system shall be composed of the following core modules:
 
| Module | Description |
|--------|-------------|
| **Authentication Module** | Handles login, registration, token management, and session security |
| **Citizen Management Module** | Manages citizen profiles, verification, and account lifecycle |
| **Service Request Module** | Handles submission, routing, status tracking, and completion of requests |
| **Content Management Module** | Manages news articles, banners, categories, and media assets |
| **Notification Module** | Handles push, in-app, and email notifications and broadcasts |
| **Reports and Analytics Module** | Processes and visualizes system usage and operational data |
| **Emergency Hotline Module** | Manages emergency directories and alert broadcasts |
| **Audit and Activity Logging Module** | Records all user and staff actions with timestamps and identifiers |
| **File and Media Management Module** | Handles secure upload, storage, retrieval, and validation of files |
| **Workflow and Approval Engine** | Manages configurable multi-step approval flows per service type |
| **Geolocation Module** | Handles GPS capture, map display, and location-based filtering |
 
---
 
## 5. User Roles and Access Requirements
 
The system shall support the following eight (8) user roles across all three platforms:
 
---
 
### 5.1 Guest Citizen
 
**Platform:** Mobile Application (unauthenticated)
**Description:** Any person who accesses the mobile application without registering an account.
 
* View the public home screen with quick-action navigation
* Browse and read all published news and announcements
* View emergency hotlines: COMCEN (Smart, TNT, Landline), Police, BFP, Hospitals
* Use the slide-to-call and copy-to-clipboard functions on hotline numbers
* Browse the LGU services directory and citizen guide (read-only)
* Browse the emergency directory: hospitals, fire stations, police
* Cannot submit service requests
* Cannot file issue or concern reports
* Cannot receive personalized push notifications
* Cannot track any request or report status
---
 
### 5.2 Registered Citizen
 
**Platform:** Mobile Application (authenticated)
**Description:** A resident who has created and verified a personal account.
 
* All access available to Guest Citizen, plus:
* **Registration and Profile:**
  * Create an account with name, address, contact number, and barangay
  * Update personal profile information
  * Change password and manage account security settings
  * Set notification preferences (push, in-app)
* **Service Requests:**
  * Submit service requests for: Use of Government Facilities, Medical Assistance, Transportation Assistance
  * Attach photos and supporting documents to service requests
  * Receive a tracking number upon successful submission
  * View the full history and current status of all submitted requests
  * Receive push notifications when request status is updated
  * Cancel a pending service request
* **Issue and Concern Reports:**
  * Submit a local issue or concern report with category, description, up to 3 photo attachments, and GPS location
  * View the status of all submitted reports
  * Receive push notifications when report status is updated by LGU staff
* **Notifications:**
  * Receive official LGU announcements via push notification
  * Receive emergency broadcast alerts
  * View in-app notification history
---
 
### 5.3 Frontline Officer
 
**Platform:** Web Administration and Operations Portal
**Description:** LGU staff assigned to a specific department (e.g., MSSD, BPLO, Transport Office) responsible for processing requests.
 
* **Service Request Processing:**
  * View all service requests assigned to their department
  * View full request details: requestor information, description, attachments, submitted date
  * Update request status: Pending → In Review → Approved / Rejected / For Pickup / Completed
  * Add internal notes and remarks on each request
  * Attach supplementary documents to a request record
  * Transfer a request to another officer within the same department
* **Citizen Report Handling:**
  * View citizen issue reports assigned to their department
  * Update report resolution status with remarks
  * Notify the reporting citizen of resolution updates through the system
* **Restrictions:**
  * Cannot manage user accounts or staff accounts
  * Cannot publish news or content
  * Cannot access requests outside their assigned department
  * Cannot change system or workflow settings
---
 
### 5.4 Department Supervisor
 
**Platform:** Web Administration and Operations Portal
**Description:** The head or supervisor of an LGU department who oversees the work of Frontline Officers.
 
* All access available to Frontline Officer, plus:
* **Department Oversight:**
  * View all requests and reports within their department, including those assigned to other officers
  * Reassign requests from one officer to another within the department
  * Escalate requests to a higher authority or to the Super Administrator
  * Override or reverse a decision made by a Frontline Officer with documented reason
* **Department Reports:**
  * View department-level performance summaries: total processed, pending, average resolution time
  * Export department request reports to CSV or PDF
* **Restrictions:**
  * Cannot manage users outside their department
  * Cannot publish content
  * Cannot access other departments' data
---
 
### 5.5 Content Editor
 
**Platform:** Web Administration and Operations Portal
**Description:** Staff of the Public Information Office (PIO) or Municipal Communications Team.
 
* **News and Content Management:**
  * Create, edit, publish, and archive news articles and announcements
  * Upload and manage images and media assets for articles
  * Assign categories and tags to posts
  * Set a featured image for each article
  * Manage the homepage featured stories carousel
  * Manage homepage banners: upload, reorder, set active/inactive
  * Schedule articles for future publication
  * Preview an article before publishing
* **Restrictions:**
  * Cannot process service requests or citizen reports
  * Cannot manage user accounts or staff accounts
  * Cannot send emergency broadcast alerts
  * Cannot access system settings or analytics
---
 
### 5.6 Emergency Operator
 
**Platform:** Web Administration and Operations Portal
**Description:** Designated LGU staff responsible for maintaining emergency information and sending urgent alerts.
 
* **Emergency Directory Management:**
  * Add, edit, and deactivate emergency hotline entries (COMCEN, Police, BFP, Hospitals)
  * Add, edit, and deactivate hospital, fire station, and police directory listings
* **Emergency Alert Broadcasting:**
  * Compose and send broadcast push notification alerts to all app users
  * Schedule emergency alert messages
  * View the history of all sent broadcasts with timestamps and sender identity
* **Restrictions:**
  * Cannot manage user accounts or staff accounts
  * Cannot publish news or general content
  * Cannot process service requests
---
 
### 5.7 ICT Administrator
 
**Platform:** Web Administration and Operations Portal
**Description:** The designated technical staff of the LGU ICT Office responsible for system configuration and maintenance.
 
* All access available to Super Administrator, except user data management
* **System Configuration:**
  * Configure system-wide settings: application name, logo, color theme, contact details
  * Configure notification infrastructure settings
  * Configure file storage settings
  * Manage service types and service categories
  * Manage workflow templates and approval step configurations
* **Audit and Monitoring:**
  * View full audit logs of all system activity across all roles
  * View system health and error logs
  * Monitor API usage and performance metrics
* **Restrictions:**
  * Cannot view or manage citizen personal data directly
  * Cannot approve or reject citizen service requests
---
 
### 5.8 Super Administrator
 
**Platform:** Web Administration and Operations Portal
**Description:** The highest-level administrator of the iGubat system, typically held by the Municipal Mayor's office designate or the ICT Office head.
 
* **Full system access across all modules, including:**
* **User Management:**
  * View, search, verify, deactivate, and delete citizen accounts
  * Create, edit, assign roles to, and deactivate all LGU staff accounts
  * Assign departments and roles to staff
  * Reset passwords for staff accounts
* **Content and Emergency:**
  * All access available to Content Editor
  * All access available to Emergency Operator
* **Workflow Management:**
  * Create and modify workflow templates for any service type
  * Configure approval steps, routing rules, and escalation paths
* **Analytics and Reports:**
  * View the full system analytics dashboard
  * View user registration trends, service volumes, report summaries
  * Filter analytics by date range, barangay, department, or service type
  * Export all reports to PDF or CSV
* **Audit:**
  * View full audit logs of all staff actions, including login history, changes made, and timestamps
* **System Settings:**
  * All ICT Administrator access, plus direct management of user accounts
---
 
## 6. Functional Requirements by Module
 
Each module below defines its purpose, the roles that interact with it, and the specific functional requirements per role.
 
---
 
### Module 1 — Registration and Authentication
 
**Purpose:** Manage how users access the system securely across all platforms.
 
**Roles and Requirements:**
 
**Guest Citizen:**
* View the registration prompt with a "Create Account" call-to-action
* Access the sign-in screen
**Registered Citizen (self-registration):**
* Register an account by providing: full name, barangay, complete address, mobile number, and password
* Receive an OTP (One-Time Password) via SMS or email for account verification
* Sign in using mobile number or email and password
* Use "Forgot Password" to reset password via OTP
* Sign out from the mobile application
* The system shall enforce strong password requirements (minimum 8 characters, alphanumeric)
* The system shall lock the account after 5 consecutive failed login attempts
* Sessions shall expire after a configurable period of inactivity
**LGU Staff (all roles except Registered Citizen):**
* Sign in to the web administration portal using a staff-issued email and password
* Accounts are created by the ICT Administrator or Super Administrator only (no self-registration)
* The system shall enforce session expiration after inactivity
* The system shall log all login and logout events with timestamps and IP address
**ICT Administrator / Super Administrator:**
* Force password reset for any staff account
* Deactivate a staff account to revoke access immediately
* View login activity history for all accounts
---
 
### Module 2 — Citizen Profile Management
 
**Purpose:** Allow citizens to manage their personal information and account settings.
 
**Roles and Requirements:**
 
**Registered Citizen:**
* View and update personal profile: name, address, barangay, contact number
* Upload or change a profile photo
* Change account password (requires current password verification)
* Set notification preferences: enable or disable push notifications
* Set appearance preference: light mode or dark mode
* View account registration date and account status
**Frontline Officer / Department Supervisor:**
* View basic citizen profile information when viewing a service request or report submitted by that citizen
* Cannot edit citizen profile data
**ICT Administrator / Super Administrator:**
* Search and view all citizen accounts
* View citizen profile details, registration date, and activity history
* Verify, deactivate, or reactivate citizen accounts
* Cannot edit citizen personal data directly (data privacy compliance)
---
 
### Module 3 — Home and Navigation Module
 
**Purpose:** Provide the entry point and navigation hub of the mobile application.
 
**Roles and Requirements:**
 
**Guest Citizen:**
* View a time-of-day greeting banner (e.g., "Maayong Buntag")
* View a quick-action grid with navigation to: Services, Citizen Guide, E-Services, Emergency, Utilities, Transport, Business, and View More
* View a "Help us improve our city" banner with a sign-in call-to-action
* View the notification bell icon (tapping leads to sign-in prompt)
**Registered Citizen:**
* View a personalized greeting with the citizen's first name
* All Guest navigation access
* Notification bell displays unread notification count
* Tapping notification bell opens the in-app notification inbox
---
 
### Module 4 — News and Announcements Module
 
**Purpose:** Publish and display official LGU news, announcements, and updates.
 
**Roles and Requirements:**
 
**Guest Citizen:**
* View all published news articles and announcements
* Browse the featured stories carousel (horizontally scrollable photo cards)
* Browse the Latest News feed with category labels (Community, Events, Procurement, Announcements)
* Open and read full article view with title, body text, images, and publication date
* Search articles by keyword
**Registered Citizen:**
* All Guest Citizen access, plus:
* Receive push notification when a new article is published
* View unread article indicator in the notification inbox
**Content Editor:**
* Create new news articles using a rich text editor with support for headings, paragraphs, bullet lists, and inline images
* Upload and attach images to articles
* Assign a category and tags to each article
* Set a featured image for the article
* Set publication date and time (immediate or scheduled)
* Save articles as Draft before publishing
* Edit and update previously published articles
* Archive articles to remove from public view without permanent deletion
* Manage the featured stories carousel: add, reorder, and remove items
* Manage homepage banners: upload, reorder, activate, and deactivate
* Preview an article before publishing
* View the list of all articles with status filter (Draft, Published, Archived)
**Super Administrator:**
* All Content Editor access
* Delete any article or media asset permanently
---
 
### Module 5 — Service Request Module
 
**Purpose:** Allow citizens to submit service requests and enable LGU staff to receive, process, and resolve them.
 
**Roles and Requirements:**
 
**Guest Citizen:**
* View the list of available services and read their descriptions (read-only)
* View a sign-in prompt when attempting to submit a request
**Registered Citizen:**
* Browse available services organized by category (e-Services, Popular Services)
* Submit a service request by filling out a form that captures:
  * Service type selection
  * Request description
  * Preferred date and time (where applicable)
  * Photo or document attachment (up to 3 files)
  * Requestor contact information (auto-populated from profile)
* Receive a system-generated tracking number upon submission
* View a list of all personally submitted service requests with current status
* View the full details and status history of each request
* Receive a push notification when request status is updated by LGU staff
* Cancel a request that is still in Pending status
**Frontline Officer:**
* View the queue of service requests assigned to their department
* Filter requests by: service type, status, date range
* Open a request to view full details: requestor info, description, attachments, and submission history
* Update request status with one of the following: In Review, Approved, Rejected, For Pickup, Completed
* Add internal remarks or notes (visible to LGU staff only)
* Attach supplementary documents to the request record
* Transfer a request to another officer within the same department
**Department Supervisor:**
* All Frontline Officer access within their department, plus:
* View all requests within the department, regardless of assigned officer
* Reassign a request from one officer to another
* Escalate a request to the Super Administrator
* Override a status decision with a documented justification
**Super Administrator:**
* View all service requests across all departments
* Reassign any request to any officer or department
* Configure service types, categories, and available request forms
* View request volumes and processing time analytics
---
 
### Module 6 — Workflow and Approval Engine
 
**Purpose:** Provide a configurable system for defining how each service request type is processed, routed, and approved.
 
**Roles and Requirements:**
 
**Frontline Officer:**
* Follow the defined workflow steps for each service type when processing a request
* View the current workflow step and history of actions taken on a request
**Department Supervisor:**
* View workflow progress for all requests in the department
* Escalate a request when workflow is stalled
**ICT Administrator:**
* Create and modify workflow templates for each service type
* Define approval steps, responsible roles, and routing rules per step
* Configure escalation rules: automatic escalation after a defined number of days without action
* Configure reassignment rules: allow or restrict officer-to-officer transfers per service
**Super Administrator:**
* All ICT Administrator workflow access
* Override workflow routing on any active request with audit trail
**System (automated):**
* Route new service requests to the correct department and officer based on service type
* Advance request status automatically when workflow conditions are met
* Trigger notifications to citizens and officers at each workflow transition
* Record a complete timestamped history of all workflow actions on each request
---
 
### Module 7 — Citizen Issue and Concern Reports Module
 
**Purpose:** Allow citizens to report local issues (infrastructure, environment, public safety) and enable LGU staff to respond.
 
**Roles and Requirements:**
 
**Guest Citizen:**
* View a sign-in prompt when attempting to file a report
**Registered Citizen:**
* Submit a report with the following fields:
  * Report category: Road Damage, Flooding, Waste Management, Street Lighting, Public Safety, Others
  * Description of the concern
  * Photo attachments: up to 3 photos
  * Location: auto-detected GPS coordinates with option to manually adjust pin on map
* View all personally submitted reports with current status
* View report status history and LGU remarks
* Receive push notification when report status is updated
**Frontline Officer:**
* View citizen reports assigned to their department
* View report details: category, description, photos, GPS location on map
* Update report status: Received, In Progress, Resolved, Closed
* Add internal remarks visible to LGU staff
* Notify the citizen of status updates through the system
**Department Supervisor:**
* View all reports within the department
* Reassign reports between officers
* Escalate unresolved reports to the Super Administrator
**Super Administrator:**
* View all citizen reports across all departments and barangays
* View reports on an interactive map filtered by category, status, and barangay
* View report volume summaries and heatmap data
---
 
### Module 8 — Emergency Hotline and Directory Module
 
**Purpose:** Provide citizens with always-accessible emergency contact information and enable LGU staff to maintain it.
 
**Roles and Requirements:**
 
**Guest Citizen:**
* View the emergency screen displaying:
  * A "For Emergencies, Call 911" card with a slide-to-call button
  * COMCEN hotlines (Smart, TNT, Landline) with one-tap call and copy-to-clipboard
  * Category shortcuts: Hospitals, Fire Protection (BFP), Police, Disaster Response
  * Directory listings for each category: name, address, contact number
**Registered Citizen:**
* All Guest Citizen emergency access
* Receive emergency broadcast alerts as push notifications
**Emergency Operator:**
* Add, edit, and deactivate entries in the COMCEN hotlines list
* Add, edit, and deactivate entries in the hospital, BFP, and police directory
* Compose and send emergency broadcast push notification alerts to all app users
* Schedule emergency announcements for a future date and time
* View the history of all broadcast alerts sent: message, sender, timestamp, recipient count
**Super Administrator:**
* All Emergency Operator access
* Delete any emergency directory entry permanently
* View full alert broadcast history
---
 
### Module 9 — Notification Module
 
**Purpose:** Deliver timely and relevant information to citizens and LGU staff through multiple notification channels.
 
**Roles and Requirements:**
 
**Registered Citizen:**
* Receive push notifications for:
  * New published news and announcements
  * Emergency broadcast alerts
  * Service request status updates
  * Citizen report status updates
* View all received notifications in the in-app notification inbox
* Mark notifications as read or dismiss them
* Configure which notification types to receive in account settings
**Content Editor:**
* Trigger push notification to all app users when publishing a new article (optional toggle at publication)
**Emergency Operator:**
* Send immediate broadcast push notification alerts to all app users
* Schedule broadcast notifications for future delivery
**Super Administrator:**
* All notification triggering access
* View notification delivery logs
**System (automated):**
* Send push notification to the requesting citizen at every workflow status change on their request
* Send push notification to the assigned officer when a new request is assigned to them
* Retry failed notification deliveries automatically
---
 
### Module 10 — User and Staff Management Module
 
**Purpose:** Manage all citizen accounts and LGU staff accounts, and control system access.
 
**Roles and Requirements:**
 
**Registered Citizen:**
* Manage their own account (see Module 2)
**Frontline Officer / Department Supervisor / Content Editor / Emergency Operator:**
* View their own staff profile in the admin portal
* Update their own password
**ICT Administrator:**
* Create new LGU staff accounts with: name, email, role, and assigned department
* Edit staff account details and role assignments
* Deactivate or reactivate staff accounts
* Cannot create Super Administrator accounts
**Super Administrator:**
* All ICT Administrator access, plus:
* Create Super Administrator accounts
* View and manage all citizen accounts: search, view details, verify, deactivate, reactivate
* View login activity logs for all accounts
* Export citizen account list to CSV
---
 
### Module 11 — Analytics and Reports Module
 
**Purpose:** Provide LGU leadership and administrators with data for operational monitoring and decision-making.
 
**Roles and Requirements:**
 
**Department Supervisor:**
* View department-level summary: total requests received, processed, pending, and average resolution time
* Export department reports to CSV or PDF
**Super Administrator / ICT Administrator:**
* View the full analytics dashboard with:
  * Total and daily active users
  * New registrations over time (line chart)
  * Service request volume by type and status (bar chart)
  * Citizen reports by category and barangay (pie and map view)
  * Top reported issues by location
  * Notification delivery statistics
* Filter all analytics by date range, barangay, department, and service type
* Export all reports to PDF or CSV
---
 
### Module 12 — Audit and Activity Logging Module
 
**Purpose:** Maintain a complete, tamper-evident record of all significant actions taken in the system for accountability and compliance.
 
**Roles and Requirements:**
 
**System (automated):**
* Log all of the following events with: actor identity, role, timestamp, IP address, and action description:
  * User login and logout
  * Account creation, modification, and deactivation
  * Service request status changes
  * Report status changes
  * Content publication, editing, and deletion
  * Emergency alert broadcasts sent
  * Workflow configuration changes
  * System settings changes
**ICT Administrator / Super Administrator:**
* View the full audit log with search and filter by: actor, role, action type, date range
* Export audit log to CSV
* Audit logs shall be read-only and cannot be modified or deleted by any role
---
 
## 7. Non-Functional Requirements
 
* The mobile application shall support Android API level 26 (Android 8.0) and above, and iOS version 14 and above
* The system shall support a minimum of **500 concurrent users** at launch, scalable to 2,000 concurrent users
* All data transmissions between clients and the server shall be encrypted using **HTTPS/TLS 1.2 or higher**
* The system shall maintain **99% uptime** during LGU business hours (8:00 AM – 5:00 PM, Monday to Friday)
* The web administration portal shall be accessible on current versions of Chrome, Firefox, Edge, and Safari
* System response time for standard operations shall not exceed **3 seconds** under normal load
* The backend shall support **automated database backups** at minimum once daily with a retention period of 30 days
---
 
## 8. Security and Compliance Requirements
 
* The system shall implement **Role-Based Access Control (RBAC)** strictly enforcing that each role can only access functions and data within its defined scope
* All passwords shall be stored using a secure hashing algorithm (e.g., bcrypt)
* The system shall implement **account lockout** after 5 consecutive failed login attempts, with unlock via OTP or administrator action
* Session tokens shall expire after a configurable period of inactivity (default: 30 minutes for admin portal, 7 days for mobile app)
* The system shall comply with the **Data Privacy Act of 2012 (Republic Act No. 10173)** in the collection, storage, and processing of personal data of citizens
* Citizens shall be presented with a Privacy Notice and must provide consent upon registration
* The system shall implement a **disaster recovery plan** with defined Recovery Point Objective (RPO) and Recovery Time Objective (RTO)
* All uploaded files shall be validated for type and scanned for malicious content before storage
* API endpoints shall be protected using token-based authentication (e.g., JWT)
* The audit logging module (Module 12) shall maintain a tamper-evident log of all significant system actions
---
 
## 9. Notification System Requirements
 
The system shall support the following notification channels:
 
* **Push Notifications** — delivered to the citizen's mobile device via FCM (Firebase Cloud Messaging) for Android and APNs for iOS
* **In-App Notifications** — displayed within the mobile application notification inbox
* **Email Notifications** — transactional emails for account registration, OTP, and password reset
* **SMS Integration** — the system architecture shall be SMS-gateway-ready for future OTP and alert delivery via SMS
* **Emergency Broadcast Alerts** — high-priority push notifications sent to all registered citizens, bypassing individual notification preferences
* **Scheduled Notifications** — content editors and emergency operators may schedule notifications for future delivery
* The notification system shall log all sent notifications with delivery status and timestamps
---
 
## 10. File and Media Management Requirements
 
* The system shall support secure file uploads for: JPEG, PNG, GIF (images), and PDF (documents)
* Uploaded images shall be automatically compressed to reduce storage footprint while maintaining acceptable quality
* Maximum file size per upload: **5 MB per file**, maximum **3 files per submission**
* All uploaded files shall be validated for file type (MIME type verification), file size, and shall be scanned for malicious content
* Files shall be stored on a cloud or local storage system configurable by the ICT Administrator
* Uploaded files shall be accessible only through authenticated, time-limited signed URLs
* The system shall include a media asset manager in the admin portal for Content Editors to browse, upload, and delete media
* File deletion shall be soft-delete by default (files retained for 30 days before permanent removal)
---
 
## 11. Geolocation and Mapping Requirements
 
* The mobile application shall request GPS location permission from the citizen when filing an issue report
* The citizen shall have the option to auto-detect their current GPS coordinates or manually adjust a location pin on an interactive map
* Submitted report GPS coordinates shall be stored as latitude and longitude values in the database
* The web administration portal shall display citizen reports on an interactive map view filtered by category, status, and barangay
* The system architecture shall be prepared for future integration with GIS (Geographic Information System) services for barangay boundary mapping and report heatmaps
---
 
## 12. Connectivity and Offline Support Requirements
 
* The mobile application shall **cache the following content for offline viewing:**
  * Most recently loaded news and announcements (last 20 articles)
  * Emergency hotline numbers and directory
  * Citizen guide pages
* Cached content shall display a "Last updated" timestamp to indicate data freshness
* If a citizen attempts to submit a service request or report without an internet connection, the system shall display an appropriate offline notice and prompt the citizen to retry when connectivity is restored
* The application shall **automatically retry failed submissions** when an internet connection is detected
---
 
## 13. Scalability Requirements
 
The system architecture shall support:
 
* **Horizontal scaling** — the backend shall be deployable across multiple servers or containers to handle increased load
* **Cloud deployment** — the system shall be deployable on major cloud platforms (e.g., AWS, Google Cloud, Azure) or a local government-provisioned cloud infrastructure
* **API-based integration** — all functions shall be accessible via a documented API to allow integration with future systems
* **Multi-office support** — the admin portal shall support assigning staff to different offices and departments without architectural changes
* **Multi-barangay expansion** — citizen reports and analytics shall support filtering and grouping by barangay, and the system shall support adding new barangays without code changes
* **Centralized logging and monitoring** — the system shall expose logs and health metrics compatible with standard monitoring tools
* **Database optimization** — the database design shall include appropriate indexing for high-volume query performance
---
 
## 14. API and Integration Requirements
 
* The Backend Service Platform shall expose **secure RESTful APIs** consumed by the mobile application and the web administration portal
* All API endpoints shall require **token-based authentication (JWT)** except for publicly designated endpoints (e.g., news listing, emergency hotlines)
* API documentation shall be delivered as part of the project deliverables (e.g., Swagger/OpenAPI format)
* The system architecture shall be designed to support future integration with:
| Future Integration | Description |
|-------------------|-------------|
| PhilSys (PSA) | National ID verification for citizen account verification |
| DICT eGov | Compliance with national e-government framework |
| SMS Gateway | OTP delivery, status alert SMS to citizens |
| Payment Gateway | Online payment for real property tax and permits (Phase 2) |
| GIS Mapping Services | Barangay boundary maps and report geographic analysis |
| PSA Civil Registry | Verification of birth and civil registry records (Phase 2) |
 
---
 
## 15. Future Expansion Considerations
 
The architecture shall be designed to support the following future modules without requiring a complete rebuild:
 
* **Online Payments** — real property tax, business permit fees
* **Digital Document Issuance** — barangay clearance, community tax certificate (cedula), indigency certificate
* **QR Code Verification** — verify authenticity of LGU-issued documents
* **Appointment Scheduling** — book a date and time for in-person LGU transactions
* **Barangay Portals** — dedicated sub-portals for each barangay under the municipality
* **Internal LGU Task Management** — inter-office task assignment and tracking for LGU staff
* **AI Chatbot Assistance** — FAQ and guided service navigation chatbot for citizens
* **E-Document Issuance** — digitally signed and verifiable documents issued directly through the app
* **Integration with National Government Systems** — PhilSys, PSA, DICT eGov
---
 
## 16. Deliverables
 
| No. | Deliverable | Description |
|-----|-------------|-------------|
| 1 | System Requirements Specification (SRS) | Finalized and approved detailed requirements document |
| 2 | System Architecture Document | Platform architecture, module diagrams, deployment architecture |
| 3 | Database Entity Relationship Diagram (ERD) | Complete database schema and relationships |
| 4 | API Documentation | Full REST API documentation in Swagger/OpenAPI format |
| 5 | UI/UX Design Files | High-fidelity wireframes and design prototypes for all screens |
| 6 | Mobile Application — Android | Fully functional Android APK submitted to Google Play Store |
| 7 | Mobile Application — iOS | Fully functional iOS build submitted to Apple App Store |
| 8 | Web Administration and Operations Portal | Deployed and functional web admin portal |
| 9 | Backend Service Platform | Deployed REST API, database, and all backend services |
| 10 | User Manuals | Separate manuals for: Citizens, LGU Staff, and Administrators |
| 11 | User Acceptance Testing (UAT) Report | Documented UAT results with sign-off by the LGU Project Owner |
| 12 | Deployment Documentation | Production deployment guide, environment configuration, and runbook |
| 13 | Source Code Repository | Complete source code with version history, transferred to LGU ICT Office |
| 14 | Staff Orientation Report | Documentation of conducted training sessions with attendance records |
| 15 | Post-Deployment Warranty Report | Summary of issues resolved during the warranty period |
 
---
 
## 17. Project Timeline (Indicative)
 
| Phase | Activities | Duration |
|-------|------------|----------|
| Phase 1 — Requirements and Design | Requirements finalization, UI/UX design, system architecture, ERD, API design | 4 weeks |
| Phase 2 — Backend Development | Database setup, authentication, core APIs, workflow engine, notification infrastructure | 6 weeks |
| Phase 3 — Mobile Application Development | All mobile app modules: iOS and Android | 8 weeks |
| Phase 4 — Web Administration Portal Development | All admin portal modules | 6 weeks |
| Phase 5 — Integration and Testing | System integration, unit testing, UAT, bug fixes | 4 weeks |
| Phase 6 — Deployment and Handover | Production deployment, staff orientation, documentation submission | 2 weeks |
| **Total** | | **30 weeks** |
 
---
 
## 18. Roles and Responsibilities
 
| Role | Responsibility |
|------|---------------|
| LGU Project Owner (Mayor's Office) | Approve requirements and deliverables, provide final sign-off |
| ICT Office Coordinator | Coordinate technical requirements, manage infrastructure provisioning, accept technical deliverables |
| Department Heads | Provide department-specific service workflow requirements and validate UAT |
| PIO / Communications Staff | Review and validate the News and Content Management module |
| Developer / Service Provider | Full design, development, testing, deployment, documentation, and orientation |
| End Users — Citizens | Participate in mobile app UAT |
| End Users — LGU Staff | Participate in admin portal UAT |
 
---
 
## 19. Assumptions and Constraints
 
* The LGU shall provide all necessary data to populate initial directories: emergency hotlines, hospital listings, BFP contacts, police contacts, and service categories
* The LGU ICT Office shall procure or provision the required cloud hosting infrastructure prior to deployment
* Integration with national government systems (PhilSys, PSA, DICT eGov) and online payment processing are **out of scope for Phase 1**
* Digital document issuance (cedula, barangay clearance, etc.) is **out of scope for Phase 1**
* Apple Developer Program and Google Play Developer accounts required for app store submission shall be procured or provided by the LGU or the developer as agreed in the contract
* The developer shall conduct a minimum of two (2) orientation sessions for LGU staff before go-live
* SMS gateway integration is **future-ready only** in Phase 1; actual SMS delivery is out of scope for Phase 1
---
 
## 20. Acceptance Criteria
 
The system shall be formally accepted upon satisfaction of all of the following conditions:
 
* All functional requirements defined in Section 6 (Modules 1–12) have been implemented and verified
* All non-functional requirements in Section 7 have been tested and met
* Security and compliance requirements in Section 8 have been validated
* User Acceptance Testing (UAT) has been completed with sign-off from the LGU Project Owner and designated department representatives
* The mobile application has been successfully deployed to the Google Play Store and Apple App Store
* The web administration portal has been deployed to a production server and is accessible to LGU staff
* All deliverables listed in Section 16 have been submitted and accepted
* Staff orientation has been conducted and attendance documented
---
 
## 21. Warranty and Post-Deployment Support
 
The developer / service provider shall provide post-deployment support as follows:
 
* **Warranty Period:** A minimum of **three (3) months** from the date of final acceptance, extendable to six (6) months as negotiated in the contract
* **Bug Fixing:** All defects and system errors discovered during the warranty period shall be resolved at no additional cost to the LGU
* **Minor Adjustments:** Minor functional adjustments and configuration changes (not constituting new features) shall be accommodated during the warranty period
* **Technical Assistance:** The developer shall provide technical support for ICT staff for system administration tasks during the warranty period
* **Response Time:** Critical issues (system downtime, data loss) shall be responded to within **4 hours**; non-critical issues within **2 business days**
* **Handover:** At the end of the warranty period, the developer shall conduct a final handover session with the LGU ICT Office confirming full operational readiness
---
 
*End of Terms of Reference*
 
*iGubat LGU Digital Services Application — TOR Version 2.0*
*Municipality of Igubat, ICT Office*
 

