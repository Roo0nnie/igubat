import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/mock/seed_data.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/widgets/igubat_logo.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/shared/widgets/glass/glass_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBarangay;
  bool _obscurePassword = true;

  /// Explicit consent to processing of personal data under the Data Privacy
  /// Act of 2012 (RA 10173). Required before an account can be created.
  bool _agreeToDpa = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToDpa) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Consent Required',
              message:
                  'Please review the Privacy Notice and consent to the '
                  'processing of your personal data to register.',
              contentType: ContentType.warning,
            ),
          ),
        );
      return;
    }

    final email = _emailController.text.trim();
    final registered = await ref.read(authStateProvider.notifier).signUp(
          email: email,
          password: _passwordController.text,
          name: _nameController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          barangay: _selectedBarangay!,
          address: _addressController.text.trim(),
          dpaConsent: _agreeToDpa,
        );

    if (!mounted) return;

    if (!registered) {
      if (!context.mounted) return;
      final error = ref.read(authStateProvider).error;
      final message = error is Failure
          ? error.message
          : 'Registration failed. Please try again.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Sign Up Failed',
              message: message,
              contentType: ContentType.failure,
            ),
          ),
        );
      return;
    }

    if (!context.mounted) return;
    // Account created in an unverified state — a verification OTP was
    // dispatched server-side. Route to OTP verification with the email under
    // verification before the citizen reaches authenticated surfaces (TOR
    // Step 2b). Forward any post-authentication continuation so a guest who
    // started from a guarded surface still returns there after verifying.
    final redirect = GoRouterState.of(context)
        .uri
        .queryParameters[AppRoutes.redirectQueryParam];
    context.push(AppRoutes.otpWith(email, redirect));
  }

  /// Presents the Privacy Notice (RA 10173) the citizen must acknowledge
  /// before consenting. Shown inline as a scrollable bottom sheet.
  void _showPrivacyNotice() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Notice',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The Municipality of Gubat, through the iGubat application, '
                  'collects your full name, barangay, address, mobile number, '
                  'and optional email to create and verify your account and to '
                  'process the service requests and reports you submit.\n\n'
                  'Your personal data is processed in accordance with the Data '
                  'Privacy Act of 2012 (Republic Act No. 10173). It is used '
                  'only for legitimate government service delivery, is kept '
                  'confidential, and is retained only for as long as necessary.\n\n'
                  'You may access, correct, or request deletion of your data, '
                  'and withdraw consent, by contacting the LGU Data Protection '
                  'Officer. By consenting, you confirm that the information you '
                  'provided is true and accurate.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 22,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark 
                ? theme.colorScheme.surface.withOpacity(0.5)
                : theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildBarangayDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Barangay',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedBarangay,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          dropdownColor: theme.colorScheme.surface,
          hint: Text(
            'Select your barangay',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_city_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 22,
            ),
            filled: true,
            fillColor: isDark
                ? theme.colorScheme.surface.withOpacity(0.5)
                : theme.colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: border(theme.colorScheme.outline.withOpacity(0.3)),
            enabledBorder: border(theme.colorScheme.outline.withOpacity(0.3)),
            focusedBorder: border(theme.colorScheme.primary, 2),
            errorBorder: border(theme.colorScheme.error),
            focusedErrorBorder: border(theme.colorScheme.error, 2),
          ),
          items: [
            for (final barangay in SeedData.barangays)
              DropdownMenuItem(value: barangay, child: Text(barangay)),
          ],
          onChanged: (value) => setState(() => _selectedBarangay = value),
          validator: (value) =>
              value == null ? 'Please select your barangay' : null,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            color: isDark ? Colors.transparent : theme.colorScheme.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IgubatLogo(
                      height: 120, 
                      darkText: !isDark,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Start your Journey',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your register information',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.47,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    _buildTextField(
                      context: context,
                      label: 'Full Name',
                      hint: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),

                    _buildTextField(
                      context: context,
                      label: 'Mobile Number',
                      hint: 'e.g. 0917 123 4567',
                      prefixIcon: Icons.phone_outlined,
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final digits =
                            (value ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.isEmpty) {
                          return 'Mobile number is required';
                        }
                        if (digits.length < 10) {
                          return 'Enter a valid mobile number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      context: context,
                      label: 'Email',
                      hint: 'Email address',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        // Email is the identifier the citizen will sign in with,
                        // so it is required until mobile-number login exists.
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildBarangayDropdown(context),

                    const SizedBox(height: 20),

                    _buildTextField(
                      context: context,
                      label: 'Complete Address',
                      hint: 'House no., street, purok/sitio',
                      prefixIcon: Icons.home_outlined,
                      controller: _addressController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      context: context,
                      label: 'Password',
                      hint: 'Enter Password',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                          return 'Use letters and numbers only';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToDpa,
                            onChanged: (value) {
                              setState(() {
                                _agreeToDpa = value ?? false;
                              });
                            },
                            activeColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text.rich(
                              TextSpan(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.8),
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'I have read the ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Notice',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showPrivacyNotice,
                                  ),
                                  const TextSpan(
                                    text:
                                        ' and consent to the processing of my '
                                        'personal data under the Data Privacy '
                                        'Act of 2012 (RA 10173).',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Row(
                      children: [
                        _buildSocialButton(
                          context: context,
                          label: 'Google',
                          icon: Image.network(
                            'https://cdn-icons-png.flaticon.com/512/2991/2991148.png', 
                            height: 20,
                            width: 20,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.g_mobiledata, 
                              size: 24, 
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          context: context,
                          label: 'Apple',
                          icon: Icon(
                            Icons.apple,
                            size: 22,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign in',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
