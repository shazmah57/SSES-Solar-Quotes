import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../models/saved_quotation.dart';
import '../services/quotation_save_service.dart';
import '../theme/app_surfaces.dart';
import 'quotation_form_screen.dart';

class QuotationHistoryScreen extends StatefulWidget {
  const QuotationHistoryScreen({super.key});

  @override
  State<QuotationHistoryScreen> createState() => _QuotationHistoryScreenState();
}

class _QuotationHistoryScreenState extends State<QuotationHistoryScreen> {
  final _saveService = QuotationSaveService.instance;
  List<SavedQuotation> _quotations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  Future<void> _loadQuotations() async {
    setState(() => _isLoading = true);
    final quotes = await _saveService.getAllQuotations();
    setState(() {
      _quotations = quotes;
      _isLoading = false;
    });
  }

  Future<void> _deleteQuotation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quotation'),
        content: const Text('Are you sure you want to delete this quotation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _saveService.deleteQuotation(id);
      await _loadQuotations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quotation deleted')),
        );
      }
    }
  }

  Future<void> _editQuotation(SavedQuotation quotation) async {
    final draft = _saveService.toDraft(quotation);
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuotationFormScreen(initialDraft: draft, isEditing: true, editId: quotation.id),
      ),
    );
    if (result == true) {
      await _loadQuotations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : null,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _quotations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 80,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No saved quotations',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Save quotations from the Quotation Form',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _quotations.length,
                        itemBuilder: (context, index) {
                          final quote = _quotations[index];
                          return _QuotationCard(
                            quotation: quote,
                            onEdit: () => _editQuotation(quote),
                            onDelete: () => _deleteQuotation(quote.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Material(
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
                      'Saved Quotations',
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
    );
  }
}

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedQuotation quotation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 0 : 2,
      color: isDark ? const Color(0xFF141414) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quotation.quotationNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppSurfaces.primaryText(context),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quotation.quotedTo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.letterheadGreen,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: AppSurfaces.secondaryText(context)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      quotation.contactNo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppSurfaces.secondaryText(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppSurfaces.secondaryText(context)),
                  const SizedBox(width: 4),
                  Text(
                    'Saved: ${quotation.formattedDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppSurfaces.secondaryText(context),
                    ),
                  ),
                ],
              ),
              if (quotation.lastModified != null && quotation.lastModified != quotation.savedAt)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.edit_calendar, size: 14, color: AppSurfaces.secondaryText(context)),
                      const SizedBox(width: 4),
                      Text(
                        'Modified: ${DateFormat('dd-MM-yyyy HH:mm').format(quotation.lastModified!)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppSurfaces.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}