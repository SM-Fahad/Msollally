import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../model/campaign_notice_model.dart';
import '../service/campaign_notice_service.dart';

class CampaignNoticeController extends GetxController {
  final int campaignId;
  final CampaignNoticeService _service;

  CampaignNoticeController({
    required this.campaignId,
    CampaignNoticeService? service,
  }) : _service = service ?? CampaignNoticeService();

  final notices = <CampaignNoticeModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final titleController = TextEditingController();
  final noticeController = TextEditingController();
  final editingNoticeId = RxnInt();
  final expandedNoticeIds = <int>{}.obs;

  bool get isEditing => editingNoticeId.value != null;

  @override
  void onInit() {
    super.onInit();
    fetchNotices();
  }

  Future<void> fetchNotices() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      notices.assignAll(await _service.fetchNotices(campaignId));
      expandedNoticeIds.clear();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(CampaignNoticeModel notice) {
    editingNoticeId.value = notice.id;
    titleController.text = notice.title;
    noticeController.text = notice.notice;
  }

  void clearForm() {
    editingNoticeId.value = null;
    titleController.clear();
    noticeController.clear();
  }

  bool isNoticeExpanded(int id) => expandedNoticeIds.contains(id);

  void toggleNoticeExpanded(int id) {
    if (expandedNoticeIds.contains(id)) {
      expandedNoticeIds.remove(id);
    } else {
      expandedNoticeIds.add(id);
    }
    expandedNoticeIds.refresh();
  }

  Future<bool> saveNotice() async {
    final title = titleController.text.trim();
    final noticeText = noticeController.text.trim();

    if (title.isEmpty) {
      EasyLoading.showError('Notice title is required');
      return false;
    }
    if (noticeText.isEmpty) {
      EasyLoading.showError('Notice description is required');
      return false;
    }

    try {
      isSaving.value = true;
      if (isEditing) {
        final updated = await _service.updateNotice(
          noticeId: editingNoticeId.value!,
          title: title,
          notice: noticeText,
        );
        final index = notices.indexWhere((e) => e.id == updated.id);
        if (index >= 0) {
          notices[index] = updated;
        }
        EasyLoading.showSuccess('Notice updated');
      } else {
        final created = await _service.createNotice(
          campaignId: campaignId,
          title: title,
          notice: noticeText,
        );
        notices.insert(0, created);
        EasyLoading.showSuccess('Notice created');
      }
      clearForm();
      return true;
    } catch (e) {
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    noticeController.dispose();
    super.onClose();
  }
}
