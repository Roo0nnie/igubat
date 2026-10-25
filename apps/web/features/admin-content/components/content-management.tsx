"use client"

import { useState } from "react"
import { useQueryClient } from "@tanstack/react-query"
import { Edit, ImageIcon, Plus, Save, Search, Star } from "lucide-react"
import { toast } from "sonner"

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
import { TablePagination } from "@/core/components/ui/table-pagination"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/core/components/ui/tabs"
import { Textarea } from "@/core/components/ui/textarea"
import { useDebouncedValue } from "@/core/hooks/use-debounced-value"
import { orpc } from "@/services/orpc/client"
import {
	useAdminArticlesQuery,
	useUpsertArticleMutation,
} from "@/features/admin-content/api/content.hooks"
import { CommunityStatsSettings } from "@/features/admin-content/components/community-stats-settings"
import { EventsManagement } from "@/features/admin-events/components/events-management"

const PAGE_SIZE = 25

const STATUS_OPTIONS = ["draft", "scheduled", "published", "archived"] as const

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
	const queryClient = useQueryClient()
	const [search, setSearch] = useState("")
	const [page, setPage] = useState(1)
	const [loadingArticleId, setLoadingArticleId] = useState<number | undefined>()
	const [form, setForm] = useState<ArticleForm>(emptyForm)
	const debouncedSearch = useDebouncedValue(search.trim())
	const articles = useAdminArticlesQuery({
		search: debouncedSearch || undefined,
		page,
		limit: PAGE_SIZE,
	})
	const fetchedArticles = articles.data ?? []
	const articleRows = fetchedArticles.slice(0, PAGE_SIZE)
	const upsertArticle = useUpsertArticleMutation()

	async function editArticle(id: number) {
		setLoadingArticleId(id)
		try {
			const article = await queryClient.fetchQuery({
				...orpc.igubat.admin.article.queryOptions({ input: { id } }),
				staleTime: 60_000,
			})
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
		} catch (error) {
			toast.error(error instanceof Error ? error.message : "Article could not be loaded.")
		} finally {
			setLoadingArticleId(undefined)
		}
	}

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
						Manage everything citizens see on the mobile Home: news, events and community stats.
					</p>
				</div>
			</div>

			<Tabs defaultValue="news" className="space-y-4">
				<TabsList>
					<TabsTrigger value="news">News & Announcements</TabsTrigger>
					<TabsTrigger value="events">Events</TabsTrigger>
					<TabsTrigger value="stats">Community Stats</TabsTrigger>
				</TabsList>
				<TabsContent value="events">
					<EventsManagement />
				</TabsContent>
				<TabsContent value="stats">
					<CommunityStatsSettings />
				</TabsContent>
				<TabsContent value="news" className="space-y-4">
					<div className="flex justify-end">
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
											onChange={event => {
												setSearch(event.target.value)
												setPage(1)
											}}
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
											<TableStateRows
												colSpan={6}
												isLoading={articles.isLoading}
												isError={articles.isError}
												isEmpty={articleRows.length === 0}
												onRetry={() => void articles.refetch()}
												loadingText="Loading news and announcements..."
												errorText="Content could not be loaded."
												emptyText="No articles found."
												emptyHint="Write your first post using the editor."
											/>
											{articleRows.map(article => (
												<TableRow key={article.id}>
													<TableCell className="max-w-[300px] font-medium">
														<div className="truncate">{article.title}</div>
														<div className="text-muted-foreground truncate text-xs">
															{article.slug}
														</div>
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
															disabled={loadingArticleId !== undefined}
															loading={loadingArticleId === article.id}
															onClick={() => void editArticle(article.id)}
														>
															<Edit className="size-4" /> Edit
														</Button>
													</TableCell>
												</TableRow>
											))}
										</TableBody>
									</Table>
								</div>
								<TablePagination
									page={page}
									pageSize={PAGE_SIZE}
									rowCount={fetchedArticles.length}
									onPageChange={setPage}
								/>
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
										onChange={event =>
											setForm(current => ({ ...current, body: event.target.value }))
										}
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
									Featured article
								</label>
								<p className="text-muted-foreground -mt-2 text-xs">
									The featured article is shown on the mobile Home under Featured Community News
									(the most recently published featured article wins).
								</p>
								<Button
									disabled={!form.title || !form.slug || !form.body}
									loading={upsertArticle.isPending}
									loadingText="Saving post..."
									onClick={submitForm}
								>
									<Save className="size-4" /> Save post
								</Button>
							</CardContent>
						</Card>
					</div>
				</TabsContent>
			</Tabs>
		</div>
	)
}
