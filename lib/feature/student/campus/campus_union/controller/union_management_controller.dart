import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/union_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/campus_service.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/union_management_models.dart';

class UnionManagementController extends GetxController {
  final int unionId;
  UnionManagementController._({required this.unionId});
  factory UnionManagementController.of(int unionId) {
    final tag = 'union_mgmt_$unionId';
    if (!Get.isRegistered<UnionManagementController>(tag: tag)) {
      Get.put(
        UnionManagementController._(unionId: unionId),
        tag: tag,
        permanent: false,
      );
    }
    return Get.find<UnionManagementController>(tag: tag);
  }

  final _service = CampusService();
  final members = <UnionMemberModel>[].obs;
  final officials = <UnionMemberModel>[].obs;
  final pendingRequests = <UnionMemberModel>[].obs;
  final stats = Rx<UnionStatsModel?>(null);
  final union = Rx<UnionModel?>(null);

  final isLoadingMembers = false.obs;
  final isLoadingOfficials = false.obs;
  final isLoadingPending = false.obs;
  final isLoadingStats = false.obs;
  final selectedTab = 0.obs;

  static const String rolePresident = 'president';
  static const String roleOfficial = 'official';
  static const String roleMember = 'member';

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void loadAll() {
    fetchMembers();
    fetchOfficials();
    fetchPendingRequests();
    fetchStats();
    fetchUnionDetails();
  }

  Future<void> fetchUnionDetails() async {
    try {
      union.value = await _service.fetchUnionById(unionId);
    } catch (e) {
      debugPrint('fetchUnionDetails error: $e');
    }
  }

  Future<void> fetchMembers() async {
    try {
      isLoadingMembers.value = true;
      members.assignAll(await _service.fetchUnionMembers(unionId));
    } catch (e) {
      debugPrint('fetchMembers error: $e');
    } finally {
      isLoadingMembers.value = false;
    }
  }

  Future<void> fetchOfficials() async {
    try {
      isLoadingOfficials.value = true;
      officials.assignAll(await _service.fetchUnionOfficials(unionId));
    } catch (e) {
      debugPrint('fetchOfficials error: $e');
    } finally {
      isLoadingOfficials.value = false;
    }
  }

  Future<void> fetchPendingRequests() async {
    try {
      isLoadingPending.value = true;
      pendingRequests.assignAll(await _service.fetchPendingRequests(unionId));
    } catch (e) {
      debugPrint('fetchPendingRequests error: $e');
    } finally {
      isLoadingPending.value = false;
    }
  }

  Future<void> fetchStats() async {
    try {
      isLoadingStats.value = true;
      stats.value = await _service.fetchUnionStats(unionId);
    } catch (e) {
      debugPrint('fetchStats error: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> approveRequest(int membershipId) async {
    EasyLoading.show(status: 'Approving...');
    try {
      final ok = await _service.approveUnionMember(unionId, membershipId);
      if (ok) {
        pendingRequests.removeWhere((m) => m.id == membershipId);
        EasyLoading.showSuccess('Request approved');
        fetchMembers();
        fetchStats();
      } else {
        EasyLoading.showError('Failed to approve');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> rejectRequest(int membershipId) async {
    EasyLoading.show(status: 'Rejecting...');
    try {
      final ok = await _service.rejectUnionMember(unionId, membershipId);
      if (ok) {
        pendingRequests.removeWhere((m) => m.id == membershipId);
        EasyLoading.showSuccess('Request rejected');
        fetchStats();
      } else {
        EasyLoading.showError('Failed to reject');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> removeMember(int memberId) async {
    EasyLoading.show(status: 'Removing member...');
    try {
      final ok = await _service.removeUnionMember(unionId, memberId);
      if (ok) {
        members.removeWhere((m) => m.id == memberId);
        EasyLoading.showSuccess('Member removed');
        fetchStats();
      } else {
        EasyLoading.showError('Failed to remove member');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> promoteToOfficial(int memberId) async {
    await _changeRole(memberId, roleOfficial);
  }

  Future<void> demoteToMember(int memberId) async {
    await _changeRole(memberId, roleMember);
  }

  Future<void> _changeRole(int memberId, String newRole) async {
    EasyLoading.show(status: 'Updating role...');
    try {
      final ok = await _service.updateMemberRole(unionId, memberId, newRole);
      if (ok) {
        EasyLoading.showSuccess('Role updated to $newRole');
        fetchMembers();
        fetchOfficials();
      } else {
        EasyLoading.showError('Failed to update role');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> transferPresidency(int newPresidentUserId) async {
    EasyLoading.show(status: 'Transferring presidency...');
    try {
      final ok = await _service.transferPresidency(unionId, newPresidentUserId);
      if (ok) {
        EasyLoading.showSuccess('Presidency transferred successfully');
        // Refresh to reflect new roles
        fetchMembers();
        fetchUnionDetails();
      } else {
        EasyLoading.showError('Failed to transfer presidency');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> inviteMember(int userId) async {
    EasyLoading.show(status: 'Sending invite...');
    try {
      final errorMsg = await _service.inviteToUnion(unionId, userId);
      if (errorMsg == null) {
        EasyLoading.showSuccess('Invite sent!');
      } else {
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }
}
