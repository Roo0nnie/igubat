import "dotenv/config"

import { inArray, or } from "drizzle-orm"
import { drizzle } from "drizzle-orm/node-postgres"
import { randomBytes, scryptSync } from "node:crypto"
import { Pool } from "pg"

import {
	accounts,
	auditLogs,
	citizenReports,
	departments,
	emergencyDirectory,
	newsArticles,
	notifications,
	schema,
	serviceRequestAttachments,
	serviceRequests,
	tickets,
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

function buildSeedUsers(now: Date, deptIds: Record<string, number>): Array<typeof users.$inferInsert> {
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
					departmentId: user.departmentId ?? null,
					mobileNumber: user.mobileNumber ?? null,
					barangay: user.barangay ?? null,
					address: user.address ?? null,
					dpaConsent: user.dpaConsent ?? false,
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
	await tx.delete(notifications).where(inArray(notifications.userId, [...SEED_USER_IDS]))
	await tx.delete(auditLogs).where(inArray(auditLogs.actorId, [...SEED_USER_IDS]))
	await tx
		.delete(tickets)
		.where(
			or(inArray(tickets.email, [...SEED_TICKET_EMAILS]), inArray(tickets.authorId, [...SEED_USER_IDS]))
		)
	await tx.delete(newsArticles).where(inArray(newsArticles.authorId, [...SEED_USER_IDS]))
	await tx.delete(citizenReports).where(inArray(citizenReports.authorId, [...SEED_USER_IDS]))
	await tx
		.delete(serviceRequests)
		.where(
			or(
				inArray(serviceRequests.trackingNumber, [...SEED_TRACKING_NUMBERS]),
				inArray(serviceRequests.authorId, [...SEED_USER_IDS])
			)
		)
	await tx.delete(workflowTemplates)
	await tx.delete(emergencyDirectory)
	await tx.update(users).set({ departmentId: null }).where(inArray(users.id, [...SEED_USER_IDS]))
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
		{ name: "MSSD", description: "Municipal Social Services and Development", createdAt: now, updatedAt: now },
		{ name: "BPLO", description: "Business Permits and Licensing Office", createdAt: now, updatedAt: now },
		{ name: "Transport Office", description: "Transportation Office", createdAt: now, updatedAt: now },
		{ name: "MHO", description: "Municipal Health Office", createdAt: now, updatedAt: now },
		{ name: "MDRRMO", description: "Municipal Disaster Risk Reduction and Management Office", createdAt: now, updatedAt: now },
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

			const workflowRows = [
				{ serviceType: "Business Permit", departmentId: deptIds.BPLO, steps: WORKFLOW_STEPS, isActive: true, createdAt: now, updatedAt: now },
				{ serviceType: "Certificate of Residency", departmentId: deptIds.MSSD, steps: WORKFLOW_STEPS, isActive: true, createdAt: now, updatedAt: now },
				{ serviceType: "Medical Assistance", departmentId: deptIds.MHO, steps: WORKFLOW_STEPS, isActive: true, createdAt: now, updatedAt: now },
				{ serviceType: "Transportation Assistance", departmentId: deptIds["Transport Office"], steps: WORKFLOW_STEPS, isActive: true, createdAt: now, updatedAt: now },
				{ serviceType: "Barangay Clearance", departmentId: deptIds.MSSD, steps: WORKFLOW_STEPS, isActive: true, createdAt: now, updatedAt: now },
				{ serviceType: "Facility Use", departmentId: deptIds.MSSD, steps: WORKFLOW_STEPS, isActive: true, createdAt: now, updatedAt: now },
			] satisfies Array<typeof workflowTemplates.$inferInsert>
			await tx.insert(workflowTemplates).values(workflowRows)

			const seedNewsArticles: Array<typeof newsArticles.$inferInsert> = [
				{
					title: "Business Permit Renewal Period Now Open",
					body: "The Municipality of Gubat is now accepting new and renewal business permit applications for the upcoming year. Visit the BPLO office or apply online via iGubat.",
					category: "Business",
					status: "published",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-20T08:00:00Z"),
					createdAt: new Date("2026-05-20T08:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Free Medical Mission This Saturday",
					body: "The Municipal Health Office invites all residents to a free medical mission at the town plaza. Bring valid IDs for verification.",
					category: "Health",
					status: "published",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-18T09:30:00Z"),
					createdAt: new Date("2026-05-18T09:30:00Z"),
					updatedAt: now,
				},
				{
					title: "Road Repair Schedule for May",
					body: "Expect traffic rerouting along the national road from May 22-25 due to ongoing road repair operations.",
					category: "Infrastructure",
					status: "published",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-15T07:15:00Z"),
					createdAt: new Date("2026-05-15T07:15:00Z"),
					updatedAt: now,
				},
				{
					title: "Coastal Clean-Up Drive",
					body: "Join the LGU and volunteer groups for a coastal clean-up activity at Rizal Beach this Sunday.",
					category: "Community",
					status: "published",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-10T10:00:00Z"),
					createdAt: new Date("2026-05-10T10:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Scheduled Power Interruption",
					body: "Please be informed of a scheduled power interruption on May 30 due to line maintenance in selected barangays.",
					category: "Utilities",
					status: "published",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-26T08:00:00Z"),
					createdAt: new Date("2026-05-26T08:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Tax Payment Deadline Reminder",
					body: "Reminder: Real property tax payment deadline is June 30. Avoid penalties by paying early at the Treasurer's Office or via iGubat.",
					category: "Business",
					status: "published",
					authorId: "seed-user-editor",
					publishedAt: new Date("2026-05-22T10:00:00Z"),
					createdAt: new Date("2026-05-22T10:00:00Z"),
					updatedAt: now,
				},
				{
					title: "Upcoming Town Fiesta Program",
					body: "Draft program outline for the annual town fiesta opening ceremonies at the Municipal Plaza.",
					category: "Community",
					status: "draft",
					authorId: "seed-user-editor",
					createdAt: new Date("2026-05-28T14:00:00Z"),
					updatedAt: now,
				},
				{
					title: "New Solid Waste Collection Schedule",
					body: "Draft schedule for updated garbage collection routes starting July 2026.",
					category: "Infrastructure",
					status: "draft",
					authorId: "seed-user-editor",
					createdAt: new Date("2026-05-29T09:00:00Z"),
					updatedAt: now,
				},
				{
					title: "2025 Business Permit Renewal Closed",
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

			const seedEmergencyDirectory: Array<typeof emergencyDirectory.$inferInsert> = [
				{ name: "National Emergency Hotline", type: "comcen", contactNumber: "911", isActive: true, createdAt: now, updatedAt: now },
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

			const seedCitizenReports: Array<typeof citizenReports.$inferInsert> = [
				{
					category: "Road Damage",
					description: "Large pothole causing traffic at Mabini St., Brgy. Poblacion.",
					status: "in_progress",
					latitude: "13.0917",
					longitude: "123.5100",
					authorId: "seed-user-juan",
					createdAt: new Date("2026-05-18T08:30:00Z"),
					updatedAt: now,
				},
				{
					category: "Waste Management",
					description: "Uncollected garbage for 3 days at Bonifacio St., Brgy. Bagacay.",
					status: "received",
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
					latitude: "13.0880",
					longitude: "123.5080",
					authorId: "seed-user-ana",
					createdAt: new Date("2026-05-10T14:00:00Z"),
					updatedAt: now,
				},
				{
					category: "Flooding",
					description: "Standing water after heavy rain along Rizal St., Brgy. Rizal.",
					status: "closed",
					latitude: "13.0900",
					longitude: "123.5095",
					authorId: "seed-user-maria",
					createdAt: new Date("2026-04-20T11:00:00Z"),
					updatedAt: now,
				},
				{
					category: "Public Safety",
					description: "Damaged pedestrian railing along the coastal road near Rizal Beach.",
					status: "received",
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
					latitude: "13.0910",
					longitude: "123.5105",
					authorId: "seed-user-ana",
					createdAt: new Date("2026-05-24T07:30:00Z"),
					updatedAt: now,
				},
			]
			await tx.insert(citizenReports).values(seedCitizenReports)

			const seedServiceRequests: Array<typeof serviceRequests.$inferInsert> = [
				{
					trackingNumber: "BP-2026-0418",
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

			const insertedRequests = await tx.insert(serviceRequests).values(seedServiceRequests).returning({
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

			const seedNotifications: Array<typeof notifications.$inferInsert> = [
				{
					userId: "seed-user-juan",
					title: "Business Permit Approved",
					body: "Your business permit application BP-2026-0418 has been approved. You may now claim your permit.",
					type: "in_app",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "BP-2026-0418" },
					createdAt: new Date("2026-05-26T14:20:00Z"),
				},
				{
					userId: "seed-user-juan",
					title: "Document Ready for Pickup",
					body: "Your requested Certificate of Residency CR-2026-0117 is ready for pickup at the barangay hall.",
					type: "in_app",
					isRead: true,
					metadata: { entityType: "service_request", entityId: "CR-2026-0117" },
					createdAt: new Date("2026-05-22T08:30:00Z"),
				},
				{
					userId: "seed-user-juan",
					title: "New Announcement Posted",
					body: "A new community announcement has been published. Tap to read more.",
					type: "in_app",
					isRead: true,
					metadata: { entityType: "news_article", entityId: "1" },
					createdAt: new Date("2026-05-24T11:45:00Z"),
				},
				{
					userId: "seed-user-juan",
					title: "Severe Weather Advisory",
					body: "A low pressure area is being monitored east of Sorsogon. Stay alert and prepare for possible heavy rains.",
					type: "in_app",
					isRead: false,
					metadata: { entityType: "emergency", entityId: "weather-advisory-2026-05" },
					createdAt: new Date("2026-05-25T06:00:00Z"),
				},
				{
					userId: "seed-user-maria",
					title: "Request Received",
					body: "Your business permit application BP-2026-0422 has been received and is pending review.",
					type: "in_app",
					isRead: false,
					metadata: { entityType: "service_request", entityId: "BP-2026-0422" },
					createdAt: new Date("2026-05-18T10:30:00Z"),
				},
				{
					userId: "seed-user-maria",
					title: "Medical Assistance In Review",
					body: "Your medical assistance request MA-2026-0033 is now being reviewed by MSSD.",
					type: "in_app",
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
					isRead: false,
					metadata: { entityType: "service_request", entityId: "BP-2026-0431" },
					createdAt: new Date("2026-05-24T16:00:00Z"),
				},
				{
					userId: "seed-user-pedro",
					title: "Report Received",
					body: "Your waste management report has been received and will be reviewed by the LGU.",
					type: "in_app",
					isRead: true,
					metadata: { entityType: "citizen_report", entityId: "2" },
					createdAt: new Date("2026-05-25T16:30:00Z"),
				},
				{
					userId: "seed-user-ana",
					title: "Request Completed",
					body: "Your transportation assistance request TA-2026-0007 has been completed.",
					type: "in_app",
					isRead: true,
					metadata: { entityType: "service_request", entityId: "TA-2026-0007" },
					createdAt: new Date("2026-04-20T15:00:00Z"),
				},
				{
					userId: "seed-user-ana",
					title: "Report Resolved",
					body: "Your street lighting report has been marked as resolved. Thank you for reporting.",
					type: "in_app",
					isRead: false,
					metadata: { entityType: "citizen_report", entityId: "3" },
					createdAt: new Date("2026-05-15T11:00:00Z"),
				},
				{
					userId: "seed-user-ana",
					title: "Severe Weather Advisory",
					body: "A low pressure area is being monitored east of Sorsogon. Stay alert and prepare for possible heavy rains.",
					type: "in_app",
					isRead: false,
					metadata: { entityType: "emergency", entityId: "weather-advisory-2026-05" },
					createdAt: new Date("2026-05-25T06:00:00Z"),
				},
			]
			await tx.insert(notifications).values(seedNotifications)

			const seedAuditLogs: Array<typeof auditLogs.$inferInsert> = [
				{ actorId: "seed-user-admin", actionType: "login", entityType: "user", entityId: "seed-user-admin", details: { method: "email" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-officer", actionType: "login", entityType: "user", entityId: "seed-user-officer", details: { method: "email" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-editor", actionType: "login", entityType: "user", entityId: "seed-user-editor", details: { method: "email" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-officer", actionType: "status_change", entityType: "service_request", entityId: "BP-2026-0418", details: { from: "in_review", to: "approved" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-officer", actionType: "status_change", entityType: "service_request", entityId: "BP-2026-0431", details: { from: "in_review", to: "rejected" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-supervisor", actionType: "assign", entityType: "service_request", entityId: "MA-2026-0033", details: { assignedOfficerId: "seed-user-supervisor" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-officer", actionType: "status_change", entityType: "citizen_report", entityId: "1", details: { from: "received", to: "in_progress" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-editor", actionType: "publish", entityType: "news_article", entityId: "1", details: { title: "Business Permit Renewal Period Now Open" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-editor", actionType: "archive", entityType: "news_article", entityId: "9", details: { title: "2025 Business Permit Renewal Closed" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-emergency", actionType: "create", entityType: "emergency_directory", entityId: "1", details: { name: "COMCEN Gubat (Smart)" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-emergency", actionType: "update", entityType: "emergency_directory", entityId: "5", details: { field: "contactNumber" }, ipAddress: "127.0.0.1", createdAt: now },
				{ actorId: "seed-user-ict", actionType: "view", entityType: "user", entityId: "seed-user-juan", details: { action: "role_inspection" }, ipAddress: "127.0.0.1", createdAt: now },
			]
			await tx.insert(auditLogs).values(seedAuditLogs)

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
					concern: "I would like to confirm the requirements for renewing my sari-sari store permit.",
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
					concern: "This anonymous ticket exists to test support workflows without a linked account.",
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
				workflowTemplates: workflowRows.length,
				newsArticles: seedNewsArticles.length,
				emergencyDirectory: seedEmergencyDirectory.length,
				citizenReports: seedCitizenReports.length,
				serviceRequests: seedServiceRequests.length,
				serviceRequestAttachments: seedAttachments.length,
				notifications: seedNotifications.length,
				auditLogs: seedAuditLogs.length,
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
		console.log("  supervisor@igubat.local (department_supervisor), officer@igubat.local (frontline_officer)")
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
