import { Module } from "@nestjs/common"

import { IgubatController } from "./igubat.controller"
import { IgubatService } from "./igubat.service"
import { TransparencyController } from "./transparency/transparency.controller"
import { TransparencyCron } from "./transparency/transparency.cron"
import { TransparencyService } from "./transparency/transparency.service"

@Module({
	controllers: [IgubatController, TransparencyController],
	providers: [IgubatService, TransparencyService, TransparencyCron],
})
export class IgubatModule {}
