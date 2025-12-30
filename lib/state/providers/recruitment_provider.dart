import 'package:flutter/foundation.dart';
import '../../data/models/job_posting_model.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/candidate_document_model.dart';
import '../../data/services/recruitment_service.dart';

/// Provider for recruitment/hiring module state management
class RecruitmentProvider with ChangeNotifier {
  final RecruitmentService _recruitmentService = RecruitmentService();

  // ==================== STATE VARIABLES ====================

  // Job Postings
  List<JobPosting> _jobPostings = [];
  bool _isJobPostingsLoading = false;
  String? _jobPostingsError;

  // Candidates
  List<Candidate> _candidates = [];
  bool _isCandidatesLoading = false;
  String? _candidatesError;
  int? _selectedJobPostingId;

  // Candidate Documents
  List<CandidateDocument> _candidateDocuments = [];
  bool _isDocumentsLoading = false;
  String? _documentsError;

  // File upload progress
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // ==================== GETTERS ====================

  List<JobPosting> get jobPostings => _jobPostings;
  bool get isJobPostingsLoading => _isJobPostingsLoading;
  String? get jobPostingsError => _jobPostingsError;

  List<Candidate> get candidates => _candidates;
  bool get isCandidatesLoading => _isCandidatesLoading;
  String? get candidatesError => _candidatesError;
  int? get selectedJobPostingId => _selectedJobPostingId;

  List<CandidateDocument> get candidateDocuments => _candidateDocuments;
  bool get isDocumentsLoading => _isDocumentsLoading;
  String? get documentsError => _documentsError;

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  String? get error => _jobPostingsError ?? _candidatesError ?? _documentsError;

  // ==================== JOB POSTINGS METHODS ====================

  Future<void> fetchJobPostings() async {
    _isJobPostingsLoading = true;
    _jobPostingsError = null;
    notifyListeners();

    try {
      _jobPostings = await _recruitmentService.getJobPostings();
      _jobPostingsError = null;
    } catch (e) {
      _jobPostingsError = e.toString();
      _jobPostings = [];
    } finally {
      _isJobPostingsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJobPosting(Map<String, dynamic> data) async {
    try {
      final newJobPosting = await _recruitmentService.createJobPosting(data);
      _jobPostings.add(newJobPosting);
      notifyListeners();
      return true;
    } catch (e) {
      _jobPostingsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateJobPosting(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _recruitmentService.updateJobPosting(id, data);
      final index = _jobPostings.indexWhere((jp) => jp.id == id);
      if (index != -1) {
        _jobPostings[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _jobPostingsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteJobPosting(int id) async {
    try {
      await _recruitmentService.deleteJobPosting(id);
      _jobPostings.removeWhere((jp) => jp.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _jobPostingsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== CANDIDATES METHODS ====================

  Future<void> fetchCandidates({int? jobPostingId}) async {
    _isCandidatesLoading = true;
    _candidatesError = null;
    notifyListeners();

    try {
      _candidates = await _recruitmentService.getCandidates(
        jobPostingId: jobPostingId,
      );
      _candidatesError = null;
    } catch (e) {
      _candidatesError = e.toString();
      _candidates = [];
    } finally {
      _isCandidatesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCandidate(Map<String, dynamic> data) async {
    try {
      final newCandidate = await _recruitmentService.createCandidate(data);
      _candidates.add(newCandidate);
      notifyListeners();
      return true;
    } catch (e) {
      _candidatesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCandidate(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _recruitmentService.updateCandidate(id, data);
      final index = _candidates.indexWhere((c) => c.id == id);
      if (index != -1) {
        _candidates[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _candidatesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCandidate(int id) async {
    try {
      await _recruitmentService.deleteCandidate(id);
      _candidates.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _candidatesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setJobPostingFilter(int? jobPostingId) {
    _selectedJobPostingId = jobPostingId;
    fetchCandidates(jobPostingId: jobPostingId);
  }

  // ==================== FILE UPLOAD METHODS ====================

  Future<String?> uploadResume(int candidateId, String filePath) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final resumeUrl = await _recruitmentService.uploadResume(
        candidateId,
        filePath,
      );
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      return resumeUrl;
    } catch (e) {
      _candidatesError = e.toString();
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return null;
    }
  }

  // ==================== CANDIDATE DOCUMENTS METHODS ====================

  Future<void> fetchCandidateDocuments(int candidateId) async {
    _isDocumentsLoading = true;
    _documentsError = null;
    notifyListeners();

    try {
      _candidateDocuments = await _recruitmentService.getCandidateDocuments(
        candidateId,
      );
      _documentsError = null;
    } catch (e) {
      _documentsError = e.toString();
      _candidateDocuments = [];
    } finally {
      _isDocumentsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required int candidateId,
    required String documentType,
    required String filePath,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final document = await _recruitmentService.uploadDocument(
        candidateId: candidateId,
        documentType: documentType,
        filePath: filePath,
      );
      _candidateDocuments.add(document);
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      return true;
    } catch (e) {
      _documentsError = e.toString();
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(int id) async {
    try {
      await _recruitmentService.deleteCandidateDocument(id);
      _candidateDocuments.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _documentsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearErrors() {
    _jobPostingsError = null;
    _candidatesError = null;
    _documentsError = null;
    notifyListeners();
  }
}
