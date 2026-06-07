"use client"

import Image from "next/image"
import Link from "next/link"
import { useForm } from "@tanstack/react-form"
import { Lock, Mail } from "lucide-react"

import { Button, buttonVariants } from "@/core/components/ui/button"
import { Card, CardContent } from "@/core/components/ui/card"
import { Field, FieldError, FieldGroup } from "@/core/components/ui/field"
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
			<Card className="w-full max-w-md overflow-hidden rounded-2xl p-6 shadow-xl sm:p-10">
				<CardContent className="p-0">
					<form
						onSubmit={e => {
							e.preventDefault()
							form.handleSubmit()
						}}
					>
						<FieldGroup className="gap-8">
							<div className="flex flex-col items-center gap-4 text-center">
								<div className="mb-2 flex justify-center">
									<Image
										src="/logo/lightmode_logo.png"
										alt="iGubat Logo"
										width={80}
										height={80}
										className="object-contain dark:hidden"
									/>
									<Image
										src="/logo/darkmode_logo.png"
										alt="iGubat Logo"
										width={80}
										height={80}
										className="hidden object-contain dark:block"
									/>
								</div>
								<div>
									<h1 className="text-foreground text-3xl font-bold">Welcome Back</h1>
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
												<div className="border-border/50 focus-within:border-primary flex items-center border-b-2 py-2 transition-colors">
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
														className="h-auto flex-1 border-0 bg-transparent px-0 text-base shadow-none focus-visible:ring-0"
													/>
												</div>
												{isInvalid && (
													<FieldError errors={field.state.meta.errors} className="mt-1" />
												)}
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
												<div className="border-border/50 focus-within:border-primary flex items-center border-b-2 py-2 transition-colors">
													<Lock className="text-muted-foreground mr-4 h-5 w-5 shrink-0" />
													<div className="relative w-full flex-1">
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
															className="h-auto w-full border-0 bg-transparent px-0 pr-10 text-base shadow-none focus-visible:ring-0"
														/>
													</div>
												</div>
												{isInvalid && (
													<FieldError errors={field.state.meta.errors} className="mt-1" />
												)}
											</Field>
										)
									}}
								/>
							</div>

							<Field className="pt-4">
								<Button
									type="submit"
									disabled={isPending}
									className="bg-primary text-primary-foreground hover:bg-primary/90 h-12 w-full rounded-xl text-base font-medium hover:cursor-pointer"
								>
									{isPending ? "Signing in..." : "Sign In"}
								</Button>
							</Field>

							<div className="text-center text-sm">
								<span className="text-muted-foreground">Don&apos;t have an account?</span>{" "}
								<Link
									className="text-foreground hover:text-primary ml-1 font-bold transition-colors"
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
