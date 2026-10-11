import { Injectable, Logger } from "@nestjs/common"
import { Cron, CronExpression } from "@nestjs/schedule"

import { DiscoverGubatService } from "./discover-gubat.service"

@Injectable()
export class DiscoverGubatCron {
	private readonly logger = new Logger(DiscoverGubatCron.name)

	constructor(private readonly discoverGubatService: DiscoverGubatService) {}

	@Cron(CronExpression.EVERY_MINUTE)
	async promoteDueScheduledEntries() {
		try {
			await this.discoverGubatService.promoteScheduled()
		} catch (error) {
			this.logger.error("Scheduled Discover Gubat publish sweep failed", error)
		}
	}
}
