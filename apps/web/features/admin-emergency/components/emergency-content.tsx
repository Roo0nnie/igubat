"use client"

import { useState } from "react"
import { Phone, Radio, History, Plus, Send, AlertCircle } from "lucide-react"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/core/components/ui/card"
import { Button } from "@/core/components/ui/button"
import { Input } from "@/core/components/ui/input"
import { Textarea } from "@/core/components/ui/textarea"
import { Badge } from "@/core/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/core/components/ui/tabs"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/core/components/ui/table"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/core/components/ui/alert-dialog"
import { useRole } from "@/core/context/role-provider"

const MAX_BROADCAST_LENGTH = 480

type DirectoryEntry = {
  id: number
  name: string
  category: string
  contact: string
  address: string
  isActive: boolean
}

type Broadcast = {
  id: number
  message: string
  sender: string
  sentAt: string
  recipients: number
  status: string
}

const MOCK_DIRECTORY: DirectoryEntry[] = []
const MOCK_BROADCASTS: Broadcast[] = []

export function EmergencyContent() {
  const { isAdmin } = useRole()
  const [message, setMessage] = useState("")

  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-primary">Emergency</h1>
        <p className="text-muted-foreground mt-2">
          Manage the COMCEN directory and dispatch emergency broadcasts to citizens.
        </p>
      </div>

      <Tabs defaultValue="directory">
        <TabsList>
          <TabsTrigger value="directory">
            <Phone className="mr-2 h-4 w-4" /> Directory
          </TabsTrigger>
          <TabsTrigger value="broadcast">
            <Radio className="mr-2 h-4 w-4" /> Compose Broadcast
          </TabsTrigger>
          <TabsTrigger value="history">
            <History className="mr-2 h-4 w-4" /> History
          </TabsTrigger>
        </TabsList>

        {/* Step 5a — COMCEN Hotlines and Directory */}
        <TabsContent value="directory" className="mt-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <div>
                <CardTitle>COMCEN & Directory</CardTitle>
                <CardDescription>
                  Hospitals, BFP, PNP, Disaster and COMCEN hotlines. Changes propagate to the mobile app.
                </CardDescription>
              </div>
              <Button>
                <Plus className="mr-2 h-4 w-4" /> Add Entry
              </Button>
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Name</TableHead>
                      <TableHead>Category</TableHead>
                      <TableHead>Contact</TableHead>
                      <TableHead>Address</TableHead>
                      <TableHead>Status</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {MOCK_DIRECTORY.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={5} className="h-24 text-center text-muted-foreground">
                          No directory entries yet.
                        </TableCell>
                      </TableRow>
                    ) : (
                      MOCK_DIRECTORY.map((entry) => (
                        <TableRow key={entry.id}>
                          <TableCell className="font-medium">{entry.name}</TableCell>
                          <TableCell>{entry.category}</TableCell>
                          <TableCell>{entry.contact}</TableCell>
                          <TableCell>{entry.address}</TableCell>
                          <TableCell>
                            <Badge variant={entry.isActive ? "default" : "secondary"} className={entry.isActive ? "bg-primary" : ""}>
                              {entry.isActive ? "Active" : "Inactive"}
                            </Badge>
                          </TableCell>
                        </TableRow>
                      ))
                    )}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Step 5b — Compose Broadcast */}
        <TabsContent value="broadcast" className="mt-4">
          <Card>
            <CardHeader>
              <CardTitle>Compose Broadcast</CardTitle>
              <CardDescription>
                High-priority push to all opted-in citizens. Sending requires explicit confirmation.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Textarea
                  placeholder="Emergency message body..."
                  value={message}
                  maxLength={MAX_BROADCAST_LENGTH}
                  onChange={(e) => setMessage(e.target.value)}
                  rows={5}
                />
                <p className="text-right text-xs text-muted-foreground">
                  {message.length}/{MAX_BROADCAST_LENGTH}
                </p>
              </div>
              <div className="flex flex-wrap items-center gap-3">
                <Input type="datetime-local" className="w-auto" aria-label="Schedule date and time" />
                <AlertDialog>
                  <AlertDialogTrigger asChild>
                    <Button disabled={message.trim().length === 0}>
                      <Send className="mr-2 h-4 w-4" /> Send Broadcast
                    </Button>
                  </AlertDialogTrigger>
                  <AlertDialogContent>
                    <AlertDialogHeader>
                      <AlertDialogTitle className="flex items-center gap-2">
                        <AlertCircle className="h-5 w-5 text-destructive" /> Confirm Emergency Broadcast
                      </AlertDialogTitle>
                      <AlertDialogDescription>
                        This dispatches a high-priority push notification to all opted-in citizens.
                        This action cannot be undone.
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                      <AlertDialogCancel>Cancel</AlertDialogCancel>
                      <AlertDialogAction>Confirm & Send</AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Step 5c — Broadcast History */}
        <TabsContent value="history" className="mt-4">
          <Card>
            <CardHeader>
              <CardTitle>Broadcast History</CardTitle>
              <CardDescription>All sent broadcasts with delivery summary.</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Message</TableHead>
                      <TableHead>Sender</TableHead>
                      <TableHead>Sent</TableHead>
                      <TableHead>Recipients</TableHead>
                      <TableHead>Status</TableHead>
                      {isAdmin && <TableHead className="text-right">Actions</TableHead>}
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {MOCK_BROADCASTS.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={isAdmin ? 6 : 5} className="h-24 text-center text-muted-foreground">
                          No broadcasts sent yet.
                        </TableCell>
                      </TableRow>
                    ) : (
                      MOCK_BROADCASTS.map((b) => (
                        <TableRow key={b.id}>
                          <TableCell className="max-w-xs truncate">{b.message}</TableCell>
                          <TableCell>{b.sender}</TableCell>
                          <TableCell>{new Date(b.sentAt).toLocaleString()}</TableCell>
                          <TableCell>{b.recipients}</TableCell>
                          <TableCell>{b.status}</TableCell>
                          {isAdmin && (
                            <TableCell className="text-right">
                              {/* Admin-only hard delete (spec Step 5d) */}
                              <Button variant="ghost" size="sm" className="text-destructive">
                                Delete
                              </Button>
                            </TableCell>
                          )}
                        </TableRow>
                      ))
                    )}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
