import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_surfaces.dart';

class QuotationFormScreen extends StatefulWidget {
  const QuotationFormScreen({super.key});

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // FIXED BRANDED HEADER WITH BACK NAVIGATION
          Material(
            color: AppColors.letterheadGreen,
            elevation: 1,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SSES Solar Quotes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Solar Quotation Generator',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // WORKSPACE CONTAINER BODY
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quotation Form Workspace',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppSurfaces.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ready for system specs and financial rules.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppSurfaces.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}