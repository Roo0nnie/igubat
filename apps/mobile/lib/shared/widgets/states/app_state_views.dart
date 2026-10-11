import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/glass_tokens.dart';
import '../../../core/widgets/igubat_logo.dart';
import '../glass/glass_button.dart';
import '../glass/glass_surface.dart';

const Duration kSlowLoadingThreshold = Duration(seconds: 8);

/// Skeleton placeholder with a status caption. After [slowAfter] the caption
/// switches to a connection hint and offers [onRetry].
class LoadingStateView extends StatefulWidget {
  const LoadingStateView({
    super.key,
    required this.skeleton,
    this.message = 'Loading...',
    this.onRetry,
    this.slowAfter = kSlowLoadingThreshold,
  });

  final Widget skeleton;
  final String message;
  final VoidCallback? onRetry;
  final Duration slowAfter;

  @override
  State<LoadingStateView> createState() => _LoadingStateViewState();
}

class _LoadingStateViewState extends State<LoadingStateView> {
  Timer? _timer;
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.slowAfter, () {
      if (mounted) setState(() => _slow = true);
    });
  }

  void _retry() {
    setState(() => _slow = false);
    _startTimer();
    widget.onRetry?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LoadingCaption(
          message: widget.message,
          slow: _slow,
          onRetry: widget.onRetry == null ? null : _retry,
        ),
        const SizedBox(height: 16),
        ExcludeSemantics(child: widget.skeleton),
      ],
    );
  }
}

class _LoadingCaption extends StatelessWidget {
  const _LoadingCaption({
    required this.message,
    required this.slow,
    this.onRetry,
  });

  final String message;
  final bool slow;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final Widget content;
    if (slow) {
      content = GlassSurface(
        key: const ValueKey('slow'),
        intensity: GlassIntensity.subtle,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        boxShadow: const [],
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, size: 20, color: Colors.orange.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Still loading. Please check your internet connection.',
                style: TextStyle(fontSize: 13, color: glass.textOnGlass),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: GlassTokens.accentGreen,
                  minimumSize: const Size(48, 40),
                ),
                child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      );
    } else {
      content = Row(
        key: const ValueKey('normal'),
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: reduceMotion
                ? Icon(Icons.hourglass_top_rounded, size: 14, color: GlassTokens.secondaryGreen)
                : const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: GlassTokens.secondaryGreen,
                  ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: glass.textOnGlassMuted,
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      liveRegion: true,
      label: slow ? 'Still loading. Please check your internet connection.' : message,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: content,
      ),
    );
  }
}

/// Turns raw exceptions into wording a citizen can act on.
String friendlyErrorMessage(Object? error) {
  final text = error?.toString().toLowerCase() ?? '';
  if (error is SocketException ||
      text.contains('socketexception') ||
      text.contains('connection refused') ||
      text.contains('failed host lookup') ||
      text.contains('network is unreachable') ||
      text.contains('connection error')) {
    return 'You appear to be offline. Check your internet connection and try again.';
  }
  if (error is TimeoutException || text.contains('timeout') || text.contains('timed out')) {
    return 'The server is taking too long to respond. Please try again in a moment.';
  }
  if (text.contains('401') || text.contains('unauthorized')) {
    return 'Your session has expired. Please sign in again.';
  }
  return 'Something went wrong on our end. Please try again.';
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    this.title = 'Unable to load',
    this.message,
    this.error,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  final String title;
  final String? message;
  final Object? error;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: icon,
      iconColor: const Color(0xFFB91C1C),
      title: title,
      message: message ?? friendlyErrorMessage(error),
      action: onRetry == null
          ? null
          : GlassButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: icon,
      iconColor: GlassTokens.secondaryGreen,
      title: title,
      message: message,
      action: action,
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: glass.textOnGlass,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.4, color: glass.textOnGlassMuted),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-screen branded wait (app start, session restore, full-page loads).
class BrandedLoader extends StatelessWidget {
  const BrandedLoader({super.key, this.message = 'Getting things ready...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget logo = const IgubatLogo(height: 64);
    if (!reduceMotion) {
      logo = logo
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 0.96, end: 1.04, duration: 1100.ms, curve: Curves.easeInOut)
          .fade(begin: 0.75, end: 1, duration: 1100.ms);
    }

    return Center(
      child: Semantics(
        liveRegion: true,
        label: message,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            logo,
            const SizedBox(height: 24),
            if (!reduceMotion) ...[
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    color: GlassTokens.secondaryGreen,
                    backgroundColor: GlassTokens.secondaryGreen.withValues(alpha: 0.15),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            ExcludeSemantics(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: glass.textOnGlassMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spinner + verb label for use inside buttons while an action is running.
class ButtonLoadingLabel extends StatelessWidget {
  const ButtonLoadingLabel({
    super.key,
    required this.label,
    this.color = Colors.white,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
          const SizedBox(width: 12),
          ExcludeSemantics(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hosts a full-body state inside an always-scrollable list so
/// pull-to-refresh keeps working while loading, failed, or empty.
class StateScrollView extends StatelessWidget {
  const StateScrollView({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding ??
          EdgeInsets.fromLTRB(24, 16, 24, AppLayout.scrollBottomPadding(context)),
      children: [child],
    );
  }
}

extension AsyncValueStateViews<T> on AsyncValue<T> {
  /// Standard loading / error / empty / data rendering for a screen section.
  Widget buildStates({
    required Widget Function(T data) data,
    required Widget skeleton,
    required String loadingMessage,
    VoidCallback? onRetry,
    String errorTitle = 'Unable to load',
    bool Function(T data)? isEmpty,
    Widget Function()? empty,
  }) {
    return when(
      loading: () => LoadingStateView(
        skeleton: skeleton,
        message: loadingMessage,
        onRetry: onRetry,
      ),
      error: (e, _) => ErrorStateView(
        title: errorTitle,
        error: e,
        onRetry: onRetry,
      ),
      data: (value) {
        if (isEmpty != null && empty != null && isEmpty(value)) return empty();
        return data(value);
      },
    );
  }
}
