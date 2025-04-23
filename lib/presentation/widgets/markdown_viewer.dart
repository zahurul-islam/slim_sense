import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';

class MarkdownViewer extends StatelessWidget {
  final String markdown;
  final bool selectable;
  final EdgeInsets padding;
  final ScrollPhysics? physics;

  const MarkdownViewer({
    Key? key,
    required this.markdown,
    this.selectable = true,
    this.padding = EdgeInsets.zero,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: MarkdownBody(
        data: markdown,
        selectable: selectable,
        styleSheet: MarkdownStyleSheet(
          h1: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
          h2: AppTypography.heading4.copyWith(color: AppColors.textPrimary),
          h3: AppTypography.heading5.copyWith(color: AppColors.textPrimary),
          h4: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary),
          h5: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
          h6: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
          p: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          strong: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          em: AppTypography.bodyMedium.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.textPrimary,
          ),
          blockquote: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          code: AppTypography.bodyMedium.copyWith(
            fontFamily: 'monospace',
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          codeblockPadding: const EdgeInsets.all(16),
          listBullet: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          tableHead: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          tableBody: AppTypography.bodyMedium,
          tableBorder: TableBorder.all(
            color: AppColors.borderColor,
            width: 1,
            borderRadius: BorderRadius.circular(4),
          ),
          tableColumnWidth: const FixedColumnWidth(200),
          tableCellsPadding: const EdgeInsets.all(8),
          checkbox: TextStyle(color: AppColors.primary),
          a: AppTypography.bodyMedium.copyWith(
            color: AppColors.linkColor,
            decoration: TextDecoration.underline,
          ),
        ),
        onTapLink: (text, href, title) {
          if (href != null) {
            _launchUrl(href);
          }
        },
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch URL: $e');
    }
  }
}
