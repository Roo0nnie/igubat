import { Module } from "@nestjs/common"

import { IgubatController } from "./igubat.controller"
import { IgubatService } from "./igubat.service"

@Module({
	controllers: [IgubatController],
	providers: [IgubatService],
})
export class IgubatModule {}
