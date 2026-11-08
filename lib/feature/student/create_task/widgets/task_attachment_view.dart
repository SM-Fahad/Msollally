import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class TaskAttachmentView extends StatelessWidget {
  final String? fileUrl;

  const TaskAttachmentView({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    if (fileUrl == null || fileUrl!.isEmpty) {
      return _buildAttachmentMessage('No attachment found');
    }

    if (!_isImageUrl(fileUrl!)) {
      return _buildFileLink(fileUrl!);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.radius),
      child: Image.network(
        fileUrl!,
        height: 389.height,
        width: 353.width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: 389.height,
            width: 353.width,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFileLink(fileUrl!);
        },
      ),
    );
  }

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }

  Widget _buildAttachmentMessage(String message) {
    return SizedBox(
      height: 80.height,
      width: 353.width,
      child: Center(
        child: Text(
          message,
          style: appTextStyleHeading2(color: AppColors.tertiaryTextColor),
        ),
      ),
    );
  }

  Widget _buildFileLink(String fileUrl) {
    return InkWell(
      onTap: () => _openAttachment(fileUrl),
      child: Container(
        width: 353.width,
        padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.radius),
          border: Border.all(color: AppColors.sectionBorderColor),
          color: AppColors.ghostWhiteF9F9FB,
        ),
        child: Text(
          fileUrl,
          style: appTextStyleHeading2(
            color: AppColors.royalBlue2563EB,
            letterSpacing: 0.1.fontSize,
          ),
        ),
      ),
    );
  }

  Future<void> _openAttachment(String fileUrl) async {
    final uri = Uri.tryParse(fileUrl);
    if (uri == null) {
      EasyLoading.showError('Invalid attachment URL');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      EasyLoading.showError('Could not open attachment');
    }
  }
}
