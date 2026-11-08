import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class StudentCourseDetailsMsgController extends GetxController {
  var textController = TextEditingController();
  var scrollController = ScrollController();

  var message = <String>[].obs;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    message.add(text.trim());

    // Clear input after sending
    textController.clear();

    // Scroll to bottom after rebuild
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Scroll to bottom when page is first opened
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
