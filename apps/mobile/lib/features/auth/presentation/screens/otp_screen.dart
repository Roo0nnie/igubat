import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/widgets/igubat_logo.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/providers/auth_redirect_provider.dart';
import 'package:mobile/shared/widgets/glass/glass_background.dart';

/// Number of digits in the verification code (TOR: 6-digit OTP).
const int _kOtpLength = 6;

/// Cool-down (seconds) before a new code can be requested. Resend is
/// rate-limited with a visible countdown to throttle SMS/email dispatch.
const int _kResendCooldownSeconds = 60;

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(_kOtpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_kOtpLength, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorText;

  Timer? _resendTimer;
  int _resendSecondsLeft = _kResendCooldownSeconds;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Starts (or restarts) the resend cool-down countdown.
  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _kResendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft--);
      }
    });
  }

  /// The email under verification, carried through the auth funnel.
  String get _email =>
      GoRouterState.of(context).uri.queryParameters[AppRoutes.emailQueryParam] ??
      '';

  void _handleResend() async {
    if (_resendSecondsLeft > 0) return;
    final email = _email;
    // Start the cool-down immediately so the button can't be spammed while the
    // request is in flight.
    _startResendCountdown();
    try {
      await ref
          .read(authStateProvider.notifier)
          .resendVerificationOtp(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('A new code has been sent.')),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Could not resend the code. Please try again.'),
          ),
        );
    }
  }

  void _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < _kOtpLength) {
      setState(() => _errorText = 'Enter the $_kOtpLength-digit code.');
      return;
    }

    final email = _email;
    final redirect = GoRouterState.of(context)
        .uri
        .queryParameters[AppRoutes.redirectQueryParam];

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // Validate the OTP server-side. Only a successful validation establishes
    // an authenticated session; until then the citizen stays unauthenticated.
    final verified = await ref
        .read(authStateProvider.notifier)
        .verifyEmailOtp(email: email, otp: code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!verified) {
      final error = ref.read(authStateProvider).error;
      setState(() => _errorText =
          error != null ? 'Invalid or expired code. Please try again.' : null);
      return;
    }

    // Verified and authenticated. Record any pending continuation so the main
    // shell resumes the action the user originally attempted, then enter the
    // authenticated shell.
    final continuation = _continuationFor(redirect);
    if (continuation != null) {
      ref.read(authContinuationProvider.notifier).state = continuation;
    }
    if (!context.mounted) return;
    context.go(AppRoutes.home);
  }

  /// Maps the `redirect` query value carried through the auth flow onto a
  /// concrete [AuthContinuation], or `null` when there is nothing to resume.
  AuthContinuation? _continuationFor(String? redirect) {
    switch (redirect) {
      case AppRoutes.redirectNotifications:
        return AuthContinuation.notifications;
      case AppRoutes.redirectProfile:
        return AuthContinuation.profile;
      case AppRoutes.redirectBusinessPermit:
        return AuthContinuation.businessPermit;
      default:
        return null;
    }
  }

  Widget _buildOtpBox(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 46,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface.withOpacity(0.5) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (_errorText != null) setState(() => _errorText = null);
          if (value.isNotEmpty && index < _kOtpLength - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (value.isNotEmpty && index == _kOtpLength - 1) {
            _focusNodes[index].unfocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Verify Code',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enter the code we just sent to\nyour email',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      height: 1.47,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _kOtpLength,
                        (index) => _buildOtpBox(index),
                      ),
                    ),
                  ),

                  if (_errorText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive OTP? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      _resendSecondsLeft > 0
                          ? Text(
                              'Resend in ${_resendSecondsLeft}s',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : TextButton(
                              onPressed: _handleResend,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Resend code',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
