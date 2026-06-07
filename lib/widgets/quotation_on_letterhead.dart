import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../models/quotation.dart';
import 'quotation_document_content.dart';

/// Shows the final quotation laid out on the company letterhead image.
class QuotationOnLetterhead extends StatefulWidget {
  const QuotationOnLetterhead({super.key, required this.draft});

  final QuotationDraft draft;

  @override
  State<QuotationOnLetterhead> createState() => _QuotationOnLetterheadState();
}

class _QuotationOnLetterheadState extends State<QuotationOnLetterhead> {
  String? _letterheadPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLetterhead();
  }

  Future<void> _loadLetterhead() async {
    final path = await AppAssets.resolveLetterheadPath(forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _letterheadPath = path;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFFECEFF1),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Material(
              elevation: 4,
              color: Colors.white,
              child: _letterheadPath == null
                  ? _missingLetterheadBody()
                  : _letterheadBody(_letterheadPath!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _missingLetterheadBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: const Color(0xFFFFF3E0),
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Letterhead image not found.\n'
            'Add your file as assets/images/letterhead.jpg, '
            'then run: flutter pub get',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: QuotationDocumentContent(draft: widget.draft),
        ),
      ],
    );
  }

  Widget _letterheadBody(String assetPath) {
    // Full-page letterhead: image as background, quotation text on top (same as PDF).
    const a4AspectRatio = 595.28 / 841.89;

    return AspectRatio(
      aspectRatio: a4AspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final top = AppAssets.previewContentTopForHeight(
            constraints.maxHeight,
          );
          final horizontal = AppAssets.previewContentHorizontalForWidth(
            constraints.maxWidth,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                assetPath,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFFFF3E0),
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Could not load letterhead image. Check assets/images/letterhead.jpg',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, 24),
                child: SingleChildScrollView(
                  child: QuotationDocumentContent(draft: widget.draft),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
