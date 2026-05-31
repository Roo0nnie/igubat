"use client"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/core/components/ui/card"
const ADMIN_DASHBOARD_STATS = { totalUsers: 0, pendingRequests: 0, activeServices: 0, newReports: 0, publishedAnnouncements: 0 };
const MOCK_REQUESTS: any[] = [];
import { Users, FileText, Activity, AlertTriangle, Newspaper } from "lucide-react"
import { Badge } from "@/core/components/ui/badge"

export function DashboardContent() {
  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-primary">Dashboard</h1>
        <p className="text-muted-foreground mt-2">Welcome back to the iGubat Admin Portal.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-5">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Users</CardTitle>
            <Users className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{ADMIN_DASHBOARD_STATS.totalUsers}</div>
            <p className="text-xs text-muted-foreground">+180 from last month</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pending Requests</CardTitle>
            <FileText className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{ADMIN_DASHBOARD_STATS.pendingRequests}</div>
            <p className="text-xs text-muted-foreground">-4 from yesterday</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Services</CardTitle>
            <Activity className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{ADMIN_DASHBOARD_STATS.activeServices}</div>
            <p className="text-xs text-muted-foreground">All systems operational</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">New Reports</CardTitle>
            <AlertTriangle className="h-4 w-4 text-destructive" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{ADMIN_DASHBOARD_STATS.newReports}</div>
            <p className="text-xs text-muted-foreground">+2 since last login</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Announcements</CardTitle>
            <Newspaper className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{ADMIN_DASHBOARD_STATS.publishedAnnouncements}</div>
            <p className="text-xs text-muted-foreground">Published to app</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="col-span-4">
          <CardHeader>
            <CardTitle>Recent Requests</CardTitle>
            <CardDescription>
              A summary of the latest service requests submitted by citizens.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-8">
              {MOCK_REQUESTS.map((request) => (
                <div key={request.id} className="flex items-center">
                  <div className="space-y-1">
                    <p className="text-sm font-medium leading-none">{request.citizenName}</p>
                    <p className="text-sm text-muted-foreground">
                      {request.serviceType}
                    </p>
                  </div>
                  <div className="ml-auto font-medium">
                    <Badge variant={request.status === "Approved" ? "default" : request.status === "Pending" ? "outline" : "secondary"} className={request.status === "Approved" ? "bg-primary" : ""}>
                      {request.status}
                    </Badge>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
        
        <Card className="col-span-3">
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>
              Common tasks and administrative actions.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="border rounded-lg p-4 flex flex-col items-center justify-center gap-2 cursor-pointer hover:bg-muted transition-colors">
                <Newspaper className="h-6 w-6 text-primary" />
                <span className="text-sm font-medium">Post Update</span>
              </div>
              <div className="border rounded-lg p-4 flex flex-col items-center justify-center gap-2 cursor-pointer hover:bg-muted transition-colors">
                <AlertTriangle className="h-6 w-6 text-destructive" />
                <span className="text-sm font-medium text-center">Broadcast Alert</span>
              </div>
              <div className="border rounded-lg p-4 flex flex-col items-center justify-center gap-2 cursor-pointer hover:bg-muted transition-colors">
                <Users className="h-6 w-6 text-primary" />
                <span className="text-sm font-medium">Verify Users</span>
              </div>
              <div className="border rounded-lg p-4 flex flex-col items-center justify-center gap-2 cursor-pointer hover:bg-muted transition-colors">
                <FileText className="h-6 w-6 text-primary" />
                <span className="text-sm font-medium">Generate Report</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
