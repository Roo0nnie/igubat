"use client"

import { useState } from "react"
import { Edit, ImageIcon, Plus, Save, Search, Star } from "lucide-react"

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
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/core/components/ui/select"
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
	useAdminArticlesQuery,
	useUpsertArticleMutation,
} from "@/features/admin-content/api/content.hooks"

const STATUS_OPTIONS = ["draft", "published", "archived"] as const

type ArticleForm = {
	id?: number
	title: string
	slug: string
	excerpt: string
	category: string
	body: string
	status: (typeof STATUS_OPTIONS)[number]
	imageUrl: string
	isFeatured: boolean
}

const emptyForm: ArticleForm = {
	title: "",
	slug: "",
	excerpt: "",
	category: "Announcement",
	body: "",
	status: "draft",
	imageUrl: "/images/placeholders/news-business-permit.png",
	isFeatured: false,
}

function slugify(value: string) {
	return value
		.toLowerCase()
		.replace(/[^a-z0-9]+/g, "-")
		.replace(/^-|-$/g, "")
}

function formatDate(value: string | Date | null) {
	if (!value) return "Not published"
	return new Date(value).toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		year: "numeric",
	})
}

export function ContentManagement() {
	const [search, setSearch] = useState("")
	const [form, setForm] = useState<ArticleForm>(emptyForm)
	const articles = useAdminArticlesQuery({ search: search.trim() || undefined })
	const upsertArticle = useUpsertArticleMutation()

	function submitForm() {
		upsertArticle.mutate({
			...form,
			excerpt: form.excerpt || undefined,
			imageUrl: form.imageUrl || undefined,
		})
	}

	return (
		<div className="mx-auto max-w-7xl space-y-6 p-6 md:p-8">
			<div className="flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
				<div>
					<h1 className="text-primary text-3xl font-bold tracking-tight">Content Management</h1>
					<p className="text-muted-foreground mt-2">
						Publish news, announcements, carousel content, and media references.
					</p>
				</div>
				<Button onClick={() => setForm(emptyForm)}>
					<Plus className="size-4" /> New post
				</Button>
			</div>

			<div className="grid gap-6 lg:grid-cols-5">
				<Card className="lg:col-span-3">
					<CardHeader className="pb-3">
						<div className="flex flex-col justify-between gap-4 sm:flex-row">
							<div>
								<CardTitle>News & Announcements</CardTitle>
								<CardDescription>
									Clickable rows can be edited in the panel beside the table.
								</CardDescription>
							</div>
							<div className="relative w-full max-w-sm">
								<Search className="text-muted-foreground absolute top-2.5 left-2.5 size-4" />
								<Input
									type="search"
									placeholder="Search articles..."
									className="pl-8"
									value={search}
									onChange={event => setSearch(event.target.value)}
								/>
							</div>
						</div>
					</CardHeader>
					<CardContent>
						<div className="rounded-md border">
							<Table>
								<TableHeader>
									<TableRow>
										<TableHead>Title</TableHead>
										<TableHead>Category</TableHead>
										<TableHead>Status</TableHead>
										<TableHead>Published</TableHead>
										<TableHead>Featured</TableHead>
										<TableHead className="text-right">Actions</TableHead>
									</TableRow>
								</TableHeader>
								<TableBody>
									{articles.isLoading && (
										<TableRow>
											<TableCell colSpan={6} className="text-muted-foreground h-24 text-center">
												Loading content...
											</TableCell>
										</TableRow>
									)}
									{articles.isError && (
										<TableRow>
											<TableCell colSpan={6} className="text-destructive h-24 text-center">
												Content could not be loaded.
											</TableCell>
										</TableRow>
									)}
									{!articles.isLoading &&
										!articles.isError &&
										(articles.data ?? []).length === 0 && (
											<TableRow>
												<TableCell colSpan={6} className="text-muted-foreground h-24 text-center">
													No articles found.
												</TableCell>
											</TableRow>
										)}
									{articles.data?.map(article => (
										<TableRow key={article.id}>
											<TableCell className="max-w-[300px] font-medium">
												<div className="truncate">{article.title}</div>
												<div className="text-muted-foreground truncate text-xs">{article.slug}</div>
											</TableCell>
											<TableCell>{article.category}</TableCell>
											<TableCell>
												<Badge
													variant={
														article.status === "published"
															? "default"
															: article.status === "archived"
																? "secondary"
																: "outline"
													}
												>
													{article.status}
												</Badge>
											</TableCell>
											<TableCell>{formatDate(article.publishedAt)}</TableCell>
											<TableCell>
												{article.isFeatured ? (
													<Badge variant="default" className="bg-amber-500 hover:bg-amber-600">
														<Star className="mr-1 size-3 fill-current" /> Featured
													</Badge>
												) : (
													<span className="text-muted-foreground text-sm">No</span>
												)}
											</TableCell>
											<TableCell className="text-right">
												<Button
													variant="outline"
													size="sm"
													onClick={() =>
														setForm({
															id: article.id,
															title: article.title,
															slug: article.slug ?? "",
															excerpt: article.excerpt ?? "",
															category: article.category,
															body: article.body,
															status: article.status,
															imageUrl: article.imageUrl ?? "",
															isFeatured: article.isFeatured,
														})
													}
												>
													<Edit className="size-4" /> Edit
												</Button>
											</TableCell>
										</TableRow>
									))}
								</TableBody>
							</Table>
						</div>
					</CardContent>
				</Card>

				<Card className="lg:col-span-2">
					<CardHeader>
						<CardTitle>{form.id ? "Edit Post" : "Create Post"}</CardTitle>
						<CardDescription>
							Saved posts are available to the mobile app and portal content lists.
						</CardDescription>
					</CardHeader>
					<CardContent className="space-y-4">
						<div className="space-y-2">
							<Label htmlFor="title">Title</Label>
							<Input
								id="title"
								value={form.title}
								onChange={event => {
									const title = event.target.value
									setForm(current => ({
										...current,
										title,
										slug:
											!current.id && (!current.slug || current.slug === slugify(current.title))
												? slugify(title)
												: current.slug,
									}))
								}}
							/>
						</div>
						<div className="grid gap-4 md:grid-cols-2">
							<div className="space-y-2">
								<Label htmlFor="slug">Slug</Label>
								<Input
									id="slug"
									value={form.slug}
									onChange={event =>
										setForm(current => ({ ...current, slug: slugify(event.target.value) }))
									}
								/>
							</div>
							<div className="space-y-2">
								<Label htmlFor="category">Category</Label>
								<Input
									id="category"
									value={form.category}
									onChange={event =>
										setForm(current => ({ ...current, category: event.target.value }))
									}
								/>
							</div>
						</div>
						<div className="space-y-2">
							<Label>Status</Label>
							<Select
								value={form.status}
								onValueChange={value =>
									setForm(current => ({ ...current, status: value as ArticleForm["status"] }))
								}
							>
								<SelectTrigger className="w-full">
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{STATUS_OPTIONS.map(option => (
										<SelectItem key={option} value={option}>
											{option}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</div>
						<div className="space-y-2">
							<Label htmlFor="excerpt">Excerpt</Label>
							<Textarea
								id="excerpt"
								value={form.excerpt}
								onChange={event =>
									setForm(current => ({ ...current, excerpt: event.target.value }))
								}
								rows={3}
							/>
						</div>
						<div className="space-y-2">
							<Label htmlFor="body">Body</Label>
							<Textarea
								id="body"
								value={form.body}
								onChange={event => setForm(current => ({ ...current, body: event.target.value }))}
								rows={8}
							/>
						</div>
						<div className="space-y-2">
							<Label htmlFor="image-url">Image URL</Label>
							<div className="flex gap-2">
								<Input
									id="image-url"
									value={form.imageUrl}
									onChange={event =>
										setForm(current => ({ ...current, imageUrl: event.target.value }))
									}
								/>
								<Button variant="outline" size="icon" aria-label="Media reference">
									<ImageIcon className="size-4" />
								</Button>
							</div>
						</div>
						<label className="flex items-center gap-2 text-sm">
							<Checkbox
								checked={form.isFeatured}
								onCheckedChange={checked =>
									setForm(current => ({ ...current, isFeatured: checked === true }))
								}
							/>
							Featured carousel/banner item
						</label>
						<Button
							disabled={upsertArticle.isPending || !form.title || !form.slug || !form.body}
							onClick={submitForm}
						>
							<Save className="size-4" /> {upsertArticle.isPending ? "Saving..." : "Save post"}
						</Button>
					</CardContent>
				</Card>
			</div>
		</div>
	)
}
