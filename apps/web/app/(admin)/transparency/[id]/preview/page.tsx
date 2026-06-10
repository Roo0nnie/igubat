import { TransparencyManagement } from "@/features/admin-transparency/components/transparency-management"

export const metadata = {
	title: "Preview Transparency Item - iGubat",
}

export default async function PreviewTransparencyPage({
	params,
}: {
	params: Promise<{ id: string }>
}) {
	const { id } = await params
	return <TransparencyManagement initialItemId={Number(id)} initialPreview />
}
