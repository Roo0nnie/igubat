import { Module } from "@nestjs/common"

import { DiscoverGubatController } from "./discover-gubat/discover-gubat.controller"
import { DiscoverGubatCron } from "./discover-gubat/discover-gubat.cron"
import { DiscoverGubatService } from "./discover-gubat/discover-gubat.service"
import { IgubatController } from "./igubat.controller"
import { IgubatService } from "./igubat.service"
import { TransparencyController } from "./transparency/transparency.controller"
import { TransparencyCron } from "./transparency/transparency.cron"
import { TransparencyService } from "./transparency/transparency.service"

@Module({
	controllers: [IgubatController, TransparencyController, DiscoverGubatController],
	providers: [
		IgubatService,
		TransparencyService,
		TransparencyCron,
		DiscoverGubatService,
		DiscoverGubatCron,
	],
})
export class IgubatModule {}
