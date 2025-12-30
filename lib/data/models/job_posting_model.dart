/// Approval status enum for job postings
enum ApprovalStatus {
  pending,
  accepted,
  rejected;

  String toJson() => name;

  static ApprovalStatus fromJson(String value) {
    return ApprovalStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ApprovalStatus.pending,
    );
  }
}

/// Job Posting model for recruitment
class JobPosting {
  final int id;
  final int jobDescriptionId;
  final int numberOfPositions;
  final String employmentType;
  final String location;
  final int? salary;
  final DateTime postingDate;
  final DateTime? closingDate;
  final ApprovalStatus approvalStatus;
  final String? createdBy;
  final String? modifiedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobPosting({
    required this.id,
    required this.jobDescriptionId,
    required this.numberOfPositions,
    required this.employmentType,
    required this.location,
    this.salary,
    required this.postingDate,
    this.closingDate,
    this.approvalStatus = ApprovalStatus.pending,
    this.createdBy,
    this.modifiedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['id'],
      jobDescriptionId: json['job_description_id'],
      numberOfPositions: json['number_of_positions'],
      employmentType: json['employment_type'],
      location: json['location'],
      salary: json['salary'],
      postingDate: DateTime.parse(json['posting_date']),
      closingDate: json['closing_date'] != null
          ? DateTime.parse(json['closing_date'])
          : null,
      approvalStatus: json['approval_status'] != null
          ? ApprovalStatus.fromJson(json['approval_status'])
          : ApprovalStatus.pending,
      createdBy: json['created_by'],
      modifiedBy: json['modified_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_description_id': jobDescriptionId,
      'number_of_positions': numberOfPositions,
      'employment_type': employmentType,
      'location': location,
      'salary': salary,
      'posting_date': postingDate.toIso8601String().split('T')[0],
      'closing_date': closingDate?.toIso8601String().split('T')[0],
    };
  }

  /// Check if job posting is still open
  bool get isOpen {
    if (closingDate == null) return true;
    return DateTime.now().isBefore(closingDate!);
  }

  /// Get status badge color
  String get statusColor {
    switch (approvalStatus) {
      case ApprovalStatus.accepted:
        return 'green';
      case ApprovalStatus.rejected:
        return 'red';
      case ApprovalStatus.pending:
        return 'orange';
    }
  }
}
