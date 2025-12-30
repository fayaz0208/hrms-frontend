import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../state/providers/recruitment_provider.dart';
import '../../../data/models/candidate_document_model.dart';

/// Screen for managing candidate documents with multi-file upload
class CandidateDocumentsScreen extends StatefulWidget {
  final int candidateId;
  final String candidateName;

  const CandidateDocumentsScreen({
    super.key,
    required this.candidateId,
    required this.candidateName,
  });

  @override
  State<CandidateDocumentsScreen> createState() =>
      _CandidateDocumentsScreenState();
}

class _CandidateDocumentsScreenState extends State<CandidateDocumentsScreen> {
  String _selectedDocumentType = 'Resume';
  final List<String> _documentTypes = [
    'Resume',
    'Cover Letter',
    'Certificate',
    'ID Proof',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecruitmentProvider>(
        context,
        listen: false,
      ).fetchCandidateDocuments(widget.candidateId);
    });
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final filePath = result.files.single.path;
        if (filePath == null) return;

        final provider = Provider.of<RecruitmentProvider>(
          context,
          listen: false,
        );

        final success = await provider.uploadDocument(
          candidateId: widget.candidateId,
          documentType: _selectedDocumentType,
          filePath: filePath,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Document uploaded successfully'
                    : provider.documentsError ?? 'Failed to upload document',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(CandidateDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete this ${document.documentType}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<RecruitmentProvider>(
                context,
                listen: false,
              );
              final success = await provider.deleteDocument(document.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Document deleted successfully'
                          : provider.documentsError ??
                                'Failed to delete document',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents - ${widget.candidateName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RecruitmentProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Upload Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Upload New Document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDocumentType,
                      decoration: const InputDecoration(
                        labelText: 'Document Type',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _documentTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDocumentType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: provider.isUploading
                          ? null
                          : _pickAndUploadDocument,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Select and Upload File'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (provider.isUploading) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: provider.uploadProgress),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading... ${(provider.uploadProgress * 100).toInt()}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Allowed formats: PDF, DOC, DOCX, JPG, PNG',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Documents List
              Expanded(
                child: () {
                  if (provider.isDocumentsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.documentsError != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(provider.documentsError!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.fetchCandidateDocuments(
                              widget.candidateId,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final documents = provider.candidateDocuments;

                  if (documents.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No documents uploaded yet'),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        provider.fetchCandidateDocuments(widget.candidateId),
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              child: Icon(
                                _getDocumentIcon(document),
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(document.documentType),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(document.fileName),
                                if (document.createdAt != null)
                                  Text(
                                    'Uploaded: ${document.createdAt!.day}/${document.createdAt!.month}/${document.createdAt!.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download, size: 14),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Downloading document...',
                                          ),
                                        ),
                                      );
                                    },
                                    tooltip: 'Download',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 14),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmation(document),
                                    tooltip: 'Delete',
                                    color: AppColors.danger,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }(),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getDocumentIcon(CandidateDocument document) {
    if (document.isPdf) return Icons.picture_as_pdf;
    if (document.isWord) return Icons.description;
    if (document.isImage) return Icons.image;
    return Icons.insert_drive_file;
  }
}
