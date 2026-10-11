"use client"

import { useState } from "react"
import { Save } from "lucide-react"

import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/core/components/ui/card"
import { Checkbox } from "@/core/components/ui/checkbox"
import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"
import { TableStateRows } from "@/core/components/ui/loading-state"
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/core/components/ui/table"
import { Textarea } from "@/core/components/ui/textarea"
import {
	useSystemSettingsQuery,
	useUpsertSystemSettingMutation,
} from "@/features/admin-settings/api/settings.hooks"

export function SettingsContent() {
	const settings = useSystemSettingsQuery()
	const upsert = useUpsertSystemSettingMutation()
	const [key, setKey] = useState("application.branding")
	const [category, setCategory] = useState("application")
	const [value, setValue] = useState('{"appName":"iGubat"}')
	const [isSecret, setIsSecret] = useState(false)

	function saveSetting() {
		upsert.mutate({
			key,
			category,
			value: JSON.parse(value) as unknown,
			isSecret,
		})
	}

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div>
				<h1 className="text-primary text-3xl font-bold tracking-tight">System Settings</h1>
				<p className="text-muted-foreground mt-2">
					Configure global application preferences and local integration stubs.
				</p>
			</div>

			<div className="grid gap-6 lg:grid-cols-3">
				<Card className="lg:col-span-2">
					<CardHeader>
						<CardTitle>Settings</CardTitle>
						<CardDescription>Values are stored as structured JSON.</CardDescription>
					</CardHeader>
					<CardContent>
						<div className="rounded-md border">
							<Table>
								<TableHeader>
									<TableRow>
										<TableHead>Key</TableHead>
										<TableHead>Category</TableHead>
										<TableHead>Value</TableHead>
										<TableHead>Secret</TableHead>
										<TableHead className="text-right">Actions</TableHead>
									</TableRow>
								</TableHeader>
								<TableBody>
									<TableStateRows
										colSpan={5}
										isLoading={settings.isLoading}
										isError={settings.isError}
										isEmpty={(settings.data ?? []).length === 0}
										onRetry={() => void settings.refetch()}
										loadingText="Loading settings..."
										errorText="Settings could not be loaded."
										emptyText="No settings saved yet."
										emptyHint="Add one using the editor."
									/>
									{settings.data?.map(setting => (
										<TableRow key={setting.id}>
											<TableCell className="font-medium">{setting.key}</TableCell>
											<TableCell>{setting.category}</TableCell>
											<TableCell className="max-w-[360px] truncate">
												{JSON.stringify(setting.value)}
											</TableCell>
											<TableCell>
												<Badge variant={setting.isSecret ? "destructive" : "outline"}>
													{setting.isSecret ? "Secret" : "Visible"}
												</Badge>
											</TableCell>
											<TableCell className="text-right">
												<Button
													variant="outline"
													size="sm"
													onClick={() => {
														setKey(setting.key)
														setCategory(setting.category)
														setValue(JSON.stringify(setting.value, null, 2))
														setIsSecret(setting.isSecret)
													}}
												>
													Edit
												</Button>
											</TableCell>
										</TableRow>
									))}
								</TableBody>
							</Table>
						</div>
					</CardContent>
				</Card>

				<Card>
					<CardHeader>
						<CardTitle>Edit Setting</CardTitle>
						<CardDescription>Use valid JSON for the setting value.</CardDescription>
					</CardHeader>
					<CardContent className="space-y-4">
						<div className="space-y-2">
							<Label htmlFor="key">Key</Label>
							<Input id="key" value={key} onChange={event => setKey(event.target.value)} />
						</div>
						<div className="space-y-2">
							<Label htmlFor="category">Category</Label>
							<Input
								id="category"
								value={category}
								onChange={event => setCategory(event.target.value)}
							/>
						</div>
						<div className="space-y-2">
							<Label htmlFor="value">Value</Label>
							<Textarea
								id="value"
								value={value}
								onChange={event => setValue(event.target.value)}
								rows={8}
							/>
						</div>
						<label className="flex items-center gap-2 text-sm">
							<Checkbox
								checked={isSecret}
								onCheckedChange={checked => setIsSecret(checked === true)}
							/>
							Secret value
						</label>
						<Button
							disabled={!key || !category}
							loading={upsert.isPending}
							loadingText="Saving..."
							onClick={saveSetting}
						>
							<Save className="size-4" /> Save setting
						</Button>
					</CardContent>
				</Card>
			</div>
		</div>
	)
}
