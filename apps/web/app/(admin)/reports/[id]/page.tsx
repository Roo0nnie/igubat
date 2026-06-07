import { ReportDetailContent } from "@/features/admin-reports/components/report-detail-content"

export const metadata = {
	title: "Citizen Report Detail - iGubat",
}

export default async function ReportDetailPage({ params }: { params: Promise<{ id: string }> }) {
	const { id } = await params
	return <ReportDetailContent id={Number(id)} />
}
