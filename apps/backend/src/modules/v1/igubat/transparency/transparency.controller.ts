import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { AllowAnonymous, Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { ApiEndpoint } from "@/common/decorators/api-endpoint.decorator"
import { v1 } from "@/config/api-versions.config"

import { TransparencyService } from "./transparency.service"

function sessionUser(session: UserSession) {
	return session.user as {
		id: string
		name?: string
		email?: string
		role?: string | null
	}
}

@Controller()
export class TransparencyController {
	constructor(private readonly transparencyService: TransparencyService) {}

	@AllowAnonymous()
	@ApiEndpoint({ summary: "List published transparency items" })
	@Implement(v1.igubat.public.transparency.list)
	async publicList() {
		return implement(v1.igubat.public.transparency.list).handler(({ input }) =>
			this.transparencyService.listPublic(input)
		)
	}

	@AllowAnonymous()
	@ApiEndpoint({ summary: "Get a published transparency item by slug" })
	@Implement(v1.igubat.public.transparency.detail)
	async publicItem() {
		return implement(v1.igubat.public.transparency.detail).handler(({ input }) =>
			this.transparencyService.getPublicBySlug(input.slug)
		)
	}

	@ApiEndpoint({ summary: "Export transparency items to CSV" })
	@Implement(v1.igubat.admin.transparency.exportCsv)
	async adminExport(@Session() session: UserSession) {
		return implement(v1.igubat.admin.transparency.exportCsv).handler(({ input }) =>
			this.transparencyService.exportCsv(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "List transparency items for staff" })
	@Implement(v1.igubat.admin.transparency.list)
	async adminList(@Session() session: UserSession) {
		return implement(v1.igubat.admin.transparency.list).handler(({ input }) =>
			this.transparencyService.listAdmin(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "Get a transparency item for staff" })
	@Implement(v1.igubat.admin.transparency.detail)
	async adminItem(@Session() session: UserSession) {
		return implement(v1.igubat.admin.transparency.detail).handler(({ input }) =>
			this.transparencyService.getAdminById(sessionUser(session), input.id)
		)
	}

	@ApiEndpoint({ summary: "Create a transparency item draft" })
	@Implement(v1.igubat.admin.transparency.create)
	async create(@Session() session: UserSession) {
		return implement(v1.igubat.admin.transparency.create).handler(({ input }) =>
			this.transparencyService.create(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "Update a transparency item" })
	@Implement(v1.igubat.admin.transparency.update)
	async update(@Session() session: UserSession) {
		return implement(v1.igubat.admin.transparency.update).handler(({ input }) =>
			this.transparencyService.update(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "Publish or schedule a transparency item" })
	@Implement(v1.igubat.admin.transparency.publish)
	async publish(@Session() session: UserSession) {
		return implement(v1.igubat.admin.transparency.publish).handler(({ input }) =>
			this.transparencyService.publish(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "Archive a transparency item" })
	@Implement(v1.igubat.admin.transparency.archive)
	async archive(@Session() session: UserSession) {
		return implement(v1.igubat.admin.transparency.archive).handler(({ input }) =>
			this.transparencyService.archive(sessionUser(session), input.id)
		)
	}

	@ApiEndpoint({ summary: "Delete a transparency item" })
	@Implement(v1.igubat.admin.transparency.delete)
	async remove(@Session() session: UserSession) {
		return implement(v1.igubat.admin.transparency.delete).handler(({ input }) =>
			this.transparencyService.remove(sessionUser(session), input)
		)
	}
}
