import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/recruiter/chat/model/recruiter_chat_room_model.dart';
import 'package:msollaally/feature/recruiter/chat/repository/recruiter_chat_repository.dart';
import 'package:msollaally/feature/recruiter/chat/service/chat_badge_service.dart';

class InboxController extends GetxController {
  final RecruiterChatRepository _repository;
  final SharedPreferenceHelper _prefs;

  InboxController({
    RecruiterChatRepository? repository,
    SharedPreferenceHelper? prefs,
  }) : _repository = repository ?? RecruiterChatRepository(),
       _prefs = prefs ?? SharedPreferenceHelper();

  final currentUserId = 0.obs;

  final chats = <RecruiterChatRoomModel>[].obs;
  final searchQuery = ''.obs;
  final selectedTab = 'All'.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    loadChats();
  }

  Future<void> _loadCurrentUser() async {
    final id = await _prefs.getUserId();
    currentUserId.value = int.tryParse(id ?? '') ?? 0;
  }

  Future<void> loadChats() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repository.getChats();
      chats.assignAll(result);
      // Push badge count to global singleton so campus tab badge updates
      // even when InboxController is not currently registered.
      ChatBadgeService.unreadCount.value = totalUnreadRooms;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  List<RecruiterChatRoomModel> get filteredChats {
    List<RecruiterChatRoomModel> list = chats;

    if (selectedTab.value == 'Courses') {
      list = list.where((c) => c.isGroup).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  /// Returns the display name for a chat room:
  /// - Group chat → group name or 'Group Chat'
  /// - Personal chat → the OTHER participant's username
  String displayName(RecruiterChatRoomModel room) {
    if (room.isGroup) {
      return room.name.trim().isNotEmpty ? room.name.trim() : 'Group Chat';
    }
    // For personal chats: find the participant that is NOT the current user
    final other = room.participants.firstWhere(
      (p) => p.user.id != currentUserId.value,
      orElse: () => room.participants.isNotEmpty
          ? room.participants.first
          : const RecruiterChatParticipantModel(
              id: 0,
              user: RecruiterChatUserModel(
                id: 0,
                username: 'Unknown',
                phoneNumber: '',
                role: '',
              ),
              lastReadMessageId: null,
              isMuted: false,
            ),
    );
    return other.user.displayName;
  }

  /// Avatar initials for a room.
  String avatarInitial(RecruiterChatRoomModel room) {
    final name = displayName(room);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Returns the number of unread messages for a room.
  /// Uses lastReadMessageId of the current user's participant entry.
  /// If lastReadMessageId is null → all messages are unread (show 1+ indicator).
  /// We don't have per-room message counts from the list API, so we use
  /// presence of null vs non-null as a binary unread flag for now.
  bool hasUnread(RecruiterChatRoomModel room) {
    final me = room.participants.where((p) => p.user.id == currentUserId.value);
    if (me.isEmpty) return false;
    // If my lastReadMessageId is null it means I've never read any message
    return me.first.lastReadMessageId == null;
  }

  /// Total rooms with unread messages — used for the badge on the message icon.
  int get totalUnreadRooms => chats.where(hasUnread).length;

  /// Derive last-message preview from the room model.
  String lastMessage(RecruiterChatRoomModel room) {
    return room.isGroup ? 'Group chat' : 'Tap to open chat';
  }
}
