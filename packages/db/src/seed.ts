import "dotenv/config"

import { randomBytes, scryptSync } from "node:crypto"
import { inArray, or } from "drizzle-orm"
import { drizzle } from "drizzle-orm/node-postgres"
import { Pool } from "pg"

import {
	accounts,
	auditLogs,
	citizenReportAttachments,
	citizenReports,
	citizenReportStatusHistory,
	contentPlacements,
	departments,
	emergencyBroadcasts,
	emergencyDirectory,
	events,
	helpArticles,
	mediaAssets,
	newsArticles,
	notificationDeliveryLogs,
	notificationPreferences,
	notifications,
	policyDocuments,
	schema,
	serviceCategories,
	serviceRequestAttachments,
	serviceRequests,
	serviceRequestStatusHistory,
	serviceTypes,
	systemSettings,
	tickets,
	userLoginActivity,
	users,
	workflowTemplates,
} from "./schema.js"

// ---------------------------------------------------------------------------
// Seed identifiers (used for idempotent cleanup on re-run)
// ---------------------------------------------------------------------------

export const SEED_USER_IDS = [
	"seed-user-juan",
	"seed-user-maria",
	"seed-user-pedro",
	"seed-user-ana",
	"seed-user-unverified",
	"seed-user-admin",
	"seed-user-ict",
	"seed-user-supervisor",
	"seed-user-officer",
	"seed-user-officer2",
	"seed-user-editor",
	"seed-user-emergency",
] as const

export const SEED_TRACKING_NUMBERS = [
	"BP-2026-0418",
	"BP-2026-0422",
	"BP-2026-0431",
	"CR-2026-0117",
	"MA-2026-0033",
	"TA-2026-0007",
	"BC-2026-0021",
	"FU-2026-0004",
] as const

const SEED_DEPARTMENT_NAMES = ["MSSD", "BPLO", "Transport Office", "MHO", "MDRRMO"] as const
const SEED_SERVICE_CATEGORY_SLUGS = ["permits", "certificates", "assistance", "facilities"] as const
const SEED_SERVICE_TYPE_SLUGS = [
	"facility-use",
	"medical-assistance",
	"transportation-assistance",
	"business-permit",
	"certification",
	"barangay-clearance",
] as const

const SEED_TICKET_EMAILS = [
	"admin@igubat.local",
	"juan@example.com",
	"maria@example.com",
	"guest@igubat.local",
] as const

const WORKFLOW_STEPS = ["pending", "in_review", "approved", "rejected", "for_pickup", "completed"]

const SEED_PASSWORD = "password123"

async function hashPassword(password: string): Promise<string> {
	const saltHex = randomBytes(16).toString("hex")
	const key = scryptSync(password.normalize("NFKC"), saltHex, 64, {
		N: 16384,
		r: 16,
		p: 1,
		maxmem: 128 * 16384 * 16 * 2,
	})

	return `${saltHex}:${key.toString("hex")}`
}

type Db = ReturnType<typeof drizzle<typeof schema>>
type Tx = Parameters<Parameters<Db["transaction"]>[0]>[0]

function buildSeedUsers(
	now: Date,
	deptIds: Record<string, number>
): Array<typeof users.$inferInsert> {
	return [
		// Citizens (mobile app)
		{
			id: "seed-user-juan",
			name: "Juan Dela Cruz",
			email: "juan@example.com",
			emailVerified: true,
			image: null,
			role: "registered_citizen",
			mobileNumber: "09171234567",
			barangay: "Cogon",
			address: "Sitio Riverside, Brgy. Cogon, Gubat, Sorsogon",
			dpaConsent: true,
			createdAt: new Date("2024-01-15T08:00:00Z"),
			updatedAt: now,
		},
		{
			id: "seed-user-maria",
			name: "Maria Santos",
			email: "maria@example.com",
			emailVerified: true,
			image: null,
			role: "registered_citizen",
			mobileNumber: "09181234567",
			barangay: "Bagacay",
			address: "Purok 3, Brgy. Bagacay, Gubat, Sorsogon",
			dpaConsent: true,
			createdAt: new Date("2024-02-20T10:30:00Z"),
			updatedAt: now,
		},
		{
			id: "seed-user-pedro",
			name: "Pedro Reyes",
			email: "pedro@example.com",
			emailVerified: true,
			image: null,
			role: "registered_citizen",
			mobileNumber: "09191234567",
			barangay: "Panganiban (Poblacion)",
			address: "National Road, Brgy. Panganiban, Gubat, Sorsogon",
			dpaConsent: true,
			createdAt: new Date("2024-03-05T14:15:00Z"),
			updatedAt: now,
		},
		{
			id: "seed-user-ana",
			name: "Ana Villareal",
			email: "ana@igubat.local",
			emailVerified: true,
			image: null,
			role: "registered_citizen",
			mobileNumber: "09201234567",
			barangay: "Manook",
			address: "Brgy. Manook, Gubat, Sorsogon",
			dpaConsent: true,
			createdAt: new Date("2024-04-01T09:00:00Z"),
			updatedAt: now,
		},
		{
			id: "seed-user-unverified",
			name: "Carlos Unverified",
			email: "unverified@igubat.local",
			emailVerified: false,
			image: null,
			role: "registered_citizen",
			mobileNumber: "09211234567",
			barangay: "Rizal",
			address: "Brgy. Rizal, Gubat, Sorsogon",
			dpaConsent: true,
			createdAt: new Date("2024-05-01T12:00:00Z"),
			updatedAt: now,
		},
		// Staff (web portal)
		{
			id: "seed-user-admin",
			name: "Super Admin",
			email: "admin@igubat.local",
			emailVerified: true,
			image: null,
			role: "super_admin",
			dpaConsent: false,
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-ict",
			name: "ICT Administrator",
			email: "ict@igubat.local",
			emailVerified: true,
			image: null,
			role: "ict_admin",
			dpaConsent: false,
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-supervisor",
			name: "Elena Supervisor",
			email: "supervisor@igubat.local",
			emailVerified: true,
			image: null,
			role: "department_supervisor",
			departmentId: deptIds.MSSD,
			dpaConsent: false,
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-officer",
			name: "Ramon Officer",
			email: "officer@igubat.local",
			emailVerified: true,
			image: null,
			role: "frontline_officer",
			departmentId: deptIds.BPLO,
			dpaConsent: false,
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-officer2",
			name: "Liza Transport Officer",
			email: "officer2@igubat.local",
			emailVerified: true,
			image: null,
			role: "frontline_officer",
			departmentId: deptIds["Transport Office"],
			dpaConsent: false,
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-editor",
			name: "Content Editor",
			email: "editor@igubat.local",
			emailVerified: true,
			image: null,
			role: "content_editor",
			dpaConsent: false,
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-emergency",
			name: "Emergency Operator",
			email: "emergency@igubat.local",
			emailVerified: true,
			image: null,
			role: "emergency_operator",
			dpaConsent: false,
			createdAt: now,
			updatedAt: now,
		},
	]
}

async function upsertUsersAndAccounts(
	tx: Tx,
	seedUsers: Array<typeof users.$inferInsert>,
	hashedPassword: string,
	now: Date
) {
	for (const user of seedUsers) {
		await tx
			.insert(users)
			.values(user)
			.onConflictDoUpdate({
				target: users.id,
				set: {
					name: user.name,
					email: user.email,
					emailVerified: user.emailVerified,
					image: user.image,
					role: user.role,
					status: user.status ?? "active",
					departmentId: user.departmentId ?? null,
					mobileNumber: user.mobileNumber ?? null,
					barangay: user.barangay ?? null,
					address: user.address ?? null,
					dpaConsent: user.dpaConsent ?? false,
					failedLoginAttempts: user.failedLoginAttempts ?? 0,
					lockedUntil: user.lockedUntil ?? null,
					forcePasswordReset: user.forcePasswordReset ?? false,
					lastLoginAt: user.lastLoginAt ?? null,
					updatedAt: now,
				},
			})
	}

	for (const user of seedUsers) {
		await tx
			.insert(accounts)
			.values({
				providerId: "credential",
				accountId: user.id,
				userId: user.id,
				password: hashedPassword,
				createdAt: now,
				updatedAt: now,
			})
			.onConflictDoUpdate({
				target: [accounts.providerId, accounts.accountId],
				set: {
					userId: user.id,
					password: hashedPassword,
					updatedAt: now,
				},
			})
	}
}

async function clearSeedDomainData(tx: Tx) {
	await tx.delete(notificationDeliveryLogs)
	await tx.delete(notifications).where(inArray(notifications.userId, [...SEED_USER_IDS]))
	await tx
		.delete(notificationPreferences)
		.where(inArray(notificationPreferences.userId, [...SEED_USER_IDS]))
	await tx.delete(auditLogs).where(inArray(auditLogs.actorId, [...SEED_USER_IDS]))
	await tx.delete(userLoginActivity).where(inArray(userLoginActivity.userId, [...SEED_USER_IDS]))
	await tx
		.delete(tickets)
		.where(
			or(
				inArray(tickets.email, [...SEED_TICKET_EMAILS]),
				inArray(tickets.authorId, [...SEED_USER_IDS])
			)
		)
	await tx.delete(newsArticles).where(inArray(newsArticles.authorId, [...SEED_USER_IDS]))
	await tx.delete(contentPlacements)
	await tx.delete(events)
	await tx.delete(mediaAssets).where(inArray(mediaAssets.uploadedById, [...SEED_USER_IDS]))
	await tx.delete(helpArticles)
	await tx.delete(policyDocuments)
	await tx.delete(systemSettings)
	await tx.delete(emergencyBroadcasts)
	await tx.delete(citizenReportAttachments)
	await tx.delete(citizenReportStatusHistory)
	await tx.delete(citizenReports).where(inArray(citizenReports.authorId, [...SEED_USER_IDS]))
	await tx.delete(serviceRequestAttachments)
	await tx.delete(serviceRequestStatusHistory)
	await tx
		.delete(serviceRequests)
		.where(
			or(
				inArray(serviceRequests.trackingNumber, [...SEED_TRACKING_NUMBERS]),
				inArray(serviceRequests.authorId, [...SEED_USER_IDS])
			)
		)
	await tx.delete(workflowTemplates)
	await tx.delete(serviceTypes).where(inArray(serviceTypes.slug, [...SEED_SERVICE_TYPE_SLUGS]))
	await tx
		.delete(serviceCategories)
		.where(inArray(serviceCategories.slug, [...SEED_SERVICE_CATEGORY_SLUGS]))
	await tx.delete(emergencyDirectory)
	await tx
		.update(users)
		.set({ departmentId: null })
		.where(inArray(users.id, [...SEED_USER_IDS]))
	await tx.delete(departments)
}

async function seedDatabase() {
	const connectionString = process.env.DATABASE_URL

	if (!connectionString) {
		throw new Error("DATABASE_URL environment variable is not set")
	}

	const pool = new Pool({ connectionString })
	const db = drizzle({ client: pool, schema })
	const now = new Date()
	const hashedSeedPassword = await hashPassword(SEED_PASSWORD)

	const seedDepartments: Array<typeof departments.$inferInsert> = [
		{
			name: "MSSD",
			description: "Municipal Social Services and Development",
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "BPLO",
			description: "Business Permits and Licensing Office",
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "Transport Office",
			description: "Transportation Office",
			createdAt: now,
			updatedAt: now,
		},
		{ name: "MHO", description: "Municipal Health Office", createdAt: now, updatedAt: now },
		{
			name: "MDRRMO",
			description: "Municipal Disaster Risk Reduction and Management Office",
			createdAt: now,
			updatedAt: now,
		},
	]

	try {
		const counts = await db.transaction(async tx => {
			await clearSeedDomainData(tx)

			const insertedDepartments = await tx.insert(departments).values(seedDepartments).returning({
				id: departments.id,
				name: departments.name,
			})

			const deptIds = Object.fromEntries(insertedDepartments.map(d => [d.name, d.id])) as Record<
				(typeof SEED_DEPARTMENT_NAMES)[number],
				number
			>

			const seedUsers = buildSeedUsers(now, deptIds)
			await upsertUsersAndAccounts(tx, seedUsers, hashedSeedPassword, now)

			const serviceCategoryRows = [
				{
					name: "Permits",
					slug: "permits",
					description: "Business, facility, and other permit-based LGU transactions.",
					sortOrder: 1,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Certificates",
					slug: "certificates",
					description: "Resident certifications, barangay clearances, and supporting documents.",
					sortOrder: 2,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Assistance",
					slug: "assistance",
					description: "Medical, transportation, and other citizen assistance requests.",
					sortOrder: 3,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Facilities",
					slug: "facilities",
					description: "Reservations and use requests for municipal venues and assets.",
					sortOrder: 4,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
			] satisfies Array<typeof serviceCategories.$inferInsert>
			const insertedCategories = await tx
				.insert(serviceCategories)
				.values(serviceCategoryRows)
				.returning({
					id: serviceCategories.id,
					slug: serviceCategories.slug,
				})
			const categoryIds = Object.fromEntries(insertedCategories.map(c => [c.slug, c.id])) as Record<
				(typeof SEED_SERVICE_CATEGORY_SLUGS)[number],
				number
			>

			const serviceTypeRows = [
				{
					name: "Facility Use",
					slug: "facility-use",
					description:
						"Reserve an LGU-managed venue for meetings, assemblies, or community activities.",
					categoryId: categoryIds.facilities,
					requirements: ["Valid ID", "Purpose letter", "Preferred schedule"],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 3,
					icon: "building-2",
					imageUrl: "/images/placeholders/service-facility.png",
					isPopular: true,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Medical Assistance",
					slug: "medical-assistance",
					description:
						"Request medical assistance review with supporting hospital or clinical documents.",
					categoryId: categoryIds.assistance,
					requirements: ["Valid ID", "Medical certificate", "Hospital billing statement"],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 5,
					icon: "heart-pulse",
					imageUrl: "/images/placeholders/service-medical.png",
					isPopular: true,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Transportation Assistance",
					slug: "transportation-assistance",
					description: "Request transport support for approved citizen assistance cases.",
					categoryId: categoryIds.assistance,
					requirements: ["Valid ID", "Destination and schedule", "Purpose of travel"],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 4,
					icon: "bus",
					imageUrl: "/images/placeholders/service-transport.png",
					isPopular: false,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Business Permit",
					slug: "business-permit",
					description: "Apply for or renew a local business permit with BPLO review.",
					categoryId: categoryIds.permits,
					requirements: [
						"Valid ID",
						"Barangay clearance",
						"DTI/SEC registration",
						"Lease or ownership proof",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 5,
					icon: "briefcase",
					imageUrl: "/images/placeholders/service-business-permit.png",
					isPopular: true,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Certification",
					slug: "certification",
					description:
						"Request municipal certifications for residency, indigency, and related attestations.",
					categoryId: categoryIds.certificates,
					requirements: ["Valid ID", "Barangay endorsement", "Purpose of request"],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 2,
					icon: "badge-check",
					imageUrl: "/images/placeholders/service-certification.png",
					isPopular: true,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Barangay Clearance",
					slug: "barangay-clearance",
					description: "Request a barangay clearance for local transactions and employment needs.",
					categoryId: categoryIds.certificates,
					requirements: ["Valid ID", "Barangay residency confirmation"],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 2,
					icon: "file-text",
					imageUrl: "/images/placeholders/service-clearance.png",
					isPopular: false,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
			] satisfies Array<typeof serviceTypes.$inferInsert>
			const insertedServiceTypes = await tx.insert(serviceTypes).values(serviceTypeRows).returning({
				id: serviceTypes.id,
				name: serviceTypes.name,
				slug: serviceTypes.slug,
			})
			const serviceTypeIdsByName = Object.fromEntries(
				insertedServiceTypes.map(s => [s.name, s.id])
			) as Record<string, number>

			const workflowRows = [
				{
					serviceType: "Business Permit",
					departmentId: deptIds.BPLO,
					steps: WORKFLOW_STEPS,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					serviceType: "Certificate of Residency",
					departmentId: deptIds.MSSD,
					steps: WORKFLOW_STEPS,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					serviceType: "Medical Assistance",
					departmentId: deptIds.MHO,
					steps: WORKFLOW_STEPS,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					serviceType: "Transportation Assistance",
					departmentId: deptIds["Transport Office"],
					steps: WORKFLOW_STEPS,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					serviceType: "Barangay Clearance",
					departmentId: deptIds.MSSD,
					steps: WORKFLOW_STEPS,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					serviceType: "Facility Use",
					departmentId: deptIds.MSSD,
					steps: WORKFLOW_STEPS,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
			] satisfies Array<typeof workflowTemplates.$inferInsert>
			await tx.insert(workflowTemplates).values(workflowRows)

			const seedNewsArticles: Array<typeof newsArticles.$inferInsert> = [
				{
					title: "Business Permit Renewal Period Now Open",
					slug: "business-permit-renewal-period-now-open",
					excerpt:
						"Business permit renewal and new applications are now accepted through BPLO and iGubat.",
					body: "The Municipality of Gubat is now accepting new and renewal business permit applications for the upcoming year. Visit the BPLO office or apply online via iGubat.",
					category: "Business",
					status: "published",
					imageUrl: "/images/placeholders/news-business-permit.png",
					isFeatured: true,
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-20T08:00:00Z"),
					createdAt: new Date("2026-05-20T08:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Free Medical Mission This Saturday",
					slug: "free-medical-mission-this-saturday",
					excerpt: "Residents are invited to a free medical mission at the town plaza.",
					body: "The Municipal Health Office invites all residents to a free medical mission at the town plaza. Bring valid IDs for verification.",
					category: "Health",
					status: "published",
					imageUrl: "/images/placeholders/news-medical-mission.png",
					isFeatured: false,
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-18T09:30:00Z"),
					createdAt: new Date("2026-05-18T09:30:00Z"),
					updatedAt: now,
				},
				{
					title: "Road Repair Schedule for May",
					slug: "road-repair-schedule-for-may",
					excerpt: "Road repairs will affect traffic flow along selected national road segments.",
					body: "Expect traffic rerouting along the national road from May 22-25 due to ongoing road repair operations.",
					category: "Infrastructure",
					status: "published",
					imageUrl: "/images/placeholders/news-road-repair.png",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-15T07:15:00Z"),
					createdAt: new Date("2026-05-15T07:15:00Z"),
					updatedAt: now,
				},
				{
					title: "Coastal Clean-Up Drive",
					slug: "coastal-clean-up-drive",
					excerpt:
						"Volunteer groups and residents are invited to join the Rizal Beach clean-up drive.",
					body: "Join the LGU and volunteer groups for a coastal clean-up activity at Rizal Beach this Sunday.",
					category: "Community",
					status: "published",
					imageUrl: "/images/placeholders/news-cleanup.png",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-10T10:00:00Z"),
					createdAt: new Date("2026-05-10T10:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Scheduled Power Interruption",
					slug: "scheduled-power-interruption",
					excerpt:
						"Selected barangays will experience a scheduled power interruption for line maintenance.",
					body: "Please be informed of a scheduled power interruption on May 30 due to line maintenance in selected barangays.",
					category: "Utilities",
					status: "published",
					imageUrl: "/images/placeholders/news-utilities.png",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-26T08:00:00Z"),
					createdAt: new Date("2026-05-26T08:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Tax Payment Deadline Reminder",
					slug: "tax-payment-deadline-reminder",
					excerpt: "Real property tax payments are due by June 30.",
					body: "Reminder: Real property tax payment deadline is June 30. Avoid penalties by paying early at the Treasurer's Office or via iGubat.",
					category: "Business",
					status: "published",
					imageUrl: "/images/placeholders/news-tax-deadline.png",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-22T10:00:00Z"),
					createdAt: new Date("2026-05-22T10:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Upcoming Town Fiesta Program",
					slug: "upcoming-town-fiesta-program",
					excerpt: "Draft program for the annual town fiesta opening ceremonies.",
					body: "Draft program outline for the annual town fiesta opening ceremonies at the Municipal Plaza.",
					category: "Community",
					status: "draft",
					authorId: "seed-user-editor",
					createdAt: new Date("2026-05-28T14:00:00Z"),
					updatedAt: now,
				},
				{
					title: "New Solid Waste Collection Schedule",
					slug: "new-solid-waste-collection-schedule",
					excerpt: "Draft schedule for updated garbage collection routes.",
					body: "Draft schedule for updated garbage collection routes starting July 2026.",
					category: "Infrastructure",
					status: "draft",
					authorId: "seed-user-editor",
					createdAt: new Date("2026-05-29T09:00:00Z"),
					updatedAt: now,
				},
				{
					title: "2025 Business Permit Renewal Closed",
					slug: "2025-business-permit-renewal-closed",
					excerpt: "Archived advisory for the 2025 business permit renewal period.",
					body: "The 2025 business permit renewal period has officially closed. Late applications are subject to penalties.",
					category: "Business",
					status: "archived",
					authorId: "seed-user-editor",
					publishedAt: new Date("2025-01-31T17:00:00Z"),
					createdAt: new Date("2025-01-15T08:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Typhoon Preparedness Advisory 2025",
					slug: "typhoon-preparedness-advisory-2025",
					excerpt: "Archived rainy-season preparedness reminder.",
					body: "Archived advisory from the 2025 typhoon season. Keep emergency kits ready during the rainy season.",
					category: "Community",
					status: "archived",
					authorId: "seed-user-editor",
					publishedAt: new Date("2025-06-01T06:00:00Z"),
					createdAt: new Date("2025-05-28T12:00:00Z"),
					updatedAt: now,
				},
			]
			await tx.insert(newsArticles).values(seedNewsArticles)

			const seedContentPlacements: Array<typeof contentPlacements.$inferInsert> = [
				{
					type: "carousel",
					title: "Business Permit Renewal",
					imageUrl: "/images/placeholders/news-business-permit.png",
					linkType: "article",
					linkTarget: "business-permit-renewal-period-now-open",
					sortOrder: 1,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					type: "carousel",
					title: "Free Medical Mission",
					imageUrl: "/images/placeholders/news-medical-mission.png",
					linkType: "article",
					linkTarget: "free-medical-mission-this-saturday",
					sortOrder: 2,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					type: "banner",
					title: "Help us improve our city",
					imageUrl: "/images/placeholders/banner-civic-help.png",
					linkType: "service",
					linkTarget: "facility-use",
					sortOrder: 1,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(contentPlacements).values(seedContentPlacements)

			const seedEvents: Array<typeof events.$inferInsert> = [
				{
					title: "Town Fiesta Opening",
					slug: "town-fiesta-opening",
					description: "Opening ceremonies and community program at the Municipal Plaza.",
					category: "Community",
					location: "Municipal Plaza",
					imageUrl: "/images/placeholders/event-fiesta.png",
					status: "published",
					startsAt: new Date("2026-06-12T08:00:00Z"),
					endsAt: new Date("2026-06-12T18:00:00Z"),
					publishedAt: new Date("2026-05-25T08:00:00Z"),
					createdAt: now,
					updatedAt: now,
				},
				{
					title: "Tax Payment Deadline",
					slug: "tax-payment-deadline",
					description: "Last day for real property tax payments before penalties apply.",
					category: "Business",
					location: "Treasurer's Office",
					imageUrl: "/images/placeholders/event-tax-deadline.png",
					status: "published",
					startsAt: new Date("2026-06-30T08:00:00Z"),
					endsAt: new Date("2026-06-30T17:00:00Z"),
					publishedAt: new Date("2026-05-25T08:00:00Z"),
					createdAt: now,
					updatedAt: now,
				},
				{
					title: "Barangay Assembly",
					slug: "barangay-assembly-cogon",
					description: "Community assembly for residents of Barangay Cogon.",
					category: "Community",
					location: "Barangay Cogon Hall",
					imageUrl: "/images/placeholders/event-assembly.png",
					status: "published",
					startsAt: new Date("2026-06-05T09:00:00Z"),
					endsAt: new Date("2026-06-05T12:00:00Z"),
					publishedAt: new Date("2026-05-24T08:00:00Z"),
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(events).values(seedEvents)

			const seedEmergencyDirectory: Array<typeof emergencyDirectory.$inferInsert> = [
				{
					name: "National Emergency Hotline",
					type: "comcen",
					contactNumber: "911",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "COMCEN Gubat (Smart)",
					type: "comcen",
					contactNumber: "0998-555-0117",
					address: "Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon — 24/7",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "COMCEN Gubat (TNT)",
					type: "comcen",
					contactNumber: "0907-555-0117",
					address: "Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon — 24/7",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "COMCEN Gubat (Landline)",
					type: "comcen",
					contactNumber: "(056) 311-0117",
					address: "Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon — 24/7",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Gubat Municipal Police Station",
					type: "police",
					contactNumber: "(056) 311-1234",
					address: "Brgy. Poblacion, Gubat, Sorsogon — 24/7",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Bureau of Fire Protection - Gubat",
					type: "bfp",
					contactNumber: "(056) 311-5678",
					address: "National Road, Brgy. Cota na Daco, Gubat, Sorsogon — 24/7",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Gubat District Hospital",
					type: "hospital",
					contactNumber: "(056) 311-9876",
					address: "Brgy. Manook, Gubat, Sorsogon — 24/7 Emergency Room",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "MDRRMO Gubat",
					type: "comcen",
					contactNumber: "(056) 311-2468",
					address: "Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon — 24/7",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Rural Health Unit",
					type: "hospital",
					contactNumber: "(056) 311-1357",
					address: "Brgy. Poblacion, Gubat, Sorsogon — Mon–Fri 8:00 AM – 5:00 PM",
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(emergencyDirectory).values(seedEmergencyDirectory)

			const seedEmergencyBroadcasts: Array<typeof emergencyBroadcasts.$inferInsert> = [
				{
					title: "Severe Weather Advisory",
					message:
						"A low pressure area is being monitored east of Sorsogon. Prepare emergency kits and monitor LGU updates.",
					severity: "warning",
					status: "sent",
					sentAt: new Date("2026-05-25T06:00:00Z"),
					senderId: "seed-user-emergency",
					recipientCount: 4,
					createdAt: new Date("2026-05-25T05:55:00Z"),
					updatedAt: now,
				},
				{
					title: "Coastal Flood Watch",
					message:
						"Residents in coastal barangays are advised to monitor tide levels and report urgent concerns to COMCEN.",
					severity: "critical",
					status: "scheduled",
					scheduledAt: new Date("2026-06-10T05:30:00Z"),
					senderId: "seed-user-emergency",
					recipientCount: 0,
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(emergencyBroadcasts).values(seedEmergencyBroadcasts)

			const seedCitizenReports: Array<typeof citizenReports.$inferInsert> = [
				{
					category: "Road Damage",
					description: "Large pothole causing traffic at Mabini St., Brgy. Poblacion.",
					status: "in_progress",
					barangay: "Panganiban (Poblacion)",
					locationAddress: "Mabini St., Brgy. Poblacion",
					latitude: "13.0917",
					longitude: "123.5100",
					publicRemarks: "Engineering team has been notified and inspection is underway.",
					departmentId: deptIds.MDRRMO,
					assignedOfficerId: "seed-user-officer",
					authorId: "seed-user-juan",
					createdAt: new Date("2026-05-18T08:30:00Z"),
					updatedAt: now,
				},
				{
					category: "Waste Management",
					description: "Uncollected garbage for 3 days at Bonifacio St., Brgy. Bagacay.",
					status: "received",
					barangay: "Bagacay",
					locationAddress: "Bonifacio St., Brgy. Bagacay",
					latitude: "13.0925",
					longitude: "123.5110",
					authorId: "seed-user-pedro",
					createdAt: new Date("2026-05-25T16:00:00Z"),
					updatedAt: now,
				},
				{
					category: "Street Lighting",
					description: "Broken streetlight near the barangay hall entrance, Brgy. Manook.",
					status: "resolved",
					barangay: "Manook",
					locationAddress: "Barangay hall entrance, Brgy. Manook",
					latitude: "13.0880",
					longitude: "123.5080",
					publicRemarks: "Streetlight was repaired by the maintenance team.",
					departmentId: deptIds.MDRRMO,
					assignedOfficerId: "seed-user-supervisor",
					authorId: "seed-user-ana",
					createdAt: new Date("2026-05-10T14:00:00Z"),
					updatedAt: now,
				},
				{
					category: "Flooding",
					description: "Standing water after heavy rain along Rizal St., Brgy. Rizal.",
					status: "closed",
					barangay: "Rizal",
					locationAddress: "Rizal St., Brgy. Rizal",
					latitude: "13.0900",
					longitude: "123.5095",
					publicRemarks: "Drainage was cleared and case has been closed.",
					authorId: "seed-user-maria",
					createdAt: new Date("2026-04-20T11:00:00Z"),
					updatedAt: now,
				},
				{
					category: "Public Safety",
					description: "Damaged pedestrian railing along the coastal road near Rizal Beach.",
					status: "received",
					barangay: "Rizal",
					locationAddress: "Coastal road near Rizal Beach",
					latitude: "13.0930",
					longitude: "123.5120",
					authorId: "seed-user-juan",
					createdAt: new Date("2026-05-27T09:15:00Z"),
					updatedAt: now,
				},
				{
					category: "Others",
					description: "Stray dogs congregating near the public market area.",
					status: "in_progress",
					barangay: "Panganiban (Poblacion)",
					locationAddress: "Public Market Area",
					latitude: "13.0910",
					longitude: "123.5105",
					publicRemarks: "Municipal veterinary office has been asked to inspect the area.",
					departmentId: deptIds.MHO,
					assignedOfficerId: "seed-user-supervisor",
					authorId: "seed-user-ana",
					createdAt: new Date("2026-05-24T07:30:00Z"),
					updatedAt: now,
				},
			]
			const insertedReports = await tx.insert(citizenReports).values(seedCitizenReports).returning({
				id: citizenReports.id,
				category: citizenReports.category,
				status: citizenReports.status,
			})
			await tx.insert(citizenReportStatusHistory).values(
				insertedReports.flatMap(report => [
					{
						citizenReportId: report.id,
						status: "received" as const,
						remarks: "Report received by the LGU.",
						visibility: "public" as const,
						changedById: null,
						createdAt: now,
					},
					...(report.status !== "received"
						? [
								{
									citizenReportId: report.id,
									status: report.status,
									remarks: "Status updated by LGU staff.",
									visibility: "public" as const,
									changedById: "seed-user-officer",
									createdAt: now,
								},
							]
						: []),
				])
			)

			const seedServiceRequests: Array<typeof serviceRequests.$inferInsert> = [
				{
					trackingNumber: "BP-2026-0418",
					serviceTypeId: serviceTypeIdsByName["Business Permit"],
					serviceType: "Business Permit",
					description: "Permit is ready for claiming at the BPLO office.",
					status: "approved",
					departmentId: deptIds.BPLO,
					assignedOfficerId: "seed-user-officer",
					authorId: "seed-user-juan",
					createdAt: new Date("2026-05-10T08:30:00Z"),
					updatedAt: now,
				},
				{
					trackingNumber: "BP-2026-0422",
					serviceTypeId: serviceTypeIdsByName["Business Permit"],
					serviceType: "Business Permit",
					description: "Awaiting review of submitted documents.",
					status: "pending",
					departmentId: deptIds.BPLO,
					authorId: "seed-user-maria",
					createdAt: new Date("2026-05-18T10:15:00Z"),
					updatedAt: now,
				},
				{
					trackingNumber: "BP-2026-0431",
					serviceTypeId: serviceTypeIdsByName["Business Permit"],
					serviceType: "Business Permit",
					description: "Incomplete requirements. Please re-submit missing documents.",
					status: "rejected",
					departmentId: deptIds.BPLO,
					assignedOfficerId: "seed-user-officer",
					authorId: "seed-user-pedro",
					createdAt: new Date("2026-05-23T14:00:00Z"),
					updatedAt: now,
				},
				{
					trackingNumber: "CR-2026-0117",
					serviceTypeId: serviceTypeIdsByName["Certification"],
					serviceType: "Certificate of Residency",
					description: "Certificate is available for pickup at the barangay hall.",
					status: "for_pickup",
					departmentId: deptIds.MSSD,
					assignedOfficerId: "seed-user-officer",
					authorId: "seed-user-juan",
					createdAt: new Date("2026-05-12T09:45:00Z"),
					updatedAt: now,
				},
				{
					trackingNumber: "MA-2026-0033",
					serviceTypeId: serviceTypeIdsByName["Medical Assistance"],
					serviceType: "Medical Assistance",
					description: "Verifying hospital documents and eligibility.",
					status: "in_review",
					departmentId: deptIds.MHO,
					assignedOfficerId: "seed-user-supervisor",
					authorId: "seed-user-maria",
					createdAt: new Date("2026-05-20T13:45:00Z"),
					updatedAt: now,
				},
				{
					trackingNumber: "TA-2026-0007",
					serviceTypeId: serviceTypeIdsByName["Transportation Assistance"],
					serviceType: "Transportation Assistance",
					description: "Transportation assistance request completed and closed.",
					status: "completed",
					departmentId: deptIds["Transport Office"],
					assignedOfficerId: "seed-user-officer2",
					authorId: "seed-user-ana",
					createdAt: new Date("2026-04-15T10:00:00Z"),
					updatedAt: now,
				},
				{
					trackingNumber: "BC-2026-0021",
					serviceTypeId: serviceTypeIdsByName["Barangay Clearance"],
					serviceType: "Barangay Clearance",
					description: "Application received and queued for barangay verification.",
					status: "pending",
					departmentId: deptIds.MSSD,
					authorId: "seed-user-pedro",
					createdAt: new Date("2026-05-28T08:00:00Z"),
					updatedAt: now,
				},
				{
					trackingNumber: "FU-2026-0004",
					serviceTypeId: serviceTypeIdsByName["Facility Use"],
					serviceType: "Facility Use",
					description: "Municipal plaza reservation under review by MSSD.",
					status: "in_review",
					departmentId: deptIds.MSSD,
					assignedOfficerId: "seed-user-supervisor",
					authorId: "seed-user-ana",
					createdAt: new Date("2026-05-26T11:30:00Z"),
					updatedAt: now,
				},
			]

			const insertedRequests = await tx
				.insert(serviceRequests)
				.values(seedServiceRequests)
				.returning({
					id: serviceRequests.id,
					trackingNumber: serviceRequests.trackingNumber,
				})

			const requestIdByTracking = Object.fromEntries(
				insertedRequests.map(r => [r.trackingNumber, r.id])
			) as Record<(typeof SEED_TRACKING_NUMBERS)[number], number>

			const seedAttachments: Array<typeof serviceRequestAttachments.$inferInsert> = [
				{
					serviceRequestId: requestIdByTracking["BP-2026-0418"],
					fileUrl: "/uploads/seed/business-permit-application.pdf",
					fileName: "business-permit-application.pdf",
					createdAt: now,
				},
				{
					serviceRequestId: requestIdByTracking["MA-2026-0033"],
					fileUrl: "/uploads/seed/medical-certificate.pdf",
					fileName: "medical-certificate.pdf",
					createdAt: now,
				},
				{
					serviceRequestId: requestIdByTracking["BP-2026-0431"],
					fileUrl: "/uploads/seed/incomplete-requirements.pdf",
					fileName: "incomplete-requirements.pdf",
					createdAt: now,
				},
			]
			await tx.insert(serviceRequestAttachments).values(seedAttachments)

			const seedRequestHistory: Array<typeof serviceRequestStatusHistory.$inferInsert> =
				insertedRequests.flatMap(request => {
					const source = seedServiceRequests.find(r => r.trackingNumber === request.trackingNumber)
					const currentStatus = source?.status ?? "pending"
					return [
						{
							serviceRequestId: request.id,
							status: "pending",
							remarks: "Request submitted through iGubat.",
							visibility: "public" as const,
							changedById: null,
							createdAt: source?.createdAt ?? now,
						},
						...(currentStatus !== "pending"
							? [
									{
										serviceRequestId: request.id,
										status: currentStatus,
										remarks: source?.description ?? "Request status updated.",
										visibility: "public" as const,
										changedById: source?.assignedOfficerId ?? "seed-user-officer",
										createdAt: source?.updatedAt ?? now,
									},
								]
							: []),
					]
				})
			await tx.insert(serviceRequestStatusHistory).values(seedRequestHistory)

			const seedNotifications: Array<typeof notifications.$inferInsert> = [
				{
					userId: "seed-user-juan",
					title: "Business Permit Approved",
					body: "Your business permit application BP-2026-0418 has been approved. You may now claim your permit.",
					type: "in_app",
					category: "service_request",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "BP-2026-0418" },
					createdAt: new Date("2026-05-26T14:20:00Z"),
				},
				{
					userId: "seed-user-juan",
					title: "Document Ready for Pickup",
					body: "Your requested Certificate of Residency CR-2026-0117 is ready for pickup at the barangay hall.",
					type: "in_app",
					category: "service_request",
					isRead: true,
					metadata: { entityType: "service_request", entityId: "CR-2026-0117" },
					createdAt: new Date("2026-05-22T08:30:00Z"),
				},
				{
					userId: "seed-user-juan",
					title: "New Announcement Posted",
					body: "A new community announcement has been published. Tap to read more.",
					type: "in_app",
					category: "news",
					isRead: true,
					metadata: { entityType: "news_article", entityId: "1" },
					createdAt: new Date("2026-05-24T11:45:00Z"),
				},
				{
					userId: "seed-user-juan",
					title: "Severe Weather Advisory",
					body: "A low pressure area is being monitored east of Sorsogon. Stay alert and prepare for possible heavy rains.",
					type: "in_app",
					category: "emergency",
					isRead: false,
					metadata: { entityType: "emergency", entityId: "weather-advisory-2026-05" },
					createdAt: new Date("2026-05-25T06:00:00Z"),
				},
				{
					userId: "seed-user-maria",
					title: "Request Received",
					body: "Your business permit application BP-2026-0422 has been received and is pending review.",
					type: "in_app",
					category: "service_request",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "BP-2026-0422" },
					createdAt: new Date("2026-05-18T10:30:00Z"),
				},
				{
					userId: "seed-user-maria",
					title: "Medical Assistance In Review",
					body: "Your medical assistance request MA-2026-0033 is now being reviewed by MSSD.",
					type: "in_app",
					category: "service_request",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "MA-2026-0033" },
					createdAt: new Date("2026-05-21T09:00:00Z"),
				},
				{
					userId: "seed-user-maria",
					title: "New Announcement Posted",
					body: "Free Medical Mission This Saturday — read the full announcement in the news section.",
					type: "in_app",
					isRead: true,
					metadata: { entityType: "news_article", entityId: "2" },
					createdAt: new Date("2026-05-18T10:00:00Z"),
				},
				{
					userId: "seed-user-pedro",
					title: "Business Permit Rejected",
					body: "Your business permit application BP-2026-0431 was rejected due to incomplete requirements.",
					type: "in_app",
					category: "service_request",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "BP-2026-0431" },
					createdAt: new Date("2026-05-24T16:00:00Z"),
				},
				{
					userId: "seed-user-pedro",
					title: "Report Received",
					body: "Your waste management report has been received and will be reviewed by the LGU.",
					type: "in_app",
					category: "issue_report",
					isRead: true,
					metadata: { entityType: "citizen_report", entityId: "2" },
					createdAt: new Date("2026-05-25T16:30:00Z"),
				},
				{
					userId: "seed-user-ana",
					title: "Request Completed",
					body: "Your transportation assistance request TA-2026-0007 has been completed.",
					type: "in_app",
					category: "service_request",
					isRead: true,
					metadata: { entityType: "service_request", entityId: "TA-2026-0007" },
					createdAt: new Date("2026-04-20T15:00:00Z"),
				},
				{
					userId: "seed-user-ana",
					title: "Report Resolved",
					body: "Your street lighting report has been marked as resolved. Thank you for reporting.",
					type: "in_app",
					category: "issue_report",
					isRead: false,
					metadata: { entityType: "citizen_report", entityId: "3" },
					createdAt: new Date("2026-05-15T11:00:00Z"),
				},
				{
					userId: "seed-user-ana",
					title: "Severe Weather Advisory",
					body: "A low pressure area is being monitored east of Sorsogon. Stay alert and prepare for possible heavy rains.",
					type: "in_app",
					category: "emergency",
					isRead: false,
					metadata: { entityType: "emergency", entityId: "weather-advisory-2026-05" },
					createdAt: new Date("2026-05-25T06:00:00Z"),
				},
			]
			const insertedNotifications = await tx
				.insert(notifications)
				.values(seedNotifications)
				.returning({
					id: notifications.id,
					userId: notifications.userId,
					type: notifications.type,
				})

			const seedNotificationPreferences: Array<typeof notificationPreferences.$inferInsert> = [
				"seed-user-juan",
				"seed-user-maria",
				"seed-user-pedro",
				"seed-user-ana",
			].map(userId => ({
				userId,
				news: true,
				serviceRequests: true,
				issueReports: true,
				emergencyBroadcasts: true,
				pushEnabled: true,
				emailEnabled: true,
				createdAt: now,
				updatedAt: now,
			}))
			await tx.insert(notificationPreferences).values(seedNotificationPreferences)

			await tx.insert(notificationDeliveryLogs).values(
				insertedNotifications.map(notification => ({
					notificationId: notification.id,
					userId: notification.userId,
					channel: notification.type,
					status: "sent" as const,
					providerMessage: "local-dev-stub",
					createdAt: now,
				}))
			)

			const seedAuditLogs: Array<typeof auditLogs.$inferInsert> = [
				{
					actorId: "seed-user-admin",
					actionType: "login",
					entityType: "user",
					entityId: "seed-user-admin",
					details: { method: "email" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-officer",
					actionType: "login",
					entityType: "user",
					entityId: "seed-user-officer",
					details: { method: "email" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-editor",
					actionType: "login",
					entityType: "user",
					entityId: "seed-user-editor",
					details: { method: "email" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-officer",
					actionType: "status_change",
					entityType: "service_request",
					entityId: "BP-2026-0418",
					details: { from: "in_review", to: "approved" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-officer",
					actionType: "status_change",
					entityType: "service_request",
					entityId: "BP-2026-0431",
					details: { from: "in_review", to: "rejected" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-supervisor",
					actionType: "assign",
					entityType: "service_request",
					entityId: "MA-2026-0033",
					details: { assignedOfficerId: "seed-user-supervisor" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-officer",
					actionType: "status_change",
					entityType: "citizen_report",
					entityId: "1",
					details: { from: "received", to: "in_progress" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-editor",
					actionType: "publish",
					entityType: "news_article",
					entityId: "1",
					details: { title: "Business Permit Renewal Period Now Open" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-editor",
					actionType: "archive",
					entityType: "news_article",
					entityId: "9",
					details: { title: "2025 Business Permit Renewal Closed" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-emergency",
					actionType: "create",
					entityType: "emergency_directory",
					entityId: "1",
					details: { name: "COMCEN Gubat (Smart)" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-emergency",
					actionType: "update",
					entityType: "emergency_directory",
					entityId: "5",
					details: { field: "contactNumber" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
				{
					actorId: "seed-user-ict",
					actionType: "view",
					entityType: "user",
					entityId: "seed-user-juan",
					details: { action: "role_inspection" },
					ipAddress: "127.0.0.1",
					createdAt: now,
				},
			]
			await tx.insert(auditLogs).values(seedAuditLogs)

			const seedMediaAssets: Array<typeof mediaAssets.$inferInsert> = [
				{
					fileName: "news-business-permit.png",
					fileUrl: "/images/placeholders/news-business-permit.png",
					mimeType: "image/png",
					sizeBytes: 0,
					altText: "Business permit renewal placeholder image",
					folder: "news",
					uploadedById: "seed-user-editor",
					createdAt: now,
					updatedAt: now,
				},
				{
					fileName: "service-business-permit.png",
					fileUrl: "/images/placeholders/service-business-permit.png",
					mimeType: "image/png",
					sizeBytes: 0,
					altText: "Business permit service placeholder image",
					folder: "services",
					uploadedById: "seed-user-editor",
					createdAt: now,
					updatedAt: now,
				},
				{
					fileName: "event-fiesta.png",
					fileUrl: "/images/placeholders/event-fiesta.png",
					mimeType: "image/png",
					sizeBytes: 0,
					altText: "Town fiesta event placeholder image",
					folder: "events",
					uploadedById: "seed-user-editor",
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(mediaAssets).values(seedMediaAssets)

			const seedHelpArticles: Array<typeof helpArticles.$inferInsert> = [
				{
					slug: "how-to-submit-service-request",
					title: "How to submit a service request",
					category: "Services",
					content:
						"Open Services, choose the service you need, complete the stepper form, attach up to three files, and submit. You will receive a tracking number after submission.",
					audience: "citizen",
					sortOrder: 1,
					isPublished: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					slug: "how-to-track-request",
					title: "How to track a request",
					category: "Services",
					content:
						"Open My Requests or tap a recent activity card from Home to view status, timeline, remarks, and available actions.",
					audience: "citizen",
					sortOrder: 2,
					isPublished: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					slug: "staff-processing-guide",
					title: "Staff processing guide",
					category: "Portal",
					content:
						"Open a request or report detail page, review attachments and citizen information, then apply the next valid status with remarks. Every transition is logged.",
					audience: "staff",
					sortOrder: 1,
					isPublished: true,
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(helpArticles).values(seedHelpArticles)

			const seedPolicyDocuments: Array<typeof policyDocuments.$inferInsert> = [
				{
					slug: "privacy-policy",
					title: "Privacy Policy",
					version: "1.0",
					content:
						"iGubat collects only the personal information needed to provide LGU digital services, including name, contact details, barangay, address, request details, and uploaded supporting documents. Data is processed according to the Data Privacy Act of 2012.",
					publishedAt: now,
					createdAt: now,
					updatedAt: now,
				},
				{
					slug: "terms-of-use",
					title: "Terms of Use",
					version: "1.0",
					content:
						"Use iGubat only for legitimate citizen service requests, reports, and public information. False submissions may be reviewed by LGU staff and handled according to applicable policy.",
					publishedAt: now,
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(policyDocuments).values(seedPolicyDocuments)

			const seedSystemSettings = [
				{
					key: "application.branding",
					category: "application",
					value: {
						municipalityName: "Municipality of Gubat",
						appName: "iGubat",
						primaryContact: "COMCEN Gubat",
					},
					isSecret: false,
					updatedById: "seed-user-admin",
					createdAt: now,
					updatedAt: now,
				},
				{
					key: "integrations.delivery",
					category: "notifications",
					value: { email: "local-dev-stub", sms: "local-dev-stub", push: "local-dev-stub" },
					isSecret: false,
					updatedById: "seed-user-admin",
					createdAt: now,
					updatedAt: now,
				},
				{
					key: "uploads.policy",
					category: "storage",
					value: {
						maxFiles: 3,
						maxFileSizeMb: 5,
						allowedMimeTypes: ["image/jpeg", "image/png", "application/pdf"],
					},
					isSecret: false,
					updatedById: "seed-user-admin",
					createdAt: now,
					updatedAt: now,
				},
			] satisfies Array<typeof systemSettings.$inferInsert>
			await tx.insert(systemSettings).values(seedSystemSettings)

			const seedLoginActivity: Array<typeof userLoginActivity.$inferInsert> = [
				{
					userId: "seed-user-admin",
					identifier: "admin@igubat.local",
					success: true,
					ipAddress: "127.0.0.1",
					userAgent: "seed",
					createdAt: now,
				},
				{
					userId: "seed-user-officer",
					identifier: "officer@igubat.local",
					success: true,
					ipAddress: "127.0.0.1",
					userAgent: "seed",
					createdAt: now,
				},
				{
					userId: "seed-user-juan",
					identifier: "juan@example.com",
					success: false,
					failureReason: "invalid_password",
					ipAddress: "127.0.0.1",
					userAgent: "seed",
					createdAt: new Date("2026-05-27T08:00:00Z"),
				},
			]
			await tx.insert(userLoginActivity).values(seedLoginActivity)

			const seedTickets: Array<typeof tickets.$inferInsert> = [
				{
					name: "Super Admin",
					email: "admin@igubat.local",
					subject: "Initial admin setup check",
					priority: "high",
					concern: "Please verify seeded admin data appears correctly across the dashboard.",
					status: "in_progress",
					authorId: "seed-user-admin",
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Juan Dela Cruz",
					email: "juan@example.com",
					subject: "Business permit inquiry",
					priority: "medium",
					concern:
						"I would like to confirm the requirements for renewing my sari-sari store permit.",
					status: "received",
					authorId: "seed-user-juan",
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Maria Santos",
					email: "maria@example.com",
					subject: "Mobile app feedback",
					priority: "low",
					concern: "The notification badge count does not clear after reading all messages.",
					status: "received",
					authorId: "seed-user-maria",
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Guest Reporter",
					email: "guest@igubat.local",
					subject: "Public feedback sample",
					priority: "low",
					concern:
						"This anonymous ticket exists to test support workflows without a linked account.",
					status: "received",
					authorId: null,
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(tickets).values(seedTickets)

			return {
				users: seedUsers.length,
				departments: seedDepartments.length,
				serviceCategories: serviceCategoryRows.length,
				serviceTypes: serviceTypeRows.length,
				workflowTemplates: workflowRows.length,
				newsArticles: seedNewsArticles.length,
				contentPlacements: seedContentPlacements.length,
				events: seedEvents.length,
				emergencyDirectory: seedEmergencyDirectory.length,
				emergencyBroadcasts: seedEmergencyBroadcasts.length,
				citizenReports: seedCitizenReports.length,
				serviceRequests: seedServiceRequests.length,
				serviceRequestAttachments: seedAttachments.length,
				serviceRequestStatusHistory: seedRequestHistory.length,
				notifications: seedNotifications.length,
				notificationPreferences: seedNotificationPreferences.length,
				notificationDeliveryLogs: insertedNotifications.length,
				auditLogs: seedAuditLogs.length,
				mediaAssets: seedMediaAssets.length,
				helpArticles: seedHelpArticles.length,
				policyDocuments: seedPolicyDocuments.length,
				systemSettings: seedSystemSettings.length,
				userLoginActivity: seedLoginActivity.length,
				tickets: seedTickets.length,
			}
		})

		console.log("iGubat database seeded successfully.\n")
		console.log("Table counts:")
		for (const [table, count] of Object.entries(counts)) {
			console.log(`  ${table}: ${count}`)
		}
		console.log(`\nDefault password for all accounts: ${SEED_PASSWORD}`)
		console.log("\nCitizens (mobile app):")
		console.log("  juan@example.com, maria@example.com, pedro@example.com, ana@igubat.local")
		console.log("  unverified@igubat.local — OTP testing only (cannot sign in until verified)")
		console.log("\nStaff (web portal):")
		console.log("  admin@igubat.local (super_admin), ict@igubat.local (ict_admin)")
		console.log(
			"  supervisor@igubat.local (department_supervisor), officer@igubat.local (frontline_officer)"
		)
		console.log("  officer2@igubat.local (frontline_officer), editor@igubat.local (content_editor)")
		console.log("  emergency@igubat.local (emergency_operator)")
	} finally {
		await pool.end()
	}
}

void seedDatabase().catch(error => {
	console.error("Database seeding failed.")
	console.error(error)
	process.exitCode = 1
})
