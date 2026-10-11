import 'package:flutter/material.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/glass_tokens.dart';

/// A "slide to act" control used by the Emergency screen so the most critical
/// action (dialing 911) requires a deliberate horizontal gesture rather than a
/// single tap that could be triggered accidentally.
///
/// The user drags the circular thumb from the left edge to the right edge of
/// the track. Once it crosses the completion threshold, [onSlideComplete]
/// fires exactly once and the thumb settles at the end; otherwise it springs
/// back to the start (User Story 7.1: "the slide gesture initiates a tel:
/// action").
class GlassSlideToCall extends StatefulWidget {
  const GlassSlideToCall({
    super.key,
    required this.label,
    required this.onSlideComplete,
    this.icon = Icons.call,
    this.color = const Color(0xFFB91C1C),
    this.height = 64,
    this.onColoredBackground = false,
  });

  /// Instructional text shown on the track, e.g. "Slide to call 911".
  final String label;

  /// Invoked once when the thumb is dragged past the completion threshold.
  final VoidCallback onSlideComplete;

  /// Icon rendered inside the draggable thumb.
  final IconData icon;

  /// Accent colour for the thumb and track tint.
  final Color color;

  /// Overall control height; the thumb is sized to fit inside it.
  final double height;

  /// Renders a white track and thumb so the control reads on a [color] card.
  final bool onColoredBackground;

  @override
  State<GlassSlideToCall> createState() => _GlassSlideToCallState();
}

class _GlassSlideToCallState extends State<GlassSlideToCall> {
  /// Current horizontal offset of the thumb, in logical pixels from the left.
  double _dragX = 0;

  /// Guards [GlassSlideToCall.onSlideComplete] so it fires only once per
  /// completed slide.
  bool _completed = false;

  /// Fraction of the track that must be crossed to count as a completed slide.
  static const double _completionFraction = 0.85;

  /// Accessible activation path (e.g. screen-reader "double-tap to activate").
  ///
  /// A raw semantic tap must never place the emergency call directly: that
  /// would let a single assistive activation bypass the deliberate slide
  /// confirmation. Instead we surface an explicit confirm dialog so dialing
  /// still requires an intentional second action.
  Future<void> _confirmAndCall() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.label),
        content: const Text(
          'This will place an emergency call. Confirm to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Call'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onSlideComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = widget.height - 8;
    final onColor = widget.onColoredBackground;
    final trackColor = onColor
        ? Colors.white.withValues(alpha: 0.18)
        : widget.color.withValues(alpha: 0.12);
    final trackBorder = onColor
        ? Colors.white.withValues(alpha: 0.45)
        : widget.color.withValues(alpha: 0.3);
    final labelColor = onColor ? Colors.white : widget.color;
    final thumbColor = onColor ? Colors.white : widget.color;
    final thumbIconColor = onColor ? widget.color : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final maxDragX = (trackWidth - thumbSize - 8).clamp(0.0, trackWidth);
        final progress = maxDragX == 0 ? 0.0 : (_dragX / maxDragX).clamp(0.0, 1.0);

        void onDragUpdate(DragUpdateDetails details) {
          if (_completed) return;
          setState(() {
            _dragX = (_dragX + details.delta.dx).clamp(0.0, maxDragX);
          });
        }

        void onDragEnd(DragEndDetails details) {
          if (_completed) return;
          if (progress >= _completionFraction) {
            setState(() {
              _dragX = maxDragX;
              _completed = true;
            });
            widget.onSlideComplete();
            // Reset shortly after so the control is reusable for a second call.
            Future.delayed(const Duration(milliseconds: 600), () {
              if (!mounted) return;
              setState(() {
                _dragX = 0;
                _completed = false;
              });
            });
          } else {
            setState(() => _dragX = 0);
          }
        }

        return Semantics(
          button: true,
          label: widget.label,
          // Route assistive activation through an explicit confirmation rather
          // than dialing directly, so the slide remains the only single-step
          // path to the call.
          onTap: _confirmAndCall,
          child: Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(widget.height / 2),
              border: Border.all(color: trackBorder, width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Label fades out as the thumb advances so it does not sit
                // under the thumb at the end of the slide.
                Opacity(
                  opacity: (1 - progress * 1.4).clamp(0.0, 1.0),
                  child: Padding(
                    padding: EdgeInsets.only(left: thumbSize + 8, right: 40),
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  child: Opacity(
                    opacity: (1 - progress * 1.4).clamp(0.0, 1.0),
                    child: Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: labelColor.withValues(alpha: 0.8),
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  left: 4,
                  child: AnimatedSlide(
                    // AnimatedSlide animates the spring-back; during an active
                    // drag the offset tracks the finger directly.
                    duration: _dragX == 0
                        ? AppMotion.durationFast
                        : Duration.zero,
                    curve: AppMotion.enterCurve,
                    offset: Offset(_dragX / thumbSize, 0),
                    child: GestureDetector(
                      onHorizontalDragUpdate: onDragUpdate,
                      onHorizontalDragEnd: onDragEnd,
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          shape: BoxShape.circle,
                          boxShadow: GlassTokens.ambientShadow(
                            color: Colors.black,
                            opacity: 0.18,
                          ),
                        ),
                        child: Icon(widget.icon, color: thumbIconColor, size: 26),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
