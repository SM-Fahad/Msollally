part of '../../details/controller/fusra_details_controller.dart';

extension FusraDetailsRegistrationApi on FusraDetailsController {
  Future<void> fetchRegistrations({
    String search = '',
    bool loadMore = false,
  }) async {
    final id = competitionId.value.trim();

    if (id.isEmpty) {
      _setRegistrationError('Competition id not found');
      return;
    }

    if (!_startRegistrationLoading(loadMore)) return;

    final page = loadMore ? currentRegistrationPage.value + 1 : 1;

    try {
      final token = await _prefs.getAccessToken();

      final response = await _networkCaller.getRequest(
        Urls.getRegistrations(
          competitionId: id,
          search: Uri.encodeQueryComponent(search.trim()),
          page: page,
          limit: registrationLimit,
        ),
        token: _bearerToken(token),
      );

      if (!response.isSuccess) {
        if (!loadMore) _clearRegistrations();
        registrationsError.value = _safeValue(
          response.errorMessage,
          fallback: 'Failed to load registrations',
        );
        return;
      }

      final body = response.responseData;
      final payload = _resolveRegistrationPayload(body);
      final dataMap = body is Map<String, dynamic> ? body : <String, dynamic>{};

      final students = _mapRegistrationStudents(payload['items']);

      if (loadMore) {
        registeredStudents.addAll(students);
      } else {
        registeredStudents.assignAll(students);
      }

      _setPagination(
        page: page,
        mappedCount: students.length,
        pagination: payload['pagination'],
        dataMap: dataMap,
      );
    } catch (e) {
      if (!loadMore) _clearRegistrations();
      registrationsError.value = _cleanException(e);
    } finally {
      _stopRegistrationLoading(loadMore);
    }
  }

  Future<void> exportRegistrationsCsv() async {
    await _exportRegistrationsFile(isCsv: true);
  }

  Future<void> exportRegistrationsExcel() async {
    await _exportRegistrationsFile(isCsv: false);
  }

  Future<void> _exportRegistrationsFile({required bool isCsv}) async {
    final id = competitionId.value.trim();

    if (id.isEmpty) {
      EasyLoading.showError('Competition id not found');
      return;
    }

    try {
      EasyLoading.show(status: 'Downloading...');

      final token = await _prefs.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final fileConfig = _registrationExportConfig(id, isCsv);

      final response = await http.get(
        Uri.parse(fileConfig.url),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to download file');
      }

      final tempFile = File(
        '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_${fileConfig.fileName}',
      );

      await tempFile.writeAsBytes(response.bodyBytes, flush: true);

      await DeviceDownloadService.saveToDownloads(
        sourcePath: tempFile.path,
        fileName: fileConfig.fileName,
        mimeType: fileConfig.mimeType,
      );

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Saved to Downloads');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_cleanException(e));
    }
  }

  bool _startRegistrationLoading(bool loadMore) {
    if (loadMore) {
      if (isRegistrationsLoading.value || isLoadingMore.value) return false;
      isLoadingMore.value = true;
      return true;
    }

    if (isRegistrationsLoading.value) return false;

    isRegistrationsLoading.value = true;
    registrationsError.value = '';
    currentRegistrationPage.value = 1;
    totalRegistrationPages.value = 1;
    hasMoreRegistrations.value = true;
    expandedRegistrationSections.clear();
    registeredStudents.clear();

    return true;
  }

  void _stopRegistrationLoading(bool loadMore) {
    if (loadMore) {
      isLoadingMore.value = false;
    } else {
      isRegistrationsLoading.value = false;
    }
  }

  void _setRegistrationError(String message) {
    registrationsError.value = message;
    _clearRegistrations();
  }

  void _clearRegistrations() {
    registeredStudents.clear();
    totalRegistration.value = 0;
    hasMoreRegistrations.value = false;
  }

  String? _bearerToken(String? token) {
    if (token == null || token.isEmpty) return null;
    return 'Bearer $token';
  }

  List<RegistrationStudent> _mapRegistrationStudents(dynamic rawList) {
    if (rawList is! List) return const [];

    final students = <RegistrationStudent>[];

    for (final item in rawList) {
      if (item is! Map) continue;

      final row = Map<String, dynamic>.from(item);

      students.add(
        RegistrationStudent(
          uniqueId: _studentUniqueId(row, students.length),
          name: _safeValue(
            row['fullName'] ?? row['registerName'] ?? row['name'],
          ),
          id: _safeValue(row['studentId']),
          position: _safeValue(row['rank'] ?? row['position']),
          positionColor: _positionColor(row['rank'] ?? row['position']),
          positionTextColor: _positionTextColor(row['rank'] ?? row['position']),
          date: _safeValue(row['createdAt'] ?? row['date']),
          qualificationStatus: _qualificationStatus(
            row['hasPassedQualification'],
          ),
          qualificationScore: _safeValue(row['qualificationScore']),
          attempts: _safeValue(row['weeklyFinalAttempts']),
          coins: _safeValue(row['coins']),
          academic: _academicSection(row),
          contact: _contactSection(row),
          // address: _addressSection(row),
          // bank: _bankSection(row),
        ),
      );
    }

    return students;
  }

  String _studentUniqueId(Map<String, dynamic> row, int index) {
    return _safeValue(
      row['registrationId'] ?? row['userId'] ?? row['studentId'] ?? row['id'],
      fallback: 'student-${registeredStudents.length + index + 1}',
    );
  }

  RegistrationSectionData _academicSection(Map<String, dynamic> row) {
    return RegistrationSectionData(
      title: 'Academic Information',
      backgroundColor: AppColors.linenF7F4EC,
      fields: [
        InfoField(
          label: 'University',
          value: _safeValue(row['university'] ?? row['universityName']),
        ),
        InfoField(label: 'Program', value: _safeValue(row['programName'])),
        InfoField(label: 'Year', value: _safeValue(row['studyYear'])),
      ],
    );
  }

  RegistrationSectionData _contactSection(Map<String, dynamic> row) {
    return RegistrationSectionData(
      title: 'Contact Information',
      backgroundColor: AppColors.aliceBlueEDF5FF,
      fields: [
        InfoField(label: 'Email', value: _safeValue(row['email'])),
        InfoField(label: 'Phone', value: _safeValue(row['phone'])),
      ],
    );
  }

  void _setPagination({
    required int page,
    required int mappedCount,
    required Map<String, dynamic> pagination,
    required Map<String, dynamic> dataMap,
  }) {
    final totalPages = _resolveInt(
      pagination['totalPages'] ?? dataMap['totalPages'],
      fallback: 1,
    );

    final totalCount = _resolveInt(
      pagination['total'] ??
          pagination['totalItems'] ??
          dataMap['totalRegistration'] ??
          dataMap['total'],
    );

    currentRegistrationPage.value = page;
    totalRegistrationPages.value = totalPages < 1 ? 1 : totalPages;
    totalRegistration.value = totalCount == 0
        ? registeredStudents.length
        : totalCount;

    hasMoreRegistrations.value = _hasMoreResults(
      mappedCount: mappedCount,
      currentPage: currentRegistrationPage.value,
      totalPages: totalRegistrationPages.value,
    );
  }

  _RegistrationExportConfig _registrationExportConfig(String id, bool isCsv) {
    if (isCsv) {
      return _RegistrationExportConfig(
        url: Urls.getExportCSV(id),
        fileName: 'registrations_$id.csv',
        mimeType: 'text/csv',
      );
    }

    return _RegistrationExportConfig(
      url: Urls.getExportExcel(id),
      fileName: 'registrations_$id.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Map<String, dynamic> _resolveRegistrationPayload(dynamic body) {
    if (body is List) {
      return {'items': body, 'pagination': <String, dynamic>{}};
    }

    if (body is! Map<String, dynamic>) {
      return {'items': const [], 'pagination': <String, dynamic>{}};
    }

    final data = body['data'];

    if (data is List) {
      return {'items': data, 'pagination': _asMap(body['pagination'])};
    }

    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final items =
          dataMap['data'] ?? dataMap['items'] ?? dataMap['registrations'];

      return {
        'items': items is List ? items : const [],
        'pagination': _asMap(dataMap['pagination']).isNotEmpty
            ? _asMap(dataMap['pagination'])
            : dataMap,
      };
    }

    return {'items': const [], 'pagination': <String, dynamic>{}};
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(value);
  }

  bool _hasMoreResults({
    required int mappedCount,
    required int currentPage,
    required int totalPages,
  }) {
    if (mappedCount == 0) return false;
    if (totalPages > 1) return currentPage < totalPages;
    return mappedCount >= registrationLimit;
  }

  int _resolveInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  String _safeValue(dynamic value, {String fallback = 'N/A'}) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;

    return text;
  }

  String _qualificationStatus(dynamic value) {
    if (value is bool) return value ? 'Passed' : 'Pending';

    final text = _safeValue(value);
    if (text == 'N/A') return text;

    return text;
  }

  Color _positionColor(dynamic rankValue) {
    final rank = _resolveInt(rankValue);

    if (rank == 1) return AppColors.navajoWhiteFFE7A3;
    if (rank == 2) return AppColors.lavenderDCE8F6;
    if (rank == 3) return AppColors.bisqueF6DBC7;

    return AppColors.aliceBlueE8F1FD;
  }

  Color _positionTextColor(dynamic rankValue) {
    final rank = _resolveInt(rankValue);

    if (rank >= 1 && rank <= 3) return AppColors.saddleBrown6B4F00;

    return AppColors.royalBlue1D4ED8;
  }

  String _cleanException(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }
}

class _RegistrationExportConfig {
  const _RegistrationExportConfig({
    required this.url,
    required this.fileName,
    required this.mimeType,
  });

  final String url;
  final String fileName;
  final String mimeType;
}
