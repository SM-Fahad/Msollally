import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/chat/model/pro_partners_chat_room_model.dart';
import 'package:msollaally/feature/pro_partners/chat/repository/pro_partners_chat_repository.dart';
import 'package:msollaally/feature/pro_partners/chat/service/chat_badge_service.dart';

class ProPartnersInboxController extends GetxController {
  final ProPartnersChatRepository _repository;
  final SharedPreferenceHelper _prefs;

  ProPartnersInboxController({
    ProPartnersChatRepository? repository,
    SharedPreferenceHelper? prefs,
  }) : _repository = repository ?? ProPartnersChatRepository(),
       _prefs = prefs ?? SharedPreferenceHelper();

  final currentUserId = 0.obs;
  final chats = <ProPartnersChatRoomModel>[].obs;
  final searchQuery = ''.obs;
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
      ChatBadgeService.unreadCount.value = totalUnreadRooms;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  List<ProPartnersChatRoomModel> get filteredChats {
    List<ProPartnersChatRoomModel> list = chats;
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((c) {
        final name = displayName(c).toLowerCase();
        return name.contains(q) || c.name.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  String displayName(ProPartnersChatRoomModel room) {
    if (room.isGroup) {
      return room.name.trim().isNotEmpty ? room.name.trim() : 'Group Chat';
    }
    final other = room.participants.firstWhere(
      (p) => p.user.id != currentUserId.value,
      orElse: () => room.participants.isNotEmpty
          ? room.participants.first
          : const ProPartnersChatParticipantModel(
              id: 0,
              user: ProPartnersChatUserModel(
                id: 0,
                username: 'Student',
                phoneNumber: '',
                role: '',
              ),
              lastReadMessageId: null,
              isMuted: false,
            ),
    );
    return other.user.displayName;
  }

  String avatarInitial(ProPartnersChatRoomModel room) {
    final name = displayName(room);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool hasUnread(ProPartnersChatRoomModel room) {
    final me = room.participants.where((p) => p.user.id == currentUserId.value);
    if (me.isEmpty) return false;
    return me.first.lastReadMessageId == null;
  }

  int get totalUnreadRooms => chats.where(hasUnread).length;

  String lastMessage(ProPartnersChatRoomModel room) {
    return room.isGroup ? 'Group chat' : 'Tap to open chat';
  }
}
