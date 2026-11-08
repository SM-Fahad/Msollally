import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/teacher/courses/course_students/model/course_student_chat_model.dart';

class CourseStudentChatTile extends StatelessWidget {
  final CourseStudentChatModel chat;
  final Widget? trailing;

  const CourseStudentChatTile({super.key, required this.chat, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blue.withValues(alpha: 0.12),
        backgroundImage: chat.avatar.isNotEmpty
            ? NetworkImage(chat.avatar)
            : null,
        child: chat.avatar.isEmpty
            ? Text(
                chat.initials,
                style: getTextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
      title: Text(chat.name, style: getTextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(
                color: chat.unreadCount > 0 ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          if (chat.time.isNotEmpty)
            Text(
              "• ${chat.time}",
              style: getTextStyle(
                fontSize: 12,
                color: chat.unreadCount > 0 ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
      trailing:
          trailing ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (chat.isMuted)
                ImageIcon(AssetImage(IconsPath.notificationOffTeacherFlow)),
            ],
          ),
    );
  }
}
