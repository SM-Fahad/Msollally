import 'package:flutter/material.dart';

class TeacherProfileTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const TeacherProfileTile({
    super.key,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(clipTitle(value)),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

String clipTitle(String title, {int maxLength = 17}) {
  if (title.length <= maxLength) {
    return title;
  } else {
    return '${title.substring(0, maxLength)}..';
  }
}
