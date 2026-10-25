import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { AllowAnonymous, Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { v1 } from "@/config/api-versions.config"

import { IgubatService } from "./igubat.service"

function sessionUser(session: UserSession) {
	return session.user as {
		id: string
		name?: string
		email?: string
		role?: string | null
	}
}

@Controller()
export class IgubatController {
	constructor(private readonly igubatService: IgubatService) {}

	@AllowAnonymous()
	@Implement(v1.igubat.public.dashboard)
	async publicDashboard() {
		return implement(v1.igubat.public.dashboard).handler(() => this.igubatService.publicDashboard())
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.news)
	async publicNews() {
		return implement(v1.igubat.public.news).handler(({ input }) =>
			this.igubatService.listNews(input)
		)
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.article)
	async publicArticle() {
		return implement(v1.igubat.public.article).handler(({ input }) =>
			this.igubatService.getArticle(input.slug)
		)
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.placements)
	async publicPlacements() {
		return implement(v1.igubat.public.placements).handler(() => this.igubatService.listPlacements())
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.events)
	async publicEvents() {
		return implement(v1.igubat.public.events).handler(() => this.igubatService.listEvents())
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.event)
	async publicEvent() {
		return implement(v1.igubat.public.event).handler(({ input }) =>
			this.igubatService.getEvent(input.slug)
		)
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.serviceCategories)
	async publicServiceCategories() {
		return implement(v1.igubat.public.serviceCategories).handler(() =>
			this.igubatService.listServiceCategories()
		)
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.services)
	async publicServices() {
		return implement(v1.igubat.public.services).handler(({ input }) =>
			this.igubatService.listServices(input)
		)
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.service)
	async publicService() {
		return implement(v1.igubat.public.service).handler(({ input }) =>
			this.igubatService.getService(input.slug)
		)
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.emergencyDirectory)
	async publicEmergencyDirectory() {
		return implement(v1.igubat.public.emergencyDirectory).handler(() =>
			this.igubatService.listEmergencyDirectory()
		)
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.help)
	async publicHelp() {
		return implement(v1.igubat.public.help).handler(() => this.igubatService.listHelp())
	}

	@AllowAnonymous()
	@Implement(v1.igubat.public.policy)
	async publicPolicy() {
		return implement(v1.igubat.public.policy).handler(({ input }) =>
			this.igubatService.getPolicy(input.slug)
		)
	}

	@Implement(v1.igubat.me.profile)
	async profile(@Session() session: UserSession) {
		return implement(v1.igubat.me.profile).handler(() =>
			this.igubatService.getProfile(sessionUser(session))
		)
	}

	@Implement(v1.igubat.me.updateProfile)
	async updateProfile(@Session() session: UserSession) {
		return implement(v1.igubat.me.updateProfile).handler(({ input }) =>
			this.igubatService.updateProfile(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.me.notificationPreferences)
	async notificationPreferences(@Session() session: UserSession) {
		return implement(v1.igubat.me.notificationPreferences).handler(() =>
			this.igubatService.getNotificationPreferences(sessionUser(session))
		)
	}

	@Implement(v1.igubat.me.updateNotificationPreferences)
	async updateNotificationPreferences(@Session() session: UserSession) {
		return implement(v1.igubat.me.updateNotificationPreferences).handler(({ input }) =>
			this.igubatService.updateNotificationPreferences(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.me.requests)
	async myRequests(@Session() session: UserSession) {
		return implement(v1.igubat.me.requests).handler(() =>
			this.igubatService.listMyRequests(sessionUser(session))
		)
	}

	@Implement(v1.igubat.me.request)
	async myRequest(@Session() session: UserSession) {
		return implement(v1.igubat.me.request).handler(({ input }) =>
			this.igubatService.getRequestDetail(input.id, sessionUser(session))
		)
	}

	@Implement(v1.igubat.me.createRequest)
	async createRequest(@Session() session: UserSession) {
		return implement(v1.igubat.me.createRequest).handler(({ input }) =>
			this.igubatService.createRequest(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.me.cancelRequest)
	async cancelRequest(@Session() session: UserSession) {
		return implement(v1.igubat.me.cancelRequest).handler(({ input }) =>
			this.igubatService.cancelRequest(sessionUser(session), input.id)
		)
	}

	@Implement(v1.igubat.me.reports)
	async myReports(@Session() session: UserSession) {
		return implement(v1.igubat.me.reports).handler(() =>
			this.igubatService.listMyReports(sessionUser(session))
		)
	}

	@Implement(v1.igubat.me.report)
	async myReport(@Session() session: UserSession) {
		return implement(v1.igubat.me.report).handler(({ input }) =>
			this.igubatService.getReportDetail(input.id, sessionUser(session))
		)
	}

	@Implement(v1.igubat.me.createReport)
	async createReport(@Session() session: UserSession) {
		return implement(v1.igubat.me.createReport).handler(({ input }) =>
			this.igubatService.createReport(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.me.notifications)
	async myNotifications(@Session() session: UserSession) {
		return implement(v1.igubat.me.notifications).handler(() =>
			this.igubatService.listNotifications(sessionUser(session))
		)
	}

	@Implement(v1.igubat.me.markNotificationRead)
	async markNotificationRead(@Session() session: UserSession) {
		return implement(v1.igubat.me.markNotificationRead).handler(({ input }) =>
			this.igubatService.markNotificationRead(sessionUser(session), input.id)
		)
	}

	@Implement(v1.igubat.me.markAllNotificationsRead)
	async markAllNotificationsRead(@Session() session: UserSession) {
		return implement(v1.igubat.me.markAllNotificationsRead).handler(() =>
			this.igubatService.markAllNotificationsRead(sessionUser(session))
		)
	}

	@Implement(v1.igubat.admin.dashboard)
	async adminDashboard(@Session() session: UserSession) {
		return implement(v1.igubat.admin.dashboard).handler(() =>
			this.igubatService.adminDashboard(sessionUser(session))
		)
	}

	@Implement(v1.igubat.admin.requests)
	async adminRequests(@Session() session: UserSession) {
		return implement(v1.igubat.admin.requests).handler(({ input }) =>
			this.igubatService.listAdminRequests(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.request)
	async adminRequest(@Session() session: UserSession) {
		return implement(v1.igubat.admin.request).handler(({ input }) =>
			this.igubatService.getRequestDetail(input.id, sessionUser(session), true)
		)
	}

	@Implement(v1.igubat.admin.updateRequestStatus)
	async updateRequestStatus(@Session() session: UserSession) {
		return implement(v1.igubat.admin.updateRequestStatus).handler(({ input }) =>
			this.igubatService.updateRequestStatus(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.reports)
	async adminReports(@Session() session: UserSession) {
		return implement(v1.igubat.admin.reports).handler(({ input }) =>
			this.igubatService.listAdminReports(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.report)
	async adminReport(@Session() session: UserSession) {
		return implement(v1.igubat.admin.report).handler(({ input }) =>
			this.igubatService.getReportDetail(input.id, sessionUser(session), true)
		)
	}

	@Implement(v1.igubat.admin.updateReportStatus)
	async updateReportStatus(@Session() session: UserSession) {
		return implement(v1.igubat.admin.updateReportStatus).handler(({ input }) =>
			this.igubatService.updateReportStatus(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.articles)
	async adminArticles(@Session() session: UserSession) {
		return implement(v1.igubat.admin.articles).handler(({ input }) =>
			this.igubatService.listAdminArticles(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.article)
	async adminArticle(@Session() session: UserSession) {
		return implement(v1.igubat.admin.article).handler(({ input }) =>
			this.igubatService.getAdminArticle(sessionUser(session), input.id)
		)
	}

	@Implement(v1.igubat.admin.upsertArticle)
	async upsertArticle(@Session() session: UserSession) {
		return implement(v1.igubat.admin.upsertArticle).handler(({ input }) =>
			this.igubatService.upsertArticle(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.events)
	async adminEvents(@Session() session: UserSession) {
		return implement(v1.igubat.admin.events).handler(({ input }) =>
			this.igubatService.listAdminEvents(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.event)
	async adminEvent(@Session() session: UserSession) {
		return implement(v1.igubat.admin.event).handler(({ input }) =>
			this.igubatService.getAdminEvent(sessionUser(session), input.id)
		)
	}

	@Implement(v1.igubat.admin.upsertEvent)
	async upsertEvent(@Session() session: UserSession) {
		return implement(v1.igubat.admin.upsertEvent).handler(({ input }) =>
			this.igubatService.upsertEvent(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.deleteEvent)
	async deleteEvent(@Session() session: UserSession) {
		return implement(v1.igubat.admin.deleteEvent).handler(({ input }) =>
			this.igubatService.deleteEvent(sessionUser(session), input.id)
		)
	}

	@Implement(v1.igubat.admin.communityStats)
	async adminCommunityStats(@Session() session: UserSession) {
		return implement(v1.igubat.admin.communityStats).handler(() =>
			this.igubatService.getAdminCommunityStats(sessionUser(session))
		)
	}

	@Implement(v1.igubat.admin.updateCommunityStats)
	async updateCommunityStats(@Session() session: UserSession) {
		return implement(v1.igubat.admin.updateCommunityStats).handler(({ input }) =>
			this.igubatService.updateCommunityStats(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.emergencyDirectory)
	async adminEmergencyDirectory(@Session() session: UserSession) {
		return implement(v1.igubat.admin.emergencyDirectory).handler(() =>
			this.igubatService.listAdminEmergencyDirectory(sessionUser(session))
		)
	}

	@Implement(v1.igubat.admin.upsertDirectoryEntry)
	async upsertDirectoryEntry(@Session() session: UserSession) {
		return implement(v1.igubat.admin.upsertDirectoryEntry).handler(({ input }) =>
			this.igubatService.upsertDirectoryEntry(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.broadcasts)
	async broadcasts(@Session() session: UserSession) {
		return implement(v1.igubat.admin.broadcasts).handler(({ input }) =>
			this.igubatService.listBroadcasts(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.createBroadcast)
	async createBroadcast(@Session() session: UserSession) {
		return implement(v1.igubat.admin.createBroadcast).handler(({ input }) =>
			this.igubatService.createBroadcast(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.citizens)
	async citizens(@Session() session: UserSession) {
		return implement(v1.igubat.admin.citizens).handler(({ input }) =>
			this.igubatService.listCitizens(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.citizen)
	async citizen(@Session() session: UserSession) {
		return implement(v1.igubat.admin.citizen).handler(({ input }) =>
			this.igubatService.getCitizen(sessionUser(session), input.id)
		)
	}

	@Implement(v1.igubat.admin.staff)
	async staff(@Session() session: UserSession) {
		return implement(v1.igubat.admin.staff).handler(({ input }) =>
			this.igubatService.listStaff(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.createStaff)
	async createStaff(@Session() session: UserSession) {
		return implement(v1.igubat.admin.createStaff).handler(({ input }) =>
			this.igubatService.createStaff(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.analytics)
	async analytics(@Session() session: UserSession) {
		return implement(v1.igubat.admin.analytics).handler(() =>
			this.igubatService.analytics(sessionUser(session))
		)
	}

	@Implement(v1.igubat.admin.auditLogs)
	async auditLogs(@Session() session: UserSession) {
		return implement(v1.igubat.admin.auditLogs).handler(({ input }) =>
			this.igubatService.listAuditLogs(sessionUser(session), input)
		)
	}

	@Implement(v1.igubat.admin.settings)
	async settings(@Session() session: UserSession) {
		return implement(v1.igubat.admin.settings).handler(() =>
			this.igubatService.listSettings(sessionUser(session))
		)
	}

	@Implement(v1.igubat.admin.upsertSetting)
	async upsertSetting(@Session() session: UserSession) {
		return implement(v1.igubat.admin.upsertSetting).handler(({ input }) =>
			this.igubatService.upsertSetting(sessionUser(session), input)
		)
	}
}
