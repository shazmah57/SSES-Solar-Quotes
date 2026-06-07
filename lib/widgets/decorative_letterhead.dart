import 'dart:io';

import 'package:flutter/material.dart';

import '../services/branding_service.dart';

/// Letterhead background with header/footer text washed out; center logo stays faint.
class DecorativeLetterhead extends StatelessWidget {
  const DecorativeLetterhead({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return ColoredBox(
        color: const Color(0xFF121212),
        child: child,
      );
    }
    return ValueListenableBuilder<BrandingState>(
      valueListenable: BrandingService.instance.state,
      builder: (context, branding, _) {
        return Stack(
          fit: StackFit.expand,
          children: [_letterheadImage(branding), _textMaskOverlay(), child],
        );
      },
    );
  }

  Widget _letterheadImage(BrandingState branding) {
    if (branding.useDefaultAssets) {
      return Image.asset(
        'assets/images/letterhead.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => ColoredBox(color: Colors.grey.shade200),
      );
    }
    final file = File(branding.letterheadPath!);
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => ColoredBox(color: Colors.grey.shade200),
    );
  }

  Widget _textMaskOverlay() {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.94),
              Colors.white.withValues(alpha: 0.72),
              Colors.white.withValues(alpha: 0.78),
              Colors.white.withValues(alpha: 0.92),
            ],
            stops: const [0.0, 0.28, 0.62, 1.0],
          ),
        ),
      ),
    );
  }
}
