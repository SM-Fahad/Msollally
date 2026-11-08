class CampaignSocialFeedMapper {
  static Map<String, dynamic>? extractCampaignData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) return data;
      return responseData;
    }
    return null;
  }

  static List<dynamic> buildCommentTree(List<dynamic> source) {
    final normalized = source
        .map((e) => _normalizeComment(asMap(e)))
        .where((e) => e.isNotEmpty)
        .toList();
    if (normalized.isEmpty) return [];

    final hasAnyParent = normalized.any(
      (e) => toNullableInt(e['parentCommentId']) != null,
    );
    if (!hasAnyParent) {
      normalized.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
      for (final item in normalized) {
        _sortTreeByDate(item);
      }
      return normalized;
    }

    final byId = <int, Map<String, dynamic>>{};
    final flatNodes = <Map<String, dynamic>>[];
    for (final root in normalized) {
      _collectNodes(root, flatNodes);
    }

    for (final node in flatNodes) {
      final id = toInt(node['id']);
      if (id > 0) {
        node['replies'] = <dynamic>[];
        byId[id] = node;
      }
    }

    final roots = <dynamic>[];
    for (final node in byId.values) {
      final parentId = toNullableInt(node['parentCommentId']);
      if (parentId == null || !byId.containsKey(parentId)) {
        roots.add(node);
      } else {
        (byId[parentId]!['replies'] as List<dynamic>).add(node);
      }
    }

    for (final root in roots) {
      _sortTreeByDate(root);
    }
    roots.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
    return roots;
  }

  static bool appendReplyRecursively(
    List<dynamic> source,
    int parentId,
    dynamic reply,
  ) {
    for (var i = 0; i < source.length; i++) {
      final node = asMap(source[i]);
      if (toInt(node['id']) == parentId) {
        final List<dynamic> children = List<dynamic>.from(
          (node['replies'] as List?) ?? const [],
        );
        children.insert(0, reply);
        node['replies'] = children;
        source[i] = node;
        return true;
      }

      final List<dynamic> children = List<dynamic>.from(
        (node['replies'] as List?) ?? const [],
      );
      final found = appendReplyRecursively(children, parentId, reply);
      if (found) {
        node['replies'] = children;
        source[i] = node;
        return true;
      }
    }
    return false;
  }

  static List<dynamic> removeReplyById(List<dynamic> source, dynamic id) {
    source.removeWhere((item) => asMap(item)['id'] == id);
    for (var i = 0; i < source.length; i++) {
      final node = asMap(source[i]);
      node['replies'] = removeReplyById(
        List<dynamic>.from((node['replies'] as List?) ?? const []),
        id,
      );
      source[i] = node;
    }
    return source;
  }

  static DateTime dateOf(dynamic input) {
    final raw = asMap(input)['createdAt']?.toString();
    if (raw == null || raw.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(raw)?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static int toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static int? toNullableInt(dynamic value) {
    final v = toInt(value);
    return v <= 0 ? null : v;
  }

  static Map<String, dynamic> asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    return <String, dynamic>{};
  }

  static String pickName(Map<String, dynamic> item) {
    final author = item['author'];
    if (author is Map<String, dynamic>) {
      final profile = author['profile'];
      if (profile is Map<String, dynamic>) {
        final fullName = profile['fullName']?.toString().trim();
        if (fullName != null && fullName.isNotEmpty) return fullName;
        final company = profile['companyName']?.toString().trim();
        if (company != null && company.isNotEmpty) return company;
      }
      final fullName = author['fullName']?.toString().trim();
      if (fullName != null && fullName.isNotEmpty) return fullName;
      final username = author['username']?.toString().trim();
      if (username != null && username.isNotEmpty) return username;
    }

    final fullName = item['fullName']?.toString().trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    final username = item['username']?.toString().trim();
    if (username != null && username.isNotEmpty) return username;
    final name = item['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Partner';
  }

  static String pickAuthorImage(Map<String, dynamic> item) {
    final author = item['author'];
    if (author is Map<String, dynamic>) {
      final profile = author['profile'];
      if (profile is Map<String, dynamic>) {
        return profile['profilePicture']?.toString().trim() ?? '';
      }
      return author['profilePicture']?.toString().trim() ?? '';
    }

    return (item['profilePicture'] ?? item['profileImage'] ?? '')
        .toString()
        .trim();
  }

  static String detectMediaType(String source, {String? fallbackExt}) {
    final raw = source.trim().toLowerCase();
    final ext = (fallbackExt ?? raw.split('?').first.split('.').last)
        .toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext)) {
      return 'image';
    }
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      return 'video';
    }
    return raw.isEmpty ? '' : 'file';
  }

  static Map<String, dynamic> parsePublicProfile(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return {};
    final data = responseData['data'];
    if (data is Map<String, dynamic>) return data;
    return responseData;
  }

  static String extractPublicProfilePicture(Map<String, dynamic> userMap) {
    final profile = userMap['profile'];
    if (profile is Map<String, dynamic>) {
      return profile['profilePicture']?.toString().trim() ?? '';
    }
    return userMap['profilePicture']?.toString().trim() ?? '';
  }

  static void _sortTreeByDate(dynamic node) {
    final map = asMap(node);
    final replies = List<dynamic>.from((map['replies'] as List?) ?? const []);
    replies.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
    map['replies'] = replies;
    for (final child in replies) {
      _sortTreeByDate(child);
    }
  }

  static Map<String, dynamic> _normalizeComment(Map<String, dynamic> input) {
    if (input.isEmpty) return {};
    final comment = Map<String, dynamic>.from(input);
    final replies = (comment['replies'] as List?) ?? const [];
    comment['replies'] = replies
        .map((e) => _normalizeComment(asMap(e)))
        .where((e) => e.isNotEmpty)
        .toList();
    return comment;
  }

  static void _collectNodes(
    Map<String, dynamic> node,
    List<Map<String, dynamic>> out,
  ) {
    out.add(node);
    final replies = (node['replies'] as List?) ?? const [];
    for (final reply in replies) {
      _collectNodes(asMap(reply), out);
    }
  }
}
