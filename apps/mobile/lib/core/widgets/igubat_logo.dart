import 'package:flutter/material.dart';

class IgubatLogo extends StatelessWidget {
  final double height;
  final bool darkText;

  /// Crops the postal code line baked into the logo asset.
  static const double _logoCropHeightFactor = 0.86;

  const IgubatLogo({
    super.key,
    this.height = 40,
    this.darkText = false,
  });

  @override
  Widget build(BuildContext context) {
    final assetName = darkText
        ? 'assets/images/lightmode_logo.png'
        : 'assets/images/darkmode_logo.png';

    final image = Image.asset(
      assetName,
      height: height / _logoCropHeightFactor,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );

    return Center(
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: _logoCropHeightFactor,
          child: image,
        ),
      ),
    );
  }
}
