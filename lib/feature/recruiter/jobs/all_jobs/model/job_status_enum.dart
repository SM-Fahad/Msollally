enum JobStatus { draft, published, closed, filled, archived }

extension JobStatusExtension on JobStatus {
  /// Get the API value for this status
  String get apiValue {
    switch (this) {
      case JobStatus.draft:
        return 'draft';
      case JobStatus.published:
        return 'published';
      case JobStatus.closed:
        return 'closed';
      case JobStatus.filled:
        return 'filled';
      case JobStatus.archived:
        return 'archived';
    }
  }

  /// Get the display label for this status
  String get displayLabel {
    switch (this) {
      case JobStatus.draft:
        return 'On-Hold';
      case JobStatus.published:
        return 'Open';
      case JobStatus.closed:
        return 'Closed';
      case JobStatus.filled:
        return 'Filled';
      case JobStatus.archived:
        return 'Archived';
    }
  }
}

/// Convert API status string to JobStatus enum
JobStatus statusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'draft':
      return JobStatus.draft;
    case 'published':
      return JobStatus.published;
    case 'closed':
      return JobStatus.closed;
    case 'filled':
      return JobStatus.filled;
    case 'archived':
      return JobStatus.archived;
    default:
      return JobStatus.published;
  }
}
