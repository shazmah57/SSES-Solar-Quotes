import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_surfaces.dart';
import 'load_calculation_screen.dart';
import 'battery_backup_screen.dart';
import 'quotation_form_screen.dart'; 
import '../services/app_settings_service.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // FIXED GREEN BRAND HEADER WITH SEGMENTED TOGGLE
          Material(
            color: AppColors.letterheadGreen,
            elevation: 2,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SSES Solar Quotes',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Professional Engineering Suite',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    // PREMIUM SEGMENTED THEME STRIP
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildThemeSegment('Light', !isDark),
                          _buildThemeSegment('Dark', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // MAIN NAVIGATION WORKSPACE
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ToolCard(
                  icon: Icons.calculate_outlined,
                  title: 'Load Calculation',
                  subtitle: 'Determine structural connected appliance wattage parameters.',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoadCalculationScreen()),
                    );
                  },
                ),
                const SizedBox(height: 4),
                _ToolCard(
                  icon: Icons.battery_charging_full_outlined,
                  title: 'Battery Backup Calculator',
                  subtitle: 'Build emergency storage runtimes and discharge profile windows.',
                  color: Colors.amber,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BatteryBackupScreen()),
                    );
                  },
                ),
                const SizedBox(height: 4),
                // SOLAR QUOTATION TAB
                _ToolCard(
                  icon: Icons.description_outlined,
                  title: 'Solar Quotation Generator',
                  subtitle: 'Compile comprehensive financial quotes, system specs, and terms.',
                  color: const Color(0xFF2E7D32),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuotationFormScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSegment(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          setState(() {
            if (label == 'Dark') {
              AppSettingsService.instance.setThemeMode(ThemeMode.dark);
            } else {
              AppSettingsService.instance.setThemeMode(ThemeMode.light);
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.letterheadGreen : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatefulWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    
    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) {
        _animController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          elevation: isDark ? 0 : 2,
          color: isDark ? const Color(0xFF141414) : AppSurfaces.card(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: widget.color.withAlpha((0.12 * 255).round()),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppSurfaces.primaryText(context),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppSurfaces.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: widget.color.withOpacity(0.7), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}