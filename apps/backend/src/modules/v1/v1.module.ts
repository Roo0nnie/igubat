import { Module } from "@nestjs/common"

import { ExamplesModule } from "./examples/examples.module"
import { HealthModule } from "./health/health.module"
import { IgubatModule } from "./igubat/igubat.module"
import { TicketsModule } from "./tickets/tickets.module"

@Module({
	imports: [ExamplesModule, HealthModule, TicketsModule, IgubatModule],
})
export class V1Module {}
