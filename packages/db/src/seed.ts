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
	discoverGubatEntries,
	discoverGubatPhotos,
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
	transparencyAttachments,
	transparencyItems,
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
	"seed-user-demo",
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
	// Demo citizen: one request per workflow status.
	"CT-2026-0101",
	"SC-2026-0012",
	"BU-2026-0005",
	"ED-2026-0040",
	"CV-2026-0150",
	"GY-2026-0003",
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
	"community-tax-certificate",
	"civil-registry-documents",
	"building-permit",
	"fisherfolk-registration",
	"senior-citizen-id",
	"pwd-id",
	"educational-assistance",
	"burial-assistance",
	"gymnasium-reservation",
] as const

const DEMO_USER_ID = "seed-user-demo"
const DEMO_USER_EMAIL = "demo@igubat.local"

type RequestStatus = NonNullable<(typeof serviceRequests.$inferInsert)["status"]>

const REQUEST_STATUS_PATHS: Record<RequestStatus, RequestStatus[]> = {
	pending: ["pending"],
	in_review: ["pending", "in_review"],
	approved: ["pending", "in_review", "approved"],
	rejected: ["pending", "in_review", "rejected"],
	for_pickup: ["pending", "in_review", "approved", "for_pickup"],
	completed: ["pending", "in_review", "approved", "for_pickup", "completed"],
}

const REQUEST_STATUS_REMARKS: Record<RequestStatus, string> = {
	pending: "Request submitted through iGubat.",
	in_review: "Your request and documents are now being reviewed.",
	approved: "Your request has been approved.",
	rejected: "Your request could not be approved.",
	for_pickup: "Your document is ready for pickup.",
	completed: "Request completed. Thank you for using iGubat.",
}

const DAY_MS = 24 * 60 * 60 * 1000

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
			image: "https://i.pravatar.cc/300?u=seed-user-juan",
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
			image: "https://i.pravatar.cc/300?u=seed-user-maria",
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
			image: "https://i.pravatar.cc/300?u=seed-user-pedro",
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
			image: "https://i.pravatar.cc/300?u=seed-user-ana",
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
			image: "https://i.pravatar.cc/300?u=seed-user-unverified",
			role: "registered_citizen",
			mobileNumber: "09211234567",
			barangay: "Rizal",
			address: "Brgy. Rizal, Gubat, Sorsogon",
			dpaConsent: true,
			createdAt: new Date("2024-05-01T12:00:00Z"),
			updatedAt: now,
		},
		// Demo citizen: complete, verified profile with data on every mobile screen.
		{
			id: DEMO_USER_ID,
			name: "Rosa Lim",
			email: DEMO_USER_EMAIL,
			emailVerified: true,
			emailVerifiedAt: new Date("2025-01-10T08:05:00Z"),
			image: "https://i.pravatar.cc/300?u=seed-user-demo",
			role: "registered_citizen",
			mobileNumber: "09271234567",
			mobileVerified: true,
			mobileVerifiedAt: new Date("2025-01-10T08:06:00Z"),
			barangay: "Panganiban (Poblacion)",
			address: "123 Rizal St., Brgy. Panganiban (Poblacion), Gubat, Sorsogon 4710",
			appearancePreference: "system",
			dpaConsent: true,
			dpaConsentAt: new Date("2025-01-10T08:00:00Z"),
			lastLoginAt: new Date(now.getTime() - DAY_MS),
			createdAt: new Date("2025-01-10T08:00:00Z"),
			updatedAt: now,
		},
		// Staff (web portal)
		{
			id: "seed-user-admin",
			name: "Super Admin",
			email: "admin@igubat.local",
			emailVerified: true,
			image: "https://i.pravatar.cc/300?u=seed-user-admin",
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
			image: "https://i.pravatar.cc/300?u=seed-user-ict",
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
			image: "https://i.pravatar.cc/300?u=seed-user-supervisor",
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
			image: "https://i.pravatar.cc/300?u=seed-user-officer",
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
			image: "https://i.pravatar.cc/300?u=seed-user-officer2",
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
			image: "https://i.pravatar.cc/300?u=seed-user-editor",
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
			image: "https://i.pravatar.cc/300?u=seed-user-emergency",
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
					emailVerifiedAt: user.emailVerifiedAt ?? null,
					image: user.image,
					role: user.role,
					status: user.status ?? "active",
					departmentId: user.departmentId ?? null,
					mobileNumber: user.mobileNumber ?? null,
					mobileVerified: user.mobileVerified ?? false,
					mobileVerifiedAt: user.mobileVerifiedAt ?? null,
					barangay: user.barangay ?? null,
					address: user.address ?? null,
					appearancePreference: user.appearancePreference ?? "system",
					dpaConsent: user.dpaConsent ?? false,
					dpaConsentAt: user.dpaConsentAt ?? null,
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
	// transparency_attachments cascade-delete with their parent items.
	await tx.delete(transparencyItems).where(inArray(transparencyItems.authorId, [...SEED_USER_IDS]))
	// discover_gubat_photos cascade-delete with their parent entries.
	await tx
		.delete(discoverGubatEntries)
		.where(inArray(discoverGubatEntries.authorId, [...SEED_USER_IDS]))
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
					imageUrl: "https://picsum.photos/seed/service-facility/800/600",
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
					imageUrl: "https://picsum.photos/seed/service-medical/800/600",
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
					imageUrl: "https://picsum.photos/seed/service-transport/800/600",
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
					imageUrl: "https://picsum.photos/seed/service-business-permit/800/600",
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
					imageUrl: "https://picsum.photos/seed/service-certification/800/600",
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
					imageUrl: "https://picsum.photos/seed/service-clearance/800/600",
					isPopular: false,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Community Tax Certificate (Cedula)",
					slug: "community-tax-certificate",
					description:
						"Get your yearly cedula, often required for permits, IDs, and notarized documents.",
					categoryId: categoryIds.certificates,
					requirements: [
						"Valid ID",
						"Previous year's cedula (if any)",
						"Proof of income (if employed or with business)",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 1,
					icon: "receipt",
					imageUrl: "https://picsum.photos/seed/service-cedula/800/600",
					isPopular: true,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Civil Registry Documents",
					slug: "civil-registry-documents",
					description:
						"Request certified copies of birth, marriage, or death records from the Municipal Civil Registrar.",
					categoryId: categoryIds.certificates,
					requirements: [
						"Valid ID",
						"Full name and date on the record",
						"Authorization letter (if requesting for someone else)",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 3,
					icon: "scroll-text",
					imageUrl: "https://picsum.photos/seed/service-civil-registry/800/600",
					isPopular: true,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Building Permit",
					slug: "building-permit",
					description:
						"Apply for a permit before building, renovating, or extending a house or structure.",
					categoryId: categoryIds.permits,
					requirements: [
						"Valid ID",
						"Land title or tax declaration",
						"Signed building plans",
						"Barangay clearance",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 7,
					icon: "hard-hat",
					imageUrl: "https://picsum.photos/seed/service-building-permit/800/600",
					isPopular: false,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Fisherfolk Registration",
					slug: "fisherfolk-registration",
					description:
						"Register as a municipal fisherfolk or register your banca to join LGU and BFAR programs.",
					categoryId: categoryIds.permits,
					requirements: [
						"Valid ID",
						"1x1 photo",
						"Barangay certificate of residency",
						"Boat details (if boat owner)",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 3,
					icon: "fish",
					imageUrl: "https://picsum.photos/seed/service-fisherfolk/800/600",
					isPopular: false,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Senior Citizen ID",
					slug: "senior-citizen-id",
					description:
						"Apply for a Senior Citizen ID (60 years old and above) to get discounts and benefits.",
					categoryId: categoryIds.assistance,
					requirements: [
						"Birth certificate or valid ID showing age",
						"1x1 photo",
						"Barangay certificate of residency",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 5,
					icon: "user-round",
					imageUrl: "https://picsum.photos/seed/service-senior-id/800/600",
					isPopular: true,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "PWD ID",
					slug: "pwd-id",
					description:
						"Apply for a Persons with Disability ID to access discounts and government benefits.",
					categoryId: categoryIds.assistance,
					requirements: [
						"Medical certificate stating the disability",
						"1x1 photo",
						"Barangay certificate of residency",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 5,
					icon: "accessibility",
					imageUrl: "https://picsum.photos/seed/service-pwd-id/800/600",
					isPopular: false,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Educational Assistance",
					slug: "educational-assistance",
					description:
						"Request financial help for school fees, supplies, or allowance for students.",
					categoryId: categoryIds.assistance,
					requirements: [
						"School ID or certificate of enrollment",
						"Latest report card",
						"Certificate of indigency",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 7,
					icon: "graduation-cap",
					imageUrl: "https://picsum.photos/seed/service-education/800/600",
					isPopular: false,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Burial Assistance",
					slug: "burial-assistance",
					description: "Request financial help for the funeral and burial of a family member.",
					categoryId: categoryIds.assistance,
					requirements: [
						"Death certificate",
						"Valid ID of the claimant",
						"Funeral contract or billing",
					],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 3,
					icon: "heart-handshake",
					imageUrl: "https://picsum.photos/seed/service-burial/800/600",
					isPopular: false,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
				{
					name: "Gymnasium Reservation",
					slug: "gymnasium-reservation",
					description:
						"Book the municipal gymnasium or sports complex for games, events, or practice.",
					categoryId: categoryIds.facilities,
					requirements: ["Valid ID", "Activity letter", "Preferred date and time"],
					formFields: ["description", "preferredDate", "attachments"],
					workflowSteps: WORKFLOW_STEPS,
					processingDays: 3,
					icon: "dumbbell",
					imageUrl: "https://picsum.photos/seed/service-gymnasium/800/600",
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
					imageUrl: "https://picsum.photos/seed/news-business-permit/800/600",
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
					imageUrl: "https://picsum.photos/seed/news-medical-mission/800/600",
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
					imageUrl: "https://picsum.photos/seed/news-road-repair/800/600",
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
					imageUrl: "https://picsum.photos/seed/news-cleanup/800/600",
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
					imageUrl: "https://picsum.photos/seed/news-utilities/800/600",
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
					imageUrl: "https://picsum.photos/seed/news-tax-deadline/800/600",
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
					imageUrl: "https://picsum.photos/seed/news-business-permit/1200/600",
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
					imageUrl: "https://picsum.photos/seed/news-medical-mission/1200/600",
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
					imageUrl: "https://picsum.photos/seed/banner-civic-help/1200/400",
					linkType: "service",
					linkTarget: "facility-use",
					sortOrder: 1,
					isActive: true,
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(contentPlacements).values(seedContentPlacements)

			// Event dates are relative to the seed run so "Upcoming Events" on Home
			// always has upcoming items. Hours are Philippine time (UTC+8).
			const manilaTime = (daysFromNow: number, hour: number) => {
				const date = new Date(now.getTime() + daysFromNow * DAY_MS)
				date.setUTCHours(hour - 8, 0, 0, 0)
				return date
			}
			const seedEvents: Array<typeof events.$inferInsert> = [
				{
					title: "Barangay Assembly",
					slug: "barangay-assembly-cogon",
					description: "Community assembly for residents of Barangay Cogon.",
					category: "Community",
					location: "Barangay Cogon Hall",
					imageUrl: "https://picsum.photos/seed/event-assembly/800/600",
					status: "published",
					startsAt: manilaTime(5, 9),
					endsAt: manilaTime(5, 12),
					publishedAt: manilaTime(-7, 8),
					createdAt: now,
					updatedAt: now,
				},
				{
					title: "Free Medical and Dental Mission",
					slug: "free-medical-dental-mission",
					description:
						"Free check-ups, dental services and basic medicines from the Municipal Health Office. Bring a valid ID.",
					category: "Health",
					location: "Gubat Municipal Gymnasium",
					imageUrl: "https://picsum.photos/seed/news-medical-mission/800/600",
					status: "published",
					startsAt: manilaTime(9, 8),
					endsAt: manilaTime(9, 15),
					publishedAt: manilaTime(-5, 8),
					createdAt: now,
					updatedAt: now,
				},
				{
					title: "Town Fiesta Opening",
					slug: "town-fiesta-opening",
					description: "Opening ceremonies and community program at the Municipal Plaza.",
					category: "Community",
					location: "Municipal Plaza",
					imageUrl: "https://picsum.photos/seed/event-fiesta/800/600",
					status: "published",
					startsAt: manilaTime(14, 8),
					endsAt: manilaTime(14, 18),
					publishedAt: manilaTime(-6, 8),
					createdAt: now,
					updatedAt: now,
				},
				{
					title: "Coastal Clean-up Drive",
					slug: "coastal-clean-up-drive",
					description:
						"Join the MENRO and barangay volunteers in cleaning the Gubat shoreline. Gloves and sacks will be provided.",
					category: "Environment",
					location: "Rizal Beach, Gubat",
					imageUrl: "https://picsum.photos/seed/news-cleanup/800/600",
					status: "published",
					startsAt: manilaTime(20, 6),
					endsAt: manilaTime(20, 10),
					publishedAt: manilaTime(-3, 8),
					createdAt: now,
					updatedAt: now,
				},
				{
					title: "Tax Payment Deadline",
					slug: "tax-payment-deadline",
					description: "Last day for real property tax payments before penalties apply.",
					category: "Business",
					location: "Treasurer's Office",
					imageUrl: "https://picsum.photos/seed/event-tax-deadline/800/600",
					status: "published",
					startsAt: manilaTime(30, 8),
					endsAt: manilaTime(30, 17),
					publishedAt: manilaTime(-6, 8),
					createdAt: now,
					updatedAt: now,
				},
				{
					title: "Business Permit Orientation",
					slug: "business-permit-orientation",
					description: "Draft: orientation for first-time business permit applicants.",
					category: "Business",
					location: "Municipal Session Hall",
					status: "draft",
					startsAt: manilaTime(40, 9),
					endsAt: manilaTime(40, 11),
					createdAt: now,
					updatedAt: now,
				},
				{
					title: "Disaster Preparedness Seminar",
					slug: "disaster-preparedness-seminar",
					description: "Past event: MDRRMO seminar on typhoon and tsunami preparedness.",
					category: "Safety",
					location: "MDRRMO Training Room",
					status: "published",
					startsAt: manilaTime(-10, 9),
					endsAt: manilaTime(-10, 16),
					publishedAt: manilaTime(-20, 8),
					createdAt: now,
					updatedAt: now,
				},
			]
			await tx.insert(events).values(seedEvents)

			// Contact numbers other than 911 are placeholders; replace with the
			// official LGU directory before production.
			const municipalHall = "Municipal Hall Compound, Brgy. Poblacion, Gubat, Sorsogon"
			const seedEmergencyDirectory: Array<typeof emergencyDirectory.$inferInsert> = (
				[
					// COMCEN — shown in the "COMCEN Hotlines" card (911 feeds the slide-to-call).
					{
						name: "National Emergency Hotline",
						type: "comcen",
						contactNumber: "911",
						address: "Nationwide, free from any network",
						hours: "24/7",
						sortOrder: 1,
					},
					{
						name: "COMCEN Gubat (Smart)",
						type: "comcen",
						contactNumber: "0998-555-0117",
						address: municipalHall,
						hours: "24/7",
						latitude: "12.9186",
						longitude: "124.1225",
						sortOrder: 2,
					},
					{
						name: "COMCEN Gubat (TNT)",
						type: "comcen",
						contactNumber: "0907-555-0117",
						address: municipalHall,
						hours: "24/7",
						latitude: "12.9186",
						longitude: "124.1225",
						sortOrder: 3,
					},
					{
						name: "COMCEN Gubat (Landline)",
						type: "comcen",
						contactNumber: "(056) 311-0117",
						address: municipalHall,
						hours: "24/7",
						latitude: "12.9186",
						longitude: "124.1225",
						sortOrder: 4,
					},
					// Police (PNP)
					{
						name: "Gubat Municipal Police Station",
						type: "police",
						contactNumber: "(056) 311-1234",
						address: "Brgy. Poblacion, Gubat, Sorsogon",
						hours: "24/7",
						latitude: "12.9192",
						longitude: "124.1219",
						sortOrder: 10,
					},
					{
						name: "Women and Children Protection Desk (PNP Gubat)",
						type: "police",
						contactNumber: "0917-555-0188",
						address: "Gubat Municipal Police Station, Brgy. Poblacion, Gubat, Sorsogon",
						hours: "24/7",
						latitude: "12.9192",
						longitude: "124.1219",
						sortOrder: 11,
					},
					// Fire (BFP)
					{
						name: "Bureau of Fire Protection - Gubat",
						type: "bfp",
						contactNumber: "(056) 311-5678",
						address: "National Road, Brgy. Cota na Daco, Gubat, Sorsogon",
						hours: "24/7",
						latitude: "12.9221",
						longitude: "124.1198",
						sortOrder: 20,
					},
					// Hospitals
					{
						name: "Gubat District Hospital",
						type: "hospital",
						contactNumber: "(056) 311-9876",
						address: "Brgy. Manook, Gubat, Sorsogon (Emergency Room)",
						hours: "24/7",
						latitude: "12.9143",
						longitude: "124.1187",
						sortOrder: 30,
					},
					{
						name: "Rural Health Unit",
						type: "hospital",
						contactNumber: "(056) 311-1357",
						address: "Brgy. Poblacion, Gubat, Sorsogon",
						hours: "Mon–Fri, 8:00 AM – 5:00 PM",
						latitude: "12.9180",
						longitude: "124.1230",
						sortOrder: 31,
					},
					{
						name: "Sorsogon Provincial Hospital",
						type: "hospital",
						contactNumber: "(056) 211-0222",
						address: "Brgy. Sirangan, Sorsogon City (for referrals)",
						hours: "24/7",
						latitude: "12.9714",
						longitude: "124.0064",
						sortOrder: 32,
					},
					// Disaster response
					{
						name: "MDRRMO Gubat",
						type: "disaster_response",
						contactNumber: "(056) 311-2468",
						address: municipalHall,
						hours: "24/7",
						latitude: "12.9186",
						longitude: "124.1225",
						sortOrder: 40,
					},
					{
						name: "Philippine Coast Guard - Gubat Sub-Station",
						type: "disaster_response",
						contactNumber: "0917-555-0145",
						address: "Gubat Port Area, Brgy. Bagacay, Gubat, Sorsogon",
						hours: "24/7",
						latitude: "12.9235",
						longitude: "124.1302",
						sortOrder: 41,
					},
					{
						name: "Philippine Red Cross - Sorsogon Chapter",
						type: "disaster_response",
						contactNumber: "(056) 211-0143",
						address: "Sorsogon City, Sorsogon",
						hours: "Mon–Sat, 8:00 AM – 5:00 PM",
						sortOrder: 42,
					},
				] satisfies Array<typeof emergencyDirectory.$inferInsert>
			).map(entry => ({
				...entry,
				isActive: true,
				updatedById: "seed-user-emergency",
				createdAt: now,
				updatedAt: now,
			}))
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
				{
					category: "Street Lighting",
					description: "Two streetlights are not working along Rizal St. near the plaza.",
					status: "received",
					barangay: "Panganiban (Poblacion)",
					locationAddress: "Rizal St. near the Municipal Plaza",
					latitude: "12.9188",
					longitude: "124.1228",
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 1 * DAY_MS),
					updatedAt: now,
				},
				{
					category: "Waste Management",
					description: "Garbage has not been collected for 4 days at the corner of Rizal St.",
					status: "in_progress",
					barangay: "Panganiban (Poblacion)",
					locationAddress: "Corner of Rizal St. and Mabini St.",
					latitude: "12.9184",
					longitude: "124.1222",
					publicRemarks: "A collection truck has been scheduled for your area.",
					departmentId: deptIds.MDRRMO,
					assignedOfficerId: "seed-user-officer",
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 4 * DAY_MS),
					updatedAt: now,
				},
				{
					category: "Road Damage",
					description: "Deep pothole in front of the public market entrance.",
					status: "resolved",
					barangay: "Panganiban (Poblacion)",
					locationAddress: "Public Market entrance, Brgy. Poblacion",
					latitude: "12.9179",
					longitude: "124.1233",
					publicRemarks: "The pothole has been patched. Thank you for reporting!",
					departmentId: deptIds.MDRRMO,
					assignedOfficerId: "seed-user-supervisor",
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 20 * DAY_MS),
					updatedAt: now,
				},
			]
			const insertedReports = await tx.insert(citizenReports).values(seedCitizenReports).returning({
				id: citizenReports.id,
				category: citizenReports.category,
				status: citizenReports.status,
				authorId: citizenReports.authorId,
			})
			const demoReportIdByCategory = Object.fromEntries(
				insertedReports.filter(r => r.authorId === DEMO_USER_ID).map(r => [r.category, r.id])
			) as Record<string, number>
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
				{
					trackingNumber: "CT-2026-0101",
					serviceTypeId: serviceTypeIdsByName["Community Tax Certificate (Cedula)"],
					serviceType: "Community Tax Certificate (Cedula)",
					description: "Cedula for 2026, needed for my barangay clearance.",
					status: "pending",
					departmentId: deptIds.BPLO,
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 1 * DAY_MS),
					updatedAt: now,
				},
				{
					trackingNumber: "SC-2026-0012",
					serviceTypeId: serviceTypeIdsByName["Senior Citizen ID"],
					serviceType: "Senior Citizen ID",
					description: "Senior Citizen ID application for my mother, Lourdes Lim (age 64).",
					status: "in_review",
					publicRemarks: "OSCA is verifying the submitted birth certificate.",
					departmentId: deptIds.MSSD,
					assignedOfficerId: "seed-user-supervisor",
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 3 * DAY_MS),
					updatedAt: now,
				},
				{
					trackingNumber: "BU-2026-0005",
					serviceTypeId: serviceTypeIdsByName["Building Permit"],
					serviceType: "Building Permit",
					description: "Permit for a second-floor extension of our house on Rizal St.",
					status: "approved",
					publicRemarks: "Approved. Please pay the permit fee at the Treasurer's Office.",
					departmentId: deptIds.BPLO,
					assignedOfficerId: "seed-user-officer",
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 10 * DAY_MS),
					updatedAt: now,
				},
				{
					trackingNumber: "ED-2026-0040",
					serviceTypeId: serviceTypeIdsByName["Educational Assistance"],
					serviceType: "Educational Assistance",
					description:
						"School supplies assistance for my son, Grade 9 at Gubat National High School.",
					status: "rejected",
					publicRemarks:
						"The certificate of enrollment is missing. You may submit a new request with the complete documents.",
					departmentId: deptIds.MSSD,
					assignedOfficerId: "seed-user-supervisor",
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 14 * DAY_MS),
					updatedAt: now,
				},
				{
					trackingNumber: "CV-2026-0150",
					serviceTypeId: serviceTypeIdsByName["Civil Registry Documents"],
					serviceType: "Civil Registry Documents",
					description: "Two certified copies of my birth certificate for a passport application.",
					status: "for_pickup",
					publicRemarks:
						"Ready for pickup at the Civil Registrar's window, Mon–Fri 8 AM – 5 PM. Bring a valid ID.",
					departmentId: deptIds.MSSD,
					assignedOfficerId: "seed-user-officer",
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 6 * DAY_MS),
					updatedAt: now,
				},
				{
					trackingNumber: "GY-2026-0003",
					serviceTypeId: serviceTypeIdsByName["Gymnasium Reservation"],
					serviceType: "Gymnasium Reservation",
					description: "Barangay youth basketball league, Saturday 1 PM – 6 PM.",
					status: "completed",
					publicRemarks: "Reservation completed. Thank you for keeping the venue clean!",
					departmentId: deptIds.MSSD,
					assignedOfficerId: "seed-user-supervisor",
					authorId: DEMO_USER_ID,
					createdAt: new Date(now.getTime() - 30 * DAY_MS),
					completedAt: new Date(now.getTime() - 22 * DAY_MS),
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
					fileUrl: "https://mozilla.github.io/pdf.js/web/compressed.tracemonkey-pldi-09.pdf",
					fileName: "business-permit-application.pdf",
					createdAt: now,
				},
				{
					serviceRequestId: requestIdByTracking["MA-2026-0033"],
					fileUrl: "https://mozilla.github.io/pdf.js/web/compressed.tracemonkey-pldi-09.pdf",
					fileName: "medical-certificate.pdf",
					createdAt: now,
				},
				{
					serviceRequestId: requestIdByTracking["BP-2026-0431"],
					fileUrl: "https://mozilla.github.io/pdf.js/web/compressed.tracemonkey-pldi-09.pdf",
					fileName: "incomplete-requirements.pdf",
					createdAt: now,
				},
			]
			await tx.insert(serviceRequestAttachments).values(seedAttachments)

			const seedRequestHistory: Array<typeof serviceRequestStatusHistory.$inferInsert> =
				insertedRequests.flatMap(request => {
					const source = seedServiceRequests.find(r => r.trackingNumber === request.trackingNumber)
					const path = REQUEST_STATUS_PATHS[source?.status ?? "pending"]
					const submittedAt = source?.createdAt ?? now
					return path.map((status, index) => {
						const isCurrent = index === path.length - 1
						return {
							serviceRequestId: request.id,
							status,
							remarks:
								isCurrent && index > 0
									? (source?.publicRemarks ?? source?.description ?? REQUEST_STATUS_REMARKS[status])
									: REQUEST_STATUS_REMARKS[status],
							visibility: "public" as const,
							changedById: index === 0 ? null : (source?.assignedOfficerId ?? "seed-user-officer"),
							createdAt: new Date(Math.min(submittedAt.getTime() + index * DAY_MS, now.getTime())),
						}
					})
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
				{
					userId: DEMO_USER_ID,
					title: "Welcome to iGubat!",
					body: "Your account is verified. You can now request services, report issues, and track them here.",
					type: "in_app",
					isRead: true,
					createdAt: new Date("2025-01-10T08:10:00Z"),
				},
				{
					userId: DEMO_USER_ID,
					title: "Request Received",
					body: "Your Cedula request CT-2026-0101 has been received and is waiting for review.",
					type: "in_app",
					category: "service_request",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "CT-2026-0101" },
					createdAt: new Date(now.getTime() - 1 * DAY_MS),
				},
				{
					userId: DEMO_USER_ID,
					title: "Ready for Pickup",
					body: "Your birth certificate copies (CV-2026-0150) are ready at the Civil Registrar's window. Bring a valid ID.",
					type: "in_app",
					category: "service_request",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "CV-2026-0150" },
					createdAt: new Date(now.getTime() - 3 * DAY_MS),
				},
				{
					userId: DEMO_USER_ID,
					title: "Building Permit Approved",
					body: "Your building permit BU-2026-0005 has been approved. Please pay the permit fee at the Treasurer's Office.",
					type: "in_app",
					category: "service_request",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "BU-2026-0005" },
					createdAt: new Date(now.getTime() - 8 * DAY_MS),
				},
				{
					userId: DEMO_USER_ID,
					title: "Action Needed: Educational Assistance",
					body: "Request ED-2026-0040 is missing a certificate of enrollment. You may submit a new request with complete documents.",
					type: "in_app",
					category: "service_request",
					isRead: true,
					metadata: { entityType: "service_request", entityId: "ED-2026-0040" },
					createdAt: new Date(now.getTime() - 12 * DAY_MS),
				},
				{
					userId: DEMO_USER_ID,
					title: "Report Update",
					body: "Your waste management report is now in progress. A collection truck has been scheduled.",
					type: "in_app",
					category: "issue_report",
					isRead: false,
					metadata: {
						entityType: "citizen_report",
						entityId: String(demoReportIdByCategory["Waste Management"]),
					},
					createdAt: new Date(now.getTime() - 2 * DAY_MS),
				},
				{
					userId: DEMO_USER_ID,
					title: "Report Resolved",
					body: "Your road damage report has been resolved. Thank you for helping improve Gubat!",
					type: "in_app",
					category: "issue_report",
					isRead: true,
					metadata: {
						entityType: "citizen_report",
						entityId: String(demoReportIdByCategory["Road Damage"]),
					},
					createdAt: new Date(now.getTime() - 15 * DAY_MS),
				},
				{
					userId: DEMO_USER_ID,
					title: "Severe Weather Advisory",
					body: "A low pressure area is being monitored east of Sorsogon. Stay alert and prepare for possible heavy rains.",
					type: "in_app",
					category: "emergency",
					isRead: false,
					metadata: { entityType: "emergency", entityId: "weather-advisory-2026-05" },
					createdAt: new Date(now.getTime() - 5 * DAY_MS),
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
				DEMO_USER_ID,
			].map(userId => ({
				userId,
				news: true,
				serviceRequests: true,
				issueReports: true,
				emergencyBroadcasts: true,
				discoverGubat: true,
				transparency: true,
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
					fileName: "news-business-permit.jpg",
					fileUrl: "https://picsum.photos/seed/news-business-permit/800/600",
					mimeType: "image/jpeg",
					sizeBytes: 0,
					altText: "Business permit renewal placeholder image",
					folder: "news",
					uploadedById: "seed-user-editor",
					createdAt: now,
					updatedAt: now,
				},
				{
					fileName: "service-business-permit.jpg",
					fileUrl: "https://picsum.photos/seed/service-business-permit/800/600",
					mimeType: "image/jpeg",
					sizeBytes: 0,
					altText: "Business permit service placeholder image",
					folder: "services",
					uploadedById: "seed-user-editor",
					createdAt: now,
					updatedAt: now,
				},
				{
					fileName: "event-fiesta.jpg",
					fileUrl: "https://picsum.photos/seed/event-fiesta/800/600",
					mimeType: "image/jpeg",
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
					// Home → Community Stats: order, labels and visibility (values are
					// computed live). Managed in Admin → Content → Community Stats.
					key: "home.community_stats",
					category: "home",
					value: [
						{ key: "registered_citizens", label: "Citizens Registered", enabled: true },
						{ key: "pending_requests", label: "Pending Requests", enabled: true },
						{ key: "active_services", label: "Active Services", enabled: true },
						{ key: "new_reports", label: "New Reports", enabled: true },
						{ key: "published_news", label: "Published News", enabled: true },
						{ key: "completed_requests", label: "Requests Completed", enabled: false },
						{ key: "upcoming_events", label: "Upcoming Events", enabled: false },
					],
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
				{
					userId: DEMO_USER_ID,
					identifier: DEMO_USER_EMAIL,
					success: true,
					ipAddress: "127.0.0.1",
					userAgent: "seed",
					createdAt: new Date(now.getTime() - DAY_MS),
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

			// Discover Gubat (Module 12)
			type SeedDiscoverGubat = typeof discoverGubatEntries.$inferInsert & {
				photos?: Array<Omit<typeof discoverGubatPhotos.$inferInsert, "discoverGubatEntryId">>
			}
			const seedDiscoverGubatEntries: SeedDiscoverGubat[] = [
				{
					type: "tourist_spot",
					title: "Buenavista Beach",
					slug: "buenavista-beach",
					summary: "A public coastal destination known for surf breaks and sunrise views.",
					body: "Buenavista Beach anchors Gubat's reputation as a surfing destination for residents and visitors.",
					category: "Beaches & Surfing",
					status: "published",
					coverImageUrl: "https://picsum.photos/seed/discover-buenavista/900/600",
					mapLocation: "Buenavista, Gubat, Sorsogon",
					metadata: {
						type: "tourist_spot",
						mapLocation: "Buenavista, Gubat, Sorsogon",
						bestFor: "Surfing, sunrise viewing, beach walks",
					},
					notifyOnPublish: true,
					publishedAt: new Date("2026-03-05T08:00:00Z"),
					photos: [
						{
							imageUrl: "https://picsum.photos/seed/discover-buenavista-photo/1200/800",
							altText: "Buenavista Beach shoreline",
							sortOrder: 0,
						},
					],
				},
				{
					type: "tourist_spot",
					title: "Castillo de Gubat",
					slug: "castillo-de-gubat",
					summary: "Spanish-era watchtower ruins tied to the municipality history.",
					body: "The Castillo de Gubat is a heritage landmark connected to the town's coastal history.",
					category: "Heritage & Landmarks",
					status: "published",
					coverImageUrl: "https://picsum.photos/seed/discover-castillo/900/600",
					mapLocation: "Poblacion, Gubat, Sorsogon",
					metadata: {
						type: "tourist_spot",
						mapLocation: "Poblacion, Gubat, Sorsogon",
						travelNote: "Best paired with a town-center heritage walk.",
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-03-06T08:00:00Z"),
				},
				{
					type: "festival_culture",
					title: "Ginubat Festival",
					slug: "ginubat-festival",
					summary: "Annual celebration honoring Gubat history, faith, and community identity.",
					body: "The Ginubat Festival is connected to the town fiesta of San Antonio de Padua and celebrates local identity.",
					category: "Festival",
					status: "published",
					coverImageUrl: "https://picsum.photos/seed/discover-ginubat/900/600",
					eventDate: new Date("2026-06-13T00:00:00Z"),
					metadata: {
						type: "festival_culture",
						cultureKind: "festival",
						eventDate: "2026-06-13",
						culturalNote:
							"An annual town celebration connected to the feast of San Antonio de Padua.",
					},
					notifyOnPublish: true,
					publishedAt: new Date("2026-03-07T08:00:00Z"),
				},
				{
					type: "festival_culture",
					title: "San Antonio de Padua Parish",
					slug: "san-antonio-de-padua-parish",
					summary: "A historic parish church and civic landmark in the town center.",
					body: "The parish anchors religious and civic heritage routes in central Gubat.",
					category: "Heritage",
					status: "published",
					coverImageUrl: "https://picsum.photos/seed/discover-parish/900/600",
					metadata: {
						type: "festival_culture",
						cultureKind: "heritage",
						culturalNote:
							"A civic and religious landmark that anchors local heritage walking routes.",
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-03-08T08:00:00Z"),
				},
				{
					type: "local_product",
					title: "Timitim",
					slug: "timitim",
					summary: "Cassava-and-pili local sweet commonly bought as pasalubong.",
					body: "Timitim is a local kakanin-style sweet made with cassava and pili.",
					category: "Delicacies/Kakanin",
					status: "published",
					coverImageUrl: "https://picsum.photos/seed/discover-timitim/900/600",
					whereToBuy: "Public market and local pasalubong stalls",
					metadata: {
						type: "local_product",
						productKind: "delicacy",
						whereToBuy: "Public market and local pasalubong stalls",
						pasalubongNote: "Best bought fresh in the morning.",
					},
					notifyOnPublish: true,
					publishedAt: new Date("2026-03-09T08:00:00Z"),
				},
				{
					type: "local_product",
					title: "Salanigo",
					slug: "salanigo",
					summary: "Hand-woven abaca slippers produced by local makers.",
					body: "Salanigo showcases local handicraft and OTOP-style livelihood products.",
					category: "Handicrafts/OTOP",
					status: "published",
					coverImageUrl: "https://picsum.photos/seed/discover-salanigo/900/600",
					whereToBuy: "Local OTOP stalls and community product fairs",
					metadata: {
						type: "local_product",
						productKind: "handicraft",
						whereToBuy: "Local OTOP stalls and community product fairs",
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-03-10T08:00:00Z"),
				},
			]

			const insertedDiscoverEntries: Array<{
				id: number
				type: SeedDiscoverGubat["type"]
				title: string
				slug: string | null
				summary: string | null
				status: SeedDiscoverGubat["status"]
				publishedAt: Date | null
			}> = []

			for (const entry of seedDiscoverGubatEntries) {
				const { photos, ...entryValues } = entry
				const [insertedEntry] = await tx
					.insert(discoverGubatEntries)
					.values({ ...entryValues, authorId: "seed-user-editor", createdAt: now, updatedAt: now })
					.returning({
						id: discoverGubatEntries.id,
						type: discoverGubatEntries.type,
						title: discoverGubatEntries.title,
						slug: discoverGubatEntries.slug,
						summary: discoverGubatEntries.summary,
						status: discoverGubatEntries.status,
						publishedAt: discoverGubatEntries.publishedAt,
					})
				if (insertedEntry) {
					insertedDiscoverEntries.push(insertedEntry)
				}
				if (insertedEntry && photos?.length) {
					await tx.insert(discoverGubatPhotos).values(
						photos.map(photo => ({
							...photo,
							discoverGubatEntryId: insertedEntry.id,
						}))
					)
				}
			}

			const discoverNotifications: Array<typeof notifications.$inferInsert> =
				insertedDiscoverEntries
					.filter(entry => entry.status === "published" && entry.slug)
					.map((entry, index) => ({
						userId: "seed-user-juan",
						title: `New Discover Gubat ${entry.type.replace(/_/g, " ")}`,
						body: `${entry.title} has been published.`,
						type: "in_app",
						category: "discover_gubat",
						isRead: false,
						metadata: {
							type: "discover_gubat",
							slug: entry.slug,
							entryId: entry.id,
							routeType: entry.type,
						},
						createdAt: entry.publishedAt
							? new Date(entry.publishedAt.getTime() + 5 * 60_000)
							: new Date(now.getTime() + index * 60_000),
					}))
			if (discoverNotifications.length > 0) {
				await tx.insert(notifications).values(discoverNotifications)
			}

			// Transparency & Good Governance (Module 13)
			// Representative records across all six content types: two Published
			// and one Draft per type. Attachments use placeholder file URLs.
			type SeedTransparency = typeof transparencyItems.$inferInsert & {
				attachments?: Array<Omit<typeof transparencyAttachments.$inferInsert, "transparencyItemId">>
			}
			const seedTransparencyItems: SeedTransparency[] = [
				{
					type: "program_project",
					referenceNumber: "PRJ-2026-014",
					title: "Buenavista Beach Mangrove Rehabilitation",
					slug: "prj-2026-014-buenavista-beach-mangrove-rehabilitation",
					summary:
						"Rehabilitation and reforestation of 4.2 hectares of mangrove coastline in Brgy. Buenavista to restore coastal protection and fisheries.",
					body: "## Overview\nThe LGU, in partnership with the MENRO, will replant 12,000 mangrove propagules across the Buenavista coastline.",
					fiscalYear: 2026,
					barangay: "Buenavista",
					status: "published",
					metadata: {
						type: "program_project",
						projectStatus: "ongoing",
						startDate: "2026-02-01",
						costPhp: 1850000,
						implementingOffice: "MENRO",
						beneficiaries: "Coastal fisherfolk of Brgy. Buenavista",
						locationAddress: "Buenavista coastline, Gubat, Sorsogon",
					},
					coverImageUrl: "https://picsum.photos/seed/transparency-mangrove/800/600",
					notifyOnPublish: true,
					publishedAt: new Date("2026-03-01T08:00:00Z"),
					attachments: [
						{
							fileName: "Mangrove_Project_Brief.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/prj-2026-014-brief.pdf",
							mimeType: "application/pdf",
							sizeBytes: 318_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "program_project",
					referenceNumber: "PRJ-2026-009",
					title: "Farm-to-Market Road Concreting — Brgy. Rizal",
					slug: "prj-2026-009-farm-to-market-road-concreting-brgy-rizal",
					summary:
						"Concreting of 1.8 km farm-to-market road to improve agricultural transport for upland barangays.",
					body: "## Scope\nConcreting of 1.8 km of road with line canals.",
					fiscalYear: 2026,
					barangay: "Rizal",
					status: "published",
					metadata: {
						type: "program_project",
						projectStatus: "planned",
						startDate: "2026-07-01",
						costPhp: 4250000,
						implementingOffice: "Municipal Engineering Office",
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-04-12T08:00:00Z"),
					attachments: [
						{
							fileName: "PRJ-2026-009_Project_Profile.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/prj-2026-009-profile.pdf",
							mimeType: "application/pdf",
							sizeBytes: 286_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "program_project",
					referenceNumber: "PRJ-2026-021",
					title: "Solar Streetlight Installation Program (Draft)",
					slug: "prj-2026-021-solar-streetlight-installation-program",
					summary: "Installation of 60 solar streetlights across six barangays.",
					body: "Draft project brief pending council endorsement.",
					fiscalYear: 2026,
					status: "draft",
					metadata: {
						type: "program_project",
						projectStatus: "planned",
						startDate: "2026-09-01",
						costPhp: 2100000,
						implementingOffice: "Municipal Engineering Office",
					},
					notifyOnPublish: false,
					attachments: [
						{
							fileName: "PRJ-2026-021_Draft_Project_Brief.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/prj-2026-021-draft.pdf",
							mimeType: "application/pdf",
							sizeBytes: 194_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "bid_procurement",
					referenceNumber: "IB-2026-007",
					title: "Invitation to Bid — Concreting of Brgy. Rizal Road",
					slug: "ib-2026-007-concreting-of-brgy-rizal-road",
					summary:
						"Public bidding for the concreting of Brgy. Rizal road. Sealed bids accepted until the closing date.",
					body: "The Municipality of Gubat invites bids for the above contract per RA 9184.",
					fiscalYear: 2026,
					effectiveDate: new Date("2026-06-28T00:00:00Z"),
					status: "published",
					metadata: {
						type: "bid_procurement",
						approvedBudgetForContractPhp: 4250000,
						procurementMode: "public_bidding",
						closingDate: "2026-06-28",
						bidStatus: "open",
					},
					notifyOnPublish: true,
					publishedAt: new Date("2026-06-10T08:00:00Z"),
					attachments: [
						{
							fileName: "IB-2026-007_Invitation.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/ib-2026-007.pdf",
							mimeType: "application/pdf",
							sizeBytes: 240_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "bid_procurement",
					referenceNumber: "IB-2026-003",
					title: "Rehabilitation of Public Market — Phase 2",
					slug: "ib-2026-003-rehabilitation-of-public-market-phase-2",
					summary: "Award notice for the rehabilitation of the public market, phase 2.",
					body: "Notice of Award issued to the lowest calculated responsive bidder.",
					fiscalYear: 2026,
					status: "published",
					metadata: {
						type: "bid_procurement",
						approvedBudgetForContractPhp: 9200000,
						procurementMode: "public_bidding",
						closingDate: "2026-04-15",
						awardedTo: "Sorsogon Builders Inc.",
						awardedAmountPhp: 8640000,
						bidStatus: "awarded",
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-05-02T08:00:00Z"),
					attachments: [
						{
							fileName: "IB-2026-003_Notice_of_Award.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/ib-2026-003-award.pdf",
							mimeType: "application/pdf",
							sizeBytes: 222_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "bid_procurement",
					referenceNumber: "RFQ-2026-031",
					title: "Request for Quotation — School Furniture (Draft)",
					slug: "rfq-2026-031-school-furniture",
					summary: "Supply and delivery of school furniture for three barangay schools.",
					body: "Draft RFQ pending BAC review.",
					fiscalYear: 2026,
					status: "draft",
					metadata: {
						type: "bid_procurement",
						approvedBudgetForContractPhp: 1890000,
						procurementMode: "small_value",
						closingDate: "2026-07-05",
						bidStatus: "posted",
					},
					notifyOnPublish: false,
					attachments: [
						{
							fileName: "RFQ-2026-031_Draft_Request.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/rfq-2026-031-draft.pdf",
							mimeType: "application/pdf",
							sizeBytes: 158_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "financial_report",
					referenceNumber: "SAOB-Q1-2026",
					title: "Statement of Allotments, Obligations and Balances — Q1 2026",
					slug: "saob-q1-2026",
					summary: "Quarterly SAOB for the first quarter of fiscal year 2026.",
					body: "See attached PDF for the full statement.",
					fiscalYear: 2026,
					status: "published",
					metadata: {
						type: "financial_report",
						reportType: "saob",
						fiscalPeriod: "Q1 2026",
						preparedBy: "Municipal Accounting Office",
					},
					notifyOnPublish: true,
					publishedAt: new Date("2026-04-20T08:00:00Z"),
					attachments: [
						{
							fileName: "SAOB_Q1_2026.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/saob-q1-2026.pdf",
							mimeType: "application/pdf",
							sizeBytes: 512_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "financial_report",
					referenceNumber: "COA-2025",
					title: "COA Annual Audit Report — FY 2025",
					slug: "coa-2025-annual-audit-report",
					summary: "Commission on Audit annual audit report for fiscal year 2025.",
					body: "Full COA annual audit report.",
					fiscalYear: 2025,
					status: "published",
					metadata: {
						type: "financial_report",
						reportType: "coa_annual",
						fiscalPeriod: "FY 2025",
						preparedBy: "Commission on Audit",
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-02-10T08:00:00Z"),
					attachments: [
						{
							fileName: "COA_Annual_Audit_Report_FY2025.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/coa-2025-report.pdf",
							mimeType: "application/pdf",
							sizeBytes: 842_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "financial_report",
					referenceNumber: "SRE-Q2-2026",
					title: "Statement of Receipts and Expenditures — Q2 2026 (Draft)",
					slug: "sre-q2-2026",
					summary: "Draft quarterly SRE for the second quarter of fiscal year 2026.",
					body: "Draft pending finalization.",
					fiscalYear: 2026,
					status: "draft",
					metadata: {
						type: "financial_report",
						reportType: "sre",
						fiscalPeriod: "Q2 2026",
					},
					notifyOnPublish: false,
					attachments: [
						{
							fileName: "SRE_Q2_2026_Draft.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/sre-q2-2026-draft.pdf",
							mimeType: "application/pdf",
							sizeBytes: 376_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "annual_budget",
					referenceNumber: "AB-2026",
					title: "Annual Budget FY 2026",
					slug: "ab-2026-annual-budget",
					summary: "The approved annual budget of the Municipality of Gubat for fiscal year 2026.",
					body: "## Executive Budget Message\nThe FY 2026 budget prioritizes coastal resilience, health, and education.",
					fiscalYear: 2026,
					status: "published",
					metadata: {
						type: "annual_budget",
						budgetType: "annual",
						totalAmountPhp: 312_000_000,
						endorsedBy: "Hon. Sangguniang Bayan",
					},
					notifyOnPublish: true,
					publishedAt: new Date("2026-01-15T08:00:00Z"),
					attachments: [
						{
							fileName: "Annual_Budget_FY2026.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/ab-2026.pdf",
							mimeType: "application/pdf",
							sizeBytes: 1_240_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "annual_budget",
					referenceNumber: "SB-2026-01",
					title: "Supplemental Budget No. 1, FY 2026",
					slug: "sb-2026-01-supplemental-budget",
					summary: "First supplemental budget for fiscal year 2026.",
					body: "Supplemental appropriations for disaster preparedness.",
					fiscalYear: 2026,
					status: "published",
					metadata: {
						type: "annual_budget",
						budgetType: "supplemental",
						totalAmountPhp: 18_500_000,
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-05-20T08:00:00Z"),
					attachments: [
						{
							fileName: "Supplemental_Budget_No_1_FY2026.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/sb-2026-01.pdf",
							mimeType: "application/pdf",
							sizeBytes: 438_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "annual_budget",
					referenceNumber: "EB-2027",
					title: "Executive Budget FY 2027 (Draft)",
					slug: "eb-2027-executive-budget",
					summary: "Draft executive budget proposal for fiscal year 2027.",
					body: "Draft executive budget pending council deliberation.",
					fiscalYear: 2027,
					status: "draft",
					metadata: {
						type: "annual_budget",
						budgetType: "executive_budget",
						totalAmountPhp: 330_000_000,
					},
					notifyOnPublish: false,
					attachments: [
						{
							fileName: "Executive_Budget_FY2027_Draft.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/eb-2027-draft.pdf",
							mimeType: "application/pdf",
							sizeBytes: 558_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "legislative_ordinance",
					referenceNumber: "Ord. No. 2026-018",
					title: "An Ordinance Reducing Single-Use Plastic in Public Markets",
					slug: "ord-2026-018-single-use-plastic-reduction",
					summary:
						"This ordinance prohibits the use of single-use plastic carry bags by vendors in all public markets of the Municipality of Gubat.",
					body: "## Section 1. Title\nThis ordinance shall be known as the Single-Use Plastic Reduction Ordinance.",
					fiscalYear: 2026,
					effectiveDate: new Date("2026-03-27T00:00:00Z"),
					status: "published",
					metadata: {
						type: "legislative_ordinance",
						dateApproved: "2026-03-12",
						principalAuthor: "Hon. M. Dela Cruz",
						sponsors: "Hon. R. Bautista, Hon. J. Reyes",
						sbSessionDate: "2026-03-12",
					},
					notifyOnPublish: true,
					publishedAt: new Date("2026-03-13T08:00:00Z"),
					attachments: [
						{
							fileName: "Ordinance_2026-018_Full_Text.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/ord-2026-018.pdf",
							mimeType: "application/pdf",
							sizeBytes: 412_000,
							sortOrder: 0,
						},
						{
							fileName: "SB_Minutes_2026-03-12.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/sb-minutes-2026-03-12.pdf",
							mimeType: "application/pdf",
							sizeBytes: 186_000,
							sortOrder: 1,
						},
					],
				},
				{
					type: "legislative_ordinance",
					referenceNumber: "Ord. No. 2026-012",
					title: "An Ordinance Establishing the Municipal Disaster Response Fund",
					slug: "ord-2026-012-disaster-response-fund",
					summary: "Establishes a standing municipal disaster response fund.",
					body: "Full text of the disaster response fund ordinance.",
					fiscalYear: 2026,
					effectiveDate: new Date("2026-02-20T00:00:00Z"),
					status: "published",
					metadata: {
						type: "legislative_ordinance",
						dateApproved: "2026-02-05",
						principalAuthor: "Hon. J. Reyes",
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-02-06T08:00:00Z"),
					attachments: [
						{
							fileName: "Ordinance_2026-012_Full_Text.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/ord-2026-012.pdf",
							mimeType: "application/pdf",
							sizeBytes: 348_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "legislative_ordinance",
					referenceNumber: "Ord. No. 2026-022",
					title: "Anti-Noise Pollution Ordinance (Draft)",
					slug: "ord-2026-022-anti-noise-pollution",
					summary: "Draft ordinance regulating noise levels in residential zones.",
					body: "Draft pending second reading.",
					fiscalYear: 2026,
					status: "draft",
					metadata: {
						type: "legislative_ordinance",
						dateApproved: "2026-07-10",
						principalAuthor: "Hon. R. Bautista",
					},
					notifyOnPublish: false,
					attachments: [
						{
							fileName: "Ordinance_2026-022_Draft.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/ord-2026-022-draft.pdf",
							mimeType: "application/pdf",
							sizeBytes: 226_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "executive_order",
					referenceNumber: "EO No. 2026-05",
					title: "Implementation of Pacific Coast Cleanliness Drive",
					slug: "eo-2026-05-pacific-coast-cleanliness-drive",
					summary:
						"Directs all barangays to conduct monthly coastal clean-up activities along the Pacific coast of Gubat.",
					body: "## Executive Order No. 2026-05\nBy virtue of the powers vested in the Office of the Mayor...",
					fiscalYear: 2026,
					effectiveDate: new Date("2026-05-02T00:00:00Z"),
					status: "published",
					metadata: {
						type: "executive_order",
						dateIssued: "2026-05-01",
						issuedBy: "Hon. Sharon Rose Aragon-Escoto",
					},
					notifyOnPublish: true,
					publishedAt: new Date("2026-05-02T08:00:00Z"),
					attachments: [
						{
							fileName: "EO_2026-05.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/eo-2026-05.pdf",
							mimeType: "application/pdf",
							sizeBytes: 168_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "executive_order",
					referenceNumber: "EO No. 2026-03",
					title: "Creation of the Municipal Investment Promotion Team",
					slug: "eo-2026-03-investment-promotion-team",
					summary: "Creates a team to streamline local investment under RA 11032.",
					body: "Full text of the executive order.",
					fiscalYear: 2026,
					status: "published",
					metadata: {
						type: "executive_order",
						dateIssued: "2026-03-10",
						issuedBy: "Hon. Sharon Rose Aragon-Escoto",
					},
					notifyOnPublish: false,
					publishedAt: new Date("2026-03-11T08:00:00Z"),
					attachments: [
						{
							fileName: "EO_2026-03.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/eo-2026-03.pdf",
							mimeType: "application/pdf",
							sizeBytes: 152_000,
							sortOrder: 0,
						},
					],
				},
				{
					type: "executive_order",
					referenceNumber: "EO No. 2026-07",
					title: "Reorganization of the Local Health Board (Draft)",
					slug: "eo-2026-07-local-health-board-reorganization",
					summary: "Draft executive order reorganizing the local health board.",
					body: "Draft pending legal review.",
					fiscalYear: 2026,
					status: "draft",
					metadata: {
						type: "executive_order",
						dateIssued: "2026-06-01",
						issuedBy: "Hon. Sharon Rose Aragon-Escoto",
						revokes: "EO No. 2024-11",
					},
					notifyOnPublish: false,
					attachments: [
						{
							fileName: "EO_2026-07_Draft.pdf",
							fileUrl: "https://files.gubat.gov.ph/transparency/eo-2026-07-draft.pdf",
							mimeType: "application/pdf",
							sizeBytes: 146_000,
							sortOrder: 0,
						},
					],
				},
			]

			const transparencyNotificationLabels: Record<SeedTransparency["type"], string> = {
				program_project: "Program and Project",
				bid_procurement: "Bid and Procurement",
				financial_report: "Financial Report",
				annual_budget: "Annual Budget",
				legislative_ordinance: "Legislative Ordinance",
				executive_order: "Executive Order",
			}
			const insertedTransparencyItems: Array<{
				id: number
				type: SeedTransparency["type"]
				title: string
				slug: string | null
				summary: string | null
				status: SeedTransparency["status"]
				publishedAt: Date | null
			}> = []

			for (const item of seedTransparencyItems) {
				const { attachments, ...itemValues } = item
				const [insertedItem] = await tx
					.insert(transparencyItems)
					.values({ ...itemValues, authorId: "seed-user-editor", createdAt: now, updatedAt: now })
					.returning({
						id: transparencyItems.id,
						type: transparencyItems.type,
						title: transparencyItems.title,
						slug: transparencyItems.slug,
						summary: transparencyItems.summary,
						status: transparencyItems.status,
						publishedAt: transparencyItems.publishedAt,
					})
				if (insertedItem) {
					insertedTransparencyItems.push(insertedItem)
				}
				if (insertedItem && attachments?.length) {
					await tx.insert(transparencyAttachments).values(
						attachments.map(attachment => ({
							...attachment,
							transparencyItemId: insertedItem.id,
						}))
					)
				}
			}

			const transparencyNotifications: Array<typeof notifications.$inferInsert> =
				insertedTransparencyItems
					.filter(item => item.status === "published")
					.map((item, index) => ({
						userId: "seed-user-juan",
						title: `New ${transparencyNotificationLabels[item.type]} disclosure`,
						body: `${item.title} has been published.`,
						type: "in_app",
						category: "transparency",
						isRead: false,
						metadata: {
							type: "transparency",
							slug: item.slug,
							entityId: String(item.id),
						},
						createdAt: item.publishedAt
							? new Date(item.publishedAt.getTime() + 5 * 60_000)
							: new Date(now.getTime() + index * 60_000),
					}))
			if (transparencyNotifications.length > 0) {
				await tx.insert(notifications).values(transparencyNotifications)
			}

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
				notifications:
					seedNotifications.length +
					discoverNotifications.length +
					transparencyNotifications.length,
				notificationPreferences: seedNotificationPreferences.length,
				notificationDeliveryLogs: insertedNotifications.length,
				auditLogs: seedAuditLogs.length,
				mediaAssets: seedMediaAssets.length,
				helpArticles: seedHelpArticles.length,
				policyDocuments: seedPolicyDocuments.length,
				systemSettings: seedSystemSettings.length,
				userLoginActivity: seedLoginActivity.length,
				tickets: seedTickets.length,
				discoverGubatEntries: seedDiscoverGubatEntries.length,
				transparencyItems: seedTransparencyItems.length,
			}
		})

		console.log("iGubat database seeded successfully.\n")
		console.log("Table counts:")
		for (const [table, count] of Object.entries(counts)) {
			console.log(`  ${table}: ${count}`)
		}
		console.log(`\nDefault password for all accounts: ${SEED_PASSWORD}`)
		console.log("\nQuick demo (mobile app) — start here:")
		console.log(`  ${DEMO_USER_EMAIL} / ${SEED_PASSWORD}`)
		console.log(
			"  Rosa Lim: complete verified profile, 1 request per status, 3 reports, notifications"
		)
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
