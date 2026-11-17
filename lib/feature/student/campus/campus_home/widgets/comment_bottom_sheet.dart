import 'dart:io';
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/comment_controller.dart';

void showCommentSheet(BuildContext context, int postId) {
  final tag = 'comment_$postId';

  if (!Get.isRegistered<CommentController>(tag: tag)) {
    Get.put(CommentController(postId: postId), tag: tag);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (_) => CommentBottomSheet(postId: postId, tag: tag),
  ).then((_) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (Get.isRegistered<CommentController>(tag: tag)) {
        Get.delete<CommentController>(tag: tag);
      }
    });
  });
}

class CommentBottomSheet extends StatelessWidget {
  final int postId;
  final String tag;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.tag,
  });

  CommentController get _c => Get.find<CommentController>(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.5, 0.75, 0.95],
        builder: (ctx, scrollCtrl) {
          return _SheetBody(ctrl: _c, scrollCtrl: scrollCtrl);
        },
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  final CommentController ctrl;
  final ScrollController scrollCtrl;

  const _SheetBody({required this.ctrl, required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.radius)),
      ),
      child: Column(
        children: [
          _DragHandle(),
          _Header(ctrl: ctrl),

          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.width,
                    vertical: 16.height,
                  ),
                  child: ShimmerLoading.list(
                    itemCount: 4,
                    height: 60.height,
                    borderRadius: 12.radius,
                  ),
                );
              }

              if (ctrl.comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 56.fontSize,
                        color: AppColors.lavenderE4E6EA,
                      ),
                      SizedBox(height: 12.height),
                      Text(
                        'No comments yet',
                        style: getTextStyle(
                          fontSize: 15.fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 4.height),
                      Text(
                        'Be the first to comment!',
                        style: getTextStyle(
                          fontSize: 13.fontSize,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: scrollCtrl,
                padding: EdgeInsets.only(top: 8.height, bottom: 8.height),
                itemCount: ctrl.comments.length,
                itemBuilder: (_, i) =>
                    _CommentItem(comment: ctrl.comments[i], ctrl: ctrl),
              );
            }),
          ),

          const Divider(height: 1, thickness: 0.5),

          Obx(
            () => ctrl.editingCommentId.value != null
                ? _EditBanner(ctrl: ctrl)
                : const SizedBox.shrink(),
          ),

          Obx(
            () => ctrl.replyToCommentId.value != null
                ? _ReplyBanner(ctrl: ctrl)
                : const SizedBox.shrink(),
          ),

          Obx(
            () => ctrl.imagePath.value != null
                ? _ImagePreviewBanner(ctrl: ctrl)
                : const SizedBox.shrink(),
          ),

          _InputBar(ctrl: ctrl),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.height),
      child: Container(
        width: 36.width,
        height: 4.height,
        decoration: BoxDecoration(
          color: AppColors.lightGrayCED0D4,
          borderRadius: BorderRadius.circular(4.radius),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CommentController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.width, 0, 4.width, 8.height),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final n = ctrl.comments.length;
            return Text(
              n > 0 ? 'Comments ($n)' : 'Comments',
              style: getTextStyle(
                fontSize: 16.fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: Get.back,
          ),
        ],
      ),
    );
  }
}

// ─── Edit banner ──────────────────────────────────────────────────────────────
class _EditBanner extends StatelessWidget {
  final CommentController ctrl;
  const _EditBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.whiteSmokeF0F2F5,
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 8.height),
      child: Row(
        children: [
          Icon(
            Icons.edit_outlined,
            size: 16.fontSize,
            color: AppColors.dodgerBlue0866FF,
          ),
          SizedBox(width: 6.width),
          Expanded(
            child: Text(
              'Editing comment',
              style: TextStyle(
                fontSize: 13.fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.dodgerBlue0866FF,
              ),
            ),
          ),
          GestureDetector(
            onTap: ctrl.cancelEditComment,
            child: Icon(
              Icons.close,
              size: 18.fontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reply banner ─────────────────────────────────────────────────────────────
class _ReplyBanner extends StatelessWidget {
  final CommentController ctrl;
  const _ReplyBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.whiteSmokeF0F2F5,
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 8.height),
      child: Row(
        children: [
          Icon(
            Icons.reply_rounded,
            size: 16.fontSize,
            color: AppColors.dodgerBlue0866FF,
          ),
          SizedBox(width: 6.width),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Replying to ',
                    style: TextStyle(
                      fontSize: 13.fontSize,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  TextSpan(
                    text: ctrl.replyToUsername.value,
                    style: TextStyle(
                      fontSize: 13.fontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dodgerBlue0866FF,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: ctrl.clearReply,
            child: Icon(Icons.close, size: 18.fontSize, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ─── Image preview banner ────────────────────────────────────────────────────────
class _ImagePreviewBanner extends StatelessWidget {
  final CommentController ctrl;
  const _ImagePreviewBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.whiteSmokeF0F2F5,
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 8.height),
      child: Row(
        children: [
          Container(
            width: 40.width,
            height: 40.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.radius),
              image: DecorationImage(
                image: FileImage(File(ctrl.imagePath.value!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.width),
          Expanded(
            child: Text(
              'Image attached',
              style: TextStyle(
                fontSize: 13.fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          GestureDetector(
            onTap: ctrl.removeImage,
            child: Icon(Icons.close, size: 18.fontSize, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final CommentController ctrl;
  const _InputBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;
    final viewPaddingBottom = mediaQuery.viewPadding.bottom;
    final double navBarHeight =
        bottomPadding > viewPaddingBottom ? bottomPadding : viewPaddingBottom;

    final double effectiveBottom = bottomInset > 0
        ? bottomInset + 10.height
        : (navBarHeight > 0 ? navBarHeight + 10.height : 22.height);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        bottom: effectiveBottom,
        left: 12.width,
        right: 12.width,
        top: 10.height,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: ctrl.pickImage,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.height, right: 8.width),
              child: Icon(
                Icons.image_outlined,
                color: Colors.grey.shade600,
                size: 24.fontSize,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctrl.textController,
              focusNode: ctrl.focusNode,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 14.fontSize, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Write a comment…',
                hintStyle: TextStyle(
                  fontSize: 14.fontSize,
                  color: Colors.grey.shade500,
                ),
                filled: true,
                fillColor: AppColors.whiteSmokeF0F2F5,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.width,
                  vertical: 10.height,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.radius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.width),
          Obx(
            () => ctrl.isSubmitting.value
                ? Padding(
                    padding: EdgeInsets.all(10.width),
                    child: SizedBox(
                      width: 22.width,
                      height: 22.height,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : GestureDetector(
                    onTap: ctrl.submitComment,
                    child: Container(
                      width: 40.width,
                      height: 40.width,
                      decoration: const BoxDecoration(
                        color: AppColors.dodgerBlue0866FF,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20.fontSize,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final dynamic comment;
  final CommentController ctrl;
  final int depth;

  const _CommentItem({
    required this.comment,
    required this.ctrl,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final replies = (comment['replies'] as List<dynamic>?) ?? [];
    final commentId = comment['id'] as int;
    final hasReplies = replies.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : 12.width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── The Comment Bubble Row ────────────────────────────────
          _CommentRow(comment: comment, ctrl: ctrl, isReply: depth > 0),

          // ── Recursive Replies ──────────────────────────────────────
          if (hasReplies)
            Padding(
              padding: EdgeInsets.only(
                left: 28.width,
              ), // Indent replies from the avatar line
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle View/Hide
                  Obx(() {
                    final expanded = ctrl.expandedReplies.contains(commentId);
                    return GestureDetector(
                      onTap: () => ctrl.toggleReplies(commentId),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.height),
                        child: Row(
                          children: [
                            Container(
                              width: 20.width,
                              height: 1.height,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(width: 8.width),
                            Text(
                              expanded
                                  ? 'Hide replies'
                                  : 'View ${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                              style: TextStyle(
                                fontSize: 12.fontSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // The Nested List
                  Obx(() {
                    if (!ctrl.expandedReplies.contains(commentId)) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: replies.map((r) {
                        return _CommentItem(
                          comment: r,
                          ctrl: ctrl,
                          depth: depth + 1,
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),

          // Extra spacing for root comments
          if (depth == 0) SizedBox(height: 8.height),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final dynamic comment;
  final CommentController ctrl;
  final bool isReply;

  const _CommentRow({
    required this.comment,
    required this.ctrl,
    required this.isReply,
  });

  @override
  Widget build(BuildContext context) {
    final author = comment['author'] ?? {};
    final profile = author['profile'] is Map ? author['profile'] as Map : {};
    final authorName =
        (profile['fullName'] ??
                author['fullName'] ??
                author['username'] ??
                'User')
            .toString();
    final avatar =
        (profile['profilePicture'] ?? author['profilePicture'] ?? '').toString();

    final content = (comment['content'] ?? '') as String;
    final mediaUrl = (comment['mediaUrl'] ?? '') as String;
    final likeCount = (comment['likeCount'] ?? 0) as int;
    final isLiked =
        (comment['isLiked'] ?? comment['isLikedByMe'] ?? false) as bool;
    final commentId = comment['id'] as int;

    final rawAuthorId = author['id'] ?? comment['authorId'];
    final authorId = rawAuthorId is int
        ? rawAuthorId
        : int.tryParse('$rawAuthorId');
    final isMe =
        (ctrl.currentUserId != null && authorId == ctrl.currentUserId) ||
        (comment['isOptimistic'] == true);

    final avatarSize = isReply ? 28.0 : 36.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 6.height),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(url: avatar, size: avatarSize),
          SizedBox(width: 10.width),
          
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Bubble
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.width,
                        vertical: 10.height,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.whiteSmokeF0F2F5,
                        borderRadius: BorderRadius.circular(16.radius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: TextStyle(
                              fontSize: 13.5.fontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          if (content.isNotEmpty) ...[
                            SizedBox(height: 3.height),
                            Text(
                              content,
                              style: TextStyle(
                                fontSize: 14.fontSize,
                                color: Colors.black,
                                height: 1.35,
                              ),
                            ),
                          ],
                          if (mediaUrl.isNotEmpty) ...[
                            SizedBox(height: 8.height),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.radius),
                              child: Image.network(
                                mediaUrl,
                                width: 220.width,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => SizedBox(
                                  width: 220.width,
                                  height: 120.height,
                                  child: Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Reaction Pill
                    if (likeCount > 0)
                      Positioned(
                        bottom: -10.height,
                        right: 8.width,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.width,
                            vertical: 3.height,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.radius),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.thumb_up_rounded,
                                size: 12.fontSize,
                                color: AppColors.dodgerBlue0866FF,
                              ),
                              SizedBox(width: 4.width),
                              Text(
                                '$likeCount',
                                style: TextStyle(
                                  fontSize: 11.5.fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // Actions
                Padding(
                  padding: EdgeInsets.only(left: 10.width, top: 4.height),
                  child: Row(
                    children: [
                      _TextAction(
                        label: 'Like',
                        bold: isLiked,
                        color: isLiked ? AppColors.dodgerBlue0866FF : null,
                        onTap: () => ctrl.toggleLikeComment(commentId, isLiked),
                      ),
                      _Dot(),
                      _TextAction(
                        label: 'Reply',
                        bold: true,
                        onTap: () => ctrl.setReplyTo(commentId, authorName),
                      ),
                      if (isMe && commentId > 0) ...[
                        _Dot(),
                        _TextAction(
                          label: 'Edit',
                          onTap: () =>
                              ctrl.startEditComment(commentId, content),
                        ),
                        _Dot(),
                        _TextAction(
                          label: 'Delete',
                          color: Colors.red.shade600,
                          onTap: () => ctrl.deleteComment(commentId),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tiny shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  const _Avatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: url != null && url!.isNotEmpty
          ? Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, e, __) {
                debugPrint('❌ [_Avatar] Failed to load $url: $e');
                return _placeholder();
              },
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Image.asset(
    ImagesPath.profilePNG,
    width: size,
    height: size,
    fit: BoxFit.cover,
  );
}

class _TextAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool bold;
  final Color? color;
  const _TextAction({
    required this.label,
    required this.onTap,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: color ?? Colors.grey.shade600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.width),
      child: Text(
        '·',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14.fontSize),
      ),
    );
  }
}
