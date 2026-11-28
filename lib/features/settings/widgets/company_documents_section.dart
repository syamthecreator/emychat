import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../emy/models/emy_models.dart';
import '../../emy/providers/emy_provider.dart';
import '../../settings/widgets/settings_section_widget.dart';

class CompanyDocumentsSection extends StatefulWidget {
  const CompanyDocumentsSection({super.key});

  @override
  State<CompanyDocumentsSection> createState() =>
      _CompanyDocumentsSectionState();
}

class _CompanyDocumentsSectionState extends State<CompanyDocumentsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EmyProvider?>()?.loadDocuments();
      }
    });
  }

  Future<void> _pickAndUpload() async {
    final emyProvider = context.read<EmyProvider?>();
    if (emyProvider == null) return;

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'docx', 'txt', 'md', 'csv'],
      );

      if (files.isEmpty) return;
      final file = files.first;
      final bytes = await file.xFile.readAsBytes();
      if (bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The selected file appears to be empty.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      await emyProvider.uploadDocument(fileName: file.name, bytes: bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Upload error: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDelete(EmyDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Delete Document',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        content: Text(
          'Remove "${doc.fileName}" from your private Emy AI knowledge base?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<EmyProvider?>()?.deleteDocument(doc.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emy = context.watch<EmyProvider?>();
    if (emy == null) {
      return const SizedBox.shrink();
    }

    return SettingsSectionWidget(
      title: 'Company Knowledge Documents (Emy AI)',
      description:
          'Upload your company PDF, DOCX, TXT, or MD files (max 10 MB). '
          'Documents are stored privately for your account only and used by Emy to answer company-specific questions.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppButton(
                label: emy.isUploadingDoc ? 'Processing...' : 'Upload Document',
                icon: RemixIcons.upload_cloud_2_line,
                isLoading: emy.isUploadingDoc,
                onPressed: emy.isUploadingDoc ? null : _pickAndUpload,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Supported: PDF, DOCX, TXT, MD, CSV',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          if (emy.docError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    RemixIcons.error_warning_line,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      emy.docError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (emy.docSuccess != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    RemixIcons.checkbox_circle_line,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      emy.docSuccess!,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (emy.isLoadingDocs)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (emy.documents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Row(
                children: [
                  Icon(
                    RemixIcons.file_text_line,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No company documents uploaded yet. Upload a PDF or DOCX to train Emy on your company information.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: emy.documents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final doc = emy.documents[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.sapphireBlue.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          RemixIcons.file_text_fill,
                          size: 17,
                          color: AppColors.arcticBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${doc.formattedSize} • ${doc.chunkCount} chunks',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: doc.status == 'READY' ? 'Ready' : doc.status,
                        type: doc.status == 'READY'
                            ? StatusType.active
                            : StatusType.warning,
                        isSmall: true,
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(
                          RemixIcons.delete_bin_line,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        tooltip: 'Delete document',
                        onPressed: () => _confirmDelete(doc),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
