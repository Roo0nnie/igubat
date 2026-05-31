"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/core/components/ui/card"
const MOCK_REPORTS: any[] = [];
import { Badge } from "@/core/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/core/components/ui/table"
import { Button } from "@/core/components/ui/button"
import { Input } from "@/core/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/core/components/ui/select"
import { Search, Filter, MoreHorizontal, Eye, MapPin } from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/core/components/ui/dropdown-menu"

export function ReportsContent() {
  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-primary">Citizen Reports</h1>
          <p className="text-muted-foreground mt-2">Manage and resolve community concerns and issues.</p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        <div className="md:col-span-2">
          <Card>
            <CardHeader className="pb-3">
              <div className="flex flex-col sm:flex-row justify-between gap-4">
                <div className="flex items-center gap-2 max-w-sm w-full">
                  <div className="relative w-full">
                    <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      type="search"
                      placeholder="Search reports..."
                      className="pl-8"
                    />
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Select defaultValue="all">
                    <SelectTrigger className="w-[130px]">
                      <SelectValue placeholder="Status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All</SelectItem>
                      <SelectItem value="received">Received</SelectItem>
                      <SelectItem value="in-progress">In Progress</SelectItem>
                      <SelectItem value="resolved">Resolved</SelectItem>
                    </SelectContent>
                  </Select>
                  <Button variant="outline" size="icon">
                    <Filter className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>ID & Category</TableHead>
                      <TableHead>Location</TableHead>
                      <TableHead>Date</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {MOCK_REPORTS.map((report) => (
                      <TableRow key={report.id}>
                        <TableCell className="font-medium">
                          <div>{report.id}</div>
                          <div className="text-sm text-muted-foreground">{report.category}</div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-1 max-w-[200px]">
                            <MapPin className="h-3 w-3 text-muted-foreground shrink-0" />
                            <span className="truncate" title={report.location}>{report.location}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          {new Date(report.dateSubmitted).toLocaleDateString()}
                        </TableCell>
                        <TableCell>
                          <Badge 
                            variant={report.status === "Resolved" ? "default" : report.status === "Received" ? "outline" : "secondary"}
                            className={report.status === "Resolved" ? "bg-primary" : ""}
                          >
                            {report.status}
                          </Badge>
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
                                <Eye className="mr-2 h-4 w-4" />
                                View Details
                              </DropdownMenuItem>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem>Update Status</DropdownMenuItem>
                              <DropdownMenuItem>Assign Department</DropdownMenuItem>
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
        
        <div>
          <Card className="h-full">
            <CardHeader>
              <CardTitle>Map View</CardTitle>
              <CardDescription>
                Geographic distribution of reports
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="w-full h-[400px] bg-muted rounded-md flex items-center justify-center border relative overflow-hidden">
                <div className="absolute inset-0 opacity-20" style={{
                  backgroundImage: "url('data:image/svg+xml,%3Csvg width=\\'20\\' height=\\'20\\' viewBox=\\'0 0 20 20\\' xmlns=\\'http://www.w3.org/2000/svg\\'%3E%3Cg fill=\\'%239C92AC\\' fill-opacity=\\'0.4\\' fill-rule=\\'evenodd\\'%3E%3Ccircle cx=\\'3\\' cy=\\'3\\' r=\\'3\\'/%3E%3Ccircle cx=\\'13\\' cy=\\'13\\' r=\\'3\\'/%3E%3C/g%3E%3C/svg%3E')",
                }} />
                <div className="z-10 flex flex-col items-center text-muted-foreground gap-2">
                  <MapPin className="h-8 w-8 text-primary/50" />
                  <span>Map integration placeholder</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
