import 'package:flutter/material.dart';

import 'decorative_letterhead.dart';

/// Letterhead background for quotation edit tab (text on letterhead hidden).
class LetterheadBackground extends StatelessWidget {
  const LetterheadBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecorativeLetterhead(child: child);
  }
}
