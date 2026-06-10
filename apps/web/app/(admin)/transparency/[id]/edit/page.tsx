import { TransparencyManagement } from "@/features/admin-transparency/components/transparency-management"

export const metadata = {
	title: "Edit Transparency Item - iGubat",
}

export default async function EditTransparencyPage({
	params,
}: {
	params: Promise<{ id: string }>
}) {
	const { id } = await params
	return <TransparencyManagement initialItemId={Number(id)} />
}
