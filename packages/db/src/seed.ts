import "dotenv/config"

import { inArray, or } from "drizzle-orm"
import { drizzle } from "drizzle-orm/node-postgres"
import { randomBytes, scryptSync } from "node:crypto"
import { Pool } from "pg"

import { accounts, citizenReports, departments, emergencyDirectory, newsArticles, schema, serviceRequests, tickets, todos, users } from "./schema.js"

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

async function seedDatabase() {
	const connectionString = process.env.DATABASE_URL

	if (!connectionString) {
		throw new Error("DATABASE_URL environment variable is not set")
	}

	const pool = new Pool({ connectionString })
	const db = drizzle({ client: pool, schema })
	const now = new Date()
	const seedPassword = "password123"
	const hashedSeedPassword = await hashPassword(seedPassword)

	const seedDepartments: Array<typeof departments.$inferInsert> = [
		{ name: "MSSD", description: "Municipal Social Services and Development", createdAt: now, updatedAt: now },
		{ name: "BPLO", description: "Business Permits and Licensing Office", createdAt: now, updatedAt: now },
		{ name: "Transport Office", description: "Transportation Office", createdAt: now, updatedAt: now },
	]

	const seedUsers: Array<typeof users.$inferInsert> = [
		{
			id: "seed-user-admin",
			name: "Admin User",
			email: "admin@turbo-template.local",
			emailVerified: true,
			image: null,
			role: "super_admin",
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-juan",
			name: "Juan Dela Cruz",
			email: "juan@example.com",
			emailVerified: true,
			image: null,
			role: "registered_citizen",
			createdAt: new Date("2024-01-15T08:00:00Z"),
			updatedAt: now,
		},
		{
			id: "seed-user-maria",
			name: "Maria Santos",
			email: "maria@example.com",
			emailVerified: false,
			image: null,
			role: "registered_citizen",
			createdAt: new Date("2024-02-20T10:30:00Z"),
			updatedAt: now,
		},
		{
			id: "seed-user-pedro",
			name: "Pedro Penduko",
			email: "pedro@example.com",
			emailVerified: true,
			image: null,
			role: "registered_citizen",
			createdAt: new Date("2024-03-05T14:15:00Z"),
			updatedAt: now,
		},
	]

	const seedTodos: Array<typeof todos.$inferInsert> = [
		{
			title: "Review onboarding checklist",
			completed: true,
			authorId: "seed-user-admin",
			createdAt: now,
			updatedAt: now,
		},
		{
			title: "Verify backend health endpoint",
			completed: false,
			authorId: "seed-user-admin",
			createdAt: now,
			updatedAt: now,
		},
		{
			title: "Connect mobile app to local API",
			completed: false,
			authorId: "seed-user-alex",
			createdAt: now,
			updatedAt: now,
		},
		{
			title: "Draft release notes for staging",
			completed: false,
			authorId: "seed-user-sam",
			createdAt: now,
			updatedAt: now,
		},
	]

	const seedTickets: Array<typeof tickets.$inferInsert> = [
		{
			name: "Admin User",
			email: "admin@turbo-template.local",
			subject: "Initial admin setup check",
			priority: "high" as const,
			concern: "Please verify seeded admin data appears correctly across the dashboard.",
			status: "in_progress" as const,
			authorId: "seed-user-admin",
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "Alex Johnson",
			email: "alex@turbo-template.local",
			subject: "Mobile API connectivity",
			priority: "medium" as const,
			concern: "Android emulator needs a stable local API URL during development.",
			status: "received" as const,
			authorId: "seed-user-alex",
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "Guest Reporter",
			email: "guest@turbo-template.local",
			subject: "Public feedback sample",
			priority: "low" as const,
			concern: "This anonymous ticket exists to test support workflows without a linked account.",
			status: "received" as const,
			authorId: null,
			createdAt: now,
			updatedAt: now,
		},
	]
	const seedNewsArticles: Array<typeof newsArticles.$inferInsert> = [
		{
			title: "Scheduled Power Interruption",
			body: "Please be informed of a scheduled power interruption on May 30 due to line maintenance.",
			category: "Utilities",
			status: "published",
			authorId: "seed-user-admin",
			publishedAt: new Date("2024-05-26T08:00:00Z"),
			createdAt: new Date("2024-05-26T08:00:00Z"),
			updatedAt: now,
		},
		{
			title: "Deadline for Business Permit Renewal",
			body: "Reminder: Business permit renewal deadline is approaching. Avoid penalties by renewing early.",
			category: "Announcements",
			status: "published",
			authorId: "seed-user-admin",
			publishedAt: new Date("2024-05-20T10:00:00Z"),
			createdAt: new Date("2024-05-20T10:00:00Z"),
			updatedAt: now,
		},
	]

	const seedCitizenReports: Array<typeof citizenReports.$inferInsert> = [
		{
			category: "Road Damage",
			description: "Large pothole causing traffic at Mabini St., Brgy. Poblacion.",
			status: "in_progress",
			latitude: "13.9167",
			longitude: "124.1167",
			authorId: "seed-user-juan",
			createdAt: new Date("2024-05-18T08:30:00Z"),
			updatedAt: now,
		},
		{
			category: "Waste Management",
			description: "Uncollected garbage for 3 days at Bonifacio St., Brgy. San Juan.",
			status: "received",
			latitude: "13.9180",
			longitude: "124.1180",
			authorId: "seed-user-pedro",
			createdAt: new Date("2024-05-25T16:00:00Z"),
			updatedAt: now,
		},
	]

	const seedEmergencyDirectory: Array<typeof emergencyDirectory.$inferInsert> = [
		{
			name: "National Emergency",
			type: "comcen",
			contactNumber: "911",
			isActive: true,
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "iGubat Police Station",
			type: "police",
			contactNumber: "0917-000-0001",
			isActive: true,
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "iGubat Fire Department",
			type: "bfp",
			contactNumber: "0917-000-0002",
			isActive: true,
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "Municipal Hospital",
			type: "hospital",
			contactNumber: "0917-000-0003",
			isActive: true,
			createdAt: now,
			updatedAt: now,
		},
	]

	const seedServiceRequests: Array<typeof serviceRequests.$inferInsert> = [
		{
			trackingNumber: "REQ-2024-001",
			serviceType: "Business Permit",
			description: "All requirements met. Ready for pickup.",
			status: "approved",
			authorId: "seed-user-juan",
			createdAt: new Date("2024-04-10T09:00:00Z"),
			updatedAt: now,
		},
		{
			trackingNumber: "REQ-2024-002",
			serviceType: "Certificate of Residency",
			description: "Waiting for frontline review.",
			status: "pending",
			authorId: "seed-user-maria",
			createdAt: new Date("2024-05-15T11:20:00Z"),
			updatedAt: now,
		},
		{
			trackingNumber: "REQ-2024-003",
			serviceType: "Medical Assistance",
			description: "Verifying hospital documents.",
			status: "in_review",
			authorId: "seed-user-pedro",
			createdAt: new Date("2024-05-20T13:45:00Z"),
			updatedAt: now,
		},
	]

	const seededUserIds = seedUsers.map(user => user.id)
	const seededTicketEmails = seedTickets.map(ticket => ticket.email)
	const seedCredentialAccounts: Array<typeof accounts.$inferInsert> = seedUsers.map(user => ({
		providerId: "credential",
		accountId: user.id,
		userId: user.id,
		password: hashedSeedPassword,
		createdAt: now,
		updatedAt: now,
	}))

	try {
		await db.transaction(async tx => {
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
							updatedAt: now,
						},
					})
			}

			for (const account of seedCredentialAccounts) {
				await tx
					.insert(accounts)
					.values(account)
					.onConflictDoUpdate({
						target: [accounts.providerId, accounts.accountId],
						set: {
							userId: account.userId,
							password: account.password,
							updatedAt: now,
						},
					})
			}

			await tx.delete(todos).where(inArray(todos.authorId, seededUserIds))

			await tx
				.delete(tickets)
				.where(
					or(inArray(tickets.email, seededTicketEmails), inArray(tickets.authorId, seededUserIds))
				)
			await tx.delete(newsArticles).where(inArray(newsArticles.authorId, seededUserIds))
			await tx.delete(citizenReports).where(inArray(citizenReports.authorId, seededUserIds))
			await tx.delete(serviceRequests).where(inArray(serviceRequests.authorId, seededUserIds))
			await tx.delete(emergencyDirectory)
			await tx.delete(departments)

			await tx.insert(departments).values(seedDepartments)
			await tx.insert(todos).values(seedTodos)
			await tx.insert(tickets).values(seedTickets)
			await tx.insert(newsArticles).values(seedNewsArticles)
			await tx.insert(citizenReports).values(seedCitizenReports)
			await tx.insert(serviceRequests).values(seedServiceRequests)
			await tx.insert(emergencyDirectory).values(seedEmergencyDirectory)
		})

		console.log(
			`Seeded ${seedUsers.length} users, ${seedCredentialAccounts.length} credential accounts, ${seedTodos.length} todos, ${seedTickets.length} tickets, ${seedNewsArticles.length} news articles, ${seedCitizenReports.length} reports, and ${seedEmergencyDirectory.length} emergency entries. Default password: ${seedPassword}`
		)
	} finally {
		await pool.end()
	}
}

void seedDatabase().catch(error => {
	console.error("Database seeding failed.")
	console.error(error)
	process.exitCode = 1
})
