"use client"

import Image from "next/image"
import Link from "next/link"
import { useForm } from "@tanstack/react-form"
import { Mail, Lock } from "lucide-react"

import { Button, buttonVariants } from "@/core/components/ui/button"
import { Card, CardContent } from "@/core/components/ui/card"
import {
	Field,
	FieldError,
	FieldGroup,
} from "@/core/components/ui/field"
import { Input } from "@/core/components/ui/input"
import { cn } from "@/core/lib/utils"
import { PasswordInput } from "@/features/auth/components/password-input"
import { TermsPrivacyNote } from "@/features/auth/components/terms-privacy-note"

import { useLoginMutation } from "../api/login.hooks"
import { LoginSchema } from "../api/login.schema"

export function LoginForm({ className, ...props }: React.ComponentProps<"div">) {
	const { mutateAsync: login, isPending, isError, error } = useLoginMutation()

	const form = useForm({
		defaultValues: {
			email: "",
			password: "",
		},
		validators: {
			onSubmit: LoginSchema,
		},
		onSubmit: async ({ value }) => {
			await login(value)
		},
	})

	return (
		<div className={cn("flex flex-col items-center justify-center gap-6", className)} {...props}>
			<Card className="w-full max-w-md overflow-hidden p-6 sm:p-10 rounded-2xl shadow-xl">
				<CardContent className="p-0">
					<form
						onSubmit={e => {
							e.preventDefault()
							form.handleSubmit()
						}}
					>
						<FieldGroup className="gap-8">
							<div className="flex flex-col items-center gap-4 text-center">
								<div className="flex justify-center mb-2">
									<Image
										src="/logo/lightmode_logo.png"
										alt="iGubat Logo"
										width={80}
										height={80}
										className="dark:hidden object-contain"
									/>
									<Image
										src="/logo/darkmode_logo.png"
										alt="iGubat Logo"
										width={80}
										height={80}
										className="hidden dark:block object-contain"
									/>
								</div>
								<div>
									<h1 className="text-3xl font-bold text-foreground">Welcome Back</h1>
									<p className="text-muted-foreground mt-2">Sign in to continue</p>
								</div>
							</div>

							{isError && (
								<div className="bg-destructive/10 text-destructive dark:bg-destructive/20 rounded-lg p-3 text-sm">
									{error instanceof Error ? error.message : "An unexpected error occurred"}
								</div>
							)}

							<div className="space-y-6">
								<form.Field
									name="email"
									children={field => {
										const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid
										return (
											<Field data-invalid={isInvalid}>
												<div className="flex items-center border-b-2 border-border/50 py-2 focus-within:border-primary transition-colors">
													<Mail className="text-muted-foreground mr-4 h-5 w-5 shrink-0" />
													<Input
														id={field.name}
														name={field.name}
														type="email"
														value={field.state.value}
														onBlur={field.handleBlur}
														onChange={e => field.handleChange(e.target.value)}
														aria-invalid={isInvalid}
														placeholder="Email"
														autoComplete="email"
														required
														disabled={isPending}
														className="border-0 bg-transparent px-0 shadow-none focus-visible:ring-0 h-auto text-base flex-1"
													/>
												</div>
												{isInvalid && <FieldError errors={field.state.meta.errors} className="mt-1" />}
											</Field>
										)
									}}
								/>

								<form.Field
									name="password"
									children={field => {
										const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid
										return (
											<Field data-invalid={isInvalid}>
												<div className="flex items-center border-b-2 border-border/50 py-2 focus-within:border-primary transition-colors">
													<Lock className="text-muted-foreground mr-4 h-5 w-5 shrink-0" />
													<div className="flex-1 w-full relative">
														<PasswordInput
															id={field.name}
															name={field.name}
															value={field.state.value}
															onBlur={field.handleBlur}
															onChange={e => field.handleChange(e.target.value)}
															aria-invalid={isInvalid}
															required
															placeholder="Password"
															autoComplete="current-password"
															disabled={isPending}
															className="border-0 bg-transparent px-0 shadow-none focus-visible:ring-0 h-auto text-base w-full pr-10"
														/>
													</div>
												</div>
												{isInvalid && <FieldError errors={field.state.meta.errors} className="mt-1" />}
											</Field>
										)
									}}
								/>
							</div>

							<Field className="pt-4">
								<Button type="submit" disabled={isPending} className="w-full hover:cursor-pointer bg-primary text-primary-foreground hover:bg-primary/90 h-12 text-base rounded-xl font-medium">
									{isPending ? "Signing in..." : "Sign In"}
								</Button>
							</Field>

							<div className="text-center text-sm">
								<span className="text-muted-foreground">Don&apos;t have an account?</span>{" "}
								<Link
									className="font-bold text-foreground hover:text-primary transition-colors ml-1"
									href="/register"
								>
									Sign Up
								</Link>
							</div>
						</FieldGroup>
					</form>
				</CardContent>
			</Card>
		</div>
	)
}
