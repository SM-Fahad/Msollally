import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class MoreHeadingProfile extends StatelessWidget {
  final String name;
  final String photoUrl;
  final VoidCallback onTap;

  const MoreHeadingProfile({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: 45,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: SizedBox(
                width: 90,
                height: 90,
                child: _buildImageWidget(photoUrl),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String url) {
    try {
      if (url.isEmpty) {
        return Image.asset('assets/images/profileJPG.jpg', fit: BoxFit.cover);
      }
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !(uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https')))) {
        return Image.asset('assets/images/profileJPG.jpg', fit: BoxFit.cover);
      }

      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/profileJPG.jpg', fit: BoxFit.cover);
        },
      );
    } catch (_) {
      return Image.asset('assets/images/profileJPG.jpg', fit: BoxFit.cover);
    }
  }
}
