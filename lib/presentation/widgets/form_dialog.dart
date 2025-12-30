import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable modal dialog for forms
class FormDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String saveButtonText;
  final String cancelButtonText;
  final bool isLoading;
  final double? maxWidth;

  const FormDialog({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.onCancel,
    this.saveButtonText = 'Save',
    this.cancelButtonText = 'Cancel',
    this.isLoading = false,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF1F5F9)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : (onCancel ?? () => Navigator.of(context).pop()),
                    child: Text(cancelButtonText),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isLoading ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(saveButtonText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show form dialog
Future<T?> showFormDialog<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  VoidCallback? onSave,
  String saveButtonText = 'Save',
  bool isLoading = false,
  double? maxWidth,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: !isLoading,
    builder: (context) => FormDialog(
      title: title,
      onSave: onSave,
      saveButtonText: saveButtonText,
      isLoading: isLoading,
      maxWidth: maxWidth,
      child: child,
    ),
  );
}
