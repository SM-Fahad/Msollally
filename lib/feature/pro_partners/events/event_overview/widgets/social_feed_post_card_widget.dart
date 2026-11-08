import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/material.dart';
import '../../../../../core/const/icons_path.dart';
import '../../../../../core/common/widgets/post_action_button.dart';
import 'package:get/get.dart';
import '../../../../../core/common/widgets/fullscreen_image_view.dart';
import '../model/post_model.dart';

class PostCardWidget extends StatelessWidget {
  final PostModel p;
  const PostCardWidget({super.key, required this.p});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) {
      return ' ${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} min ago';
    }
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.whiteSmokeECECEC),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          Text(p.body, style: const TextStyle(fontSize: 14)),
          if (p.imageUrl != null) ...[
            const SizedBox(height: 12),
            _buildMedia(),
          ],
          const SizedBox(height: 12),
          _buildStats(),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.whiteSmokeF2F2F4,
          child: Text(p.authorInitials),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (p.roleLabel.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p.roleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _timeAgo(p.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGray9A9A9A,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedia() {
    final isRemote = p.imageUrl!.startsWith('http');
    return GestureDetector(
      onTap: () {
        Get.to(
          () => FullscreenImageView(
            imageUrl: p.imageUrl!,
            isNetworkImage: isRemote,
            isFileImage: !isRemote,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isRemote
            ? Image.network(
                p.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildBrokenImage(),
              )
            : _buildFileImage(),
      ),
    );
  }

  Widget _buildFileImage() {
    final f = File(p.imageUrl!);
    if (f.existsSync()) {
      return Image.file(
        f,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _buildBrokenImage();
  }

  Widget _buildBrokenImage() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.black12,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 48,
          color: AppColors.darkGray9A9A9A,
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Text(
          '${p.likes} Likes',
          style: const TextStyle(fontSize: 13, color: AppColors.gray7A7A7A),
        ),
        const Spacer(),
        Text(
          '${p.comments} Comments',
          style: const TextStyle(fontSize: 13, color: AppColors.gray7A7A7A),
        ),
        const SizedBox(width: 16),
        Text(
          '${p.shares} Shares',
          style: const TextStyle(fontSize: 13, color: AppColors.gray7A7A7A),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        PostActionButton(
          iconPath: IconsPath.reactIcon,
          label: 'Like',
          isActive: p.isLiked,
          inactiveColor: AppColors.dimGray6F6F6F,
        ),
        const PostActionButton(
          iconPath: IconsPath.commentIcon,
          label: 'Comment',
          inactiveColor: AppColors.dimGray6F6F6F,
        ),
        const PostActionButton(
          iconPath: IconsPath.shareIcon,
          label: 'Share',
          inactiveColor: AppColors.dimGray6F6F6F,
        ),
      ],
    );
  }
}
