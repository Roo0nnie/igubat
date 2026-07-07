import { Controller } from "@nestjs/common"
import { Implement } from "@orpc/nest"
import { implement } from "@orpc/server"
import { AllowAnonymous, Session, type UserSession } from "@thallesp/nestjs-better-auth"

import { ApiEndpoint } from "@/common/decorators/api-endpoint.decorator"
import { v1 } from "@/config/api-versions.config"

import { DiscoverGubatService } from "./discover-gubat.service"

function sessionUser(session: UserSession) {
	return session.user as {
		id: string
		name?: string
		email?: string
		role?: string | null
	}
}

@Controller()
export class DiscoverGubatController {
	constructor(private readonly discoverGubatService: DiscoverGubatService) {}

	@AllowAnonymous()
	@ApiEndpoint({ summary: "List published Discover Gubat entries" })
	@Implement(v1.igubat.public.discoverGubat.list)
	async publicList() {
		return implement(v1.igubat.public.discoverGubat.list).handler(({ input }) =>
			this.discoverGubatService.listPublic(input)
		)
	}

	@AllowAnonymous()
	@ApiEndpoint({ summary: "Get a published Discover Gubat entry by slug" })
	@Implement(v1.igubat.public.discoverGubat.detail)
	async publicItem() {
		return implement(v1.igubat.public.discoverGubat.detail).handler(({ input }) =>
			this.discoverGubatService.getPublicBySlug(input.slug)
		)
	}

	@ApiEndpoint({ summary: "List Discover Gubat entries for staff" })
	@Implement(v1.igubat.admin.discoverGubat.list)
	async adminList(@Session() session: UserSession) {
		return implement(v1.igubat.admin.discoverGubat.list).handler(({ input }) =>
			this.discoverGubatService.listAdmin(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "Get a Discover Gubat entry for staff" })
	@Implement(v1.igubat.admin.discoverGubat.detail)
	async adminItem(@Session() session: UserSession) {
		return implement(v1.igubat.admin.discoverGubat.detail).handler(({ input }) =>
			this.discoverGubatService.getAdminById(sessionUser(session), input.id)
		)
	}

	@ApiEndpoint({ summary: "Create a Discover Gubat entry draft" })
	@Implement(v1.igubat.admin.discoverGubat.create)
	async create(@Session() session: UserSession) {
		return implement(v1.igubat.admin.discoverGubat.create).handler(({ input }) =>
			this.discoverGubatService.create(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "Update a Discover Gubat entry" })
	@Implement(v1.igubat.admin.discoverGubat.update)
	async update(@Session() session: UserSession) {
		return implement(v1.igubat.admin.discoverGubat.update).handler(({ input }) =>
			this.discoverGubatService.update(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "Publish or schedule a Discover Gubat entry" })
	@Implement(v1.igubat.admin.discoverGubat.publish)
	async publish(@Session() session: UserSession) {
		return implement(v1.igubat.admin.discoverGubat.publish).handler(({ input }) =>
			this.discoverGubatService.publish(sessionUser(session), input)
		)
	}

	@ApiEndpoint({ summary: "Archive a Discover Gubat entry" })
	@Implement(v1.igubat.admin.discoverGubat.archive)
	async archive(@Session() session: UserSession) {
		return implement(v1.igubat.admin.discoverGubat.archive).handler(({ input }) =>
			this.discoverGubatService.archive(sessionUser(session), input.id)
		)
	}

	@ApiEndpoint({ summary: "Delete a Discover Gubat entry" })
	@Implement(v1.igubat.admin.discoverGubat.delete)
	async remove(@Session() session: UserSession) {
		return implement(v1.igubat.admin.discoverGubat.delete).handler(({ input }) =>
			this.discoverGubatService.remove(sessionUser(session), input)
		)
	}
}
