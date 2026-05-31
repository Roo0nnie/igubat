import 'package:flutter/material.dart';

class IgubatLogo extends StatelessWidget {
  final double height;
  final bool darkText;

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

    return Image.asset(
      assetName,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
