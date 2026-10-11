import 'package:flutter/material.dart';

/// iGubat brand logo (wordmark + "4710" postal line). The asset has a white
/// outline, so the same image stays legible on light and dark backgrounds.
class IgubatLogo extends StatelessWidget {
  /// Visible height of the logo artwork (transparent padding excluded).
  final double height;

  /// Makes the logo a navigation control (e.g. scroll to top / go Home).
  final VoidCallback? onTap;

  /// Screen-reader hint for [onTap], e.g. "Back to top".
  final String? tapHint;

  static const String assetName = 'assets/images/igubat-logo.png';
  static const Size _assetSize = Size(1536, 1024);

  /// Pixel bounds of the artwork inside the asset's transparent canvas.
  static const Rect _bounds = Rect.fromLTRB(272, 266, 1264, 680);

  const IgubatLogo({super.key, this.height = 40, this.onTap, this.tapHint});

  @override
  Widget build(BuildContext context) {
    final scale = height / _bounds.height;

    Widget logo = SizedBox(
      width: _bounds.width * scale,
      height: height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: -_bounds.left * scale,
            top: -_bounds.top * scale,
            width: _assetSize.width * scale,
            height: _assetSize.height * scale,
            child: Image.asset(
              assetName,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      logo = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: logo,
      );
    }

    return Center(
      child: Semantics(
        label: 'iGubat',
        image: onTap == null,
        button: onTap != null,
        hint: tapHint,
        child: logo,
      ),
    );
  }
}
