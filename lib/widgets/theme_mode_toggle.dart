import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';

/// Segmented Light (left) / Dark (right) theme control.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key, this.compact = false});

  /// Smaller padding for tool screens with green headers.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettingsService.instance.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Segment(
                label: 'Light',
                selected: !isDark,
                compact: compact,
                onTap: () =>
                    AppSettingsService.instance.setThemeMode(ThemeMode.light),
              ),
              _Segment(
                label: 'Dark',
                selected: isDark,
                compact: compact,
                onTap: () =>
                    AppSettingsService.instance.setThemeMode(ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 8,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF1B7A3D) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
