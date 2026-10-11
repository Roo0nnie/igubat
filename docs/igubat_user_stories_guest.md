# User Stories — Guest

## iGubat — LGU Digital Services Application

> **Role:** Guest  
> **Description:** An unauthenticated visitor to the citizen mobile app. Guests can browse public information (news, emergency directory, Discover Gubat, Transparency & Good Governance) but are prompted to sign in before submitting a request or report.  
> **Derived from:** `igubat_user_stories.md` v1.1 (aligned to `igubat_tor.md` v3.2)  
> **Story count:** 24

Story format:

- **As a** Guest
- **I want to** [capability]
- **So that** [outcome]
- **Acceptance Criteria:** bullet list of testable conditions.

Stories retain their original numbering (Section.Story) from the master `igubat_user_stories.md` for cross-reference. Stories shared with another role (e.g., Guest/Authenticated User offline access, Moderator/Admin staff login) appear in both role files.

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

---

## 3. Home and Navigation

### Story 3.1 — Guest Sees Time-of-Day Greeting and Quick Actions

**As a** Guest  
**I want to** see a Filipino/Visayan time-of-day greeting and a grid of quick-action tiles  
**So that** I can reach what I need in one tap.

**Acceptance Criteria:**

- Greeting varies by time-of-day (e.g., "Maayong Buntag, Gubat!" in the morning).
- Quick-action tiles: Services, Citizen Guide, E-Services, Emergency, Utilities, Transport, Business, Discover Gubat, View More.
- A "Help us improve our city" banner is visible with a sign-in CTA.

---

### Story 3.2 — Notification Bell Routes Guest to Sign-In

**As a** Guest  
**I want to** be guided to sign in when I tap the notification bell  
**So that** I understand that notifications require an account.

**Acceptance Criteria:**

- The bell is visible but tapping it opens the sign-in flow.

---

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

---

## 15. Tourism, Culture &amp; Local Products (Discover Gubat)

### Story 15.1 — Guest Browses Tourist Spots

**As a** Guest  
**I want to** browse Gubat's tourist spots by category with photos and a map location  
**So that** I can discover places to visit in the municipality.

**Acceptance Criteria:**

- The Discover Gubat tile on Home opens the surface with three sections: Tourist Spots, Festivals & Culture, Local Delicacies & Products.
- Tourist Spot categories: Beaches & Surfing, Nature & Eco-Tourism, Heritage & Landmarks.
- A tourist spot detail shows name, photos, description, category, and a map location (e.g., Buenavista Beach, Rizal Beach, Castillo de Gubat, San Antonio de Padua Parish Church).
- All content is read-only; no authentication is required.

---

### Story 15.2 — Guest Reads a Festival/Culture Article

**As a** Guest  
**I want to** read articles about Gubat's festivals, history, and heritage  
**So that** I understand the town's cultural identity.

**Acceptance Criteria:**

- The Festivals & Culture section lists culture articles (e.g., the Ginubat Festival, town heritage, local dialect and traditions).
- An article detail shows title, body, images, and publication date.

---

### Story 15.3 — Guest Browses Local Delicacies and Products

**As a** Guest  
**I want to** browse Gubat's local delicacies and products with where-to-buy information  
**So that** I know what to taste and take home as pasalubong.

**Acceptance Criteria:**

- Product categories: Delicacies/Kakanin, Pasalubong, Handicrafts/OTOP, Seafood, Pili Products.
- A product detail shows name, type/category, description, photo, and a where-to-buy / pasalubong note (e.g., timitim, salanigo, binut-ong, dalu-dalo, sikad-sikad, pili nuts).
- The surface is informational only — no ordering, payment, or reservation in v1.

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

### Story 16.1 — Guest Sees a Transparency Section on Home

**As a** Guest **I want to** see a Transparency &amp; Good Governance section on Home **so that** I can find what the LGU is doing, buying, spending, and enacting.

**Acceptance Criteria:** 2×3 grid of six tiles (Program and Projects, Bids and Projects, Financial Reports, Annual Budget, Legislative Ordinances, Executive Orders); subtitle reads "Know where your taxes go"; section sits above "Discover Latest News".

---

### Story 16.2 — Guest Opens a Category List

**As a** Guest **I want to** open a category and see its published items **so that** I can browse the latest disclosures.

**Acceptance Criteria:** published items only, sorted most-recent first; paginated; fiscal-year filter chip and free-text search by title/reference number.

---

### Story 16.3 — Guest Opens an Item and Downloads Attachments

**As a** Guest **I want to** open an item and read it **so that** I can review the full disclosure and its documents.

**Acceptance Criteria:** item detail shows a type-specific metadata band, summary, full body, and an attachments list opened via signed URL (PDF/JPG/PNG).

---

### Story 16.11 — Citizens View Cached Transparency Items Offline

**As a** Guest or Authenticated User **I want to** view recently loaded transparency items offline **so that** I can read disclosures without connectivity.

**Acceptance Criteria:** previously loaded list items render offline with a "Last updated · cached" banner; attachments require network unless previously opened.

---

*Document version 1.1 — aligned to `igubat_tor.md` v3.2. Roles: Guest, Authenticated User, Moderator, Admin, System. 16 sections, 95+ user stories.*

---

*Guest user stories — 24 stories across 8 feature sections. Extracted from `igubat_user_stories.md` v1.1. Companion files: igubat_user_stories_guest.md, igubat_user_stories_authenticated_user.md, igubat_user_stories_moderator.md, igubat_user_stories_admin.md. System-actor stories (background jobs, audit logging, retries) remain documented only in the master file.*