import 'package:dio/dio.dart';
import '../models/job_posting_model.dart';
import '../models/candidate_model.dart';
import '../models/candidate_document_model.dart';
import 'api_service.dart';

/// Service for recruitment/hiring module API calls
class RecruitmentService {
  final ApiService _apiService = ApiService();

  // ==================== JOB POSTINGS ====================

  /// Get all job postings
  Future<List<JobPosting>> getJobPostings({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _apiService.get(
        '/job-postings/',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => JobPosting.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch job postings: $e');
    }
  }

  /// Get job posting by ID
  Future<JobPosting> getJobPostingById(int id) async {
    try {
      final response = await _apiService.get('/job-postings/$id');
      return JobPosting.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch job posting: $e');
    }
  }

  /// Create new job posting
  Future<JobPosting> createJobPosting(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/job-postings/', data: data);
      return JobPosting.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create job posting: $e');
    }
  }

  /// Update job posting
  Future<JobPosting> updateJobPosting(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/job-postings/$id', data: data);
      return JobPosting.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update job posting: $e');
    }
  }

  /// Delete job posting
  Future<void> deleteJobPosting(int id) async {
    try {
      await _apiService.delete('/job-postings/$id');
    } catch (e) {
      throw Exception('Failed to delete job posting: $e');
    }
  }

  // ==================== CANDIDATES ====================

  /// Get all candidates with optional filters
  Future<List<Candidate>> getCandidates({
    int? jobPostingId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (jobPostingId != null) queryParams['job_posting_id'] = jobPostingId;
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get(
        '/candidates/',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Candidate.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch candidates: $e');
    }
  }

  /// Get candidate by ID
  Future<Candidate> getCandidateById(int id) async {
    try {
      final response = await _apiService.get('/candidates/$id');
      return Candidate.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch candidate: $e');
    }
  }

  /// Create new candidate
  Future<Candidate> createCandidate(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/candidates/', data: data);
      return Candidate.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create candidate: $e');
    }
  }

  /// Update candidate
  Future<Candidate> updateCandidate(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/candidates/$id', data: data);
      return Candidate.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update candidate: $e');
    }
  }

  /// Delete candidate
  Future<void> deleteCandidate(int id) async {
    try {
      await _apiService.delete('/candidates/$id');
    } catch (e) {
      throw Exception('Failed to delete candidate: $e');
    }
  }

  /// Upload resume for candidate
  Future<String> uploadResume(int candidateId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiService.uploadFile(
        '/candidates/$candidateId/upload-resume',
        formData,
      );

      return response.data['resume_url'];
    } catch (e) {
      throw Exception('Failed to upload resume: $e');
    }
  }

  // ==================== CANDIDATE DOCUMENTS ====================

  /// Get all documents for a candidate
  Future<List<CandidateDocument>> getCandidateDocuments(int candidateId) async {
    try {
      final response = await _apiService.get(
        '/candidate-documents/',
        queryParameters: {'candidate_id': candidateId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => CandidateDocument.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch candidate documents: $e');
    }
  }

  /// Upload document for candidate
  Future<CandidateDocument> uploadDocument({
    required int candidateId,
    required String documentType,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'candidate_id': candidateId,
        'document_type': documentType,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiService.uploadFile(
        '/candidate-documents/upload',
        formData,
      );

      return CandidateDocument.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Delete candidate document
  Future<void> deleteCandidateDocument(int id) async {
    try {
      await _apiService.delete('/candidate-documents/$id');
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Download file from URL
  /// Returns the local file path where the file was saved
  Future<String> downloadFile(String url, String fileName) async {
    try {
      // This is a simplified version - in production you'd want to:
      // 1. Get proper download directory
      // 2. Handle permissions
      // 3. Show download progress
      // Return the URL for now - actual file download would need platform-specific implementation
      return url;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }
}
