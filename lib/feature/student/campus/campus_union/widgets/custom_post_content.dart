import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/post_model.dart'
    show PostWallModel;
import '../../../../../../core/common/styles/global_text_style.dart';
import '../../../../../../core/const/icons_path.dart';
import '../../../../../../core/common/widgets/post_action_button.dart';
import '../../../../../../core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/routes/app_route.dart';

class PostContent extends StatelessWidget {
  final PostWallModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final Function(String content)? onEdit;
  final VoidCallback? onDelete;

  const PostContent({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                if (Get.isRegistered<StudentProfileController>()) {
                  final profileController =
                      Get.find<StudentProfileController>();
                  final myId = profileController.userId.value;
                  if (post.authorId == myId) {
                    Get.toNamed(AppRoute.studentProfilePage);
                  } else {
                    Get.toNamed(
                      AppRoute.studentCampusPublicProfile,
                      arguments: post.authorId,
                    );
                  }
                }
              },
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => FullscreenImageView(
                          imageUrl: post.imageUrl,
                          isNetworkImage: post.imageUrl.startsWith('http'),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.radius),
                      child: post.imageUrl.startsWith('http')
                          ? Image.network(
                              post.imageUrl,
                              fit: BoxFit.cover,
                              height: 52.height,
                              width: 52.width,
                              errorBuilder: (_, __, ___) => Container(
                                height: 52.height,
                                width: 52.width,
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person,
                                  size: 26.radius,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            )
                          : Image.asset(
                              post.imageUrl,
                              fit: BoxFit.cover,
                              height: 52.height,
                              width: 52.width,
                              errorBuilder: (_, __, ___) => Container(
                                height: 52.height,
                                width: 52.width,
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person,
                                  size: 26.radius,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 12.width),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: appTextStyleHeading1(
                          fontSize: 20.fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5.fontSize,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            post.subtitle,
                            style: appTextStyleHeading2(fontSize: 15.fontSize),
                          ),
                          Text(
                            " ${post.time} hr ago",
                            style: appTextStyleHeading2(fontSize: 15.fontSize),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildPopupMenu(context),
          ],
        ),
        SizedBox(height: 12.height),
        _ExpandablePostText(text: post.status),
        if (post.statusImageUrl?.isNotEmpty == true) ...[
          SizedBox(height: 10.height),
          GestureDetector(
            onTap: () {
              Get.to(
                () => FullscreenImageView(
                  imageUrl: post.statusImageUrl!,
                  isNetworkImage: post.statusImageUrl!.startsWith('http'),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.radius),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 360.height,
                  minHeight: 160.height,
                  minWidth: double.infinity,
                ),
                child: post.statusImageUrl!.startsWith('http')
                    ? Image.network(
                        post.statusImageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200.height,
                            width: double.infinity,
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180.height,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey.shade400,
                            size: 40.radius,
                          ),
                        ),
                      )
                    : Image.asset(
                        post.statusImageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
              ),
            ),
          ),
        ],
        SizedBox(height: 12.height),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${post.like} likes",
              style: appTextStyleHeading2(fontSize: 12.fontSize),
            ),
            Row(
              children: [
                Text(
                  "${post.comment} Comments",
                  style: appTextStyleHeading2(fontSize: 12.fontSize),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 18.height),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PostActionButton(
              iconPath: IconsPath.reactIcon,
              label: "Like",
              onTap: onLike,
              isActive: post.isLiked,
            ),
            PostActionButton(
              iconPath: IconsPath.commentIcon,
              label: "Comment",
              onTap: onComment,
            ),
            PostActionButton(
              iconPath: IconsPath.shareIcon,
              label: "Share",
              onTap: onShare ??
                  () {
                    Share.share("${post.title}\n\nShared via LinkYetu");
                  },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return Obx(() {
      if (!Get.isRegistered<StudentProfileController>()) {
        return const SizedBox();
      }
      final profileController = Get.find<StudentProfileController>();
      if (post.authorId != profileController.userId.value) {
        return const SizedBox();
      }

      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showEditDialog(context);
          } else if (value == 'delete') {
            _showDeleteConfirmDialog();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        child: const Icon(Icons.more_vert, size: 24),
      );
    });
  }

  void _showDeleteConfirmDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              onDelete?.call();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final editController = TextEditingController(text: post.status);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: editController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Edit your post...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                Get.back();
                onEdit?.call(editController.text.trim());
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _ExpandablePostText extends StatefulWidget {
  final String text;

  const _ExpandablePostText({required this.text});

  @override
  State<_ExpandablePostText> createState() => _ExpandablePostTextState();
}

class _ExpandablePostTextState extends State<_ExpandablePostText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) return const SizedBox.shrink();

    final textStyle = appTextStyleHeading1(
      fontWeight: FontWeight.w400,
      color: AppColors.appBarTitleColor,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: 3,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: textStyle,
            ),
            if (isOverflowing) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? 'See Less' : '... See More',
                  style: appTextStyleHeading1(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
