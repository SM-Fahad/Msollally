import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/post_model.dart';
import 'package:msollaally/routes/app_route.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../../../../../core/const/icons_path.dart';
import '../../../../../core/common/widgets/post_action_button.dart';
import '../../../../../core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/core/utils/time_formatter.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/wall/wall_video_player.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/comment_bottom_sheet.dart';
import 'package:msollaally/feature/student/campus/campus_home/screen/student_edit_post_screen.dart';

class StudentCampusPostCard extends StatelessWidget {
  final PostModel post;
  final StudentCampusController controller;

  const StudentCampusPostCard({
    super.key,
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(thickness: 10, color: Colors.grey.shade100),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.width,
            vertical: 16.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              if (post.moderationStatus != 'APPROVED') ...[
                SizedBox(height: 8.height),
                _buildModerationBanner(),
              ],
              SizedBox(height: 12.height),
              _ExpandablePostText(
                text: post.content,
                style: appTextStyleHeading1(
                  fontWeight: FontWeight.w400,
                  color: AppColors.appBarTitleColor,
                ),
              ),
              if (post.effectiveMediaUrls.isNotEmpty) ...[
                SizedBox(height: 10.height),
                _buildMediaSection(post.effectiveMediaUrls),
              ],
              SizedBox(height: 12.height),
              _buildStats(),
              SizedBox(height: 18.height),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PostActionButton(
                    iconPath: IconsPath.reactIcon,
                    label: "Like",
                    isActive: post.isLiked,
                    onTap: () => controller.toggleLike(post),
                  ),
                  PostActionButton(
                    iconPath: IconsPath.commentIcon,
                    label: "Comment",
                    onTap: () => showCommentSheet(context, post.id),
                  ),
                  PostActionButton(
                    iconPath: IconsPath.shareIcon,
                    label: "Share",
                    onTap: () => controller.sharePost(post),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            if (Get.isRegistered<StudentProfileController>()) {
              final profileController = Get.find<StudentProfileController>();
              final myId = profileController.userId.value;
              if (post.author.id == myId) {
                Get.toNamed(AppRoute.studentProfilePage);
              } else {
                Get.toNamed(
                  AppRoute.studentCampusPublicProfile,
                  arguments: post.author.id,
                );
              }
            }
          },
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (post.author.profilePicture?.isNotEmpty == true) {
                    Get.to(
                      () => FullscreenImageView(
                        imageUrl: post.author.profilePicture!,
                        isNetworkImage: true,
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.radius),
                  child: (post.author.profilePicture?.isNotEmpty == true)
                      ? Image.network(
                          post.author.profilePicture!,
                          fit: BoxFit.cover,
                          height: 52.height,
                          width: 52.width,
                          errorBuilder: (_, __, ___) => _buildProfileFallback(),
                        )
                      : _buildProfileFallback(),
                ),
              ),
              SizedBox(width: 12.width),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post.author.fullName,
                        style: appTextStyleHeading1(
                          fontSize: 16.fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5.fontSize,
                        ),
                      ),
                      if (post.author.isVerified) ...[
                        SizedBox(width: 4.width),
                        Icon(
                          Icons.verified,
                          size: 15.fontSize,
                          color: Colors.blue,
                        ),
                      ],
                      SizedBox(width: 4.width),
                      Text(
                        "@${post.author.username}",
                        style: appTextStyleHeading2(
                          fontSize: 13.fontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.height),
                  Row(
                    children: [
                      Text(
                        (post.author.designation != null &&
                                post.author.designation!.isNotEmpty)
                            ? post.author.designation!
                            : post.author.role,
                        style: appTextStyleHeading2(
                          fontSize: 13.fontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        " • ${TimeFormatter.timeAgo(post.createdAt)}",
                        style: appTextStyleHeading2(
                          fontSize: 13.fontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (post.postableType == 'Union')
                        Container(
                          margin: EdgeInsets.only(left: 8.width),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.width,
                            vertical: 2.height,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(4.radius),
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: Text(
                            "Union",
                            style: appTextStyleHeading2(
                              fontSize: 10.fontSize,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      if (post.isAnnouncement)
                        Container(
                          margin: EdgeInsets.only(left: 6.width),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.width,
                            vertical: 2.height,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(4.radius),
                            border: Border.all(color: Colors.orange.shade700),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.campaign_rounded,
                                size: 11.fontSize,
                                color: Colors.orange.shade800,
                              ),
                              SizedBox(width: 3.width),
                              Text(
                                "Announcement",
                                style: appTextStyleHeading2(
                                  fontSize: 10.fontSize,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildProfileFallback() {
    return Container(
      height: 52.height,
      width: 52.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.grey.shade400, size: 32),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return Obx(() {
      if (!Get.isRegistered<StudentProfileController>()) {
        return const SizedBox();
      }
      final profileController = Get.find<StudentProfileController>();
      if (post.author.id != profileController.userId.value) {
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

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${post.likeCount} likes",
          style: appTextStyleHeading2(fontSize: 12.fontSize),
        ),
        Row(
          children: [
            Text(
              "${post.commentCount} Comments",
              style: appTextStyleHeading2(fontSize: 12.fontSize),
            ),
            // SizedBox(width: 12.width),
            // Text(
            //   "0 Shares",
            //   style: appTextStyleHeading2(fontSize: 12.fontSize),
            // ),
          ],
        ),
      ],
    );
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
              controller.deletePost(post.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationBanner() {
    final isRejected =
        post.moderationStatus == 'REJECTED' ||
        post.moderationStatus == 'FLAGGED';
    final color = isRejected ? Colors.red.shade700 : Colors.orange.shade800;
    final bgColor = isRejected ? Colors.red.shade50 : Colors.orange.shade50;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 6.height),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.radius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 16.fontSize, color: color),
          SizedBox(width: 6.width),
          Expanded(
            child: Text(
              post.moderationReason != null && post.moderationReason!.isNotEmpty
                  ? '${post.moderationStatus}: ${post.moderationReason}'
                  : 'Moderation status: ${post.moderationStatus}',
              style: TextStyle(
                fontSize: 12.fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(List<String> urls) {
    if (urls.length == 1) {
      final url = urls.first;
      if (_isVideo(url)) {
        return WallVideoPlayer(videoUrl: url);
      }
      return GestureDetector(
        onTap: () {
          Get.to(
            () => FullscreenImageView(imageUrl: url, isNetworkImage: true),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.radius),
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.width),
        itemBuilder: (context, index) {
          final url = urls[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (!_isVideo(url)) {
                    Get.to(
                      () => FullscreenImageView(
                        imageUrl: url,
                        isNetworkImage: true,
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.radius),
                  child: SizedBox(
                    width: 260.width,
                    height: 240.height,
                    child: _isVideo(url)
                        ? WallVideoPlayer(videoUrl: url)
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 8.height,
                right: 8.width,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.width,
                    vertical: 3.height,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12.radius),
                  ),
                  child: Text(
                    '${index + 1}/${urls.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    Get.to(
      () => StudentEditPostScreen(
        postId: post.id,
        initialContent: post.content,
        initialMediaUrl: post.mediaUrl,
        initialMediaUrls: post.effectiveMediaUrls,
        initialIsAnnouncement: post.isAnnouncement,
        authorName: post.author.fullName.isNotEmpty
            ? post.author.fullName
            : post.author.username,
        authorAvatarUrl: post.author.profilePicture,
      ),
    );
  }

  bool _isVideo(String url) {
    final clean = url.split('?').first.toLowerCase();
    return clean.endsWith('.mp4') ||
        clean.endsWith('.mov') ||
        clean.endsWith('.m4v') ||
        clean.endsWith('.webm') ||
        clean.endsWith('.avi') ||
        clean.endsWith('.mkv');
  }
}

class _ExpandablePostText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _ExpandablePostText({required this.text, required this.style});

  @override
  State<_ExpandablePostText> createState() => _ExpandablePostTextState();
}

class _ExpandablePostTextState extends State<_ExpandablePostText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = tp.didExceedMaxLines;

        if (!isOverflowing) {
          return Text(widget.text, style: widget.style);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                widget.text,
                maxLines: _isExpanded ? null : 1,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: widget.style,
              ),
            ),
            SizedBox(height: 4.height),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.height),
                child: Text(
                  _isExpanded ? 'Show less' : 'Show more',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
