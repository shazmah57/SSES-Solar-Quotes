import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_surfaces.dart';
import 'decorative_letterhead.dart';
import 'theme_mode_toggle.dart';

/// Scaffold with pinned green app bar; body scrolls below (not behind transparent bar).
class BrandedScaffold extends StatelessWidget {
  const BrandedScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.actions,
    this.floatingActionButton,
    this.showThemeToggle = true,
  });

  final String title;
  final Widget body;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showThemeToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final barActions = <Widget>[
      ...?actions,
      if (showThemeToggle) ...[
        const SizedBox(width: 4),
        const ThemeModeToggle(compact: true),
        const SizedBox(width: 8),
      ],
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : null,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.letterheadGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: barActions.isEmpty ? null : barActions,
        bottom: bottom == null
            ? null
            : PreferredSize(
                preferredSize: bottom!.preferredSize,
                child: ColoredBox(
                  color: AppColors.letterheadGreen,
                  child: bottom,
                ),
              ),
      ),
      floatingActionButton: floatingActionButton,
      body: isDark
          ? body
          : DecorativeLetterhead(child: body),
    );
  }
}

/// Green section heading (matches letterhead accent).
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: AppSurfaces.sectionHeading(context),
        ),
      ),
    );
  }
}

/// Same style as quotation PDF button.
class PdfActionButton extends StatelessWidget {
  const PdfActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.picture_as_pdf),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
    );
  }
}
