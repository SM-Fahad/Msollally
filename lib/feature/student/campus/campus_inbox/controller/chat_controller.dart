import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/student/campus/chat/model/student_chat_room_model.dart';
import 'package:msollaally/feature/student/campus/chat/repository/student_chat_repository.dart';
import 'package:msollaally/feature/student/campus/chat/service/chat_badge_service.dart';

class InboxController extends GetxController {
  final StudentChatRepository _repository;
  final SharedPreferenceHelper _prefs;

  InboxController({
    StudentChatRepository? repository,
    SharedPreferenceHelper? prefs,
  }) : _repository = repository ?? StudentChatRepository(),
       _prefs = prefs ?? SharedPreferenceHelper();

  final currentUserId = 0.obs;

  final chats = <StudentChatRoomModel>[].obs;
  final readRoomIds = <int>{}.obs;
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

  List<StudentChatRoomModel> get filteredChats {
    List<StudentChatRoomModel> list = chats;

    if (selectedTab.value == 'Courses') {
      list = list.where((c) => c.isGroup).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      list = list.where((c) {
        final dName = displayName(c).toLowerCase();
        final rName = c.name.toLowerCase();
        final lastMsg = lastMessage(c).toLowerCase();
        final participantMatch = c.participants.any((p) =>
            p.user.displayName.toLowerCase().contains(q) ||
            p.user.username.toLowerCase().contains(q));
        return dName.contains(q) || rName.contains(q) || lastMsg.contains(q) || participantMatch;
      }).toList();
    }

    return list;
  }

  /// Returns the display name for a chat room:
  /// - Group chat → group name or 'Group Chat'
  /// - Personal chat → the OTHER participant's username
  String displayName(StudentChatRoomModel room) {
    if (room.isGroup) {
      return room.name.trim().isNotEmpty ? room.name.trim() : 'Group Chat';
    }
    // For personal chats: find the participant that is NOT the current user
    final other = room.participants.firstWhere(
      (p) => p.user.id != currentUserId.value,
      orElse: () => room.participants.isNotEmpty
          ? room.participants.first
          : const StudentChatParticipantModel(
              id: 0,
              user: StudentChatUserModel(
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
  String avatarInitial(StudentChatRoomModel room) {
    final name = displayName(room);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void markRoomAsRead(int roomId) {
    readRoomIds.add(roomId);
    ChatBadgeService.unreadCount.value = totalUnreadRooms;
  }

  /// Returns the number of unread messages for a room.
  bool hasUnread(StudentChatRoomModel room) {
    if (readRoomIds.contains(room.id)) return false;
    final me = room.participants.where((p) => p.user.id == currentUserId.value);
    if (me.isEmpty) return false;
    return me.first.lastReadMessageId == null;
  }

  /// Total rooms with unread messages — used for the badge on the message icon.
  int get totalUnreadRooms => chats.where(hasUnread).length;

  /// Derive last-message preview from the room model.
  String lastMessage(StudentChatRoomModel room) {
    return room.isGroup ? 'Group chat' : 'Tap to open chat';
  }
}
