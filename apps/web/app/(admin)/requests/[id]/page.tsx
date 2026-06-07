import { RequestDetailContent } from "@/features/admin-requests/components/request-detail-content"

export const metadata = {
	title: "Service Request Detail - iGubat",
}

export default async function RequestDetailPage({ params }: { params: Promise<{ id: string }> }) {
	const { id } = await params
	return <RequestDetailContent id={Number(id)} />
}
