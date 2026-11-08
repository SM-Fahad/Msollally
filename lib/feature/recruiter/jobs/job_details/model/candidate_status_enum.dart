enum CandidateStatus { pending, accepted, shortlisted, rejected }

extension CandidateStatusExtension on CandidateStatus {
  String get apiValue {
    switch (this) {
      case CandidateStatus.pending:
        return 'pending';
      case CandidateStatus.accepted:
        return 'accepted';
      case CandidateStatus.shortlisted:
        return 'shortlisted';
      case CandidateStatus.rejected:
        return 'rejected';
    }
  }

  /// Get the display label for this status
  String get displayLabel {
    switch (this) {
      case CandidateStatus.pending:
        return 'Pending';
      case CandidateStatus.accepted:
        return 'Accepted';
      case CandidateStatus.shortlisted:
        return 'Shortlisted';
      case CandidateStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Convert API status string to CandidateStatus enum
CandidateStatus candidateStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return CandidateStatus.pending;
    case 'accepted':
      return CandidateStatus.accepted;
    case 'shortlisted':
      return CandidateStatus.shortlisted;
    case 'rejected':
      return CandidateStatus.rejected;
    default:
      return CandidateStatus.pending;
  }
}
