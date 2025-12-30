/// Candidate model for job applications
class Candidate {
  final int id;
  final int jobPostingId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime appliedDate;
  final String? resumeUrl;
  final String status;
  final String? createdBy;
  final String? modifiedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Candidate({
    required this.id,
    required this.jobPostingId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.appliedDate,
    this.resumeUrl,
    this.status = 'Pending',
    this.createdBy,
    this.modifiedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'],
      jobPostingId: json['job_posting_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      appliedDate: DateTime.parse(json['applied_date']),
      resumeUrl: json['resume_url'],
      status: json['status'] ?? 'Pending',
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
      'job_posting_id': jobPostingId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'resume_url': resumeUrl,
      'status': status,
    };
  }

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Check if candidate has resume
  bool get hasResume => resumeUrl != null && resumeUrl!.isNotEmpty;

  /// Get status color for badge
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'green';
      case 'rejected':
        return 'red';
      case 'pending':
      default:
        return 'orange';
    }
  }

  /// Check if candidate is pending
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if candidate is accepted
  bool get isAccepted => status.toLowerCase() == 'accepted';

  /// Check if candidate is rejected
  bool get isRejected => status.toLowerCase() == 'rejected';
}
