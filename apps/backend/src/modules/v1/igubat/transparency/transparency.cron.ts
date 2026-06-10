import { Injectable, Logger } from "@nestjs/common"
import { Cron, CronExpression } from "@nestjs/schedule"

import { TransparencyService } from "./transparency.service"

@Injectable()
export class TransparencyCron {
	private readonly logger = new Logger(TransparencyCron.name)

	constructor(private readonly transparencyService: TransparencyService) {}

	@Cron(CronExpression.EVERY_MINUTE)
	async promoteDueScheduledItems() {
		try {
			await this.transparencyService.promoteScheduled()
		} catch (error) {
			this.logger.error("Scheduled transparency publish sweep failed", error)
		}
	}
}
