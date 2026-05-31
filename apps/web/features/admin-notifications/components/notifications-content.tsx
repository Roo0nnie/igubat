"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/core/components/ui/card"
const MOCK_NOTIFICATIONS: any[] = [];
import { Badge } from "@/core/components/ui/badge"
import { Button } from "@/core/components/ui/button"
import { Input } from "@/core/components/ui/input"
import { Label } from "@/core/components/ui/label"
import { Textarea } from "@/core/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/core/components/ui/select"
import { Bell, AlertTriangle, Send } from "lucide-react"

export function NotificationsContent() {
  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-primary">Alerts & Notifications</h1>
          <p className="text-muted-foreground mt-2">Manage system notifications and send emergency broadcasts.</p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card className="flex flex-col">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-destructive" />
              Send Broadcast Alert
            </CardTitle>
            <CardDescription>
              Push a notification to all registered citizens immediately.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4 flex-1">
            <div className="space-y-2">
              <Label htmlFor="title">Alert Title</Label>
              <Input id="title" placeholder="e.g. Typhoon Warning Signal No. 3" />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="level">Severity Level</Label>
              <Select defaultValue="info">
                <SelectTrigger id="level">
                  <SelectValue placeholder="Select severity" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="info">Information (Standard)</SelectItem>
                  <SelectItem value="warning">Warning (Important)</SelectItem>
                  <SelectItem value="critical">Critical (Emergency)</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="message">Message Content</Label>
              <Textarea 
                id="message" 
                placeholder="Enter the detailed alert message..." 
                className="min-h-[120px]"
              />
            </div>
          </CardContent>
          <CardFooter>
            <Button className="w-full gap-2" variant="destructive">
              <Send className="h-4 w-4" />
              Send Broadcast Now
            </Button>
          </CardFooter>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Bell className="h-5 w-5 text-primary" />
              Recent Broadcasts
            </CardTitle>
            <CardDescription>
              History of alerts sent from the system.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {MOCK_NOTIFICATIONS.filter(n => n.type === "Emergency").map((notif) => (
                <div key={notif.id} className="border rounded-lg p-4 space-y-2">
                  <div className="flex justify-between items-start gap-2">
                    <h4 className="font-semibold">{notif.title}</h4>
                    <Badge variant={notif.level === "Critical" ? "destructive" : "default"}>
                      {notif.level}
                    </Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">{notif.message}</p>
                  <div className="text-xs text-muted-foreground pt-2">
                    Sent on {new Date(notif.dateSent).toLocaleString()}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
