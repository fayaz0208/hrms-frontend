/// Candidate Document model for file uploads
class CandidateDocument {
  final int id;
  final int candidateId;
  final String documentType;
  final String documentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? modifiedBy;

  CandidateDocument({
    required this.id,
    required this.candidateId,
    required this.documentType,
    required this.documentUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
  });

  factory CandidateDocument.fromJson(Map<String, dynamic> json) {
    return CandidateDocument(
      id: json['id'],
      candidateId: json['candidate_id'],
      documentType: json['document_type'],
      documentUrl: json['document_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      createdBy: json['created_by'],
      modifiedBy: json['modified_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candidate_id': candidateId,
      'document_type': documentType,
      'document_url': documentUrl,
    };
  }

  /// Get file name from URL
  String get fileName {
    try {
      return documentUrl.split('/').last;
    } catch (e) {
      return 'document';
    }
  }

  /// Get file extension
  String get fileExtension {
    try {
      return fileName.split('.').last.toUpperCase();
    } catch (e) {
      return 'FILE';
    }
  }

  /// Check if document is an image
  bool get isImage {
    final ext = fileExtension.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
  }

  /// Check if document is a PDF
  bool get isPdf => fileExtension.toLowerCase() == 'pdf';

  /// Check if document is a Word document
  bool get isWord {
    final ext = fileExtension.toLowerCase();
    return ['doc', 'docx'].contains(ext);
  }

  /// Get icon for document type
  String get documentIcon {
    if (isPdf) return 'picture_as_pdf';
    if (isWord) return 'description';
    if (isImage) return 'image';
    return 'insert_drive_file';
  }
}
