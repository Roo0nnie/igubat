"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/core/components/ui/card"
const MOCK_ANNOUNCEMENTS: any[] = [];
import { Badge } from "@/core/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/core/components/ui/table"
import { Button } from "@/core/components/ui/button"
import { Input } from "@/core/components/ui/input"
import { Search, Plus, MoreHorizontal, Edit, Trash, Star } from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/core/components/ui/dropdown-menu"

export function ContentManagement() {
  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-primary">Content Management</h1>
          <p className="text-muted-foreground mt-2">Publish and manage news and announcements.</p>
        </div>
        <Button className="w-full sm:w-auto gap-2">
          <Plus className="h-4 w-4" />
          Create Post
        </Button>
      </div>

      <Card>
        <CardHeader className="pb-3">
          <div className="flex flex-col sm:flex-row justify-between gap-4">
            <div className="flex items-center gap-2 max-w-sm w-full">
              <div className="relative w-full">
                <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  type="search"
                  placeholder="Search articles..."
                  className="pl-8"
                />
              </div>
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
                  <TableHead>Author</TableHead>
                  <TableHead>Date Published</TableHead>
                  <TableHead>Featured</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {MOCK_ANNOUNCEMENTS.map((post) => (
                  <TableRow key={post.id}>
                    <TableCell className="font-medium max-w-[300px] truncate">
                      {post.title}
                    </TableCell>
                    <TableCell>{post.category}</TableCell>
                    <TableCell>{post.author}</TableCell>
                    <TableCell>
                      {new Date(post.datePublished).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      {post.isFeatured ? (
                        <Badge variant="default" className="bg-amber-500 hover:bg-amber-600">
                          <Star className="h-3 w-3 mr-1 fill-current" /> Featured
                        </Badge>
                      ) : (
                        <span className="text-muted-foreground text-sm">No</span>
                      )}
                    </TableCell>
                    <TableCell className="text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" className="h-8 w-8 p-0">
                            <span className="sr-only">Open menu</span>
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Actions</DropdownMenuLabel>
                          <DropdownMenuItem>
                            <Edit className="mr-2 h-4 w-4 text-primary" />
                            Edit Post
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Star className="mr-2 h-4 w-4 text-amber-500" />
                            Toggle Featured
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem className="text-destructive">
                            <Trash className="mr-2 h-4 w-4" />
                            Archive
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
