import { DiscoverGubatDetail } from "@/features/discover-gubat/components/discover-gubat-detail"

export const metadata = {
	title: "Discover Gubat Detail - iGubat",
}

export default async function DiscoverGubatDetailPage({
	params,
}: {
	params: Promise<{ slug: string }>
}) {
	const { slug } = await params
	return <DiscoverGubatDetail slug={slug} />
}
